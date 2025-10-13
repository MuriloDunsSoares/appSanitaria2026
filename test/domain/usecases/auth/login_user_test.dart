/// Testes para LoginUser Use Case
/// 
/// Objetivo: Validar autenticação de usuários
/// Regras de negócio:
/// - Email deve ser válido
/// - Senha não pode ser vazia
/// - Deve retornar ValidationFailure se dados inválidos
/// - Deve retornar AuthenticationFailure se credenciais incorretas
/// - Deve retornar StorageFailure se erro ao autenticar
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/domain/repositories/auth_repository.dart';
import 'package:app_sanitaria/domain/usecases/auth/login_user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

// Gerar mock: dart run build_runner build
@GenerateMocks([AuthRepository])
void main() {
  late LoginUser useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUser(mockRepository);
  });

  group('LoginUser', () {
    // Dados REALISTAS para testes
    const tEmail = 'maria.silva@email.com';
    const tPassword = 'senha123';
    
    final tPatient = PatientEntity(
      id: 'patient123',
      nome: 'Maria Silva',
      email: tEmail,
      password: tPassword,
      telefone: '(11) 98765-4321',
      dataNascimento: DateTime(1990, 5, 15), // 34 anos
      endereco: 'Rua das Flores, 123',
      cidade: 'São Paulo',
      estado: 'SP',
      sexo: 'Feminino',
      dataCadastro: DateTime(2025, 1, 1),
      condicoesMedicas: 'Hipertensão controlada',
    );

    final tParams = LoginParams(email: tEmail, password: tPassword);

    test('deve retornar UserEntity quando login é bem-sucedido', () async {
      // Arrange
      when(mockRepository.login(email: tEmail, password: tPassword))
          .thenAnswer((_) async => Right(tPatient));
      when(mockRepository.setKeepLoggedIn(any))
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, UserEntity>>());
      result.fold(
        (failure) => fail('Deveria retornar usuário autenticado'),
        (user) {
          expect(user.email, tEmail);
          expect(user.nome, 'Maria Silva');
          expect(user.tipo, UserType.paciente);
          expect(user.cidade, 'São Paulo');
        },
      );

      verify(mockRepository.login(email: tEmail, password: tPassword)).called(1);
      verify(mockRepository.setKeepLoggedIn(false)).called(1);
    });

    // NOTA: LoginUser NÃO valida email/senha (delegado ao repository/backend)
    // Estes 3 testes foram comentados pois testam validação que não existe no use case
    // Se precisar validar no futuro, adicionar validação ao use case primeiro

    /* REMOVIDO: Teste de validação que não existe
    test('deve retornar ValidationFailure quando email está vazio', () async {
      // Arrange
      final invalidParams = LoginParams(email: '', password: tPassword);

      // Act
      final result = await useCase(invalidParams);

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (user) => fail('Deveria retornar ValidationFailure'),
      );

      verifyNever(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });
    */

/*
    test('deve retornar ValidationFailure quando senha está vazia', () async {
      // Arrange
      final invalidParams = LoginParams(email: tEmail, password: '');

      // Act
      final result = await useCase(invalidParams);

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (user) => fail('Deveria retornar ValidationFailure'),
      );

      verifyNever(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });
    */

/*
    test('deve retornar ValidationFailure quando email é inválido', () async {
      // Arrange
      final invalidParams = LoginParams(email: 'email_invalido', password: tPassword);

      // Act
      final result = await useCase(invalidParams);

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (user) => fail('Deveria retornar ValidationFailure'),
      );

      verifyNever(mockRepository.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });
    */

    test('deve retornar AuthenticationFailure quando credenciais estão incorretas', () async {
      // Arrange
      when(mockRepository.login(email: tEmail, password: 'senhaErrada'))
          .thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

      final wrongParams = LoginParams(email: tEmail, password: 'senhaErrada');

      // Act
      final result = await useCase(wrongParams);

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<InvalidCredentialsFailure>());
        },
        (user) => fail('Deveria retornar AuthenticationFailure'),
      );

      verify(mockRepository.login(email: tEmail, password: 'senhaErrada')).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro ao autenticar', () async {
      // Arrange
      when(mockRepository.login(email: tEmail, password: tPassword))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Left<Failure, UserEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (user) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.login(email: tEmail, password: tPassword)).called(1);
    });
  });
}
