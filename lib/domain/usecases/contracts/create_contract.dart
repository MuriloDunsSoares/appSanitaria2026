/// Use Case: Criar um novo contrato.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/contract_entity.dart';
import '../../repositories/contracts_repository.dart';

/// Use Case para criar contrato.
class CreateContract extends UseCase<ContractEntity, CreateContractParams> {
  CreateContract(this.repository);
  final ContractsRepository repository;

  @override
  Future<Either<Failure, ContractEntity>> call(
      CreateContractParams params) async {
    return repository.createContract(params.contract);
  }
}

/// Parâmetros para criar contrato
class CreateContractParams {
  const CreateContractParams(this.contract);
  final ContractEntity contract;
}
