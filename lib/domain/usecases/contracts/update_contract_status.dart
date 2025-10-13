/// Use Case: Atualizar status de um contrato.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/contract_entity.dart';
import '../../entities/contract_status.dart';
import '../../repositories/contracts_repository.dart';

/// Use Case para atualizar status do contrato.
class UpdateContractStatus
    extends UseCase<ContractEntity, UpdateContractStatusParams> {
  UpdateContractStatus(this.repository);
  final ContractsRepository repository;

  @override
  Future<Either<Failure, ContractEntity>> call(
    UpdateContractStatusParams params,
  ) async {
    return repository.updateContractStatus(
      params.contractId,
      params.newStatus,
    );
  }
}

/// Parâmetros para atualizar status.
class UpdateContractStatusParams extends Equatable {
  const UpdateContractStatusParams({
    required this.contractId,
    required this.newStatus,
  });
  final String contractId;
  final ContractStatus newStatus;

  @override
  List<Object?> get props => [contractId, newStatus];
}
