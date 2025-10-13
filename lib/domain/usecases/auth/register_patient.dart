/// Use Case: Registrar um novo paciente.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/patient_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use Case para registro de paciente.
///
/// **Responsabilidade única:** Criar conta de paciente.
class RegisterPatient extends UseCase<PatientEntity, PatientEntity> {
  final AuthRepository repository;

  RegisterPatient(this.repository);

  @override
  Future<Either<Failure, PatientEntity>> call(PatientEntity patient) async {
    return await repository.registerPatient(patient);
  }
}




