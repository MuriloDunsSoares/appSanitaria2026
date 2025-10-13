# 🌊 PLANO DE REESTRUTURAÇÃO INCREMENTAL - AppSanitaria

**Estratégia:** 4 Waves incrementais  
**Duração Total:** ~4 semanas (part-time)  
**Abordagem:** Teste → Refator → Teste → Deploy

---

## 🎯 OVERVIEW DAS WAVES

| Wave | Foco | Duração | Risco | Arquivos Afetados |
|------|------|---------|-------|-------------------|
| **Wave 1** | Foundation + Use Cases | 1 semana | 🔴 Alto | ~30 arquivos |
| **Wave 2** | Repositories + DI | 1 semana | 🔴 Alto | ~25 arquivos |
| **Wave 3** | God Objects Refactor | 1 semana | 🟡 Médio | ~15 arquivos |
| **Wave 4** | Tests + Performance | 1 semana | 🟢 Baixo | ~50 arquivos |

---

## 🌊 WAVE 1: FOUNDATION + USE CASES LAYER

### 📋 Objetivo
Estabelecer base arquitetural: interfaces de repositories, use cases, error handling e DI container.

### 📅 Duração
5-7 dias (part-time)

### 🎯 Entregas
1. Base classes (UseCase, Failure, Exception)
2. 15+ Use Cases implementados
3. Repository interfaces (7)
4. DI setup (get_it)
5. Testes unitários (30+)

---

### 📝 PASSO 1: Setup Dependencies (Dia 1 - 2h)

```bash
# 1. Adicionar dependências ao pubspec.yaml
flutter pub add get_it dartz logger mockito build_runner

# 2. Adicionar dev_dependencies
flutter pub add -d injectable_generator

# 3. Executar pub get
flutter pub get

# 4. Verificar que tudo compila
flutter analyze
```

#### Atualizar `pubspec.yaml`:
```yaml
dependencies:
  get_it: ^8.0.3
  dartz: ^0.10.1
  logger: ^2.5.0

dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.14
```

**Critério de Pronto:** 
- ✅ `flutter pub get` sem erros
- ✅ `flutter analyze` 0 errors

---

### 📝 PASSO 2: Core Classes (Dia 1-2 - 4h)

#### 2.1 Base UseCase Interface
```bash
mkdir -p lib/core/usecases
touch lib/core/usecases/usecase.dart
```

```dart
// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
```

#### 2.2 Error Handling
```bash
mkdir -p lib/core/error
touch lib/core/error/failures.dart
touch lib/core/error/exceptions.dart
```

```dart
// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Erro no servidor']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Erro ao acessar dados locais']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Sem conexão com internet']) : super(message);
}
```

```dart
// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error']);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}
```

**Critério de Pronto:**
- ✅ 3 arquivos criados
- ✅ Nenhum import error
- ✅ `flutter analyze` passa

---

### 📝 PASSO 3: Repository Interfaces (Dia 2-3 - 6h)

```bash
mkdir -p lib/domain/repositories
touch lib/domain/repositories/auth_repository.dart
touch lib/domain/repositories/professionals_repository.dart
touch lib/domain/repositories/contracts_repository.dart
touch lib/domain/repositories/chat_repository.dart
touch lib/domain/repositories/favorites_repository.dart
touch lib/domain/repositories/reviews_repository.dart
touch lib/domain/repositories/profile_repository.dart
```

#### Exemplo: AuthRepository Interface
```dart
// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, UserEntity>> register(UserEntity user);
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  
  Future<Either<Failure, bool>> isLoggedIn();
}
```

**Repetir para outros 6 repositories** seguindo mesmo pattern.

**Critério de Pronto:**
- ✅ 7 interfaces criadas
- ✅ Todos os métodos retornam `Either<Failure, Type>`
- ✅ Documentação inline presente

---

### 📝 PASSO 4: Use Cases - Auth (Dia 3-4 - 8h)

```bash
mkdir -p lib/domain/usecases/auth
touch lib/domain/usecases/auth/login_user.dart
touch lib/domain/usecases/auth/register_user.dart
touch lib/domain/usecases/auth/logout_user.dart
touch lib/domain/usecases/auth/check_auth_session.dart
```

