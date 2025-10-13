/// Interface do repositório de contratos.
///
/// **Responsabilidades:**
/// - Criar novos contratos entre pacientes e profissionais
/// - Listar contratos (por paciente ou profissional)
/// - Atualizar status de contratos (confirmar, cancelar, concluir)
/// - Gerenciar dados de contratos
library;

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/contract_entity.dart';
import '../entities/contract_status.dart';

/// Contrato do repositório de contratos.
abstract class ContractsRepository {
  /// Cria um novo contrato.
  ///
  /// Retorna:
  /// - [Right(ContractEntity)]: contrato criado com sucesso
  /// - [Left(ValidationFailure)]: dados inválidos
  /// - [Left(StorageFailure)]: erro ao salvar
  Future<Either<Failure, ContractEntity>> createContract(
    ContractEntity contract,
  );

  /// Retorna TODOS os contratos do sistema.
  ///
  /// Retorna:
  /// - [Right(List<ContractEntity>)]: lista de contratos (pode ser vazia)
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ContractEntity>>> getAllContracts();

  /// Retorna contratos de um paciente específico.
  ///
  /// Retorna:
  /// - [Right(List<ContractEntity>)]: contratos do paciente
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ContractEntity>>> getContractsByPatient(
    String patientId,
  );

  /// Retorna contratos de um profissional específico.
  ///
  /// Retorna:
  /// - [Right(List<ContractEntity>)]: contratos do profissional
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ContractEntity>>> getContractsByProfessional(
    String professionalId,
  );

  /// Retorna um contrato por ID.
  ///
  /// Retorna:
  /// - [Right(ContractEntity)]: contrato encontrado
  /// - [Left(NotFoundFailure)]: contrato não existe
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, ContractEntity>> getContractById(String id);

  /// Atualiza um contrato existente.
  ///
  /// Retorna:
  /// - [Right(ContractEntity)]: contrato atualizado
  /// - [Left(NotFoundFailure)]: contrato não existe
  /// - [Left(StorageFailure)]: erro ao salvar
  Future<Either<Failure, ContractEntity>> updateContract(
    ContractEntity contract,
  );

  /// Atualiza o status de um contrato.
  ///
  /// Retorna:
  /// - [Right(ContractEntity)]: contrato com status atualizado
  /// - [Left(NotFoundFailure)]: contrato não existe
  /// - [Left(StorageFailure)]: erro ao salvar
  Future<Either<Failure, ContractEntity>> updateContractStatus(
    String contractId,
    ContractStatus newStatus,
  );

  /// Deleta um contrato.
  ///
  /// Retorna:
  /// - [Right(Unit)]: contrato deletado com sucesso
  /// - [Left(NotFoundFailure)]: contrato não existe
  /// - [Left(StorageFailure)]: erro ao deletar
  Future<Either<Failure, Unit>> deleteContract(String contractId);
}


