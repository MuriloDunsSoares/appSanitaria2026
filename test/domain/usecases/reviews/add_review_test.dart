/// Testes para AddReview Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/review_entity.dart';
import 'package:app_sanitaria/domain/repositories/reviews_repository.dart';
import 'package:app_sanitaria/domain/usecases/reviews/add_review.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ReviewsRepository])
void main() {
  late AddReview useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = AddReview(mockRepository);
  });

  group('AddReview', () {
    const tProfessionalId = 'prof456';
    const tPatientId = 'patient123';
    const tPatientName = 'Maria Silva';
    const tRating = 5;
    const tComment = 'Excelente profissional! Muito atencioso e competente.';

    final tReview = ReviewEntity(
      id: 'review123',
      professionalId: tProfessionalId,
      patientId: tPatientId,
      patientName: tPatientName,
      rating: tRating,
      comment: tComment,
      createdAt: DateTime(2025, 10, 9),
    );

    final tParams = AddReviewParams(
      professionalId: tProfessionalId,
      patientId: tPatientId,
      patientName: tPatientName,
      rating: tRating,
      comment: tComment,
    );

    test('deve adicionar avaliação com sucesso', () async {
      // Arrange
      when(mockRepository.addReview(any))
          .thenAnswer((_) async => Right(tReview));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, ReviewEntity>>());
      result.fold(
        (failure) => fail('Deveria retornar review criada'),
        (review) {
          expect(review.professionalId, tProfessionalId);
          expect(review.rating, 5);
        },
      );

      verify(mockRepository.addReview(any)).called(1);
    });

    test('deve retornar ValidationFailure para rating inválido', () async {
      // Arrange
      final invalidParams = AddReviewParams(
        professionalId: tProfessionalId,
        patientId: tPatientId,
        patientName: tPatientName,
        rating: 6, // Inválido (> 5)
        comment: tComment,
      );

      // Act
      final result = await useCase(invalidParams);

      // Assert
      expect(result, isA<Left<Failure, ReviewEntity>>());
    });

    test('deve retornar StorageFailure quando falha ao salvar', () async {
      // Arrange
      when(mockRepository.addReview(any))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Left<Failure, ReviewEntity>>());
    });
  });
}