#### Exemplo completo: LoginUser
```dart
// lib/domain/usecases/auth/login_user.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class LoginUser implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  
  LoginUser(this.repository);
  
  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    // Validação de entrada
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }
    
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure('Email inválido'));
    }
    
    if (params.password.length < 6) {
      return const Left(ValidationFailure('Senha deve ter no mínimo 6 caracteres'));
    }
    
    // Lógica de negócio (delegação para repository)
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;
  
  const LoginParams({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object?> get props => [email, password];
}
```

**Criar outros 3 use cases de auth** seguindo mesmo pattern.

---

### 📝 PASSO 5: Use Cases - Outros Domínios (Dia 4-5 - 10h)

Criar use cases para:
- **Professionals:** `GetAllProfessionals`, `FilterProfessionals`, `GetProfessionalById`
- **Contracts:** `CreateContract`, `GetUserContracts`, `UpdateContractStatus`, `CancelContract`
- **Chat:** `SendMessage`, `GetConversations`, `GetMessages`, `MarkAsRead`
- **Favorites:** `AddFavorite`, `RemoveFavorite`, `GetFavorites`
- **Reviews:** `AddReview`, `GetReviews`, `CalculateAverageRating`
- **Profile:** `UpdateProfile`, `UploadProfileImage`

**Total:** 15+ use cases

---

### 📝 PASSO 6: DI Container Setup (Dia 5 - 3h)

```bash
touch lib/injection_container.dart
```

```dart
// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Use Cases
import 'domain/usecases/auth/login_user.dart';
import 'domain/usecases/auth/register_user.dart';
// ... (importar todos os 15+ use cases)

// Repositories (ainda não implementados, comentar por enquanto)
// import 'data/repositories/auth_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => CheckAuthSession(sl()));
  
  // Repositories (Wave 2)
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(localDataSource: sl()),
  // );
  
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  // TODO: Adicionar outros domínios em Wave 2
}
```

#### Atualizar main.dart:
```dart
// lib/main.dart
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Setup DI
  
  final sharedPreferences = di.sl<SharedPreferences>();
  
  runApp(
    ProviderScope(
      overrides: [
        // Manter overrides existentes por enquanto
      ],
      child: const AppSanitaria(),
    ),
  );
}
```

---

### 📝 PASSO 7: Testes Unitários - Use Cases (Dia 6-7 - 8h)

```bash
mkdir -p test/domain/usecases/auth
touch test/domain/usecases/auth/login_user_test.dart
```

```dart
// test/domain/usecases/auth/login_user_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/domain/repositories/auth_repository.dart';
import 'package:app_sanitaria/domain/usecases/auth/login_user.dart';

import 'login_user_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUser usecase;
  late MockAuthRepository mockAuthRepository;
  
  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUser(mockAuthRepository);
  });
  
  final tEmail = 'test@email.com';
  final tPassword = 'password123';
  final tUser = UserEntity(
    id: '1',
    nome: 'Test User',
    email: tEmail,
    tipo: UserType.paciente,
  );
  
  group('LoginUser', () {
    test('should call repository login with correct params', () async {
      // arrange
      when(mockAuthRepository.login(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => Right(tUser));
      
      // act
      final result = await usecase(LoginParams(email: tEmail, password: tPassword));
      
      // assert
      verify(mockAuthRepository.login(email: tEmail, password: tPassword));
      expect(result, Right(tUser));
    });
    
    test('should return ValidationFailure when email is empty', () async {
      // act
      final result = await usecase(LoginParams(email: '', password: tPassword));
      
      // assert
      expect(result, const Left(ValidationFailure('Email é obrigatório')));
      verifyZeroInteractions(mockAuthRepository);
    });
    
    test('should return ValidationFailure when email is invalid', () async {
      // act
      final result = await usecase(LoginParams(email: 'invalid', password: tPassword));
      
      // assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<ValidationFailure>());
      verifyZeroInteractions(mockAuthRepository);
    });
    
    test('should return ValidationFailure when password is too short', () async {
      // act
      final result = await usecase(LoginParams(email: tEmail, password: '123'));
      
      // assert
      expect(result, const Left(ValidationFailure('Senha deve ter no mínimo 6 caracteres')));
      verifyZeroInteractions(mockAuthRepository);
    });
    
    test('should return CacheFailure when repository fails', () async {
      // arrange
      when(mockAuthRepository.login(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => const Left(CacheFailure()));
      
      // act
      final result = await usecase(LoginParams(email: tEmail, password: tPassword));
      
      // assert
      expect(result, const Left(CacheFailure()));
    });
  });
}
```

