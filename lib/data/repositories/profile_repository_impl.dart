/// Implementação do ProfileRepository.
library;

import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/professional_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_storage_datasource.dart';

/// Implementação concreta do ProfileRepository.
///
/// **Responsabilidade:** Conectar Use Cases ao ProfileStorageDataSource.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.dataSource});
  final ProfileStorageDataSource dataSource;

  @override
  Future<Either<Failure, String?>> getProfileImage(String userId) async {
    try {
      final imagePath = await dataSource.getProfileImage(userId);
      return Right(imagePath);
    } on LocalStorageException {
      return const Left(StorageFailure());
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> saveProfileImage(
    String userId,
    String imagePath,
  ) async {
    try {
      await dataSource.saveProfileImage(userId, imagePath);
      return const Right(unit);
    } on LocalStorageException {
      return const Left(StorageFailure());
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProfileImage(String userId) async {
    try {
      await dataSource.deleteProfileImage(userId);
      return const Right(unit);
    } on LocalStorageException {
      return const Left(StorageFailure());
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> updatePatientProfile(
    PatientEntity patient,
  ) async {
    try {
      // Atualiza os dados do paciente no local storage
      await dataSource.savePatientProfile(patient);

      // Também atualiza o auth storage se necessário
      // TODO: Integrar com AuthStorageDataSource para manter consistência

      return Right(patient);
    } on LocalStorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, ProfessionalEntity>> updateProfessionalProfile(
    ProfessionalEntity professional,
  ) async {
    try {
      // Atualiza os dados do profissional no local storage
      await dataSource.saveProfessionalProfile(professional);

      // Também atualiza o auth storage se necessário
      // TODO: Integrar com AuthStorageDataSource para manter consistência

      return Right(professional);
    } on LocalStorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (_) {
      return const Left(StorageFailure());
    }
  }
}
