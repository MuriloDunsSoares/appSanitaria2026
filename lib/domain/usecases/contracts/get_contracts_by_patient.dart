/// Use Case: Obter contratos de um paciente.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/contract_entity.dart';
import '../../repositories/contracts_repository.dart';

/// Use Case para obter contratos do paciente.
class GetContractsByPatient extends UseCase<List<ContractEntity>, String> {
  GetContractsByPatient(this.repository);
  final ContractsRepository repository;

  @override
  Future<Either<Failure, List<ContractEntity>>> call(
    String patientId,
  ) async {
    return repository.getContractsByPatient(patientId);
  }
}

/// Parâmetros para buscar por paciente ID.
class PatientIdParams extends Equatable {
  const PatientIdParams(this.patientId);
  final String patientId;

  @override
  List<Object?> get props => [patientId];
}
