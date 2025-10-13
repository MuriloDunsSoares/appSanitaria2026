/// Testes para GetAverageRating Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/repositories/reviews_repository.dart';
import 'package:app_sanitaria/domain/usecases/reviews/get_average_rating.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ReviewsRepository])
void main() {
  late GetAverageRating useCase;
  late MockReviewsRepository mockRepository;

  setUp(() {
    mockRepository = MockReviewsRepository();
    useCase = GetAverageRating(mockRepository);
  });

  group('GetAverageRating', () {
    const tProfessionalId = 'prof456';
    const tAverageRating = 4.8;

    test('deve retornar média das avaliações do profissional', () async {
      // Arrange
      when(mockRepository.getAverageRating(tProfessionalId))
          .thenAnswer((_) async => const Right(tAverageRating));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Right<Failure, double>>());
      result.fold(
        (failure) => fail('Deveria retornar média'),
        (average) {
          expect(average, 4.8);
        },
      );

      verify(mockRepository.getAverageRating(tProfessionalId)).called(1);
    });

    test('deve retornar 0.0 quando não houver avaliações', () async {
      // Arrange
      when(mockRepository.getAverageRating(tProfessionalId))
          .thenAnswer((_) async => const Right(0.0));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Right<Failure, double>>());
      verify(mockRepository.getAverageRating(tProfessionalId)).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro', () async {
      // Arrange
      when(mockRepository.getAverageRating(tProfessionalId))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Left<Failure, double>>());
    });
  });
}
