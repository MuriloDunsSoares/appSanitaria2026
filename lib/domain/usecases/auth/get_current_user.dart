/// Use Case: Obter o usuário autenticado atualmente.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use Case para obter usuário atual.
///
/// **Responsabilidade única:** Retornar usuário autenticado.
class GetCurrentUser extends UseCase<UserEntity, NoParams> {
  GetCurrentUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return repository.getCurrentUser();
  }
}
