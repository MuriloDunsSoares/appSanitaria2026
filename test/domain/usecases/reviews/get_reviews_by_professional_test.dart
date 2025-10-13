/// Testes para GetReviewsByProfessional Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/review_entity.dart';
import 'package:app_sanitaria/domain/repositories/reviews_repository.dart';
import 'package:app_sanitaria/domain/usecases/reviews/get_reviews_by_professional.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ReviewsRepository])
void main() {
  late GetReviewsByProfessional useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = GetReviewsByProfessional(mockRepository);
  });

  group('GetReviewsByProfessional', () {
    const tProfessionalId = 'prof456';
    
    final tReview1 = ReviewEntity(
      id: 'review1',
      professionalId: tProfessionalId,
      patientId: 'patient123',
      patientName: 'Maria Silva',
      rating: 5,
      comment: 'Excelente profissional!',
      createdAt: DateTime(2025, 10, 1),
    );

    final tReview2 = ReviewEntity(
      id: 'review2',
      professionalId: tProfessionalId,
      patientId: 'patient456',
      patientName: 'João Costa',
      rating: 4,
      comment: 'Muito bom, recomendo.',
      createdAt: DateTime(2025, 10, 5),
    );

    final tReviews = [tReview1, tReview2];

    test('deve retornar lista de avaliações do profissional', () async {
      // Arrange
      when(mockRepository.getReviewsByProfessional(tProfessionalId))
          .thenAnswer((_) async => Right(tReviews));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Right<Failure, List<ReviewEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar reviews'),
        (reviews) {
          expect(reviews.length, 2);
          expect(reviews[0].professionalId, tProfessionalId);
        },
      );

      verify(mockRepository.getReviewsByProfessional(tProfessionalId)).called(1);
    });

    test('deve retornar lista vazia quando não houver avaliações', () async {
      // Arrange
      when(mockRepository.getReviewsByProfessional(tProfessionalId))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Right<Failure, List<ReviewEntity>>>());
      verify(mockRepository.getReviewsByProfessional(tProfessionalId)).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro', () async {
      // Arrange
      when(mockRepository.getReviewsByProfessional(tProfessionalId))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Left<Failure, List<ReviewEntity>>>());
    });
  });
}
