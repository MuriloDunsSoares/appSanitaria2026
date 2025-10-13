/// Use Case: Obter favoritos de um paciente.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/favorites_repository.dart';

/// Use Case para obter favoritos.
class GetFavorites extends UseCase<List<String>, String> {
  final FavoritesRepository repository;

  GetFavorites(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String patientId) async {
    return await repository.getFavorites(patientId);
  }
}

/// Parâmetros para buscar favoritos.
class PatientIdParams extends Equatable {
  final String patientId;

  const PatientIdParams(this.patientId);

  @override
  List<Object?> get props => [patientId];
}




