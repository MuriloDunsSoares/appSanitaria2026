/// Use Case: Adicionar uma avaliação.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/review_entity.dart';
import '../../repositories/reviews_repository.dart';

/// Parâmetros para adicionar avaliação
class AddReviewParams extends Equatable {
  const AddReviewParams({
    required this.professionalId,
    required this.patientId,
    required this.patientName,
    required this.rating,
    required this.comment,
  });
  final String professionalId;
  final String patientId;
  final String patientName;
  final int rating;
  final String comment;

  @override
  List<Object?> get props =>
      [professionalId, patientId, patientName, rating, comment];
}

/// Use Case para adicionar avaliação.
class AddReview extends UseCase<ReviewEntity, AddReviewParams> {
  AddReview(this.repository);
  final ReviewsRepository repository;

  @override
  Future<Either<Failure, ReviewEntity>> call(AddReviewParams params) async {
    // Validação de rating (deve estar entre 1 e 5)
    if (params.rating < 1 || params.rating > 5) {
      return const Left(ValidationFailure('Rating deve estar entre 1 e 5'));
    }

    // Construir ReviewEntity a partir dos parâmetros
    final review = ReviewEntity(
      id: '', // Será gerado pelo repository
      professionalId: params.professionalId,
      patientId: params.patientId,
      patientName: params.patientName,
      rating: params.rating,
      comment: params.comment,
      createdAt: DateTime.now(),
    );

    return repository.addReview(review);
  }
}
