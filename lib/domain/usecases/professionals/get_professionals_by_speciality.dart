/// Use Case: Obter profissionais de uma especialidade.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/professional_entity.dart';
import '../../entities/speciality.dart';
import '../../repositories/professionals_repository.dart';

/// Use Case para obter profissionais por especialidade.
class GetProfessionalsBySpeciality
    extends UseCase<List<ProfessionalEntity>, Speciality> {
  GetProfessionalsBySpeciality(this.repository);
  final ProfessionalsRepository repository;

  @override
  Future<Either<Failure, List<ProfessionalEntity>>> call(
    Speciality speciality,
  ) async {
    return repository.getProfessionalsBySpeciality(speciality);
  }
}

/// Parâmetros para buscar por especialidade.
class ProfessionalsBySpecialityParams extends Equatable {
  const ProfessionalsBySpecialityParams(this.speciality);
  final Speciality speciality;

  @override
  List<Object?> get props => [speciality];
}
