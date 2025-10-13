/// Use Case: Obter favoritos de um paciente.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/favorites_repository.dart';

/// Use Case para obter favoritos.
class GetFavorites extends UseCase<List<String>, String> {
  GetFavorites(this.repository);
  final FavoritesRepository repository;

  @override
  Future<Either<Failure, List<String>>> call(String patientId) async {
    return repository.getFavorites(patientId);
  }
}

/// Parâmetros para buscar favoritos.
class PatientIdParams extends Equatable {
  const PatientIdParams(this.patientId);
  final String patientId;

  @override
  List<Object?> get props => [patientId];
}
