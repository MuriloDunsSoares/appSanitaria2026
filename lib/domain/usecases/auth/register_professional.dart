/// Use Case: Registrar um novo profissional.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/professional_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use Case para registro de profissional.
///
/// **Responsabilidade única:** Criar conta de profissional.
class RegisterProfessional
    extends UseCase<ProfessionalEntity, ProfessionalEntity> {
  RegisterProfessional(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ProfessionalEntity>> call(
    ProfessionalEntity professional,
  ) async {
    return repository.registerProfessional(professional);
  }
}
