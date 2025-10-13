/// Testes para DeleteProfileImage Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/repositories/profile_repository.dart';
import 'package:app_sanitaria/domain/usecases/profile/delete_profile_image.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late DeleteProfileImage useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = DeleteProfileImage(mockRepository);
  });

  group('DeleteProfileImage', () {
    const tUserId = 'patient123';

    test('deve deletar imagem de perfil com sucesso', () async {
      // Arrange
      when(mockRepository.deleteProfileImage(tUserId))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(tUserId);

      // Assert
      expect(result, isA<Right<Failure, Unit>>());
      verify(mockRepository.deleteProfileImage(tUserId)).called(1);
    });

    test('deve retornar NotFoundFailure quando não houver imagem', () async {
      // Arrange
      when(mockRepository.deleteProfileImage(tUserId)).thenAnswer(
          (_) async => const Left(NotFoundFailure('Imagem de perfil')));

      // Act
      final result = await useCase(tUserId);

      // Assert
      expect(result, isA<Left<Failure, Unit>>());
      verify(mockRepository.deleteProfileImage(tUserId)).called(1);
    });

    test('deve retornar StorageFailure quando falha ao deletar', () async {
      // Arrange
      when(mockRepository.deleteProfileImage(tUserId))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tUserId);

      // Assert
      expect(result, isA<Left<Failure, Unit>>());
      verify(mockRepository.deleteProfileImage(tUserId)).called(1);
    });
  });
}
