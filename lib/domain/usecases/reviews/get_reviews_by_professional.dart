/// Use Case: Obter avaliações de um profissional.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/review_entity.dart';
import '../../repositories/reviews_repository.dart';

/// Use Case para obter avaliações.
class GetReviewsByProfessional
    extends UseCase<List<ReviewEntity>, String> {
  final ReviewsRepository repository;

  GetReviewsByProfessional(this.repository);

  @override
  Future<Either<Failure, List<ReviewEntity>>> call(
    String professionalId,
  ) async {
    return await repository.getReviewsByProfessional(professionalId);
  }
}

/// Parâmetros para buscar reviews.
class ProfessionalIdParams extends Equatable {
  final String professionalId;

  const ProfessionalIdParams(this.professionalId);

  @override
  List<Object?> get props => [professionalId];
}




