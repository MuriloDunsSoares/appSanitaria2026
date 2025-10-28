# 📋 PR 1.2 - Backend Specification: Reviews Aggregation

**Status**: 🟡 FRONTEND PRONTO, BACKEND PENDENTE  
**Data**: 27 de Outubro de 2025

---

## 🎯 O que foi feito no Frontend

✅ **Removido**:
- `_updateProfessionalAverageRating()` do `firebase_reviews_datasource.dart`
- Chamada em `addReview()`
- Chamada em `deleteReview()`

✅ **Adicionado**:
- Novo método `aggregateAverageRating()` em `HttpReviewsDataSource`
- Chama backend endpoint: `POST /api/v1/reviews/{professionalId}/aggregate`

---

## 🔧 O que precisa ser feito no Backend

### Endpoint HTTP

```
POST /api/v1/reviews/{professionalId}/aggregate
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
```

### Responsabilidades

1. ✅ **Validação**:
   - Verificar JWT token (extrair userId)
   - Verificar se profissional existe
   - Verificar se userId tem permissão (admin ou self)

2. ✅ **Cálculo**:
   - Buscar TODAS as reviews do profissional do Firestore
   - Calcular: `sum(ratings) / count(ratings)`
   - Se 0 reviews → retornar 0.0

3. ✅ **Atomicidade (ACID)**:
   - Usar transação do Firebase Admin SDK
   - Atualizar `users/{professionalId}.avaliacao`
   - Atualizar `users/{professionalId}.updatedAt`
   - Registrar em `auditLogs`

4. ✅ **Auditoria**:
   - Log: `{userId, professionalId, newAverage, timestamp}`
   - Dentro da transação

### Request

```json
{} // Body vazio (usa path param)
```

### Response (200 OK)

```json
{
  "success": true,
  "data": {
    "professionalId": "prof_123",
    "averageRating": 4.5,
    "totalReviews": 12,
    "updatedAt": "2025-10-27T10:00:00Z"
  }
}
```

### Errors

```json
// 401 Unauthorized
{
  "error": "JWT token inválido ou expirado"
}

// 403 Forbidden
{
  "error": "Você não tem permissão para atualizar este profissional"
}

// 404 Not Found
{
  "error": "Profissional não encontrado"
}

// 500 Internal Server Error
{
  "error": "Erro ao calcular avaliação média"
}
```

---

## 📝 Implementação Recomendada (Backend)

### Arquivo: `backend/lib/features/reviews/domain/services/reviews_service.dart`

```dart
class ReviewsService {
  final FirebaseFirestore _firestore;

  /// ✅ Calcula e atualiza a avaliação média do profissional
  /// ACID transaction garantida
  Future<Map<String, dynamic>> calculateAverageRating(
    String professionalId,
  ) async {
    try {
      // 1. Buscar todas as reviews do profissional
      final reviews = await _firestore
          .collection('reviews')
          .where('professionalId', isEqualTo: professionalId)
          .get();

      // 2. Calcular média
      double averageRating = 0.0;
      if (reviews.docs.isNotEmpty) {
        double sum = 0;
        for (final doc in reviews.docs) {
          sum += doc.data()['rating'] as double;
        }
        averageRating = sum / reviews.docs.length;
      }

      // 3. Usar transação para atualizar atomicamente
      await _firestore.runTransaction((transaction) async {
        // Atualizar profissional
        transaction.update(
          _firestore.collection('users').doc(professionalId),
          {
            'avaliacao': averageRating,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        // Registrar auditoria
        transaction.set(
          _firestore.collection('auditLogs').doc(),
          {
            'action': 'reviews.aggregated',
            'professionalId': professionalId,
            'averageRating': averageRating,
            'totalReviews': reviews.docs.length,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      return {
        'professionalId': professionalId,
        'averageRating': averageRating,
        'totalReviews': reviews.docs.length,
      };
    } catch (e) {
      rethrow;
    }
  }
}
```

### Arquivo: `backend/lib/features/reviews/presentation/controllers/reviews_controller.dart`

