# 📝 EXEMPLOS END-TO-END - AppSanitaria

**Data:** 7 de Outubro, 2025  
**Padrão:** Clean Architecture completo

---

## 🎯 EXEMPLO 1: FEATURE COMPLETA - AUTENTICAÇÃO

### 1.1 Entity (Domain Layer)
```dart
// lib/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

enum UserType { paciente, profissional }

class UserEntity extends Equatable {
  final String id;
  final String nome;
  final String email;
  final UserType tipo;
  
  const UserEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
  });
  
  @override
  List<Object?> get props => [id, nome, email, tipo];
}
```

### 1.2 Repository Interface (Domain Layer)
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
}
```

### 1.3 Use Case (Domain Layer)
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
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('Email é obrigatório'));
    }
    
    if (params.password.length < 6) {
      return const Left(ValidationFailure('Senha muito curta'));
    }
    
    return await repository.login(
      email: params.email,
      password: params.password,
    );
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

### 1.4 Data Model (Data Layer)
```dart
// lib/data/models/user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.nome,
    required super.email,
    required super.tipo,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      tipo: json['tipo'] == 'Paciente' 
        ? UserType.paciente 
        : UserType.profissional,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo': tipo == UserType.paciente ? 'Paciente' : 'Profissional',
    };
  }
}
```

### 1.5 Datasource (Data Layer)
```dart
// lib/data/datasources/local/auth_local_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> cacheUser(UserModel user);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  AuthLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<UserModel> login(String email, String password) async {
    final usersJson = sharedPreferences.getString('appSanitaria_hostList');
    if (usersJson == null) {
      throw CacheException('No users found');
    }
    
    final usersMap = jsonDecode(usersJson) as Map<String, dynamic>;
    
    for (var userJson in usersMap.values) {
      if (userJson['email'] == email && userJson['senha'] == password) {
        return UserModel.fromJson(userJson);
      }
    }
    
    throw CacheException('Invalid credentials');
  }
  
  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(
      'appSanitaria_userData',
      jsonEncode(user.toJson()),
    );
  }
}
```

### 1.6 Repository Implementation (Data Layer)
```dart
// lib/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({required this.localDataSource});
  
  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await localDataSource.login(email, password);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
```

### 1.7 Provider (Presentation Layer)
```dart
// lib/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/login_user.dart';
import '../../injection_container.dart' as di;

final loginUseCaseProvider = Provider((ref) => di.sl<LoginUser>());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(loginUser: ref.watch(loginUseCaseProvider));
});

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated({required this.user});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;
  
  AuthNotifier({required LoginUser loginUser})
      : _loginUser = loginUser,
        super(AuthInitial());
  
  Future<void> login(String email, String password) async {
    state = AuthLoading();
    
    final result = await _loginUser(LoginParams(email: email, password: password));
    
    result.fold(
      (failure) => state = AuthError(message: failure.message),
      (user) => state = AuthAuthenticated(user: user),
    );
  }
}
```

### 1.8 Screen (Presentation Layer)
```dart
// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 24),
            if (authState is AuthLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).login(
                    _emailController.text,
                    _passwordController.text,
                  );
                },
                child: const Text('Entrar'),
              ),
            if (authState is AuthError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  authState.message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 1.9 Teste Unitário (Use Case)
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
  late MockAuthRepository mockRepo;
  
  setUp(() {
    mockRepo = MockAuthRepository();
    usecase = LoginUser(mockRepo);
  });
  
  const tEmail = 'test@email.com';
  const tPassword = 'password123';
  const tUser = UserEntity(
    id: '1',
    nome: 'Test',
    email: tEmail,
    tipo: UserType.paciente,
  );
  
  test('should return user when credentials are valid', () async {
    // arrange
    when(mockRepo.login(email: anyNamed('email'), password: anyNamed('password')))
        .thenAnswer((_) async => const Right(tUser));
    
    // act
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));
    
    // assert
    expect(result, const Right(tUser));
    verify(mockRepo.login(email: tEmail, password: tPassword));
  });
  
  test('should return ValidationFailure when email is empty', () async {
    // act
    final result = await usecase(const LoginParams(email: '', password: tPassword));
    
    // assert
    expect(result, const Left(ValidationFailure('Email é obrigatório')));
    verifyZeroInteractions(mockRepo);
  });
}
```

---

## 🎯 EXEMPLO 2: FEATURE CONTRACTS (Resumido)

**Entity:** `ContractEntity`  
**Use Case:** `CreateContract`  
**Repository:** `ContractsRepository`  
**Datasource:** `ContractsLocalDataSource`  
**Provider:** `ContractsProvider`  
**Screen:** `HiringScreen`

*Segue mesmo padrão do Exemplo 1.*

---

## 🎯 EXEMPLO 3: FEATURE REVIEWS (Resumido)

**Entity:** `ReviewEntity`  
**Use Case:** `AddReview`, `GetReviews`, `CalculateAverageRating`  
**Repository:** `ReviewsRepository`  
**Datasource:** `ReviewsLocalDataSource`  
**Provider:** `ReviewsProvider`  
**Screen:** `AddReviewScreen`

*Segue mesmo padrão do Exemplo 1.*

---

[◀️ Voltar à Qualidade](./AUDITORIA_05_QUALIDADE_ESTILO.md) | [Próximo: Performance ▶️](./AUDITORIA_07_PERFORMANCE.md)

