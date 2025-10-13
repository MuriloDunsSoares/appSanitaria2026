/// Testes para GetFavorites Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/repositories/favorites_repository.dart';
import 'package:app_sanitaria/domain/usecases/favorites/get_favorites.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([FavoritesRepository])
void main() {
  late GetFavorites useCase;
  late MockFavoritesRepository mockRepository;

  setUp(() {
    mockRepository = MockFavoritesRepository();
    useCase = GetFavorites(mockRepository);
  });

  group('GetFavorites', () {
    const tPatientId = 'patient123';
    final tFavorites = ['prof456', 'prof789', 'prof012'];

    test('deve retornar lista de IDs dos favoritos', () async {
      // Arrange
      when(mockRepository.getFavorites(tPatientId))
          .thenAnswer((_) async => Right(tFavorites));

      // Act
      final result = await useCase(tPatientId);

      // Assert
      expect(result, isA<Right<Failure, List<String>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista de favoritos'),
        (favorites) {
          expect(favorites.length, 3);
          expect(favorites, contains('prof456'));
        },
      );

      verify(mockRepository.getFavorites(tPatientId)).called(1);
    });

    test('deve retornar lista vazia quando não houver favoritos', () async {
      // Arrange
      when(mockRepository.getFavorites(tPatientId))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(tPatientId);

      // Assert
      expect(result, isA<Right<Failure, List<String>>>());
      verify(mockRepository.getFavorites(tPatientId)).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro', () async {
      // Arrange
      when(mockRepository.getFavorites(tPatientId))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tPatientId);

      // Assert
      expect(result, isA<Left<Failure, List<String>>>());
    });
  });
}
