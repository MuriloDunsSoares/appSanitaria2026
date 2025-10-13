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
  final ProfessionalsRepository repository;

  GetProfessionalsByIds(this.repository);

  @override
  Future<Either<Failure, List<ProfessionalEntity>>> call(
    GetProfessionalsByIdsParams params,
  ) async {
    return await repository.getProfessionalsByIds(params.ids);
  }
}

/// Parâmetros para buscar múltiplos profissionais por IDs.
class GetProfessionalsByIdsParams extends Equatable {
  final List<String> ids;

  const GetProfessionalsByIdsParams(this.ids);

  @override
  List<Object?> get props => [ids];
}

