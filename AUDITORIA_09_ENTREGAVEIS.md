# 📦 ENTREGÁVEIS CONCRETOS - AppSanitaria

**Data:** 7 de Outubro, 2025  
**Total de Arquivos:** 150+ arquivos (criar + editar + remover)

---

## 📂 ARQUIVOS A CRIAR (80+)

### Domain Layer (30 arquivos)
```
lib/domain/
├── repositories/ (7 interfaces)
│   ├── auth_repository.dart
│   ├── professionals_repository.dart
│   ├── contracts_repository.dart
│   ├── chat_repository.dart
│   ├── favorites_repository.dart
│   ├── reviews_repository.dart
│   └── profile_repository.dart
│
└── usecases/ (23 use cases)
    ├── auth/ (4)
    ├── professionals/ (4)
    ├── contracts/ (4)
    ├── chat/ (4)
    ├── favorites/ (3)
    ├── reviews/ (3)
    └── profile/ (1)
```

### Data Layer (20 arquivos)
```
lib/data/
├── models/ (7)
│   └── user_model.dart, etc.
├── repositories/ (7 implementations)
│   └── auth_repository_impl.dart, etc.
└── datasources/local/ (6)
    └── (migrar .wip files)
```

### Core Layer (5 arquivos)
```
lib/core/
├── error/
│   ├── failures.dart
│   └── exceptions.dart
├── usecases/
│   └── usecase.dart
└── utils/
    ├── validators.dart
    └── performance_tracker.dart
```

### Tests (100+ arquivos)
```
test/
├── domain/usecases/ (75+ testes)
├── data/repositories/ (21+ testes)
└── presentation/widgets/ (30+ testes)
```

### Config (5 arquivos)
```
├── analysis_options.yaml (atualizar)
├── .githooks/pre-commit (criar)
├── melos.yaml (criar)
├── .editorconfig (criar)
└── l10n.yaml (criar)
```

---

## ✏️ ARQUIVOS A EDITAR (40+)

### Presentation Layer (30 arquivos)
- **Providers (7):** Migrar para usar Use Cases
- **Screens (15):** Quebrar God Objects, usar Use Cases
- **Widgets (8):** Otimizações e const

### Core (5 arquivos)
- `main.dart`: Setup DI
- `app_router.dart`: Simplificar
- `app_constants.dart`: Quebrar em categorias
- `app_theme.dart`: Otimizar
- `app_logger.dart`: Usar package logger

### Config (5 arquivos)
- `pubspec.yaml`: Adicionar dependências
- `android/app/build.gradle`: Code shrinking
- `README.md`: Atualizar instruções
- `.gitignore`: Adicionar gerados

---

## 🗑️ ARQUIVOS A REMOVER (10)

### Data Layer
- `lib/data/datasources/local_storage_datasource.dart` (853 linhas - God Object)
- `lib/data/datasources/users_storage_datasource.dart.wip` (mover para .dart)
- `lib/data/datasources/chat_storage_datasource.dart.wip` (mover para .dart)
- `lib/data/datasources/profile_storage_datasource.dart.wip` (mover para .dart)

### Deprecated
- `lib/core/widgets/` (pasta vazia)
- `test/widget_test.dart` (teste inválido)

---

## 📄 DIFFS PRINCIPAIS

### 1. pubspec.yaml
```diff
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  flutter_riverpod: ^2.6.1
  go_router: ^14.6.1
  shared_preferences: ^2.3.3
  intl: ^0.19.0
  equatable: ^2.0.5
  path: ^1.9.0
  image_picker: ^1.1.2
  path_provider: ^2.1.5
+ get_it: ^8.0.3
+ dartz: ^0.10.1
+ logger: ^2.5.0
+ hive: ^2.2.3
+ hive_flutter: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
+ mockito: ^5.4.4
+ build_runner: ^2.4.14
+ import_sorter: ^4.6.0
```

### 2. main.dart
```diff
+import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
-  final sharedPreferences = await SharedPreferences.getInstance();
+  await di.init();
  
+  final sharedPreferences = di.sl<SharedPreferences>();
  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(
          LocalStorageDataSource(sharedPreferences),
        ),
+       sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AppSanitaria(),
    ),
  );
}
```

