/// Use Case: Verificar se há usuário autenticado.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

/// Use Case para verificar autenticação.
///
/// **Responsabilidade única:** Validar se há sessão ativa.
class CheckAuthentication extends UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckAuthentication(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}




