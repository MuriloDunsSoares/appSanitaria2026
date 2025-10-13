# 🚨 RELATÓRIO DE PERFORMANCE - Frames Perdidos

**Data:** 13/10/2025  
**Severidade:** 🔴 CRÍTICA  
**Impacto:** UX severamente comprometida com travamentos visíveis

---

## 📊 Métricas Coletadas

| Métrica | Valor | Status |
|---------|-------|--------|
| **Frames perdidos** | Até 563 frames | 🔴 CRÍTICO |
| **Tempo de travamento** | ~9 segundos | 🔴 CRÍTICO |
| **FPS ideal** | 60 fps (16.67ms/frame) | Target |
| **Ocorrências** | ~30+ vezes durante inicialização | 🔴 CRÍTICO |

---

## 🔍 Causas Identificadas

### 1️⃣ **Firebase Cloud Messaging Bloqueante** (CRÍTICO)

**Arquivo:** `lib/core/services/firebase_service.dart:55-95`

```dart
Future<void> _setupFCM() async {
  // ❌ PROBLEMA: Solicitação de permissões BLOQUEIA a UI
  final settings = await messaging.requestPermission();
  
  // ❌ PROBLEMA: Obtenção de token é operação de rede síncrona
  _fcmToken = await messaging.getToken();
  
  // ❌ PROBLEMA: Configuração de handlers executa na main thread
  _setupMessageHandlers();
}
```

**Impacto:**
- Permissões iOS: ~1-2 segundos de bloqueio
- Obtenção de token: ~500ms-1s de rede
- Total: **~2-3 segundos de UI congelada**

**Solução:**
```dart
// ✅ SOLUÇÃO: Mover para background isolate ou atrasar
Future<void> initialize() async {
  // Inicializar Firebase APENAS
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // ✅ Configurar FCM EM BACKGROUND ou APÓS primeiro frame
  unawaited(_setupFCMLater());
}

Future<void> _setupFCMLater() async {
  // Aguardar primeiro frame ser renderizado
  await WidgetsBinding.instance.firstFrameCallback;
  await _setupFCM();
}
```

---

### 2️⃣ **Auth Provider Verifica Sessão no Construtor** (CRÍTICO)

**Arquivo:** `lib/presentation/providers/auth_provider_v2.dart:89-93`

```dart
AuthNotifierV2({
  // ...
}) : super(AuthState.initial()) {
  // ❌ PROBLEMA: _checkSession() executa operações Firebase IMEDIATAMENTE
  _checkSession();
}

Future<void> _checkSession() async {
  // ❌ Verifica autenticação (lê Firebase Auth)
  final result = await _checkAuthentication.call(NoParams());
  
  // ❌ Carrega usuário do Firestore (operação de rede)
  final userResult = await _getCurrentUser.call(NoParams());
}
```

**Impacto:**
- Leitura do Firebase Auth: ~200-500ms
- Query do Firestore para obter dados do usuário: ~500ms-1s
- Total: **~1-1.5 segundos de bloqueio**

**Solução:**
```dart
// ✅ SOLUÇÃO: Lazy initialization
AuthNotifierV2({...}) : super(AuthState.initial()) {
  // NÃO chamar _checkSession() aqui
}

// Chamar explicitamente após primeiro frame
final authProviderV2 = StateNotifierProvider<AuthNotifierV2, AuthState>((ref) {
  final notifier = AuthNotifierV2(...);
  
  // ✅ Agendar verificação APÓS o primeiro frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifier._checkSession();
  });
  
  return notifier;
});
```

---

### 3️⃣ **Dependency Injection Síncrona** (MODERADO)

