# 📊 INSTRUMENTATION PLAN - AppSanitaria

**Data:** 7 de Outubro, 2025  
**Status:** 📋 PLANO PRONTO PARA EXECUÇÃO  
**Objetivo:** Adicionar métricas usando `dart:developer`

---

## 🎯 O QUE É INSTRUMENTAÇÃO?

Instrumentação é o processo de adicionar **medições de performance** no código para:
- Identificar gargalos
- Monitorar operações críticas
- Visualizar fluxo de execução no DevTools Timeline

**Ferramenta:** `Timeline` API do `dart:developer`

---

## 📦 FUNÇÕES CRÍTICAS PARA INSTRUMENTAR

### **1. LocalStorageDataSource (ALTA PRIORIDADE)**

#### **1.1 `saveCurrentUser()`**
```dart
import 'dart:developer';

Future<bool> saveCurrentUser(Map<String, dynamic> userData) async {
  Timeline.startSync('LocalStorage:saveCurrentUser');
  try {
    final jsonString = jsonEncode(userData);
    final result = await _prefs.setString(
      AppConstants.storageKeyUserData,
      jsonString,
    );
    return result;
  } finally {
    Timeline.finishSync();
  }
}
```

**Por que instrumentar?**
- Operação I/O crítica
- Bloqueia login/registro
- Target: < 50ms

---

#### **1.2 `getAllUsers()`**
```dart
Future<List<Map<String, dynamic>>> getAllUsers() async {
  Timeline.startSync('LocalStorage:getAllUsers');
  try {
    final usersHostJson = _prefs.getString(AppConstants.storageKeyHostList);
    if (usersHostJson == null || usersHostJson.isEmpty) {
      return [];
    }

    final Map<String, dynamic> usersHost = jsonDecode(usersHostJson);
    return usersHost.values.map((user) => user as Map<String, dynamic>).toList();
  } finally {
    Timeline.finishSync();
  }
}
```

**Target:** < 100ms (mesmo com 1000+ usuários)

---

### **2. ProfessionalsProvider (ALTA PRIORIDADE)**

#### **2.1 `loadProfessionals()`**
```dart
Future<void> loadProfessionals() async {
  Timeline.startSync('ProfessionalsProvider:loadProfessionals');
  state = state.copyWith(isLoading: true);

  try {
    final allUsers = await _localStorage.getAllUsers();
    
    Timeline.instant('ProfessionalsProvider:filterStart', arguments: {
      'totalUsers': allUsers.length,
    });

    final professionals = allUsers.where((user) {
      final tipo = user['tipo'] as String?;
      return tipo == 'Profissional' || tipo == 'profissional';
    }).toList();

    Timeline.instant('ProfessionalsProvider:filterEnd', arguments: {
      'professionalsFound': professionals.length,
    });

    state = state.copyWith(
      professionals: professionals,
      filteredProfessionals: professionals,
      isLoading: false,
    );
  } catch (e) {
    AppLogger.error('Erro ao carregar profissionais: $e');
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Erro ao carregar profissionais',
    );
  } finally {
    Timeline.finishSync();
  }
}
```

**Target:** < 200ms para 100 profissionais

---

### **3. ChatProvider (MÉDIA PRIORIDADE)**

#### **3.1 `loadConversations()`**
```dart
Future<void> loadConversations() async {
  Timeline.startSync('ChatProvider:loadConversations');
  try {
    final conversations = await _localStorage.getConversations();
    
    Timeline.instant('ChatProvider:conversationsLoaded', arguments: {
      'count': conversations.length,
    });

    final userConversations = conversations.where((conv) =>
      conv.participants.contains(_currentUserId)
    ).toList();

    int totalUnread = 0;
    for (var conv in userConversations) {
      totalUnread += await _localStorage.getUnreadCount(conv.id, _currentUserId);
    }

    state = state.copyWith(
      conversations: userConversations,
      totalUnreadCount: totalUnread,
      isLoading: false,
    );

    AppLogger.info('💬 Conversas carregadas: ${userConversations.length}');
    AppLogger.info('📬 Mensagens não lidas: $totalUnread');
  } finally {
    Timeline.finishSync();
  }
}
```

