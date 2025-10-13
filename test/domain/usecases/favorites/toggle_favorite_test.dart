/// Testes para ToggleFavorite Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/repositories/favorites_repository.dart';
import 'package:app_sanitaria/domain/usecases/favorites/toggle_favorite.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([FavoritesRepository])
void main() {
  late ToggleFavorite useCase;
  late MockFavoritesRepository mockRepository;

  setUp(() {
    mockRepository = MockFavoritesRepository();
    useCase = ToggleFavorite(mockRepository);
  });

  group('ToggleFavorite', () {
    const tPatientId = 'patient123';
    const tProfessionalId = 'prof456';

    final tParams = ToggleFavoriteParams(
      patientId: tPatientId,
      professionalId: tProfessionalId,
    );

    test('deve adicionar favorito com sucesso', () async {
      // Arrange
      when(mockRepository.toggleFavorite(tPatientId, tProfessionalId))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, bool>>());
      verify(mockRepository.toggleFavorite(tPatientId, tProfessionalId)).called(1);
    });

    test('deve remover favorito com sucesso', () async {
      // Arrange
      when(mockRepository.toggleFavorite(tPatientId, tProfessionalId))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, bool>>());
      verify(mockRepository.toggleFavorite(tPatientId, tProfessionalId)).called(1);
    });

    test('deve retornar StorageFailure quando falha', () async {
      // Arrange
      when(mockRepository.toggleFavorite(tPatientId, tProfessionalId))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Left<Failure, bool>>());
      verify(mockRepository.toggleFavorite(tPatientId, tProfessionalId)).called(1);
    });
  });
}
