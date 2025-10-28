# 🎯 PLANO: Corrigir 111 Erros Restantes - 6 Fases Estruturadas

**Status**: 27 October 2025  
**Total Errors**: 111 (library code - não testes, não backend_dart)  
**Objetivo**: Atingir 0 errors em lib/ com abordagem faseada

---

## 📊 Categorização dos 111 Erros

| Categoria | Quantidade | Prioridade | Tempo |
|-----------|-----------|-----------|-------|
| Non-exhaustive switch statements | 6 | 🔴 HIGH | 10 min |
| Chamadas a getAverageRating removido | 1 | 🔴 HIGH | 5 min |
| ContractsScreen pagination methods | 20+ | 🟠 MEDIUM | 30 min |
| Missing repository methods | 25+ | 🟠 MEDIUM | 45 min |
| Exception/Failure handling | 30+ | 🟠 MEDIUM | 40 min |
| Missing datasource dependencies | 20+ | 🟡 LOW | 20 min |
| Outros | 9 | 🟡 LOW | 15 min |

**Total Tempo Estimado**: ~2-3 horas

---

## 🚀 FASE 1: Non-Exhaustive Switch Statements (10 min)

### ❌ Problema
O enum `ContractStatus` agora tem `accepted` e `rejected`, mas 6 switch statements não tratam esses casos.

### 📍 Arquivos Afetados
1. `lib/presentation/screens/contract_detail_screen.dart` (2 switches)
2. `lib/presentation/screens/contracts_list_screen.dart` (2 switches)
3. `lib/presentation/widgets/contract_card.dart` (2 switches)

### 🔧 Solução
Para cada switch statement, adicionar casos para `accepted` e `rejected`:

**ANTES:**
```dart
switch (contract.status) {
  case ContractStatus.pending:
    return Colors.orange;
  case ContractStatus.confirmed:
    return Colors.blue;
  case ContractStatus.completed:
    return Colors.green;
  case ContractStatus.cancelled:
    return Colors.red;
}
```

**DEPOIS:**
```dart
switch (contract.status) {
  case ContractStatus.pending:
    return Colors.orange;
  case ContractStatus.confirmed:
    return Colors.blue;
  case ContractStatus.accepted:      // ← ADD
    return Colors.green;              // ← ADD
  case ContractStatus.rejected:       // ← ADD
    return Colors.red;                // ← ADD
  case ContractStatus.completed:
    return Colors.green;
  case ContractStatus.cancelled:
    return Colors.gray;
}
```

---

## 🚀 FASE 2: Remove getAverageRating Use Case (5 min)

### ❌ Problema
Arquivo `lib/domain/usecases/reviews/get_average_rating.dart` ainda tenta chamar `repository.getAverageRating()` que removemos da interface.

### 📍 Arquivo Afetado
- `lib/domain/usecases/reviews/get_average_rating.dart` (linha 18)

### 🔧 Solução
**OPÇÃO A**: Remover o arquivo inteiro (se não for mais usado)
```bash
rm lib/domain/usecases/reviews/get_average_rating.dart
```

**OPÇÃO B**: Se ainda for usado, atualizar para retornar erro:
```dart
@override
Future<Either<Failure, double>> call(String professionalId) async {
  return const Left(
    ValidationFailure('Rating médio agora é calculado no backend'),
  );
}
```

---

## 🚀 FASE 3: ContractsScreen Pagination Methods (30 min)

### ❌ Problema
`ContractsNotifierV2` não tem métodos `loadFirstPage`, `loadNextPage`, `refresh`, e estado não tem `filteredContracts`, `currentPage`, `isLoadingMore`.

### 📍 Arquivo Afetado
- `lib/presentation/providers/contracts_provider_v2.dart`

### 🔧 Solução

**Adicionar ao ContractsState:**
```dart
class ContractsState {
  final List<ContractEntity> contracts;
  final List<ContractEntity> filteredContracts;  // ← ADD
  final bool isLoading;
  final bool isLoadingMore;                      // ← ADD
  final int currentPage;                         // ← ADD
  final String? errorMessage;

  ContractsState({
    this.contracts = const [],
    this.filteredContracts = const [],           // ← ADD
    this.isLoading = false,
    this.isLoadingMore = false,                  // ← ADD
    this.currentPage = 1,                        // ← ADD
    this.errorMessage,
  });

  ContractsState copyWith({
    List<ContractEntity>? contracts,
    List<ContractEntity>? filteredContracts,     // ← ADD
    bool? isLoading,
    bool? isLoadingMore,                         // ← ADD
    int? currentPage,                            // ← ADD
    String? errorMessage,
  }) {
    return ContractsState(
      contracts: contracts ?? this.contracts,
      filteredContracts: filteredContracts ?? this.filteredContracts,  // ← ADD
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,              // ← ADD
      currentPage: currentPage ?? this.currentPage,                    // ← ADD
      errorMessage: errorMessage,
    );
  }
}
```

