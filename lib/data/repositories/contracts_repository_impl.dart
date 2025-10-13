/// Implementação do repositório de contratos.
library;

import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/entities/contract_status.dart';
import '../../domain/repositories/contracts_repository.dart';
import '../datasources/firebase_contracts_datasource.dart';

class ContractsRepositoryImpl implements ContractsRepository {
  ContractsRepositoryImpl({required this.dataSource});
  final FirebaseContractsDataSource dataSource;

  @override
  Future<Either<Failure, ContractEntity>> createContract(
    ContractEntity contract,
  ) async {
    try {
      final created = await dataSource.createContract(contract);
      return Right(created);
    } on StorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContractEntity>>> getAllContracts() async {
    try {
      final contracts = await dataSource.getAllContracts();
      return Right(contracts);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContractEntity>>> getContractsByPatient(
    String patientId,
  ) async {
    try {
      final contracts = await dataSource.getContractsByPatient(patientId);
      return Right(contracts);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ContractEntity>>> getContractsByProfessional(
    String professionalId,
  ) async {
    try {
      final contracts =
          await dataSource.getContractsByProfessional(professionalId);
      return Right(contracts);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContractEntity>> getContractById(String id) async {
    try {
      final contract = await dataSource.getContractById(id);
      if (contract == null) {
        return const Left(NotFoundFailure('Contrato'));
      }
      return Right(contract);
    } on NotFoundException catch (_) {
      return const Left(NotFoundFailure('Contrato'));
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContractEntity>> updateContract(
    ContractEntity contract,
  ) async {
    try {
      await dataSource.updateContract(contract);
      return Right(contract);
    } on NotFoundException catch (_) {
      return const Left(NotFoundFailure('Contrato'));
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ContractEntity>> updateContractStatus(
    String contractId,
    ContractStatus newStatus,
  ) async {
    try {
      final contract = await dataSource.getContractById(contractId);
      if (contract == null) {
        return const Left(NotFoundFailure('Contrato'));
      }
      final updated = contract.copyWith(status: newStatus);
      await dataSource.updateContract(updated);
      return Right(updated);
    } on NotFoundException catch (_) {
      return const Left(NotFoundFailure('Contrato'));
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteContract(String contractId) async {
    try {
      await dataSource.deleteContract(contractId);
      return const Right(unit);
    } on NotFoundException catch (_) {
      return const Left(NotFoundFailure('Contrato'));
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
