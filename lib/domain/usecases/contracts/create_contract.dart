/// Use Case: Criar um novo contrato.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/contract_entity.dart';
import '../../repositories/contracts_repository.dart';

/// Use Case para criar contrato.
class CreateContract extends UseCase<ContractEntity, CreateContractParams> {
  final ContractsRepository repository;

  CreateContract(this.repository);

  @override
  Future<Either<Failure, ContractEntity>> call(CreateContractParams params) async {
    return await repository.createContract(params.contract);
  }
}

/// Parâmetros para criar contrato
class CreateContractParams {
  final ContractEntity contract;

  const CreateContractParams(this.contract);
}




