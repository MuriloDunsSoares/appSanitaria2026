/// Use Case: Obter todos os profissionais cadastrados.
library;

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/professional_entity.dart';
import '../../repositories/professionals_repository.dart';

/// Use Case para buscar todos os profissionais.
class GetAllProfessionals extends UseCase<List<ProfessionalEntity>, NoParams> {
  GetAllProfessionals(this.repository);
  final ProfessionalsRepository repository;

  @override
  Future<Either<Failure, List<ProfessionalEntity>>> call(
    NoParams params,
  ) async {
    return repository.getAllProfessionals();
  }
}
