import 'package:app_sanitaria/core/error/exceptions.dart';
import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/data/datasources/firebase_reviews_datasource.dart';
import 'package:app_sanitaria/data/repositories/reviews_repository_impl.dart';
import 'package:app_sanitaria/domain/entities/review_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FirebaseReviewsDataSource])
import 'reviews_repository_impl_test.mocks.dart';

void main() {
  late ReviewsRepositoryImpl repository;
  late MockFirebaseReviewsDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockFirebaseReviewsDataSource();
    repository = ReviewsRepositoryImpl(dataSource: mockDataSource);
  });

  final tReview1 = ReviewEntity(
    id: '1',
    professionalId: 'prof-1',
    patientId: 'patient-1',
    patientName: 'João Silva',
    rating: 5,
    comment: 'Excelente profissional! Muito atencioso e competente.',
    createdAt: DateTime(2025, 10, 7),
  );

  final tReview2 = ReviewEntity(
    id: '2',
    professionalId: 'prof-1',
    patientId: 'patient-2',
    patientName: 'Maria Santos',
    rating: 4,
    comment: 'Muito bom! Recomendo.',
    createdAt: DateTime(2025, 10, 6),
  );

  final tReview3 = ReviewEntity(
    id: '3',
    professionalId: 'prof-1',
    patientId: 'patient-3',
    patientName: 'Pedro Oliveira',
    rating: 5,
    comment: 'Perfeito!',
    createdAt: DateTime(2025, 10, 5),
  );

  group('ReviewsRepositoryImpl - getReviewsByProfessional', () {
    test('deve retornar lista de avaliações do profissional', () async {
      // arrange
      const professionalId = 'prof-1';
      when(mockDataSource.getReviewsByProfessional(professionalId))
          .thenAnswer((_) async => [tReview1, tReview2, tReview3]);

      // act
      final result = await repository.getReviewsByProfessional(professionalId);

      // assert
      expect(result, Right([tReview1, tReview2, tReview3]));
      verify(mockDataSource.getReviewsByProfessional(professionalId));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve retornar lista vazia quando não houver avaliações', () async {
      // arrange
      const professionalId = 'prof-sem-reviews';
      when(mockDataSource.getReviewsByProfessional(professionalId))
          .thenAnswer((_) async => []);

      // act
      final result = await repository.getReviewsByProfessional(professionalId);

      // assert
      expect(result, const Right([]));
      verify(mockDataSource.getReviewsByProfessional(professionalId));
    });

    test('deve retornar StorageFailure quando ocorre LocalStorageException',
        () async {
      // arrange
      const professionalId = 'prof-1';
      when(mockDataSource.getReviewsByProfessional(professionalId))
          .thenThrow(const LocalStorageException('Erro ao buscar avaliações'));

      // act
      final result = await repository.getReviewsByProfessional(professionalId);

      // assert
      expect(result, const Left(StorageFailure()));
    });

    test('deve retornar UnexpectedFailure quando ocorre exceção inesperada',
        () async {
      // arrange
      const professionalId = 'prof-1';
      when(mockDataSource.getReviewsByProfessional(professionalId))
          .thenThrow(Exception('Erro inesperado'));

      // act
      final result = await repository.getReviewsByProfessional(professionalId);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (_) => fail('Deveria retornar failure'),
      );
    });
  });

  group('ReviewsRepositoryImpl - addReview', () {
    test('deve adicionar avaliação com sucesso', () async {
      // arrange
      when(mockDataSource.addReview(any)).thenAnswer((_) async => tReview1);

      // act
      final result = await repository.addReview(tReview1);

      // assert
      expect(result, Right(tReview1));
      verify(mockDataSource.addReview(tReview1));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve retornar StorageFailure quando ocorre erro ao salvar', () async {
      // arrange
      when(mockDataSource.addReview(any))
          .thenThrow(const LocalStorageException('Erro ao salvar avaliação'));

      // act
      final result = await repository.addReview(tReview1);

      // assert
      expect(result, const Left(StorageFailure()));
    });

    test('deve retornar UnexpectedFailure quando ocorre exceção inesperada',
        () async {
      // arrange
      when(mockDataSource.addReview(any))
          .thenThrow(Exception('Erro inesperado'));

      // act
      final result = await repository.addReview(tReview1);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (_) => fail('Deveria retornar failure'),
      );
    });
  });

  group('ReviewsRepositoryImpl - deleteReview', () {
    test('deve deletar avaliação com sucesso', () async {
      // arrange
      const reviewId = '1';
      when(mockDataSource.deleteReview(reviewId)).thenAnswer((_) async => true);

      // act
      final result = await repository.deleteReview(reviewId);

      // assert
      expect(result, const Right(unit));
      verify(mockDataSource.deleteReview(reviewId));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve retornar NotFoundFailure quando avaliação não existe', () async {
      // arrange
      const reviewId = 'nao-existe';
      when(mockDataSource.deleteReview(reviewId))
          .thenThrow(const NotFoundException('Avaliação', 'nao-existe'));

      // act
      final result = await repository.deleteReview(reviewId);

      // assert
      expect(result, const Left(NotFoundFailure('Avaliação')));
    });

    test('deve retornar StorageFailure quando ocorre LocalStorageException',
        () async {
      // arrange
      const reviewId = '1';
      when(mockDataSource.deleteReview(reviewId))
          .thenThrow(const LocalStorageException('Erro ao deletar'));

      // act
      final result = await repository.deleteReview(reviewId);

      // assert
      expect(result, const Left(StorageFailure()));
    });
  });

  group('ReviewsRepositoryImpl - getAverageRating', () {
    test('deve retornar média das avaliações corretamente', () async {
      // arrange
      const professionalId = 'prof-1';
      when(mockDataSource.getReviewsByProfessional(professionalId)).thenAnswer(
          (_) async =>
              [tReview1, tReview2, tReview3]); // 5, 4, 5 = média 4.666...

      // act
      final result = await repository.getAverageRating(professionalId);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Deveria retornar média'),
        (average) {
          expect(average, closeTo(4.67, 0.01)); // 14/3 = 4.666...
        },
      );
      verify(mockDataSource.getReviewsByProfessional(professionalId));
    });

    test('deve retornar 0.0 quando não houver avaliações', () async {
      // arrange
      const professionalId = 'prof-sem-reviews';
      when(mockDataSource.getReviewsByProfessional(professionalId))
          .thenAnswer((_) async => []);

      // act
      final result = await repository.getAverageRating(professionalId);

      // assert
      expect(result, const Right(0));
    });

    test('deve retornar StorageFailure quando ocorre erro', () async {
      // arrange
      const professionalId = 'prof-1';
      when(mockDataSource.getReviewsByProfessional(professionalId))
          .thenThrow(const LocalStorageException('Erro'));

      // act
      final result = await repository.getAverageRating(professionalId);

      // assert
      expect(result, const Left(StorageFailure()));
    });
  });

  group('ReviewsRepositoryImpl - getReviewsCount', () {
    test('deve retornar quantidade de avaliações corretamente', () async {
      // arrange
      const professionalId = 'prof-1';
      when(mockDataSource.getReviewsByProfessional(professionalId))
          .thenAnswer((_) async => [tReview1, tReview2, tReview3]);

      // act
      final result = await repository.getReviewsCount(professionalId);

      // assert
      expect(result, const Right(3));
      verify(mockDataSource.getReviewsByProfessional(professionalId));
    });

    test('deve retornar 0 quando não houver avaliações', () async {
      // arrange
      const professionalId = 'prof-sem-reviews';
      when(mockDataSource.getReviewsByProfessional(professionalId))
          .thenAnswer((_) async => []);

      // act
      final result = await repository.getReviewsCount(professionalId);

      // assert
      expect(result, const Right(0));
    });

    test('deve retornar StorageFailure quando ocorre erro', () async {
      // arrange
      const professionalId = 'prof-1';
      when(mockDataSource.getReviewsByProfessional(professionalId))
          .thenThrow(const LocalStorageException('Erro'));

      // act
      final result = await repository.getReviewsCount(professionalId);

      // assert
      expect(result, const Left(StorageFailure()));
    });
  });
}