**Target:** < 150ms para 50 conversas

---

### **4. RatingsCacheProvider (MÉDIA PRIORIDADE)**

#### **4.1 `getRating()`**
```dart
Future<RatingData> getRating(String professionalId) async {
  if (state.containsKey(professionalId)) {
    Timeline.instant('RatingsCache:hit', arguments: {'id': professionalId});
    return state[professionalId]!;
  }

  Timeline.startSync('RatingsCache:miss');
  try {
    final averageRating = await _localStorage.getAverageRating(professionalId);
    final reviews = await _localStorage.getReviewsByProfessional(professionalId);
    final ratingData = RatingData(
      averageRating: averageRating,
      totalReviews: reviews.length,
    );
    state = {...state, professionalId: ratingData};
    
    Timeline.instant('RatingsCache:loaded', arguments: {
      'id': professionalId,
      'rating': averageRating,
      'reviews': reviews.length,
    });
    
    return ratingData;
  } finally {
    Timeline.finishSync();
  }
}
```

**Target:** 
- Cache hit: < 1ms
- Cache miss: < 80ms

---

## 🔧 COMO ATIVAR INSTRUMENTAÇÃO

### **1. Adicionar import em todos os arquivos instrumentados:**
```dart
import 'dart:developer';
```

### **2. Executar app em profile mode:**
```bash
flutter run --profile -d emulator-5554
```

### **3. Abrir DevTools → Timeline:**
- Acessar `http://127.0.0.1:9101`
- Aba **Timeline**
- Clicar **"Record"**
- Usar o app
- Clicar **"Stop"**

### **4. Analisar eventos:**
- Procurar por `LocalStorage:*`, `ProfessionalsProvider:*`, etc.
- Verificar duração de cada evento
- Identificar gargalos

---

## 📊 TIPOS DE INSTRUMENTAÇÃO

### **`Timeline.startSync()` / `Timeline.finishSync()`**
- Para operações síncronas ou async que queremos medir
- Cria um "span" no timeline
- **Uso:** Funções completas (load, save, process)

### **`Timeline.instant()`**
- Para eventos pontuais
- Não tem duração, apenas timestamp
- **Uso:** Marcos importantes (cache hit, data loaded, etc.)
- Aceita `arguments` para debugging

### **`Timeline.timeSync()`**
- Alternativa mais simples para medir blocos
```dart
Timeline.timeSync('MyOperation', () {
  // código aqui
});
```

---

## 🎯 MÉTRICAS ALVO (APÓS INSTRUMENTAÇÃO)

| Operação | Target | Crítico | Atual |
|----------|--------|---------|-------|
| saveCurrentUser | < 50ms | < 100ms | ? |
| getAllUsers | < 100ms | < 200ms | ? |
| loadProfessionals | < 200ms | < 500ms | ? |
| loadConversations | < 150ms | < 300ms | ? |
| getRating (miss) | < 80ms | < 150ms | ~120ms (estimado) |
| getRating (hit) | < 1ms | < 5ms | < 1ms ✅ |

---

## 📝 CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Adicionar `Timeline` em `local_storage_datasource.dart`
- [ ] Adicionar `Timeline` em `professionals_provider.dart`
- [ ] Adicionar `Timeline` em `chat_provider.dart`
- [ ] Adicionar `Timeline` em `ratings_cache_provider.dart`
- [ ] Executar profiling completo
- [ ] Documentar métricas reais
- [ ] Identificar gargalos (se houver)
- [ ] Aplicar otimizações
- [ ] Re-profile e confirmar melhorias

---

## 🚨 IMPORTANTE

**NÃO instrumentar:**
- ❌ Getters simples
- ❌ Funções chamadas > 100x/segundo (overhead)
- ❌ UI builds (já instrumentados pelo Flutter)

**SIM instrumentar:**
- ✅ I/O operations
- ✅ JSON parsing pesado
- ✅ Loops sobre grandes datasets
- ✅ Cálculos complexos

---

**Status:** Plano pronto. Implementação estimada: ~2 horas.

*Plano criado durante pipeline de refatoração.*

