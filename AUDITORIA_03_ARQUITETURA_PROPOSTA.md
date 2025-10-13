# 🏗️ ARQUITETURA PROPOSTA - AppSanitaria

**Data:** 7 de Outubro, 2025  
**Pattern:** Clean Architecture (Robert C. Martin)  
**State Management:** Riverpod 2.6.1  
**Dependency Injection:** get_it 8.0.3

---

## 🎯 VISÃO GERAL

### Clean Architecture em Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Screens    │  │   Widgets    │  │  Providers   │     │
│  │  (18 telas)  │  │(9 components)│  │ (Riverpod)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│           ↓                ↓                   ↓             │
└───────────────────────────────────────────────────────────┘
            ↓ Apenas Use Cases (Dependency Injection)
┌─────────────────────────────────────────────────────────────┐
│                       DOMAIN                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Use Cases   │  │   Entities   │  │ Repositories │     │
│  │    (15+)     │  │     (7)      │  │ (interfaces) │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│           ↓                                   ↓              │
└───────────────────────────────────────────────────────────┘
            ↓ Apenas interfaces (Dependency Rule)
┌─────────────────────────────────────────────────────────────┐
│                         DATA                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Repositories │  │  Datasources │  │   Services   │     │
│  │   (impl)     │  │   (7 SRP)    │  │   (image)    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│           ↓                ↓                   ↓             │
└───────────────────────────────────────────────────────────┘
            ↓ Frameworks & External APIs
