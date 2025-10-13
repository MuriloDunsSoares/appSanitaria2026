/// Implementação do AuthRepository usando Firebase 100%.
library;

import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/professional_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Implementação do repositório de autenticação usando Firebase 100%.
///
/// **Características:**
/// - Usa apenas `FirebaseAuthDataSource` (Firebase Auth + Firestore)
/// - Autenticação gerenciada pelo Firebase Auth
/// - Dados persistidos no Firestore
/// - Sessão mantida automaticamente pelo Firebase
/// - Sincronização automática entre dispositivos
class AuthRepositoryFirebaseImpl implements AuthRepository {
  AuthRepositoryFirebaseImpl({
    required this.firebaseAuthDataSource,
  });
  final FirebaseAuthDataSource firebaseAuthDataSource;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await firebaseAuthDataSource.login(
        email: email,
        password: password,
      );
      return Right(user);
    } on InvalidCredentialsException catch (_) {
      return const Left(InvalidCredentialsFailure());
    } on UserNotFoundException catch (_) {
      return const Left(UserNotFoundFailure());
    } on OfflineModeException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> registerPatient(
    PatientEntity patient,
  ) async {
    try {
      final registeredPatient = await firebaseAuthDataSource.registerPatient(
        patient,
      );
      return Right(registeredPatient);
    } on EmailAlreadyExistsException catch (_) {
      return const Left(EmailAlreadyExistsFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (_) {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, ProfessionalEntity>> registerProfessional(
    ProfessionalEntity professional,
  ) async {
    try {
      final registeredProfessional =
          await firebaseAuthDataSource.registerProfessional(professional);
      return Right(registeredProfessional);
    } on EmailAlreadyExistsException catch (_) {
      return const Left(EmailAlreadyExistsFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on NetworkException catch (_) {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await firebaseAuthDataSource.logout();
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await firebaseAuthDataSource.getCurrentUser();
      if (user == null) {
        return const Left(UserNotFoundFailure());
      }
      return Right(user);
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> getKeepLoggedIn() async {
    // Firebase Auth mantém a sessão automaticamente
    // Retorna true se o usuário está autenticado
    try {
      final isAuth = await firebaseAuthDataSource.isAuthenticated();
      return Right(isAuth);
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setKeepLoggedIn(bool value) async {
    // Firebase Auth mantém a sessão automaticamente
    // Este método não faz nada, mas é mantido para compatibilidade com o domínio
    return const Right(unit);
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuth = await firebaseAuthDataSource.isAuthenticated();
      return Right(isAuth);
    } catch (e) {
      return const Left(StorageFailure());
    }
  }
}
