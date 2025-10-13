/// Testes para GetProfileImage Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/repositories/profile_repository.dart';
import 'package:app_sanitaria/domain/usecases/profile/get_profile_image.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late GetProfileImage useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetProfileImage(mockRepository);
  });

  group('GetProfileImage', () {
    const tUserId = 'patient123';
    const tImagePath = '/storage/images/patient123.jpg';

    test('deve retornar caminho da imagem quando existe', () async {
      // Arrange
      when(mockRepository.getProfileImage(tUserId))
          .thenAnswer((_) async => const Right(tImagePath));

      // Act
      final result = await useCase(tUserId);

      // Assert
      expect(result, isA<Right<Failure, String?>>());
      result.fold(
        (failure) => fail('Deveria retornar caminho da imagem'),
        (path) {
          expect(path, tImagePath);
        },
      );

      verify(mockRepository.getProfileImage(tUserId)).called(1);
    });

    test('deve retornar null quando não houver imagem', () async {
      // Arrange
      when(mockRepository.getProfileImage(tUserId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(tUserId);

      // Assert
      expect(result, isA<Right<Failure, String?>>());
      verify(mockRepository.getProfileImage(tUserId)).called(1);
    });

    test('deve retornar StorageFailure quando falha', () async {
      // Arrange
      when(mockRepository.getProfileImage(tUserId))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tUserId);

      // Assert
      expect(result, isA<Left<Failure, String?>>());
      verify(mockRepository.getProfileImage(tUserId)).called(1);
    });
  });
}
