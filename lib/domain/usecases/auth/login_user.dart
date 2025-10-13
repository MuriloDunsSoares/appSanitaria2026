/// Use Case: Autenticar um usuário com email e senha.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use Case para login de usuário.
///
/// **Responsabilidade única:** Autenticar credenciais.
/// **Validações:** Nenhuma (delegadas ao repository).
class LoginUser extends UseCase<UserEntity, LoginParams> {
  LoginUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    print(
        '[LoginUser] Iniciando login... keepLoggedIn = ${params.keepLoggedIn}');

    final result = await repository.login(
      email: params.email,
      password: params.password,
    );

    // Salvar preferência de "manter logado" se login for bem-sucedido
    // IMPORTANTE: Aguardar setKeepLoggedIn() ANTES de retornar!
    await result.fold(
      (failure) async {
        print('[LoginUser] Login falhou: $failure');
      },
      (user) async {
        print(
            '[LoginUser] Login OK! Salvando keepLoggedIn = ${params.keepLoggedIn}');
        await repository.setKeepLoggedIn(params.keepLoggedIn);
        print('[LoginUser] keepLoggedIn salvo com sucesso!');
      },
    );

    return result;
  }
}

/// Parâmetros do Use Case LoginUser.
class LoginParams extends Equatable {
  const LoginParams({
    required this.email,
    required this.password,
    this.keepLoggedIn = false,
  });
  final String email;
  final String password;
  final bool keepLoggedIn;

  @override
  List<Object?> get props => [email, password, keepLoggedIn];
}
