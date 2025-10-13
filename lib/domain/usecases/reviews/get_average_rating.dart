/// Use Case: Obter rating médio de um profissional.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/reviews_repository.dart';

/// Use Case para obter rating médio.
class GetAverageRating extends UseCase<double, String> {
  GetAverageRating(this.repository);
  final ReviewsRepository repository;

  @override
  Future<Either<Failure, double>> call(String professionalId) async {
    return repository.getAverageRating(professionalId);
  }
}

/// Parâmetros para buscar rating.
class ProfessionalIdParams extends Equatable {
  const ProfessionalIdParams(this.professionalId);
  final String professionalId;

  @override
  List<Object?> get props => [professionalId];
}
