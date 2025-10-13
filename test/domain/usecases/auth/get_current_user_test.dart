/// Testes para GetCurrentUser Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/core/usecases/usecase.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/domain/repositories/auth_repository.dart';
import 'package:app_sanitaria/domain/usecases/auth/get_current_user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetCurrentUser useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUser(mockRepository);
  });

  group('GetCurrentUser', () {
    final tPatient = PatientEntity(
      id: 'patient123',
      nome: 'Maria Silva',
      email: 'maria.silva@email.com',
      password: 'senha123',
      telefone: '(11) 98765-4321',
      dataNascimento: DateTime(1990, 5, 15),
      endereco: 'Rua das Flores, 123',
      cidade: 'São Paulo',
      estado: 'SP',
      sexo: 'Feminino',
      dataCadastro: DateTime(2025),
      condicoesMedicas: 'Hipertensão',
    );

    test('deve retornar usuário atual quando está autenticado', () async {
      // Arrange
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tPatient));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, isA<Right<Failure, UserEntity>>());
      result.fold(
        (failure) => fail('Deveria retornar usuário'),
        (user) {
          expect(user.id, 'patient123');
          expect(user.nome, 'Maria Silva');
        },
      );

      verify(mockRepository.getCurrentUser()).called(1);
    });

    test('deve retornar AuthenticationFailure quando não está autenticado',
        () async {
      // Arrange
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(SessionExpiredFailure()));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      verify(mockRepository.getCurrentUser()).called(1);
    });
  });
}
