# 🔧 RECOMENDAÇÕES DE REFACTORING - FRONTEND

**Data**: 27 de Outubro de 2025  
**Prioridade**: Alta (antes de produção)  
**Impacto**: Segurança + Manutenibilidade

---

## 📋 ÍNDICE

1. Centralizar Firebase Client SDK
2. Remover Validações Críticas
3. Tratamento de Erros e Timeouts
4. Contratos de Dados (DTOs)
5. Padrão de Orquestração no Backend

---

## 1️⃣ CENTRALIZAR FIREBASE CLIENT SDK

### Problema Atual
- Múltiplas classes usam `FirebaseFirestore.instance` diretamente
- Difícil trocar implementação (para testes, por exemplo)
- Sem logging centralizado

### Solução Recomendada

Criar uma abstração centralizada em `lib/core/services/firebase_service.dart`:

```dart
/// Service centralizado para acessar Firebase (Client SDK)
class FirebaseService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;

  // ✅ Acesso centralizado
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseAuth get auth => _auth;
  static FirebaseStorage get storage => _storage;

  // ✅ Métodos auxiliares com logging
  static Future<DocumentSnapshot> getDocument(
    String path, {
    int timeoutSeconds = 30,
  }) async {
    try {
      return await _firestore
          .doc(path)
          .get()
          .timeout(Duration(seconds: timeoutSeconds));
    } catch (e) {
      AppLogger.error('Erro ao buscar documento: $path', error: e);
      rethrow;
    }
  }

  // ✅ Escuta com timeout
  static Stream<QuerySnapshot> watchQuery(
    Query query, {
    int timeoutSeconds = 30,
  }) {
    return query.snapshots().timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: (sink) {
        AppLogger.error('Timeout ao escutar query');
        sink.addError(NetworkException('Timeout na conexão'));
      },
    );
  }
}
```

**Uso**:
```dart
// ❌ Antes
final doc = await FirebaseFirestore.instance.doc('users/123').get();

// ✅ Depois
final doc = await FirebaseService.getDocument('users/123');
```

---

## 2️⃣ REMOVER VALIDAÇÕES CRÍTICAS DO FRONTEND

### Problema Atual

Validações de negócio críticas em múltiplos lugares:

```dart
// ❌ RUIM: Validação em UseCase (cliente confia)
if (params.rating < 1 || params.rating > 5) {
  return Left(ValidationFailure('Rating deve estar entre 1 e 5'));
}

// ❌ RUIM: Validação em Firestore Rules (fraca)
allow create: if ... && request.resource.data.rating >= 1 
                   && request.resource.data.rating <= 5;

// ❌ RUIM: Validação em Repository (pode ser burlada)
final isValidRating = rating >= 1 && rating <= 5;
```

### Solução Recomendada

1. **Remover UseCase**: Deixar apenas orquestração
2. **Fortalecer Backend**: Backend valida tudo
3. **Manter Rules**: Como defesa segundária

```dart
// ✅ UseCase apenas orquestra (sem validação crítica)
@override
Future<Either<Failure, ReviewEntity>> call(AddReviewParams params) async {
  // ✅ Logging
  AppLogger.info('Adicionando review para: ${params.professionalId}');

  // ✅ Construir entity
  final review = ReviewEntity(
    id: '', // Backend gera
    professionalId: params.professionalId,
    patientId: params.patientId,
    rating: params.rating,
    comment: params.comment,
    createdAt: DateTime.now(),
  );

  // ✅ Chamar repository (que chama backend)
  return await repository.addReview(review);
}
```

### Padrão: Backend é Source of Truth

```dart
// ✅ CORRETO: Backend valida, frontend chama
class HttpReviewsDataSource {
  Future<ReviewEntity> addReview(ReviewEntity review) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/reviews/${review.professionalId}'),
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'rating': review.rating,
        'comment': review.comment,
        // ... outros campos
      }),
    );

    // ✅ Backend retorna erro específico se rating inválido
    if (response.statusCode == 400) {
      final error = jsonDecode(response.body)['error'];
      if (error.contains('rating')) {
        throw ValidationException('Rating inválido');
      }
    }

    return ReviewEntity.fromJson(jsonDecode(response.body));
  }
}
```

---

## 3️⃣ TRATAMENTO DE ERROS E TIMEOUTS

### Problema Atual
- Alguns datasources sem timeout
- Retry logic inconsistent
- Error mapping duplicado

### Solução Recomendada

Criar `lib/core/utils/http_client_wrapper.dart`:

