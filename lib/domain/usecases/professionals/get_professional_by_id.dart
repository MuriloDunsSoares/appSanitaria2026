/// Use Case: Obter um profissional por ID.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/professional_entity.dart';
import '../../repositories/professionals_repository.dart';

/// Use Case para obter profissional por ID.
class GetProfessionalById extends UseCase<ProfessionalEntity, String> {
  GetProfessionalById(this.repository);
  final ProfessionalsRepository repository;

  @override
  Future<Either<Failure, ProfessionalEntity>> call(
    String professionalId,
  ) async {
    return repository.getProfessionalById(professionalId);
  }
}

/// Parâmetros para buscar profissional por ID.
class ProfessionalByIdParams extends Equatable {
  const ProfessionalByIdParams(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
