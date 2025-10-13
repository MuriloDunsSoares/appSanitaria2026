/// AuthProvider migrado para Clean Architecture com Use Cases.
library;

import 'package:app_sanitaria/core/di/injection_container.dart';
import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/core/usecases/usecase.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/domain/usecases/auth/check_authentication.dart';
import 'package:app_sanitaria/domain/usecases/auth/get_current_user.dart';
import 'package:app_sanitaria/domain/usecases/auth/login_user.dart';
import 'package:app_sanitaria/domain/usecases/auth/logout_user.dart';
import 'package:app_sanitaria/domain/usecases/auth/register_patient.dart';
import 'package:app_sanitaria/domain/usecases/auth/register_professional.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado de Autenticação (Clean Architecture)
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// State da Autenticação (Clean Architecture)
class AuthState {
  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(UserEntity user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }
  factory AuthState.unauthenticated() {
    return AuthState(status: AuthStatus.unauthenticated);
  }
  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, errorMessage: message);
  }
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  UserType? get userType => user?.tipo;
  String? get userId => user?.id;
  String? get userName => user?.nome;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// AuthNotifier V2 - Clean Architecture com Use Cases
class AuthNotifierV2 extends StateNotifier<AuthState> {
  AuthNotifierV2({
    required CheckAuthentication checkAuthentication,
    required GetCurrentUser getCurrentUser,
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required RegisterPatient registerPatient,
    required RegisterProfessional registerProfessional,
  })  : _checkAuthentication = checkAuthentication,
        _getCurrentUser = getCurrentUser,
        _loginUser = loginUser,
        _logoutUser = logoutUser,
        _registerPatient = registerPatient,
        _registerProfessional = registerProfessional,
        super(AuthState.initial()) {
    // ✅ OTIMIZAÇÃO: NÃO verifica sessão aqui para evitar bloquear UI
    // A verificação será feita após o primeiro frame (lazy initialization)
  }

  /// Inicializa verificação de sessão (deve ser chamado após primeiro frame)
  void initializeSession() {
    _checkSession();
  }

  final CheckAuthentication _checkAuthentication;
  final GetCurrentUser _getCurrentUser;
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RegisterPatient _registerPatient;
  final RegisterProfessional _registerProfessional;

  /// Verifica sessão existente
  Future<void> _checkSession() async {
    print('[AuthProvider] _checkSession() iniciado...');

    final result = await _checkAuthentication.call(NoParams());

    result.fold(
      (failure) {
        print('[AuthProvider] CheckAuthentication falhou: $failure');
        state = AuthState.unauthenticated();
      },
      (isAuthenticated) async {
        print('[AuthProvider] isAuthenticated = $isAuthenticated');

        if (isAuthenticated) {
          print('[AuthProvider] Carregando usuário...');
          final userResult = await _getCurrentUser.call(NoParams());
          userResult.fold(
            (failure) {
              print('[AuthProvider] GetCurrentUser falhou: $failure');
              state = AuthState.unauthenticated();
            },
            (user) {
              print('[AuthProvider] Usuário carregado: ${user.email}');
              state = AuthState.authenticated(user);
            },
          );
        } else {
          print('[AuthProvider] Não está autenticado → unauthenticated');
          state = AuthState.unauthenticated();
        }
      },
    );

    print('[AuthProvider] _checkSession() finalizado. Estado: ${state.status}');
  }

  /// Realiza login
  Future<void> login({
    required String email,
    required String password,
    bool keepLoggedIn = false,
  }) async {
    state = AuthState.loading();

    final result = await _loginUser.call(LoginParams(
      email: email,
      password: password,
      keepLoggedIn: keepLoggedIn,
    ));

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        state = AuthState.error(message);
        _resetErrorAfterDelay();
      },
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Registra paciente
  Future<void> registerPatient(PatientEntity patient) async {
    state = AuthState.loading();

    final result = await _registerPatient.call(patient);

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        state = AuthState.error(message);
        _resetErrorAfterDelay();
      },
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Registra profissional
  Future<void> registerProfessional(ProfessionalEntity professional) async {
    state = AuthState.loading();

    final result = await _registerProfessional.call(professional);

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        state = AuthState.error(message);
        _resetErrorAfterDelay();
      },
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Realiza logout
  Future<void> logout() async {
    await _logoutUser.call(NoParams());
    state = AuthState.unauthenticated();
  }

  /// Atualiza dados do usuário
  void updateUser(UserEntity updatedUser) {
    if (state.isAuthenticated) {
      state = AuthState.authenticated(updatedUser);
    }
  }

  /// Reseta erro após delay
  void _resetErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = AuthState.unauthenticated();
      }
    });
  }

  /// Mapeia Failure para mensagem
  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ValidationFailure() => 'Dados inválidos. Verifique as informações.',
      NotFoundFailure() => 'Usuário não encontrado. Verifique o email.',
      InvalidCredentialsFailure() =>
        'Email ou senha incorretos. Tente novamente.',
      UserNotFoundFailure() =>
        'Conta não encontrada. Você precisa se cadastrar primeiro.',
      EmailAlreadyExistsFailure() =>
        'Este email já está cadastrado. Faça login.',
      SessionExpiredFailure() => 'Sua sessão expirou. Faça login novamente.',
      StorageFailure() =>
        'Erro ao conectar com o servidor. Verifique sua internet e tente novamente.',
      NetworkFailure(:final message) =>
        message.isEmpty
            ? 'Sem conexão com a internet. Conecte-se e tente novamente.'
            : message,
      _ =>
        'Erro inesperado. Tente novamente ou entre em contato com o suporte.',
    };
  }
}

/// Provider para AuthNotifierV2 (Clean Architecture)
final authProviderV2 = StateNotifierProvider<AuthNotifierV2, AuthState>((ref) {
  final notifier = AuthNotifierV2(
    checkAuthentication: getIt<CheckAuthentication>(),
    getCurrentUser: getIt<GetCurrentUser>(),
    loginUser: getIt<LoginUser>(),
    logoutUser: getIt<LogoutUser>(),
    registerPatient: getIt<RegisterPatient>(),
    registerProfessional: getIt<RegisterProfessional>(),
  );

  // ✅ OTIMIZAÇÃO: Verifica sessão APÓS o primeiro frame para não bloquear UI
  Future.microtask(() {
    notifier.initializeSession();
  });

  return notifier;
});

/// Providers auxiliares
final isAuthenticatedProviderV2 = Provider<bool>((ref) {
  return ref.watch(authProviderV2).isAuthenticated;
});

final userTypeProviderV2 = Provider<UserType?>((ref) {
  return ref.watch(authProviderV2).userType;
});

final userIdProviderV2 = Provider<String?>((ref) {
  return ref.watch(authProviderV2).userId;
});

final userNameProviderV2 = Provider<String?>((ref) {
  return ref.watch(authProviderV2).userName;
});
