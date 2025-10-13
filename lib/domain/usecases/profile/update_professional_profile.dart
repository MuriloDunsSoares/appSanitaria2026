/// Use Case: Atualizar perfil de profissional.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/professional_entity.dart';
import '../../repositories/profile_repository.dart';

/// Use Case para atualizar perfil de profissional.
class UpdateProfessionalProfile
    extends UseCase<ProfessionalEntity, ProfessionalEntity> {
  UpdateProfessionalProfile(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, ProfessionalEntity>> call(
    ProfessionalEntity professional,
  ) async {
    return repository.updateProfessionalProfile(professional);
  }
}
