# 📝 PROMPT PARA PRÓXIMO CHAT - Fixar 111 Erros em 6 Fases

**Copie e cole TUDO isto no novo chat:**

---

```
PROJETO: App Sanitária (Flutter + Firebase)
STATUS: 228 erros reduzidos para 111 (chat anterior fez 3 fixes)
OBJETIVO: Corrigir os 111 erros restantes em lib/ com 6 fases estruturadas

════════════════════════════════════════════════════════════════

✅ PROGRESSO NO CHAT ANTERIOR (Concluído):

FASE 0a: ContractStatus enum ✅
  - Adicionado: accepted, rejected ao enum
  - Arquivo: lib/domain/entities/contract_status.dart
  - Resultado: Enum e displayName atualizados

FASE 0b: Provider userId/userRole ✅
  - Adicionado: userId e userRole ao UpdateContractStatusParams
  - Arquivo: lib/presentation/providers/contracts_provider_v2.dart (linha 110-116)
  - Resultado: Provider agora passa parâmetros obrigatórios

FASE 0c: ReviewsRepository cleanup ✅
  - Removido: getAverageRating() da interface
  - Arquivo: lib/domain/repositories/reviews_repository.dart
  - Motivo: Backend agora calcula via HTTP

════════════════════════════════════════════════════════════════

❌ RESTANTES: 111 erros em lib/

Categorização:
  • Non-exhaustive switch statements: 6 errors 🔴 HIGH
  • getAverageRating removed: 1 error 🔴 HIGH
  • Pagination methods missing: 20+ errors 🟠 MEDIUM
  • Repository methods missing: 25+ errors 🟠 MEDIUM
  • Exception/Failure handling: 30+ errors 🟠 MEDIUM
  • Datasource dependencies: 20+ errors 🟡 LOW
  • Outros: 9 errors 🟡 LOW

════════════════════════════════════════════════════════════════

🚀 PLANO: 6 FASES ESTRUTURADAS (2-3 horas total)

┌─ FASE 1: Switch Statements (10 min) 🔴 HIGH ─────────────┐
│                                                            │
│ PROBLEMA:                                                  │
│ O enum agora tem accepted + rejected, mas 6 switch        │
│ statements não tratam esses casos.                         │
│                                                            │
│ ARQUIVOS:                                                  │
│ 1. lib/presentation/screens/contract_detail_screen.dart   │
│    - 2 switch statements (linhas ~24, ~39)                │
│ 2. lib/presentation/screens/contracts_list_screen.dart    │
│    - 2 switch statements (linhas ~92, ~247)               │
│ 3. lib/presentation/widgets/contract_card.dart            │
│    - 2 switch statements (linhas ~21, ~36)                │
│                                                            │
│ SOLUÇÃO:                                                   │
│ Em cada switch statement, adicionar:                       │
│ case ContractStatus.accepted:                             │
│   return Colors.green; // ou valor apropriado             │
│ case ContractStatus.rejected:                             │
│   return Colors.red;   // ou valor apropriado             │
│                                                            │
│ APÓS: flutter analyze lib/ 2>&1 | grep "error" | wc -l    │
│ ESPERADO: 111 → 105 errors                                │
└────────────────────────────────────────────────────────────┘

┌─ FASE 2: getAverageRating (5 min) 🔴 HIGH ──────────────┐
│                                                          │
│ PROBLEMA:                                                │
│ Usecase ainda tenta chamar repository.getAverageRating()│
│ que foi removido.                                         │
│                                                          │
│ ARQUIVO:                                                 │
│ lib/domain/usecases/reviews/get_average_rating.dart      │
│                                                          │
│ SOLUÇÃO (OPÇÃO A - Remover):                            │
│ rm lib/domain/usecases/reviews/get_average_rating.dart  │
│                                                          │
│ OU (OPÇÃO B - Atualizar linha 18):                      │
│ Trocar:                                                  │
│   return await repository.getAverageRating(...)         │
│ Por:                                                     │
│   return const Left(ValidationFailure(                  │
│     'Rating médio calculado no backend'                 │
│   ));                                                    │
│                                                          │
│ APÓS: flutter analyze lib/ 2>&1 | grep "error" | wc -l  │
│ ESPERADO: 105 → 104 errors                              │
└──────────────────────────────────────────────────────────┘

┌─ FASE 3: Pagination Methods (30 min) 🟠 MEDIUM ────────┐
│                                                         │
│ PROBLEMA:                                               │
│ ContractsNotifierV2 faltam:                            │
│  - métodos: loadFirstPage, loadNextPage, refresh       │
│  - campos: filteredContracts, currentPage, isLoadingMore│
│                                                         │
│ ARQUIVO:                                                │
│ lib/presentation/providers/contracts_provider_v2.dart   │
│                                                         │
│ SOLUÇÃO:                                                │
│                                                         │
│ 1. ATUALIZAR ContractsState class:                     │
│    Adicionar 3 campos:                                 │
│    final List<ContractEntity> filteredContracts = []   │
│    final bool isLoadingMore = false                    │
│    final int currentPage = 1                           │
│                                                         │
│ 2. ATUALIZAR copyWith():                               │
│    Adicionar 3 parâmetros:                             │
│    List<ContractEntity>? filteredContracts,            │
│    bool? isLoadingMore,                                │
│    int? currentPage,                                   │
│                                                         │
│ 3. ADICIONAR ao ContractsNotifierV2:                   │
│    Future<void> loadFirstPage() async {                │
│      state = state.copyWith(currentPage: 1, ...);      │
│      await loadContracts();                            │
│    }                                                   │
│                                                         │
│    Future<void> loadNextPage() async {                 │
│      state = state.copyWith(                           │
│        isLoadingMore: true,                            │
│        currentPage: state.currentPage + 1              │
│      );                                                │
│      // Call paginated usecase                         │
│    }                                                   │
│                                                         │
│    Future<void> refresh() async {                      │
│      state = state.copyWith(currentPage: 1);           │
│      await loadContracts();                            │
│    }                                                   │
│                                                         │
│ APÓS: flutter analyze lib/ 2>&1 | grep "error" | wc -l │
│ ESPERADO: 104 → 84 errors                              │
└─────────────────────────────────────────────────────────┘

┌─ FASE 4: Repository Methods (45 min) 🟠 MEDIUM ───────┐
│                                                        │
│ PROBLEMA:                                              │
│ 28+ chamadas a métodos que não existem em repositories│
│                                                        │
│ MÉTODOS FALTANTES:                                     │
│ • AuthRepository:                                      │
│   - deleteAccount()                                    │
│   - sendPasswordResetEmail(String email)               │
│                                                        │
│ • ChatRepository:                                      │
│   - getMessagesPaginated(conversationId, page, size)   │
│                                                        │
│ • ContractsRepository:                                 │
│   - getContractsPaginated(userId, page, size)          │
│                                                        │
│ • ProfessionalsRepository:                             │
│   - getProfessionalsPaginated(page, size)              │
│                                                        │
│ • ReviewsRepository:                                   │
│   - getReviewsPaginated(professionalId, page, size)    │
│   - reportReview(ReviewReportEntity)                   │
│   - updateReview(ReviewEntity)                         │
│                                                        │
│ SOLUÇÃO:                                               │
│ 1. Adicionar assinatura em cada interface abstract     │
│ 2. Implementar em cada *RepositoryImpl                 │
│ 3. Exemplo padrão:                                     │
│    @override                                          │
│    Future<Either<Failure, Unit>> deleteAccount()      │
│      async {                                          │
│      try {                                            │
│        // implementação                               │
│        return const Right(unit);                      │
│      } catch (e) {                                    │
│        return Left(ServerFailure(...));               │
│      }                                                │
│    }                                                  │
│                                                        │
│ APÓS: flutter analyze lib/ 2>&1 | grep "error" | wc -l │
│ ESPERADO: 84 → 59 errors                              │
└────────────────────────────────────────────────────────┘

┌─ FASE 5: Exception/Failure (40 min) 🟠 MEDIUM ───────┐
│                                                       │
│ PROBLEMA:                                             │
│ 30+ erros relacionados a ServerException e            │
│ RateLimitException não definidos corretamente        │
│                                                       │
│ ARQUIVOS:                                             │
│ • lib/core/error/exception_to_failure_mapper.dart    │
│ • lib/data/datasources/http_messages_datasource.dart │
│ • lib/data/datasources/http_professionals_datasource │
│                                                       │
│ SOLUÇÃO:                                              │
│ 1. Verificar/criar: lib/core/error/exceptions.dart   │
│    class ServerException implements Exception {       │
│      final String message;                           │
│      final dynamic data;                             │
│      ServerException(this.message, [this.data]);     │
│    }                                                 │
│                                                       │
│    class RateLimitException implements Exception {   │
│      final String message;                           │
│      RateLimitException(this.message);              │
│    }                                                 │
│                                                       │
│ 2. Atualizar mapper com try-catch corretos           │
│ 3. Revisar datasources - usar throw Exception()      │
│                                                       │
│ APÓS: flutter analyze lib/ 2>&1 | grep "error" | wc -l │
│ ESPERADO: 59 → 29 errors                             │
└───────────────────────────────────────────────────────┘

┌─ FASE 6: Dependencies (20 min) 🟡 LOW ──────────────┐
│                                                      │
│ PROBLEMA:                                            │
│ Pacotes não instalados:                             │
│ • encrypt/encrypt.dart                              │
│ • geocoding/geocoding.dart                          │
│ • geolocator/geolocator.dart                        │
│                                                      │
│ SOLUÇÃO (escolha uma):                              │
│                                                      │
│ OPÇÃO A - Instalar:                                 │
│ flutter pub add encrypt geocoding geolocator        │
│                                                      │
│ OPÇÃO B - Remover:                                  │
│ rm lib/core/security/encryption_service.dart       │
│ rm lib/data/datasources/geocoding_datasource.dart  │
│ rm lib/data/datasources/geolocator_datasource.dart │
│                                                      │
│ OPÇÃO C - Desabilitar:                              │
│ // ignore: unused_import no topo dos arquivos       │
│                                                      │
│ APÓS: flutter analyze lib/ 2>&1 | grep "error" | wc -l │
│ ESPERADO: 29 → 0 errors ✅                          │
└──────────────────────────────────────────────────────┘

════════════════════════════════════════════════════════════════

📋 COMO PROCEDER:

1. Leia PLANO_FIX_111_ERROS.md para detalhes de cada fase
2. Siga as 6 fases na ordem (1 → 2 → 3 → 4 → 5 → 6)
3. APÓS cada fase, rode:
   flutter analyze lib/ 2>&1 | grep "^  error" | wc -l

4. Verifique se os erros diminuem conforme esperado
5. Se alguma fase travar, descreva o erro + arquivo

════════════════════════════════════════════════════════════════

📊 VALIDAÇÃO FINAL:

flutter clean && flutter pub get && flutter analyze lib/

Esperado:
✅ 0 errors
✅ 0-20 warnings (info level apenas - style/best practice)
✅ Build success

════════════════════════════════════════════════════════════════

❓ SE TRAVAR:

1. Mostre o erro exato
2. Mencione qual FASE
3. Mostre o arquivo problemático
4. Referencie PLANO_FIX_111_ERROS.md linha X

Pronto? Vamos começar pela FASE 1? 🚀
```

---

**FIM DO PROMPT**

---