**Adicionar ao ContractsNotifierV2:**
```dart
/// Carrega primeira página
Future<void> loadFirstPage() async {
  state = state.copyWith(currentPage: 1, isLoading: true);
  await loadContracts();
}

/// Carrega próxima página
Future<void> loadNextPage() async {
  state = state.copyWith(isLoadingMore: true, currentPage: state.currentPage + 1);
  // Chamar usecase com paginação
  await loadContracts();
}

/// Refresh
Future<void> refresh() async {
  state = state.copyWith(currentPage: 1);
  await loadContracts();
}
```

---

## 🚀 FASE 4: Missing Repository Methods (45 min)

### ❌ Problema
28+ chamadas a métodos que não existem nas interfaces de repository:
- `AuthRepository.deleteAccount()`
- `AuthRepository.sendPasswordResetEmail()`
- `ChatRepository.getMessagesPaginated()`
- `ContractsRepository.getContractsPaginated()`
- `ProfessionalsRepository.getProfessionalsPaginated()`
- `ReviewsRepository.getReviewsPaginated()`
- `ReviewsRepository.reportReview()`
- `ReviewsRepository.updateReview()`

### 📍 Arquivos Afetados
- `lib/domain/repositories/auth_repository.dart`
- `lib/domain/repositories/chat_repository.dart`
- `lib/domain/repositories/contracts_repository.dart`
- `lib/domain/repositories/professionals_repository.dart`
- `lib/domain/repositories/reviews_repository.dart`

### 🔧 Solução

**Adicionar métodos às interfaces:**

```dart
// lib/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  // ... existing methods ...
  
  Future<Either<Failure, Unit>> deleteAccount();
  Future<Either<Failure, Unit>> sendPasswordResetEmail(String email);
}

// lib/domain/repositories/chat_repository.dart
abstract class ChatRepository {
  // ... existing methods ...
  
  Future<Either<Failure, List<MessageEntity>>> getMessagesPaginated(
    String conversationId,
    int page,
    int pageSize,
  );
}

// E assim por diante para outros repositories...
```

**Implementar em cada *Impl:**
```dart
@override
Future<Either<Failure, Unit>> deleteAccount() async {
  try {
    // Implementação
    return const Right(unit);
  } catch (e) {
    return Left(ServerFailure('Erro ao deletar conta'));
  }
}
```

---

## 🚀 FASE 5: Exception/Failure Handling (40 min)

### ❌ Problema
30+ referências a `ServerException`, `RateLimitException` que não estão definidos corretamente.

### 📍 Arquivos Afetados
- `lib/core/error/exception_to_failure_mapper.dart`
- `lib/data/datasources/http_messages_datasource.dart`
- `lib/data/datasources/http_professionals_datasource.dart`
- Outros datasources

### 🔧 Solução

**Verificar/corrigir classes de exceção:**
```dart
// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  final dynamic data;
  
  ServerException(this.message, [this.data]);
  
  @override
  String toString() => 'ServerException: $message';
}

class RateLimitException implements Exception {
  final String message;
  
  RateLimitException(this.message);
  
  @override
  String toString() => 'RateLimitException: $message';
}
```

**Atualizar mapper:**
```dart
if (exception is ServerException) {
  return ServerFailure(exception.message);
}

if (exception is RateLimitException) {
  return RateLimitFailure(exception.message);
}
```

---

## 🚀 FASE 6: Missing Datasource Dependencies (20 min)

### ❌ Problema
Imports para pacotes não instalados:
- `package:encrypt/encrypt.dart`
- `package:geocoding/geocoding.dart`
- `package:geolocator/geolocator.dart`

### 🔧 Solução

**OPÇÃO A**: Instalar os pacotes
```bash
flutter pub add encrypt geocoding geolocator
```

**OPÇÃO B**: Remover os datasources se não são necessários
```bash
rm lib/core/security/encryption_service.dart
rm lib/data/datasources/geocoding_datasource.dart
rm lib/data/datasources/geolocator_datasource.dart
```

**OPÇÃO C**: Desabilitar imports temporariamente
```dart
// ignore: unused_import
import 'package:encrypt/encrypt.dart';
```

---

## 🎯 Sequência Recomendada

```
FASE 1 (10 min): Switch statements
  ↓ flutter analyze → check errors reduced
FASE 2 (5 min): Remove getAverageRating
  ↓ flutter analyze → check errors reduced
FASE 3 (30 min): Add pagination methods
  ↓ flutter analyze → check errors reduced
FASE 4 (45 min): Add missing repository methods
  ↓ flutter analyze → check errors reduced
FASE 5 (40 min): Fix Exception/Failure
  ↓ flutter analyze → check errors reduced
FASE 6 (20 min): Handle dependencies
  ↓ flutter analyze final
  ↓ ESPERADO: 0 errors ✅
```

---

## ✅ Validação Após Cada Fase

```bash
# Após cada fase
flutter analyze lib/ 2>&1 | grep "^  error" | wc -l

# Esperado:
FASE 1: 111 → 105
FASE 2: 105 → 104
FASE 3: 104 → 84
FASE 4: 84 → 59
FASE 5: 59 → 29
FASE 6: 29 → 0 ✅
```

---

## 📝 Próximas Ações

1. **Você quer começar pela FASE 1 agora?**
2. **Ou prefere focar em uma fase específica primeiro?**
3. **Ou quer que eu rode todas as 6 fases de uma vez?**

Qual é sua preferência? 🚀