**Gerar mocks:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Executar testes:**
```bash
flutter test test/domain/usecases/auth/login_user_test.dart
```

**Criar testes para todos os 15+ use cases** (30+ testes totais).

---

### ✅ CRITÉRIOS DE PRONTO - WAVE 1

- ✅ **Use Cases:** 15+ criados e testados
- ✅ **Repository Interfaces:** 7 criadas
- ✅ **Core Classes:** Failure, Exception, UseCase base
- ✅ **DI Container:** Configurado com get_it
- ✅ **Testes:** 30+ testes unitários passando
- ✅ **Coverage:** >80% em domain/usecases
- ✅ **Analyze:** 0 errors, 0 warnings

**Comandos de verificação:**
```bash
flutter test
flutter analyze
flutter pub run test_coverage
```

### ⚠️ RISCOS - WAVE 1
| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Dependências conflitantes | 🟡 Média | 🔴 Alto | Testar pub get imediatamente |
| Testes lentos | 🟢 Baixa | 🟡 Médio | Usar mocks, evitar I/O |
| Pattern não entendido | 🟡 Média | 🔴 Alto | Documentação inline, exemplos |

---

## 🌊 WAVE 2: REPOSITORIES + MIGRATION

### 📋 Objetivo
Implementar repositories concretos, migrar providers para usar use cases, manter compatibilidade.

### 📅 Duração
5-7 dias

### 📝 PASSO 1: Repository Implementations (Dia 1-3 - 12h)

```bash
mkdir -p lib/data/repositories
touch lib/data/repositories/auth_repository_impl.dart
# ... (criar 7 implementations)
```

```dart
// lib/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_storage_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthStorageDataSource localDataSource;
  
  AuthRepositoryImpl({required this.localDataSource});
  
  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userMap = await localDataSource.login(email, password);
      final user = UserEntity.fromMap(userMap);
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro inesperado: $e'));
    }
  }
  
  // Implementar outros métodos...
}
```

**Criar 7 repository implementations**, uma para cada domínio.

---

### 📝 PASSO 2: Atualizar DI Container (Dia 3 - 2h)

```dart
// lib/injection_container.dart
Future<void> init() async {
  //! Features - Auth
  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  // ...
  
  // Repositories (NOVO!)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  
  // Datasources (usar os SRP que já existem)
  sl.registerLazySingleton<AuthStorageDataSource>(
    () => AuthStorageDataSource(sl()),
  );
  
  // Repetir para todos os domínios...
  
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
```

---

### 📝 PASSO 3: Migrar Providers para Use Cases (Dia 4-6 - 12h)

**Antes (Provider acessa DataSource diretamente):**
```dart
class AuthProvider extends StateNotifier<AuthState> {
  final LocalStorageDataSource _datasource; // ❌ Tight coupling
  
  Future<void> login(String email, String password) async {
    // Validação aqui (❌ deveria estar em Use Case)
    // Lógica aqui (❌ deveria estar em Use Case)
    final user = await _datasource.login(email, password);
    // ...
  }
}
```

**Depois (Provider usa Use Cases):**
```dart
// lib/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/auth/login_user.dart';
import '../../domain/usecases/auth/register_user.dart';
import '../../domain/usecases/auth/logout_user.dart';
import '../../injection_container.dart' as di;

// Provider para injetar use cases
final loginUseCaseProvider = Provider((ref) => di.sl<LoginUser>());
final registerUseCaseProvider = Provider((ref) => di.sl<RegisterUser>());
final logoutUseCaseProvider = Provider((ref) => di.sl<LogoutUser>());

// Provider de estado (refatorado)
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
    if (failure is ValidationFailure) return failure.message;
    if (failure is CacheFailure) return 'Erro ao acessar dados';
    if (failure is ServerFailure) return 'Erro no servidor';
    return 'Erro inesperado';
  }
  
  // Outros métodos...
}
```

