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
  LogoutUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return repository.logout();
  }
}
