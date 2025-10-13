# 🏗️ Refatoração de Arquitetura - LocalStorageDataSource

## **📋 Status Atual**

### **Problema Identificado (PR#5):**
`LocalStorageDataSource` é um **"God Object"** com **784 linhas** e **8 responsabilidades distintas**, violando o **Single Responsibility Principle (SRP)**.

### **Responsabilidades Misturadas:**
1. **Autenticação** (current user, keep logged in)
2. **Gerenciamento de Usuários** (getAllUsers, register)
3. **Favoritos** (get/save/clear por userId)
4. **Chat** (messages, conversations)
5. **Contratos** (save/get/update/delete)
6. **Reviews** (save/get/average rating)
7. **Profile Images** (paths)
8. **Utilitários** (clearAll, getAllKeys)

---

## **✅ Solução Implementada (PR#5 - Fase 1)**

### **Arquivos Criados:**

#### 1. `local_storage_base.dart` (38 linhas)
- **Interface abstrata** para todos os datasources
- **`LocalStorageBase`**: Classe base com acesso a `SharedPreferences`
- **`LocalStorageException`**: Exceção customizada
- Métodos utilitários: `hasKey`, `remove`, `clearAll`, `getAllKeys`

#### 2. `auth_storage_datasource.dart` (108 linhas)
- **Responsabilidade única:** Autenticação
- Métodos:
  - `saveCurrentUser` / `getCurrentUser`
  - `saveCurrentUserId` / `getCurrentUserId`
  - `clearCurrentUser`
  - `saveKeepLoggedIn` / `getKeepLoggedIn` / `clearKeepLoggedIn`
  - `isLoggedIn` (utilitário)

#### 3. `local_storage_datasource_v2.dart` (79 linhas)
- **Facade pattern** para transição gradual
- Delega métodos de auth para `AuthStorageDataSource`
- Mantém compatibilidade com código existente
- Preparado para migração incremental

#### 4. Documentação em `local_storage_datasource.dart`
- Adicionado comentário de arquitetura no header
- Lista completa de refatorações planejadas
- Referências para nova arquitetura

---

## **📅 Roadmap de Refatoração**

### **Fase 1: Foundation** ✅ *CONCLUÍDA*
- ✅ `LocalStorageBase` (interface)
- ✅ `AuthStorageDataSource` (SRP compliant)
- ✅ Documentação de arquitetura

### **Fase 2: Datasources Especializados** 🚧 *PLANEJADA*
- `UsersStorageDataSource` (~80 linhas)
  - `getAllUsers()`, `registerUser()`, cache
- `FavoritesStorageDataSource` (~60 linhas)
  - `getFavorites()`, `saveFavorites()`, `clearFavorites()`
- `ChatStorageDataSource` (~200 linhas)
  - Messages, Conversations, markAsRead, delete
- `ContractsStorageDataSource` (~100 linhas)
  - CRUD completo de contratos
- `ReviewsStorageDataSource` (~100 linhas)
  - Reviews, average rating, hasReviewed
- `ProfileStorageDataSource` (~50 linhas)
  - Profile image paths

### **Fase 3: Migração de Providers** 🚧 *PLANEJADA*
- Atualizar todos os providers para usar datasources especializados
- Manter testes de compatibilidade
- Deprecar `LocalStorageDataSource` original

### **Fase 4: Cleanup** 📅 *FUTURO*
- Remover `LocalStorageDataSource` antigo
- Remover `LocalStorageDataSourceV2` (facade)
- Providers acessam datasources diretamente

---

## **🎯 Benefícios da Refatoração**

### **Antes:**
```dart
// 1 classe, 784 linhas, 8 responsabilidades
final localStorage = ref.read(localStorageProvider);
localStorage.saveCurrentUser(...);     // Auth
localStorage.getFavorites(...);         // Favorites
localStorage.saveMessage(...);          // Chat
localStorage.saveContract(...);         // Contracts
localStorage.saveReview(...);           // Reviews
```

### **Depois:**
```dart
// 7 classes especializadas, ~100 linhas cada
final authStorage = ref.read(authStorageProvider);
final favoritesStorage = ref.read(favoritesStorageProvider);
final chatStorage = ref.read(chatStorageProvider);
final contractsStorage = ref.read(contractsStorageProvider);
final reviewsStorage = ref.read(reviewsStorageProvider);

authStorage.saveCurrentUser(...);      // SRP: Apenas auth
favoritesStorage.getFavorites(...);     // SRP: Apenas favorites
chatStorage.saveMessage(...);           // SRP: Apenas chat
```

### **Vantagens:**
- ✅ **Testabilidade:** Classes menores e focadas
- ✅ **Manutenibilidade:** Mudanças isoladas
- ✅ **Legibilidade:** Código auto-documentado
- ✅ **Performance:** Possível otimização por domínio
- ✅ **Escalabilidade:** Fácil adicionar novas features

---

## **⚠️ Considerações de Implementação**

### **Por que Fase 1 apenas?**
1. **Impacto:** Refatoração completa = ~40 edições de arquivos
2. **Risco:** Migração de providers pode quebrar features existentes
3. **Testes:** Necessário validar cada migração
4. **Pragmatismo:** Foundation criada, migração incremental no futuro

### **Próximos Passos (Quando necessário):**
1. Criar datasource especializado (ex: `FavoritesStorageDataSource`)
2. Adicionar provider (`favoritesStorageProvider`)
3. Migrar 1 provider existente (ex: `FavoritesProvider`)
4. Testar extensivamente
5. Repetir para próximo domínio

---

## **📚 Referências**

- **Clean Architecture:** Robert C. Martin
- **SOLID Principles:** Single Responsibility Principle (SRP)
- **Design Patterns:** Facade, Repository
- **Flutter Best Practices:** [[memory:9623107]]

---

**Data:** 07/10/2025  
**PR:** #5 - Refatoração LocalStorageDataSource  
**Status:** Fase 1 Completa ✅