┌─────────────────────────────────────────────────────────────┐
│                      INFRASTRUCTURE                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ SharedPrefs  │  │   Firebase   │  │     HTTP     │     │
│  │    (local)   │  │   (cloud)    │  │    (API)     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└───────────────────────────────────────────────────────────┘
```

### Dependency Rule

**Regra de Ouro:** Dependências apontam APENAS para dentro.

- ✅ Presentation → Domain (via Use Cases)
- ✅ Data → Domain (implementa interfaces)
- ❌ Domain → Data (NUNCA!)
- ❌ Domain → Presentation (NUNCA!)

---

## 📂 ESTRUTURA DE PASTAS FINAL

```
lib/
├── core/                               # Shared utilities
│   ├── constants/
│   │   ├── app_constants.dart          # Global constants
│   │   └── app_theme.dart              # Design system
│   ├── error/
│   │   ├── failures.dart               # Base failure class
│   │   └── exceptions.dart             # Custom exceptions
│   ├── network/
│   │   └── network_info.dart           # Connectivity checker
│   ├── routes/
│   │   └── app_router.dart             # Navigation (GoRouter)
│   ├── usecases/
│   │   └── usecase.dart                # Base UseCase interface
│   └── utils/
│       ├── app_logger.dart             # Logging
│       ├── validators.dart             # Input validation
│       └── formatters.dart             # Text formatting
│
├── domain/                             # Business Logic Layer
│   ├── entities/
│   │   ├── user_entity.dart            # ✅ Existing
│   │   ├── patient_entity.dart         # ✅ Existing
│   │   ├── professional_entity.dart    # ✅ Existing
│   │   ├── contract_entity.dart        # ✅ Existing
│   │   ├── message_entity.dart         # ✅ Existing
│   │   ├── conversation_entity.dart    # ✅ Existing
│   │   └── review_entity.dart          # ✅ Existing
│   │
│   ├── repositories/                   # Abstract interfaces
│   │   ├── auth_repository.dart        # 🆕 Interface
│   │   ├── professionals_repository.dart # 🆕 NEW
│   │   ├── contracts_repository.dart   # 🆕 NEW
│   │   ├── chat_repository.dart        # 🆕 NEW
│   │   ├── favorites_repository.dart   # 🆕 NEW
│   │   ├── reviews_repository.dart     # 🆕 NEW
│   │   └── profile_repository.dart     # 🆕 NEW
│   │
│   └── usecases/                       # 🆕 NEW LAYER
│       ├── auth/
│       │   ├── login_user.dart
│       │   ├── register_user.dart
│       │   ├── logout_user.dart
│       │   └── check_auth_session.dart
│       ├── professionals/
│       │   ├── get_all_professionals.dart
│       │   ├── filter_professionals.dart
│       │   ├── search_professionals.dart
│       │   └── get_professional_by_id.dart
│       ├── contracts/
│       │   ├── create_contract.dart
│       │   ├── get_user_contracts.dart
│       │   ├── update_contract_status.dart
│       │   └── cancel_contract.dart
│       ├── chat/
│       │   ├── send_message.dart
│       │   ├── get_conversations.dart
│       │   ├── get_messages.dart
│       │   └── mark_messages_as_read.dart
│       ├── favorites/
│       │   ├── add_favorite.dart
│       │   ├── remove_favorite.dart
│       │   └── get_favorites.dart
│       ├── reviews/
│       │   ├── add_review.dart
│       │   ├── get_professional_reviews.dart
│       │   └── calculate_average_rating.dart
│       └── profile/
│           ├── update_profile.dart
│           ├── upload_profile_image.dart
│           └── get_user_profile.dart
│
├── data/                               # Data Layer
│   ├── models/                         # 🆕 NEW (DTOs)
│   │   ├── user_model.dart             # UserEntity + JSON
│   │   ├── contract_model.dart
│   │   ├── message_model.dart
│   │   └── ... (7 models)
│   │
│   ├── repositories/                   # Implementations
│   │   ├── auth_repository_impl.dart   # ♻️ Refactor existing
│   │   ├── professionals_repository_impl.dart # 🆕 NEW
│   │   ├── contracts_repository_impl.dart # 🆕 NEW
│   │   ├── chat_repository_impl.dart   # 🆕 NEW
│   │   ├── favorites_repository_impl.dart # 🆕 NEW
│   │   ├── reviews_repository_impl.dart # 🆕 NEW
│   │   └── profile_repository_impl.dart # 🆕 NEW
│   │
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── auth_local_datasource.dart    # ✅ Existing (migrate)
│   │   │   ├── contracts_local_datasource.dart # ✅ Existing
│   │   │   ├── reviews_local_datasource.dart  # ✅ Existing
│   │   │   ├── chat_local_datasource.dart     # ✅ Existing
│   │   │   ├── favorites_local_datasource.dart # ✅ Existing
│   │   │   ├── users_local_datasource.dart    # ♻️ From .wip
│   │   │   └── profile_local_datasource.dart  # ♻️ From .wip
│   │   │
│   │   └── remote/ (futuro)
│   │       ├── auth_remote_datasource.dart    # 🔮 Future (Firebase)
│   │       ├── professionals_remote_datasource.dart
│   │       └── ... (quando migrar para backend)
│   │
│   └── services/
│       ├── image_picker_service.dart   # ✅ Existing
│       ├── cache_service.dart          # 🆕 NEW
│       └── notification_service.dart   # 🆕 NEW (futuro)
│
├── presentation/                       # Presentation Layer
│   ├── providers/
│   │   ├── auth_provider.dart          # ♻️ Refactor (use Use Cases)
│   │   ├── professionals_provider.dart # ♻️ Refactor
│   │   ├── contracts_provider.dart     # ♻️ Refactor
│   │   ├── chat_provider.dart          # ♻️ Refactor
│   │   ├── favorites_provider.dart     # ♻️ Refactor
│   │   ├── reviews_provider.dart       # ♻️ Refactor
│   │   └── profile_provider.dart       # 🆕 NEW
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart       # ♻️ Refactor (<300 lines)
│   │   │   ├── selection_screen.dart
│   │   │   ├── patient_registration_screen.dart
│   │   │   └── professional_registration_screen.dart
│   │   ├── home/
│   │   │   ├── home_patient_screen.dart # ♻️ Split (671 → 3 files)
│   │   │   ├── home_professional_screen.dart # ♻️ Split
│   │   │   ├── specialty_cards_section.dart # 🆕 Extracted
│   │   │   └── stats_cards_section.dart # 🆕 Extracted
│   │   ├── professionals/
│   │   │   ├── professionals_list_screen.dart
│   │   │   ├── professional_profile_screen.dart
│   │   │   └── filters_bottom_sheet.dart # 🆕 Extracted
│   │   ├── chat/
│   │   │   ├── conversations_screen.dart
│   │   │   └── individual_chat_screen.dart
│   │   ├── contracts/
│   │   │   ├── hiring_screen.dart      # ♻️ Split (611 → 2 files)
│   │   │   ├── hiring_form_section.dart # 🆕 Extracted
│   │   │   ├── contracts_screen.dart
│   │   │   └── contract_detail_screen.dart
│   │   ├── favorites/
│   │   │   └── favorites_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   └── reviews/
│   │       └── add_review_screen.dart
│   │
│   └── widgets/
│       ├── common/
│       │   ├── custom_button.dart      # 🆕 NEW
│       │   ├── custom_text_field.dart  # 🆕 NEW
│       │   ├── loading_indicator.dart  # 🆕 NEW
│       │   └── error_widget.dart       # 🆕 NEW
│       ├── navigation/
│       │   ├── patient_bottom_nav.dart # ✅ Existing
│       │   └── professional_floating_buttons.dart
│       ├── cards/
│       │   ├── professional_card.dart  # ✅ Existing
│       │   ├── conversation_card.dart
│       │   ├── contract_card.dart
│       │   └── review_card.dart
│       └── specialized/
│           ├── message_bubble.dart
│           ├── rating_stars.dart
│           └── profile_image_picker.dart
│
├── injection_container.dart            # 🆕 NEW (get_it setup)
└── main.dart                           # ♻️ Refactor (DI setup)
```

---

## 🔧 PADRÕES APLICADOS

### 1. **Repository Pattern** (Completo)

```dart
// domain/repositories/auth_repository.dart (Interface)
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(UserEntity user);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getAuthSession();
}

