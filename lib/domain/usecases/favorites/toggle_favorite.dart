/// Use Case: Alternar favorito (adicionar/remover).
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/favorites_repository.dart';

/// Use Case para alternar favorito.
class ToggleFavorite extends UseCase<bool, ToggleFavoriteParams> {
  ToggleFavorite(this.repository);
  final FavoritesRepository repository;

  @override
  Future<Either<Failure, bool>> call(ToggleFavoriteParams params) async {
    return repository.toggleFavorite(
      params.patientId,
      params.professionalId,
    );
  }
}

/// Parâmetros para toggle.
class ToggleFavoriteParams extends Equatable {
  const ToggleFavoriteParams({
    required this.patientId,
    required this.professionalId,
  });
  final String patientId;
  final String professionalId;

  @override
  List<Object?> get props => [patientId, professionalId];
}