### 3. AuthProvider (Exemplo)
```diff
class AuthNotifier extends StateNotifier<AuthState> {
-  final LocalStorageDataSource _datasource;
+  final LoginUser _loginUser;
+  final RegisterUser _registerUser;
  
-  AuthNotifier(this._datasource) : super(AuthInitial());
+  AuthNotifier({
+    required LoginUser loginUser,
+    required RegisterUser registerUser,
+  }) : _loginUser = loginUser,
+       _registerUser = registerUser,
+       super(AuthInitial());
  
  Future<void> login(String email, String password) async {
    state = AuthLoading();
    
-    try {
-      // Validação aqui (errado!)
-      final user = await _datasource.login(email, password);
-      state = AuthAuthenticated(user: user);
-    } catch (e) {
-      state = AuthError(message: e.toString());
-    }
+    final result = await _loginUser(LoginParams(email: email, password: password));
+    
+    result.fold(
+      (failure) => state = AuthError(message: failure.message),
+      (user) => state = AuthAuthenticated(user: user),
+    );
  }
}
```

---

## 🤖 SCRIPTS AUXILIARES

### 1. refactor_wave_1.sh
```bash
#!/bin/bash
set -e

echo "🌊 Wave 1: Foundation + Use Cases"

# Adicionar dependências
flutter pub add get_it dartz logger
flutter pub add -d mockito build_runner

# Criar estrutura de pastas
mkdir -p lib/core/error
mkdir -p lib/core/usecases
mkdir -p lib/domain/repositories
mkdir -p lib/domain/usecases/{auth,professionals,contracts,chat,favorites,reviews,profile}

# Copiar templates
cp templates/usecase.dart lib/core/usecases/
cp templates/failures.dart lib/core/error/
cp templates/exceptions.dart lib/core/error/

echo "✅ Wave 1 setup complete"
echo "Next: Implement use cases manually"
```

### 2. run_tests.sh
```bash
#!/bin/bash

echo "🧪 Running all tests..."

# Unit tests
echo "📝 Unit tests..."
flutter test test/domain/
flutter test test/data/

# Widget tests
echo "🎨 Widget tests..."
flutter test test/presentation/widgets/

# Integration tests
echo "🔗 Integration tests..."
flutter test integration_test/

# Coverage
echo "📊 Generating coverage..."
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

echo "✅ All tests passed!"
echo "📊 Coverage report: coverage/html/index.html"
```

### 3. analyze.sh
```bash
#!/bin/bash

echo "🔍 Running analysis..."

# Format check
echo "📝 Checking format..."
dart format --set-exit-if-changed lib/ test/

# Analyze
echo "🔬 Running analyzer..."
flutter analyze --fatal-infos --fatal-warnings

# Metrics
echo "📊 Calculating metrics..."
find lib -name "*.dart" -exec wc -l {} + | sort -n -r | head -20

echo "✅ Analysis complete!"
```

---

## ⚙️ CI/CD PIPELINE (GitHub Actions)

### .github/workflows/ci.yml
```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.5'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Format check
      run: dart format --set-exit-if-changed lib/ test/
    
    - name: Analyze
      run: flutter analyze --fatal-infos --fatal-warnings
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v4
      with:
        files: ./coverage/lcov.info
        
  build_android:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: app-release.apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📋 CHECKLIST FINAL

### Wave 1
- [ ] 15+ use cases criados
- [ ] 7 repository interfaces
- [ ] Base classes (UseCase, Failure)
- [ ] DI setup (get_it)
- [ ] 30+ testes unitários

### Wave 2
- [ ] 7 repository implementations
- [ ] 7 providers migrados
- [ ] DI completo
- [ ] 50+ testes totais

### Wave 3
- [ ] God objects refatorados
- [ ] Todos <300 linhas
- [ ] SRP aplicado

### Wave 4
- [ ] Coverage >70%
- [ ] 0 warnings
- [ ] CI/CD funcional
- [ ] APK <45MB

---

[◀️ Voltar aos Testes](./AUDITORIA_08_TESTES_OBSERVABILIDADE.md) | [Próximo: JSON Summary ▶️](./AUDITORIA_10_RESUMO_JSON.json)

