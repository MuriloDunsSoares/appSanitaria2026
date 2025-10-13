# 🔧 PLANO DE CORREÇÃO: 77 ERROS DE UI

**Status:** 🚀 INICIANDO CORREÇÃO SISTEMÁTICA

---

## 📊 CATEGORIAS DE ERROS

### **1. Map → Entity (user['id'] → user.id)** - ~40 erros
- add_review_screen.dart
- contract_detail_screen.dart
- contracts_screen.dart
- home_professional_screen.dart
- individual_chat_screen.dart
- profile_screen.dart (provavelmente)

### **2. Métodos inexistentes em Providers V2** - ~25 erros
- `getFavoriteProfessionals()` → Precisa implementar
- `clearAllFavorites()` → Precisa implementar
- `startConversation()` → Precisa implementar
- `applyFilters()` → Precisa implementar
- `setSearchQuery()` → Precisa implementar
- `register()` → Usar `registerPatient()` ou `registerProfessional()`

### **3. Getters/Campos faltantes** - ~10 erros
- `FavoritesState.count` não existe
- `senderId`, `senderName` em sendMessage

### **4. Outros** - ~2 erros
- `ProfIdParamsRating` errado em reviews_provider_v2

---

## 🎯 ESTRATÉGIA

1. **Fase 1:** Corrigir Map → Entity (rápido, substituição direta)
2. **Fase 2:** Implementar métodos faltantes nos Providers
3. **Fase 3:** Ajustar campos/parâmetros
4. **Fase 4:** Validar compilação

**Tempo estimado:** 30-45 min

---

**Vamos começar!** 🚀
