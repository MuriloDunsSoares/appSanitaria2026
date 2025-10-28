/// Use Case: Cancelar um contrato em status 'pending'.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/contract_entity.dart';
import '../../entities/contract_status.dart';
import '../../repositories/contracts_repository.dart';

/// Use Case para cancelar contrato.
///
/// **Responsabilidades:**
/// - Validar se o contrato existe
/// - Validar se o status é 'pending'
/// - Validar se o usuário é o paciente que criou o contrato
/// - Chamar repository para atualizar status
class CancelContract extends UseCase<ContractEntity, CancelContractParams> {
  CancelContract(this.repository);
  final ContractsRepository repository;

  @override
  Future<Either<Failure, ContractEntity>> call(
      CancelContractParams params) async {
    // ✅ Validação 1: Contrato existe?
    final contractResult =
        await repository.getContractById(params.contractId);

    return contractResult.fold(
      (failure) => Left(failure),
      (contract) async {
        // ✅ Validação 2: Status é 'pending'?
        if (contract.status != ContractStatus.pending) {
          return const Left(
            ValidationFailure(
              'Apenas contratos em "Aguardando Confirmação" podem ser cancelados',
            ),
          );
        }

        // ✅ Validação 3: É o paciente que criou?
        if (contract.patientId != params.currentUserId) {
          return const Left(
            ValidationFailure(
              'Apenas o paciente pode cancelar seu próprio contrato',
            ),
          );
        }

        // ✅ Se passou em todas validações, chamar repository para atualizar
        return repository.updateContractStatus(
          params.contractId,
          ContractStatus.cancelled,
        );
      },
    );
  }
}

/// Parâmetros para cancelar contrato
class CancelContractParams {
  const CancelContractParams({
    required this.contractId,
    required this.currentUserId,
  });

  /// ID do contrato a cancelar
  final String contractId;

  /// ID do usuário que está tentando cancelar (deve ser o paciente)
  final String currentUserId;
}
