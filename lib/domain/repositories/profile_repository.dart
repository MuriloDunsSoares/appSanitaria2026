/// Repository abstrato para operações de perfil.
library;

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/patient_entity.dart';
import '../entities/professional_entity.dart';

/// Repository para gerenciamento de perfil de usuário.
///
/// **Responsabilidade:** Definir contrato para operações de perfil.
abstract class ProfileRepository {
  /// Obtém caminho da foto de perfil de um usuário.
  Future<Either<Failure, String?>> getProfileImage(String userId);

  /// Salva caminho da foto de perfil de um usuário.
  Future<Either<Failure, Unit>> saveProfileImage(String userId, String imagePath);

  /// Deleta foto de perfil de um usuário.
  Future<Either<Failure, Unit>> deleteProfileImage(String userId);

  /// Atualiza perfil de um paciente.
  Future<Either<Failure, PatientEntity>> updatePatientProfile(PatientEntity patient);

  /// Atualiza perfil de um profissional.
  Future<Either<Failure, ProfessionalEntity>> updateProfessionalProfile(ProfessionalEntity professional);
}
