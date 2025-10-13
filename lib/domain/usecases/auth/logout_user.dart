/// Use Case: Deslogar o usuário atual.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

/// Use Case para logout de usuário.
///
/// **Responsabilidade única:** Encerrar sessão.
class LogoutUser extends UseCase<Unit, NoParams> {
  final AuthRepository repository;

  LogoutUser(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.logout();
  }
}




