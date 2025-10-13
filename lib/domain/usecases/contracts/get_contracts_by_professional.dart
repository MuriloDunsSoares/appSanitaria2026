/// Use Case: Obter contratos de um profissional.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/contract_entity.dart';
import '../../repositories/contracts_repository.dart';

/// Use Case para obter contratos do profissional.
class GetContractsByProfessional extends UseCase<List<ContractEntity>, String> {
  GetContractsByProfessional(this.repository);
  final ContractsRepository repository;

  @override
  Future<Either<Failure, List<ContractEntity>>> call(
    String professionalId,
  ) async {
    return repository.getContractsByProfessional(professionalId);
  }
}

/// Parâmetros para buscar por profissional ID.
class ProfessionalIdParams extends Equatable {
  const ProfessionalIdParams(this.professionalId);
  final String professionalId;

  @override
  List<Object?> get props => [professionalId];
}