**Arquivo:** `lib/main.dart:120`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseService().initialize();  // ❌ Bloqueia main thread
  await setupDependencyInjection();       // ❌ ~50-100ms de bloqueio
  
  runApp(const ProviderScope(child: AppSanitaria()));
}
```

**Impacto:**
- Inicialização do Firebase: ~100-300ms
- Setup DI (GetIt): ~50-100ms
- Total: **~150-400ms antes do runApp()**

**Solução:**
```dart
// ✅ SOLUÇÃO: Splash screen com Isolate
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mostrar splash IMEDIATAMENTE
  runApp(const SplashScreen());
  
  // Inicializar em background
  await _initializeApp();
  
  // Substituir por app real
  runApp(const ProviderScope(child: AppSanitaria()));
}

Future<void> _initializeApp() async {
  await FirebaseService().initialize();
  await setupDependencyInjection();
}
```

---

### 4️⃣ **Falta de Performance Overlay** (MODERADO)

**Problema:** Sem indicadores visuais de carregamento durante operações pesadas.

**Solução:**
```dart
MaterialApp.router(
  // ✅ Adicionar builder para overlay global
  builder: (context, child) {
    return Stack(
      children: [
        child!,
        // Mostrar overlay durante operações pesadas
        if (_isLoadingHeavyOperation)
          Container(
            color: Colors.black54,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  },
);
```

---

### 5️⃣ **Build Pesado Durante Cold Start** (MODERADO)

**Problema:** Muitos widgets sendo construídos simultaneamente no primeiro frame.

**Logs:**
```
I/Choreographer: Skipped 351 frames! (linha 99)
I/Choreographer: Skipped 563 frames! (linha 118)
```

**Causas:**
- Router carregando todas as rotas
- Providers inicializando estado
- Temas sendo aplicados
- Animações iniciais

**Solução:**
```dart
// ✅ Usar LayoutBuilder para renderização progressiva
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Renderizar UI por partes usando FutureBuilder
        return FutureBuilder(
          future: Future.delayed(Duration.zero), // Frame seguinte
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return _buildHeavyContent();
          },
        );
      },
    );
  }
}
```

---

## 🎯 Plano de Ação (Priorizado)

### 🔴 **Prioridade ALTA** (Resolver Primeiro)

1. **Mover FCM para background**
   - Tempo: 30 min
   - Impacto: Reduz 2-3s de bloqueio

2. **Lazy Auth Check**
   - Tempo: 20 min
   - Impacto: Reduz 1-1.5s de bloqueio

3. **Splash Screen Adequada**
   - Tempo: 1 hora
   - Impacto: Esconde inicialização, melhora UX

### 🟡 **Prioridade MÉDIA**

4. **Otimizar Build de Widgets**
   - Tempo: 2 horas
   - Impacto: Reduz frames perdidos em 50%

5. **Performance Overlay**
   - Tempo: 30 min
   - Impacto: Melhor feedback visual

### 🟢 **Prioridade BAIXA** (Melhorias Futuras)

6. **Código Splitting**
7. **Lazy Loading de Assets**
8. **Tree Shaking Otimizado**

---

## 📈 Resultados Esperados

| Métrica | Antes | Depois | Melhoria |
|---------|-------|---------|----------|
| **Frames perdidos** | 563 | <60 | **90%** ✅ |
| **Tempo de travamento** | 9s | <1s | **89%** ✅ |
| **Cold start time** | ~5-8s | ~2-3s | **60%** ✅ |
| **Time to interactive** | ~10s | ~3s | **70%** ✅ |

---

## 🛠️ Ferramentas para Monitoramento

```bash
# 1. Flutter Performance Overlay
flutter run --profile --trace-skia

# 2. DevTools Timeline
flutter pub global activate devtools
devtools --port=9100

# 3. Performance Report
flutter run --profile --trace-startup --verbose

# 4. Build Analysis
flutter analyze --watch
flutter build apk --analyze-size
```

---

## 📚 Referências

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Reducing App Size](https://docs.flutter.dev/perf/app-size)
- [Deferred Components](https://docs.flutter.dev/perf/deferred-components)
- [Firebase Performance Monitoring](https://firebase.google.com/docs/perf-mon)

