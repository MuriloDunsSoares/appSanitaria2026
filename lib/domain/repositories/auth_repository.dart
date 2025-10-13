/// Interface do repositório de autenticação.
///
/// **Responsabilidades:**
/// - Autenticar usuários (login/logout)
/// - Registrar novos usuários (pacientes e profissionais)
/// - Gerenciar sessão do usuário atual
/// - Verificar estado de autenticação
///
/// **Princípios:**
/// - Interface pura (abstract class): não contém implementação
/// - Pertence ao Domain Layer (regras de negócio)
/// - Implementação concreta fica no Data Layer
/// - Retorna Either<Failure, Success> para tratamento funcional de erros
library;

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/patient_entity.dart';
import '../entities/professional_entity.dart';
import '../entities/user_entity.dart';

/// Contrato do repositório de autenticação.
abstract class AuthRepository {
  /// Autentica um usuário com [email] e [password].
  ///
  /// Retorna:
  /// - [Right(UserEntity)]: usuário autenticado com sucesso
  /// - [Left(InvalidCredentialsFailure)]: credenciais inválidas
  /// - [Left(UserNotFoundFailure)]: usuário não encontrado
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Registra um novo paciente no sistema.
  ///
  /// Retorna:
  /// - [Right(PatientEntity)]: paciente registrado com sucesso
  /// - [Left(EmailAlreadyExistsFailure)]: email já cadastrado
  /// - [Left(ValidationFailure)]: dados inválidos
  /// - [Left(StorageFailure)]: erro ao salvar
  Future<Either<Failure, PatientEntity>> registerPatient(
    PatientEntity patient,
  );

  /// Registra um novo profissional no sistema.
  ///
  /// Retorna:
  /// - [Right(ProfessionalEntity)]: profissional registrado com sucesso
  /// - [Left(EmailAlreadyExistsFailure)]: email já cadastrado
  /// - [Left(ValidationFailure)]: dados inválidos
  /// - [Left(StorageFailure)]: erro ao salvar
  Future<Either<Failure, ProfessionalEntity>> registerProfessional(
    ProfessionalEntity professional,
  );

  /// Retorna o usuário autenticado atualmente.
  ///
  /// Retorna:
  /// - [Right(UserEntity)]: usuário autenticado
  /// - [Left(SessionExpiredFailure)]: nenhum usuário autenticado
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Verifica se há um usuário autenticado.
  ///
  /// Retorna:
  /// - [Right(true)]: há usuário autenticado
  /// - [Right(false)]: não há usuário autenticado
  Future<Either<Failure, bool>> isAuthenticated();

  /// Desloga o usuário atual.
  ///
  /// Retorna:
  /// - [Right(Unit)]: logout realizado com sucesso
  /// - [Left(StorageFailure)]: erro ao limpar sessão
  Future<Either<Failure, Unit>> logout();

  /// Define a preferência "manter logado".
  ///
  /// Retorna:
  /// - [Right(Unit)]: preferência salva com sucesso
  /// - [Left(StorageFailure)]: erro ao salvar preferência
  Future<Either<Failure, Unit>> setKeepLoggedIn(bool value);

  /// Obtém a preferência "manter logado".
  ///
  /// Retorna:
  /// - [Right(bool)]: valor da preferência
  /// - [Left(StorageFailure)]: erro ao acessar preferência
  Future<Either<Failure, bool>> getKeepLoggedIn();
}
