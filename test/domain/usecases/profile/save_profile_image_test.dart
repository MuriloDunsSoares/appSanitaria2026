/// Testes para SaveProfileImage Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/repositories/profile_repository.dart';
import 'package:app_sanitaria/domain/usecases/profile/save_profile_image.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late SaveProfileImage useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = SaveProfileImage(mockRepository);
  });

  group('SaveProfileImage', () {
    const tUserId = 'patient123';
    const tImagePath = '/storage/images/patient123.jpg';

    const tParams = SaveProfileImageParams(
      userId: tUserId,
      imagePath: tImagePath,
    );

    test('deve salvar caminho da imagem com sucesso', () async {
      // Arrange
      when(mockRepository.saveProfileImage(tUserId, tImagePath))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, Unit>>());
      verify(mockRepository.saveProfileImage(tUserId, tImagePath)).called(1);
    });

    test('deve retornar ValidationFailure quando caminho inválido', () async {
      // Arrange
      const invalidParams = SaveProfileImageParams(
        userId: tUserId,
        imagePath: '',
      );

      // Act
      final result = await useCase(invalidParams);

      // Assert
      expect(result, isA<Left<Failure, Unit>>());
    });

    test('deve retornar StorageFailure quando falha ao salvar', () async {
      // Arrange
      when(mockRepository.saveProfileImage(tUserId, tImagePath))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Left<Failure, Unit>>());
      verify(mockRepository.saveProfileImage(tUserId, tImagePath)).called(1);
    });
  });
}