```dart
class ReviewsController {
  final ReviewsService _reviewsService;

  /// POST /api/v1/reviews/{professionalId}/aggregate
  Future<Response> aggregateAverageRating(Request request, String professionalId) async {
    try {
      // 1. Extrair JWT
      final token = request.headers['authorization']?.replaceFirst('Bearer ', '');
      if (token == null) {
        return Response(401, body: jsonEncode({'error': 'JWT requerido'}));
      }

      // 2. Validar token e extrair userId
      final userId = await _authService.validateToken(token);
      if (userId == null) {
        return Response(401, body: jsonEncode({'error': 'Token inválido'}));
      }

      // 3. Verificar permissão (admin ou self)
      final isAdmin = await _authService.isAdmin(userId);
      if (userId != professionalId && !isAdmin) {
        return Response(403, body: jsonEncode({'error': 'Sem permissão'}));
      }

      // 4. Calcular e atualizar
      final result = await _reviewsService.calculateAverageRating(professionalId);

      return Response.ok(
        jsonEncode({'success': true, 'data': result}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}));
    }
  }
}
```

### Arquivo: `backend/lib/core/routes/app_router.dart`

```dart
// Adicionar rota:
app.post('/api/v1/reviews/<professionalId>/aggregate', (request, professionalId) {
  return _reviewsController.aggregateAverageRating(request, professionalId);
});
```

---

## 🧪 Como Testar

### Unit Test (Backend)

```dart
test('calculateAverageRating calcula média corretamente', () async {
  // Arrange: Criar 3 reviews (3, 4, 5)
  // Act: Chamar calculateAverageRating
  // Assert: Verificar average = 4.0
});

test('calculateAverageRating com 0 reviews retorna 0.0', () async {
  // Arrange: Sem reviews
  // Act: Chamar calculateAverageRating
  // Assert: Verificar average = 0.0
});
```

### Integration Test (Backend + Frontend)

```dart
test('Frontend: addReview chama backend aggregate', () async {
  // 1. Adicionar review
  // 2. Chamar aggregateAverageRating()
  // 3. Verificar que profissional.avaliacao foi atualizado
});
```

---

## 📊 Frontend Status

✅ **Completo**:
- Removido cálculo local do datasource
- Adicionado método `aggregateAverageRating()` no HTTP datasource
- Pronto para chamar backend quando disponível

⏳ **Bloqueado por**:
- Backend não existir ainda
- Endpoint `/api/v1/reviews/{professionalId}/aggregate` não implementado

---

## 🔗 Fluxo Completo (com Backend)

```
Frontend UI
   ↓
AddReviewScreen → addReview()
   ↓
ReviewsNotifier → addReviewUseCase()
   ↓
ReviewsRepository → addReview()
   ↓
HttpReviewsDataSource → addReview()
   ↓
Backend POST /api/v1/reviews/{professionalId}/reviews
   ↓ (sucesso)
Backend → ACID Transaction:
   ├─ Salvar review no Firestore
   ├─ Calcular média de reviews
   ├─ Atualizar professional.avaliacao
   └─ Registrar auditoria
   ↓
Frontend recebe resposta
   ↓
Frontend chama aggregateAverageRating()
   ↓
Backend POST /api/v1/reviews/{professionalId}/aggregate
   ↓
Backend recalcula (redundância, mas seguro)
   ↓
Frontend atualiza UI com nova média
```

---

## ✨ Benefícios

- ✅ **Segurança**: Cálculo não pode ser burlado no client
- ✅ **Atomicidade**: Guarantee transacional ACID
- ✅ **Auditoria**: Rastreamento completo
- ✅ **Escalabilidade**: Pode adicionar webhook para notificações depois
- ✅ **Testabilidade**: Backend pode ser testado isoladamente

---

## 📝 Próximas Etapas

### Para Backend (alguém):
1. Criar `ReviewsService` com `calculateAverageRating()`
2. Criar `ReviewsController` com rota POST
3. Montar em app_router.dart
4. Escrever testes

### Para Frontend (já feito):
- ✅ Remover lógica local
- ✅ Adicionar método HTTP
- ⏳ Testar quando backend estiver pronto

---

**PR 1.2 Status**: Frontend pronto, aguardando backend
