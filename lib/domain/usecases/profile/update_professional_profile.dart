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
  final ProfileRepository repository;

  UpdateProfessionalProfile(this.repository);

  @override
  Future<Either<Failure, ProfessionalEntity>> call(
    ProfessionalEntity professional,
  ) async {
    return await repository.updateProfessionalProfile(professional);
  }
}