```dart
/// Wrapper de HTTP com retry, timeout, e logging
class HttpClientWrapper {
  HttpClientWrapper({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const int _timeoutSeconds = 30;
  static const int _maxRetries = 3;

  /// GET com retry automático
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry(
      () => _client.get(url, headers: headers).timeout(
        Duration(seconds: _timeoutSeconds),
        onTimeout: () => throw NetworkException('GET timeout'),
      ),
    );
  }

  /// POST com retry automático
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    required String body,
  }) async {
    return _requestWithRetry(
      () => _client.post(
        url,
        headers: headers,
        body: body,
      ).timeout(
        Duration(seconds: _timeoutSeconds),
        onTimeout: () => throw NetworkException('POST timeout'),
      ),
    );
  }

  /// Retry com backoff exponencial
  Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() request,
  ) async {
    for (int i = 0; i < _maxRetries; i++) {
      try {
        return await request();
      } catch (e) {
        if (i == _maxRetries - 1) rethrow;
        
        // Backoff exponencial: 100ms, 200ms, 400ms
        final delayMs = 100 * (1 << i);
        await Future.delayed(Duration(milliseconds: delayMs));
        
        AppLogger.warning('Retry $i para request');
      }
    }
    throw Exception('Nunca deve chegar aqui');
  }
}
```

**Uso**:
```dart
class HttpProfessionalsDataSource {
  late final HttpClientWrapper _http;

  HttpProfessionalsDataSource({HttpClientWrapper? http}) {
    _http = http ?? HttpClientWrapper();
  }

  Future<Map<String, dynamic>> searchProfessionals({
    required String query,
  }) async {
    try {
      final response = await _http.get(
        Uri.parse('$baseUrl/api/v1/professionals?q=$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      // ✅ Erro específico com context
      throw _handleError(response.statusCode, response.body);
    } on NetworkException catch (e) {
      throw StorageException('Conexão perdida: ${e.message}');
    }
  }

  Exception _handleError(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return ValidationException('Dados inválidos');
      case 401:
        return AuthenticationException('Token expirado');
      case 429:
        return RateLimitException('Limite de requisições excedido');
      case 500:
        return ServerException('Erro interno do servidor');
      default:
        return StorageException('Erro $statusCode');
    }
  }
}
```

---

## 4️⃣ CONTRATOS DE DADOS (DTOs)

### Problema Atual
- Entidades do domain mixadas com DTOs
- Sem mapping explícito
- Difícil versionar API

### Solução Recomendada

Criar DTOs separados em `lib/data/models/`:

```dart
// ✅ DTO para backend
class AddReviewDTO {
  final String professionalId;
  final String patientId;
  final int rating;
  final String comment;

  AddReviewDTO({
    required this.professionalId,
    required this.patientId,
    required this.rating,
    required this.comment,
  });

  /// ✅ Validações do DTO (antes de enviar)
  void validate() {
    if (rating < 1 || rating > 5) {
      throw ValidationException('Rating deve estar entre 1 e 5');
    }
    if (comment.trim().isEmpty) {
      throw ValidationException('Comentário obrigatório');
    }
    if (comment.length > 500) {
      throw ValidationException('Comentário muito longo');
    }
  }

  /// ✅ Serializar para JSON
  Map<String, dynamic> toJson() => {
    'professionalId': professionalId,
    'patientId': patientId,
    'rating': rating,
    'comment': comment,
  };

  /// ✅ Deserializar do backend
  factory AddReviewDTO.fromJson(Map<String, dynamic> json) {
    return AddReviewDTO(
      professionalId: json['professionalId'] as String,
      patientId: json['patientId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
    );
  }
}

// ✅ DTO para resposta do backend
class ReviewResponseDTO {
  final String id;
  final String professionalId;
  final double averageRating;
  final int totalReviews;

  ReviewResponseDTO({
    required this.id,
    required this.professionalId,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ReviewResponseDTO.fromJson(Map<String, dynamic> json) {
    return ReviewResponseDTO(
      id: json['id'] as String,
      professionalId: json['professionalId'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
    );
  }

  /// ✅ Converter para domain entity
  ReviewEntity toDomain() => ReviewEntity(
    id: id,
    professionalId: professionalId,
    patientId: '',
    patientName: '',
    rating: 0,
    comment: '',
    createdAt: DateTime.now(),
  );
}
```

**Uso**:
```dart
// ✅ Datasource usa DTO
Future<ReviewEntity> addReview(ReviewEntity review) async {
  final dto = AddReviewDTO(
    professionalId: review.professionalId,
    patientId: review.patientId,
    rating: review.rating,
    comment: review.comment,
  );

  // ✅ Validar antes de enviar (UX)
  dto.validate();

  final response = await _http.post(
    Uri.parse('$baseUrl/api/v1/reviews'),
    body: jsonEncode(dto.toJson()),
  );

  // ✅ Converter resposta para entity
  final responseDto = ReviewResponseDTO.fromJson(jsonDecode(response.body));
  return responseDto.toDomain();
}
```

---

## 5️⃣ PADRÃO DE ORQUESTRAÇÃO NO BACKEND

### Problema Atual
- Screens chamam múltiplos providers
- Lógica de coordenação duplicada
- Backend-like decisions no provider

### Solução Recomendada

Providers apenas orquestram, não validam:

