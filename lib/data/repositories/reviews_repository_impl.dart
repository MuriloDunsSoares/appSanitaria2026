/// Implementação do repositório de avaliações.
library;

import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/firebase_reviews_datasource.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final FirebaseReviewsDataSource dataSource;

  ReviewsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByProfessional(
    String professionalId,
  ) async {
    try {
      final reviews = await dataSource.getReviewsByProfessional(professionalId);
      return Right(reviews);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> addReview(ReviewEntity review) async {
    try {
      await dataSource.addReview(review);
      return Right(review);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteReview(String reviewId) async {
    try {
      await dataSource.deleteReview(reviewId);
      return const Right(unit);
    } on NotFoundException catch (_) {
      return const Left(NotFoundFailure('Avaliação'));
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageRating(
    String professionalId,
  ) async {
    try {
      final reviews = await dataSource.getReviewsByProfessional(professionalId);
      if (reviews.isEmpty) {
        return const Right(0.0);
      }
      final sum = reviews.fold<double>(
        0.0,
        (prev, review) => prev + review.rating,
      );
      final average = sum / reviews.length;
      return Right(average);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getReviewsCount(String professionalId) async {
    try {
      final reviews = await dataSource.getReviewsByProfessional(professionalId);
      return Right(reviews.length);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

