/// Testes para RegisterPatient Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/repositories/auth_repository.dart';
import 'package:app_sanitaria/domain/usecases/auth/register_patient.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late RegisterPatient useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterPatient(mockRepository);
  });

  group('RegisterPatient', () {
    final tPatient = PatientEntity(
      id: '',
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
      condicoesMedicas: 'Hipertensão controlada',
    );

    final tRegisteredPatient = PatientEntity(
      id: 'patient123',
      nome: tPatient.nome,
      email: tPatient.email,
      password: tPatient.password,
      telefone: tPatient.telefone,
      dataNascimento: tPatient.dataNascimento,
      endereco: tPatient.endereco,
      cidade: tPatient.cidade,
      estado: tPatient.estado,
      sexo: tPatient.sexo,
      dataCadastro: tPatient.dataCadastro,
      condicoesMedicas: tPatient.condicoesMedicas,
    );

    test('deve registrar paciente com sucesso quando dados são válidos',
        () async {
      // Arrange
      when(mockRepository.registerPatient(tPatient))
          .thenAnswer((_) async => Right(tRegisteredPatient));

      // Act
      final result = await useCase(tPatient);

      // Assert
      expect(result, isA<Right<Failure, PatientEntity>>());
      result.fold(
        (failure) => fail('Deveria retornar paciente registrado'),
        (patient) {
          expect(patient.id, isNotEmpty);
          expect(patient.nome, 'Maria Silva');
          expect(patient.email, 'maria.silva@email.com');
        },
      );

      verify(mockRepository.registerPatient(tPatient)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar ValidationFailure quando email já existe', () async {
      // Arrange
      when(mockRepository.registerPatient(tPatient)).thenAnswer(
          (_) async => const Left(ValidationFailure('Email já cadastrado')));

      // Act
      final result = await useCase(tPatient);

      // Assert
      expect(result, isA<Left<Failure, PatientEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, contains('Email'));
        },
        (patient) => fail('Deveria retornar ValidationFailure'),
      );

      verify(mockRepository.registerPatient(tPatient)).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro ao registrar',
        () async {
      // Arrange
      when(mockRepository.registerPatient(tPatient))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tPatient);

      // Assert
      expect(result, isA<Left<Failure, PatientEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (patient) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.registerPatient(tPatient)).called(1);
    });
  });
}