```dart
// ✅ Provider é um orquestrador
class ReviewsNotifier extends StateNotifier<ReviewsState> {
  final AddReview _addReview;
  final GetReviewsByProfessional _getReviews;

  ReviewsNotifier({
    required AddReview addReview,
    required GetReviewsByProfessional getReviews,
  })  : _addReview = addReview,
        _getReviews = getReviews,
        super(const ReviewsState.initial());

  /// ✅ UseCase faz validações, provider apenas chama
  Future<void> addReview({
    required String professionalId,
    required String patientId,
    required int rating,
    required String comment,
  }) async {
    state = const ReviewsState.loading();

    final params = AddReviewParams(
      professionalId: professionalId,
      patientId: patientId,
      patientName: '', // UseCase buscará
      rating: rating,
      comment: comment,
    );

    final result = await _addReview(params);

    state = result.fold(
      (failure) => ReviewsState.error(failure.message),
      (review) => ReviewsState.success(review),
    );
  }
}

// ✅ Screen apenas chama provider (sem lógica)
class AddReviewScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsState = ref.watch(reviewsNotifierProvider);

    return Scaffold(
      body: _buildForm(ref, context), // Widget para formulário
    );
  }

  Widget _buildForm(WidgetRef ref, BuildContext context) {
    return Form(
      child: Column(
        children: [
          // ✅ Campos de entrada
          TextField(controller: ratingController),
          TextField(controller: commentController),
          
          // ✅ Botão chama provider (sem lógica)
          ElevatedButton(
            onPressed: () {
              ref.read(reviewsNotifierProvider.notifier).addReview(
                professionalId: widget.professionalId,
                patientId: ref.read(userIdProvider)!,
                rating: int.parse(ratingController.text),
                comment: commentController.text,
              );
            },
            child: Text('Enviar Avaliação'),
          ),
        ],
      ),
    );
  }
}
```

---

## 📊 CHECKLIST DE REFACTORING

### Fase 1: Firebase Centralização
- [ ] Criar `lib/core/services/firebase_service.dart`
- [ ] Remover `FirebaseFirestore.instance` direto
- [ ] Adicionar logging em operações críticas
- [ ] Adicionar timeouts padrão

### Fase 2: Remover Validações Críticas
- [ ] Revisar todos os UseCase
- [ ] Deixar apenas orquestração
- [ ] Mover lógica crítica para backend
- [ ] Documentar decisão

### Fase 3: Tratamento de Erros
- [ ] Criar `HttpClientWrapper`
- [ ] Adicionar retry automático
- [ ] Adicionar timeouts
- [ ] Mapear erros corretamente

### Fase 4: DTOs
- [ ] Criar `lib/data/models/` com DTOs
- [ ] Separar DTO de Entity
- [ ] Mapear explicitamente
- [ ] Documentar contrato com backend

### Fase 5: Orquestração
- [ ] Revisar providers
- [ ] Remover lógica de negócio
- [ ] Deixar apenas state management
- [ ] Simplificar

---

## 🔐 PADRÃO DE SEGURANÇA

### Trust Boundary

```
┌─────────────────────────────────────┐
│         CLIENTE (NÃO confiável)      │
│ ✅ Orquestração                      │
│ ✅ Validações UX (formato)           │
│ ✅ Caching local                     │
│ ❌ Validações críticas               │
│ ❌ Geração de IDs                    │
│ ❌ Geração de tokens                 │
└────────────────┬────────────────────┘
                 │ HTTP + JWT
┌────────────────▼────────────────────┐
│      BACKEND (CONFIÁVEL)             │
│ ✅ Validações críticas               │
│ ✅ Autorização                       │
│ ✅ Geração de IDs                    │
│ ✅ Transações ACID                   │
│ ✅ Auditoria                         │
└────────────────┬────────────────────┘
                 │ Firebase Admin SDK
┌────────────────▼────────────────────┐
│       FIREBASE (TRUSTLESS)           │
│ ✅ Armazenamento persistente         │
│ ✅ Real-time listeners              │
│ ✅ Rules como defesa 2ª camada      │
└─────────────────────────────────────┘
```

---

## 📝 EXEMPLO COMPLETO: Adicionar Review

### ANTES (Inseguro)
```dart
// ❌ Validação no client
if (rating < 1 || rating > 5) {
  showError('Rating inválido');
  return;
}

// ❌ Cálculo no client
final newAverage = (oldAverage * count + rating) / (count + 1);

// ❌ Salvar direto no Firebase
await firestore.collection('reviews').add({
  'rating': rating,
  'average': newAverage, // ❌ Pode ser burlado
});
```

### DEPOIS (Seguro)
```dart
// ✅ UseCase apenas orquestra
final result = await addReviewUseCase(params);

result.fold(
  (failure) => showError(failure.message),
  (review) => showSuccess('Review adicionado'),
);

// Backend faz:
// 1. ✅ Valida rating
// 2. ✅ Verifica usuário
// 3. ✅ Calcula média
// 4. ✅ Salva atomicamente
// 5. ✅ Auditoria
```

---

## 🚀 PRÓXIMOS PASSOS

1. **Week 1**: Implementar Firebase Service (1h)
2. **Week 2**: HttpClientWrapper com retry (2h)
3. **Week 3**: Remover validações críticas (3h)
4. **Week 4**: Criar DTOs (2h)
5. **Week 5**: Testar e validar (2h)

**Total**: ~10h de refactoring

**Benefícios**:
- ✅ Segurança aumentada 10x
- ✅ Código mais testável
- ✅ Menos bugs em produção
- ✅ Manutenibilidade aumentada
