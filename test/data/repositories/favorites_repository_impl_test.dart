import 'package:app_sanitaria/core/error/exceptions.dart';
import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/data/datasources/firebase_favorites_datasource.dart';
import 'package:app_sanitaria/data/repositories/favorites_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'favorites_repository_impl_test.mocks.dart';

@GenerateMocks([FirebaseFavoritesDataSource])
void main() {
  late FavoritesRepositoryImpl repository;
  late MockFirebaseFavoritesDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockFirebaseFavoritesDataSource();
    repository = FavoritesRepositoryImpl(dataSource: mockDataSource);
  });

  const userId = 'user123';
  const professionalId = 'prof456';

  group('FavoritesRepositoryImpl - getFavorites', () {
    test('deve retornar lista de IDs dos favoritos', () async {
      // Arrange
      final favoritesList = ['prof1', 'prof2', 'prof3'];
      when(mockDataSource.getFavorites(userId))
          .thenAnswer((_) async => favoritesList);

      // Act
      final result = await repository.getFavorites(userId);

      // Assert
      expect(result, isA<Right<Failure, List<String>>>());
      result.fold(
        (failure) => fail('Should return Right'),
        (favorites) {
          expect(favorites.length, 3);
          expect(favorites, contains('prof1'));
          expect(favorites, contains('prof2'));
        },
      );
      verify(mockDataSource.getFavorites(userId)).called(1);
    });

    test('deve retornar lista vazia quando não houver favoritos', () async {
      // Arrange
      when(mockDataSource.getFavorites(userId)).thenAnswer((_) async => []);

      // Act
      final result = await repository.getFavorites(userId);

      // Assert
      expect(result, isA<Right<Failure, List<String>>>());
      result.fold(
        (failure) => fail('Should return Right'),
        (favorites) => expect(favorites, isEmpty),
      );
    });

    test('deve retornar StorageFailure quando ocorrer erro', () async {
      // Arrange
      when(mockDataSource.getFavorites(userId))
          .thenThrow(const LocalStorageException('Erro ao carregar favoritos'));

      // Act
      final result = await repository.getFavorites(userId);

      // Assert
      expect(result, isA<Left<Failure, List<String>>>());
      result.fold(
        (failure) => expect(failure, isA<StorageFailure>()),
        (favorites) => fail('Should return Left'),
      );
    });
  });

  group('FavoritesRepositoryImpl - addFavorite', () {
    test('deve adicionar favorito com sucesso', () async {
      // Arrange
      when(mockDataSource.addFavorite(userId, professionalId))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.addFavorite(userId, professionalId);

      // Assert
      expect(result, isA<Right<Failure, Unit>>());
      verify(mockDataSource.addFavorite(userId, professionalId)).called(1);
    });

    test('deve retornar StorageFailure quando ocorrer erro', () async {
      // Arrange
      when(mockDataSource.addFavorite(userId, professionalId))
          .thenThrow(const LocalStorageException('Erro ao adicionar favorito'));

      // Act
      final result = await repository.addFavorite(userId, professionalId);

      // Assert
      expect(result, isA<Left<Failure, Unit>>());
      result.fold(
        (failure) => expect(failure, isA<StorageFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('FavoritesRepositoryImpl - removeFavorite', () {
    test('deve remover favorito com sucesso', () async {
      // Arrange
      when(mockDataSource.removeFavorite(userId, professionalId))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.removeFavorite(userId, professionalId);

      // Assert
      expect(result, isA<Right<Failure, Unit>>());
      verify(mockDataSource.removeFavorite(userId, professionalId)).called(1);
    });

    test('deve retornar StorageFailure quando ocorrer erro', () async {
      // Arrange
      when(mockDataSource.removeFavorite(userId, professionalId))
          .thenThrow(const LocalStorageException('Erro ao remover favorito'));

      // Act
      final result = await repository.removeFavorite(userId, professionalId);

      // Assert
      expect(result, isA<Left<Failure, Unit>>());
      result.fold(
        (failure) => expect(failure, isA<StorageFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('FavoritesRepositoryImpl - isFavorite', () {
    test('deve retornar true quando profissional estiver nos favoritos',
        () async {
      // Arrange
      when(mockDataSource.isFavorite(userId, professionalId))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.isFavorite(userId, professionalId);

      // Assert
      expect(result, isA<Right<Failure, bool>>());
      result.fold(
        (failure) => fail('Should return Right'),
        (isFav) => expect(isFav, isTrue),
      );
    });

    test('deve retornar false quando profissional não estiver nos favoritos',
        () async {
      // Arrange
      when(mockDataSource.isFavorite(userId, professionalId))
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.isFavorite(userId, professionalId);

      // Assert
      expect(result, isA<Right<Failure, bool>>());
      result.fold(
        (failure) => fail('Should return Right'),
        (isFav) => expect(isFav, isFalse),
      );
    });

    test('deve retornar StorageFailure quando ocorrer erro', () async {
      // Arrange
      when(mockDataSource.isFavorite(userId, professionalId))
          .thenThrow(const LocalStorageException('Erro ao verificar favorito'));

      // Act
      final result = await repository.isFavorite(userId, professionalId);

      // Assert
      expect(result, isA<Left<Failure, bool>>());
      result.fold(
        (failure) => expect(failure, isA<StorageFailure>()),
        (isFav) => fail('Should return Left'),
      );
    });
  });
}