// data/repositories/auth_repository_impl.dart (Implementation)
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource; // futuro
  final NetworkInfo _networkInfo;
  
  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      // Try remote first (when implemented)
      if (await _networkInfo.isConnected) {
        final userModel = await _remoteDataSource.login(email, password);
        await _localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      }
      // Fallback to local
      final userModel = await _localDataSource.login(email, password);
      return Right(userModel.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
```

---

### 2. **Use Case Pattern** (Novo)

```dart
// core/usecases/usecase.dart (Base interface)
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

// domain/usecases/auth/login_user.dart
class LoginUser implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  
  LoginUser(this.repository);
  
  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    // Validação
    if (params.email.isEmpty || params.password.isEmpty) {
      return Left(ValidationFailure('Email e senha são obrigatórios'));
    }
    
    // Lógica de negócio
    if (params.password.length < 6) {
      return Left(ValidationFailure('Senha deve ter no mínimo 6 caracteres'));
    }
    
    // Delegação para repository
    return await repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  
  const LoginParams({required this.email, required this.password});
  
  @override
  List<Object?> get props => [email, password];
}
```

---

### 3. **Dependency Injection** (get_it)

```dart
// injection_container.dart
final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  //! Features - Auth
  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Datasources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  //! Features - Professionals (repeat pattern)
  //! Features - Contracts (repeat pattern)
  //! ... (all features)
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init(); // Setup DI
  runApp(const MyApp());
}
```

---

### 4. **State Management** (Riverpod - mantido)

```dart
// presentation/providers/auth_provider.dart
final loginUseCaseProvider = Provider((ref) => sl<LoginUser>());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUser: ref.watch(loginUseCaseProvider),
    registerUser: ref.watch(registerUseCaseProvider),
    logoutUser: ref.watch(logoutUseCaseProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final LogoutUser _logoutUser;
  
  AuthNotifier({
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required LogoutUser logoutUser,
  }) : _loginUser = loginUser,
       _registerUser = registerUser,
       _logoutUser = logoutUser,
       super(AuthInitial());
  
  Future<void> login(String email, String password) async {
    state = AuthLoading();
    
    final result = await _loginUser(LoginParams(email: email, password: password));
    
    result.fold(
      (failure) => state = AuthError(message: _mapFailureToMessage(failure)),
      (user) => state = AuthAuthenticated(user: user),
    );
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Erro no servidor';
      case CacheFailure:
        return 'Erro ao carregar dados locais';
      case ValidationFailure:
        return (failure as ValidationFailure).message;
      default:
        return 'Erro inesperado';
    }
  }
}
```

---

## 🌐 NAVEGAÇÃO (GoRouter - mantido)

```dart
// core/routes/app_router.dart (refatorado)
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState is AuthAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/';
      
      if (!isAuthenticated && !isGoingToLogin) {
        return '/'; // Force login
      }
      
      if (isAuthenticated && isGoingToLogin) {
        final userType = authState.user.type;
        return userType == UserType.paciente 
          ? '/home/patient' 
          : '/home/professional';
      }
      
      return null; // No redirect
    },
    routes: [
      // Auth routes (public)
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/selection', builder: (context, state) => const SelectionScreen()),
      
      // Patient routes (protected)
      GoRoute(path: '/home/patient', builder: (context, state) => const HomePatientScreen()),
      
      // ... (15 rotas totais)
    ],
  );
});
```

---

## 🎨 TEMA E LOCALIZAÇÃO

### Design System (mantido)
```dart
// core/constants/app_theme.dart (otimizado, <400 linhas)
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: _textTheme,
    appBarTheme: _appBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    // ... (componentes específicos)
  );
  
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: Color(0xFF667EEA),
    secondary: Color(0xFF2196F3),
    // ...
  );
}
```

### Localização (novo)
```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true # Enable l10n codegen
```

```yaml
# l10n.yaml (novo)
arb-dir: lib/l10n
template-arb-file: app_pt.arb
output-localization-file: app_localizations.dart
```

```json
// lib/l10n/app_pt.arb
{
  "@@locale": "pt",
  "loginTitle": "Entrar",
  "email": "E-mail",
  "password": "Senha",
  "login": "Entrar"
}
```

---

## 📦 DEPENDÊNCIAS ATUALIZADAS

```yaml
# pubspec.yaml (proposto)
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.6.1          # ✅ Mantido
  
  # Navigation
  go_router: ^14.6.1                # ✅ Mantido
  
  # DI
  get_it: ^8.0.3                    # 🆕 NOVO
  injectable: ^2.6.2                # 🆕 NOVO (codegen)
  
  # Functional Programming
  dartz: ^0.10.1                    # 🆕 Either<L, R>
  equatable: ^2.0.5                 # ✅ Mantido
  
  # Local Storage
  shared_preferences: ^2.3.3        # ✅ Mantido
  hive: ^2.2.3                      # 🆕 NOVO (cache)
  hive_flutter: ^1.1.0              # 🆕 NOVO
  
  # Remote (futuro)
  # dio: ^5.7.0                     # 🔮 HTTP client
  # firebase_core: ^3.10.0          # 🔮 Firebase
  # firebase_auth: ^5.5.0           # 🔮 Auth
  # cloud_firestore: ^5.7.0         # 🔮 Database
  
  # Utils
  intl: ^0.19.0                     # ✅ Mantido
  path: ^1.9.0                      # ✅ Mantido
  image_picker: ^1.1.2              # ✅ Mantido
  path_provider: ^2.1.5             # ✅ Mantido
  
  # Logging & Monitoring
  logger: ^2.5.0                    # 🆕 NOVO (melhor que custom)
  # sentry_flutter: ^8.14.0         # 🔮 Error tracking

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Linting
  flutter_lints: ^5.0.0             # ✅ Mantido
  
  # Testing
  mockito: ^5.4.4                   # 🆕 NOVO (mocks)
  build_runner: ^2.4.14             # 🆕 NOVO (codegen)
  
  # Code Generation
  injectable_generator: ^2.6.2      # 🆕 NOVO (DI codegen)
  hive_generator: ^2.0.1            # 🆕 NOVO (cache models)
```

**Adicionadas:** 8 dependências  
**Removidas:** 0 dependências  
**Futuras:** 5 dependências (Firebase/API)

---

[◀️ Voltar ao Diagnóstico](./AUDITORIA_02_DIAGNOSTICO.md) | [Próximo: Plano de Refatoração ▶️](./AUDITORIA_04_PLANO_REFATORACAO.md)

