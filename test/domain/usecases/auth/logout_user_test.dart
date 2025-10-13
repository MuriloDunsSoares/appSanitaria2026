/// Testes para LogoutUser Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/core/usecases/usecase.dart';
import 'package:app_sanitaria/domain/repositories/auth_repository.dart';
import 'package:app_sanitaria/domain/usecases/auth/logout_user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LogoutUser useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUser(mockRepository);
  });

  group('LogoutUser', () {
    test('deve fazer logout com sucesso', () async {
      // Arrange
      when(mockRepository.logout()).thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, isA<Right<Failure, Unit>>());
      verify(mockRepository.logout()).called(1);
    });

    test('deve retornar StorageFailure quando falha', () async {
      // Arrange
      when(mockRepository.logout())
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, isA<Left<Failure, Unit>>());
      verify(mockRepository.logout()).called(1);
    });
  });
}
