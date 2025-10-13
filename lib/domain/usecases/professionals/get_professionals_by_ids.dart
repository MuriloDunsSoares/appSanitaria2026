/// Use Case: Obter múltiplos profissionais por IDs.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/professional_entity.dart';
import '../../repositories/professionals_repository.dart';

/// Use Case para obter múltiplos profissionais por IDs.
/// Útil para carregar profissionais favoritos.
class GetProfessionalsByIds
    extends UseCase<List<ProfessionalEntity>, GetProfessionalsByIdsParams> {
  GetProfessionalsByIds(this.repository);
  final ProfessionalsRepository repository;

  @override
  Future<Either<Failure, List<ProfessionalEntity>>> call(
    GetProfessionalsByIdsParams params,
  ) async {
    return repository.getProfessionalsByIds(params.ids);
  }
}

/// Parâmetros para buscar múltiplos profissionais por IDs.
class GetProfessionalsByIdsParams extends Equatable {
  const GetProfessionalsByIdsParams(this.ids);
  final List<String> ids;

  @override
  List<Object?> get props => [ids];
}