**Migrar todos os 7 providers** seguindo este pattern.

---

### ✅ CRITÉRIOS DE PRONTO - WAVE 2
- ✅ **Repositories:** 7 implementations criadas
- ✅ **Providers:** 7 migrados para use cases
- ✅ **DI:** Completo e funcional
- ✅ **Testes:** 50+ (repositories + integration)
- ✅ **App funcional:** Todas features funcionando
- ✅ **Analyze:** 0 errors

---

## 🌊 WAVE 3: GOD OBJECTS REFACTORING

### 📋 Objetivo
Quebrar God Objects em componentes <300 linhas, aplicar SRP.

### 📅 Duração
5-7 dias

### 🎯 God Objects para Refatorar
1. `home_patient_screen.dart` (671 → 3 arquivos)
2. `hiring_screen.dart` (611 → 2 arquivos)
3. `home_professional_screen.dart` (597 → 3 arquivos)
4. `local_storage_datasource.dart` (853 → **DELETAR**, já tem SRP datasources)

### 📝 Exemplo: Refatorar HomePatientScreen

**Antes:** 1 arquivo, 671 linhas

**Depois:** 3 arquivos, ~250 linhas cada

```bash
mkdir -p lib/presentation/screens/home
touch lib/presentation/screens/home/home_patient_screen.dart
touch lib/presentation/screens/home/widgets/specialty_cards_section.dart
touch lib/presentation/screens/home/widgets/search_section.dart
```

```dart
// lib/presentation/screens/home/home_patient_screen.dart (~200 linhas)
class HomePatientScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Profissionais')),
      body: Column(
        children: [
          const SearchSection(), // ✅ Extraído
          const SpecialtyCardsSection(), // ✅ Extraído
        ],
      ),
      bottomNavigationBar: const PatientBottomNav(),
    );
  }
}

// lib/presentation/screens/home/widgets/specialty_cards_section.dart (~150 linhas)
class SpecialtyCardsSection extends StatelessWidget {
  // Lógica dos 4 cards de especialidades
}

// lib/presentation/screens/home/widgets/search_section.dart (~100 linhas)
class SearchSection extends StatefulWidget {
  // Lógica da busca com debounce
}
```

**Repetir para outros God Objects.**

---

### ✅ CRITÉRIOS DE PRONTO - WAVE 3
- ✅ **God Objects:** 0 (todos <300 linhas)
- ✅ **SRP:** Aplicado em todos os arquivos
- ✅ **Testes:** Mantidos e passando
- ✅ **Analyze:** 0 errors

---

## 🌊 WAVE 4: TESTS + PERFORMANCE

### 📋 Objetivo
Atingir 70% coverage, otimizar performance, polish final.

### 📅 Duração
5-7 dias

### 📝 Tarefas
1. **Testes Unitários:** 100+ (todos use cases, repositories, utils)
2. **Testes de Widget:** 30+ (todos widgets isolados)
3. **Testes de Integração:** 10+ (fluxos end-to-end)
4. **Performance:** Lazy loading, const optimization, caching
5. **CI/CD:** GitHub Actions pipeline
6. **Lints:** Resolver 13 warnings

### ✅ CRITÉRIOS DE PRONTO - WAVE 4
- ✅ **Coverage:** >70%
- ✅ **Warnings:** 0
- ✅ **APK Size:** <45 MB
- ✅ **Cold Start:** <200ms
- ✅ **CI/CD:** Pipeline funcional

---

## 🚀 COMANDOS FINAIS DE VALIDAÇÃO

```bash
# 1. Análise estática
flutter analyze

# 2. Formatação
flutter format lib/ test/

# 3. Testes completos
flutter test --coverage

# 4. Gerar relatório de coverage
genhtml coverage/lcov.info -o coverage/html

# 5. Build release
flutter build apk --release

# 6. Verificar tamanho
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

[◀️ Voltar à Arquitetura](./AUDITORIA_03_ARQUITETURA_PROPOSTA.md) | [Próximo: Qualidade e Estilo ▶️](./AUDITORIA_05_QUALIDADE_ESTILO.md)

