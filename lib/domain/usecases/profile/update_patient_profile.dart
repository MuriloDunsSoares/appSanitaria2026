/// Use Case: Atualizar perfil de paciente.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/patient_entity.dart';
import '../../repositories/profile_repository.dart';

/// Use Case para atualizar perfil de paciente.
class UpdatePatientProfile extends UseCase<PatientEntity, PatientEntity> {
  UpdatePatientProfile(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, PatientEntity>> call(PatientEntity patient) async {
    // Validação de email
    if (!_isValidEmail(patient.email)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    return repository.updatePatientProfile(patient);
  }

  /// Valida formato de email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
