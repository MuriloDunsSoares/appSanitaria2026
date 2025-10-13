# ⚡ PERFORMANCE OPTIMIZATION - AppSanitaria

**Data:** 7 de Outubro, 2025  
**Status Atual:** Davey 0ms ✅, APK 49MB, Cold Start ~270ms

---

## 📊 MÉTRICAS ATUAIS vs ALVO

| Métrica | Atual | Alvo | Gap |
|---------|-------|------|-----|
| **Cold Start** | 270ms | <200ms | -26% |
| **APK Size** | 49 MB | <45 MB | -8% |
| **Davey Duration** | 0ms | 0ms | ✅ |
| **Skipped Frames** | 416 | <500 | ✅ |
| **Memory (avg)** | ~150MB | <120MB | -20% |

---

## 🚀 STARTUP OPTIMIZATION

### 1. Lazy Initialization
```dart
// ❌ MAU: Tudo carregado no startup
void main() async {
  await di.init(); // Carrega TUDO
  runApp(MyApp());
}

// ✅ BOM: Lazy loading
void main() async {
  await di.initCore(); // Apenas essencial
  runApp(MyApp());
}

// Carregar features sob demanda
final professionalsProvider = FutureProvider((ref) async {
  await di.initProfessionalsFeature(); // Lazy
  return ref.watch(professionalsUseCaseProvider);
});
```

### 2. Deferred Loading
```dart
// Carregar código sob demanda
import 'package:app_sanitaria/features/professionals/professionals.dart' deferred as professionals;

// Quando necessário:
await professionals.loadLibrary();
professionals.showProfessionalsScreen();
```

**Ganho estimado:** -30ms cold start

---

## 🎨 RENDER OPTIMIZATION

### 1. Const Constructors
```dart
// ❌ MAU: Widget sempre reconstruído
class MyWidget extends StatelessWidget {
  Widget build(context) {
    return Container(child: Text('Hello')); // Nova instância sempre
  }
}

// ✅ BOM: Const quando possível
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  Widget build(context) {
    return const Text('Hello'); // Reutilizado
  }
}
```

**Ganho:** -20ms em rebuilds

### 2. RepaintBoundary
```dart
// Para widgets que não mudam
RepaintBoundary(
  child: ExpensiveWidget(),
)
```

---

## 📜 LISTAS OPTIMIZATION

### 1. ListView.builder (já implementado ✅)
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ProfessionalCard(professional: items[index]);
  },
)
```

### 2. Sliver Lists (recomendado)
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(/* ... */),
    SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ProfessionalCard(/* ... */),
    ),
  ],
)
```

### 3. Paginação
```dart
// Carregar 20 items por vez
final professionalsProvider = StateNotifierProvider<ProfessionalsNotifier, ProfessionalsState>((ref) {
  return ProfessionalsNotifier()..loadPage(0, pageSize: 20);
});
```

---

## 🖼️ IMAGENS OPTIMIZATION

### 1. Cache de Imagens
```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.4.1
```

```dart
CachedNetworkImage(
  imageUrl: professional.photoUrl,
  memCacheHeight: 200,
  memCacheWidth: 200,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 2. Compressão de Assets
```bash
# Otimizar imagens antes de build
find assets -name "*.png" -exec pngquant --quality=65-80 {} \;
```

**Ganho:** -5 MB APK, -30 MB memória

---

## 🔄 REBUILD OPTIMIZATION

### 1. Provider Granular
```dart
// ❌ MAU: Provider gigante
final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});

// ✅ BOM: Providers específicos
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => ...);
final professionalsProvider = StateNotifierProvider<ProfessionalsNotifier, ProfessionalsState>((ref) => ...);
```

### 2. Select para Observar Partes Específicas
```dart
// ❌ MAU: Rebuilda em qualquer mudança
final authState = ref.watch(authProvider);

// ✅ BOM: Rebuilda só quando userId muda
final userId = ref.watch(authProvider.select((state) => 
  state is AuthAuthenticated ? state.user.id : null
));
```

---

## 📦 APK SIZE REDUCTION

### 1. Code Shrinking
```gradle
// android/app/build.gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguard-android-optimize.txt'
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### 2. Remover Unused Resources
```bash
flutter build apk --release --analyze-size
```

### 3. Split APKs por ABI
```gradle
android {
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a', 'x86_64'
            universalApk false
        }
    }
}
```

**Ganho:** -10 MB APK

---

## 🧵 ISOLATES para Tarefas Pesadas

```dart
import 'dart:isolate';

// Processar dados pesados em isolate
Future<List<Professional>> filterProfessionals(List<Professional> all, String query) async {
  return await Isolate.run(() {
    return all.where((p) => p.nome.contains(query)).toList();
  });
}
```

---

## ✅ CHECKLIST DE PERFORMANCE

### Startup
- [ ] Lazy initialization de features
- [ ] Deferred loading de módulos pesados
- [ ] Minimizar código no main()
- [ ] Cache de SharedPreferences

### Render
- [ ] Const constructors onde possível
- [ ] RepaintBoundary em widgets caros
- [ ] Keys em listas para preservar estado
- [ ] Evitar setState() global

### Listas
- [ ] ListView.builder implementado
- [ ] Paginação (20 items/página)
- [ ] Lazy loading de imagens
- [ ] Dispose de controllers

### Imagens
- [ ] Cached network images
- [ ] Resize antes de carregar
- [ ] Compressão de assets
- [ ] SVG ao invés de PNG quando possível

### Memória
- [ ] Dispose de streams
- [ ] Dispose de controllers
- [ ] Weak references para cache
- [ ] Evitar memory leaks (listeners)

### Build
- [ ] Code shrinking ativo
- [ ] Resource shrinking ativo
- [ ] Split APKs por ABI
- [ ] Obfuscation ativo

---

[◀️ Voltar aos Exemplos](./AUDITORIA_06_EXEMPLOS.md) | [Próximo: Testes ▶️](./AUDITORIA_08_TESTES_OBSERVABILIDADE.md)

