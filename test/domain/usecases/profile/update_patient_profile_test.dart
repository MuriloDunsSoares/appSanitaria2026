/// Testes para UpdatePatientProfile Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/repositories/profile_repository.dart';
import 'package:app_sanitaria/domain/usecases/profile/update_patient_profile.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late UpdatePatientProfile useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = UpdatePatientProfile(mockRepository);
  });

  group('UpdatePatientProfile', () {
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
      condicoesMedicas: 'Diabetes tipo 2',
    );

    test('deve atualizar perfil do paciente com sucesso', () async {
      // Arrange
      when(mockRepository.updatePatientProfile(tPatient))
          .thenAnswer((_) async => Right(tPatient));

      // Act
      final result = await useCase(tPatient);

      // Assert
      expect(result, isA<Right<Failure, PatientEntity>>());
      verify(mockRepository.updatePatientProfile(tPatient)).called(1);
    });

    test('deve retornar ValidationFailure quando email inválido', () async {
      // Arrange
      final invalidPatient = PatientEntity(
        id: tPatient.id,
        nome: tPatient.nome,
        email: 'email_invalido',
        password: tPatient.password,
        telefone: tPatient.telefone,
        dataNascimento: tPatient.dataNascimento,
        endereco: tPatient.endereco,
        cidade: tPatient.cidade,
        estado: tPatient.estado,
        sexo: tPatient.sexo,
        dataCadastro: tPatient.dataCadastro,
      );

      // Act
      final result = await useCase(invalidPatient);

      // Assert
      expect(result, isA<Left<Failure, PatientEntity>>());
    });

    test('deve retornar StorageFailure quando falha ao atualizar', () async {
      // Arrange
      when(mockRepository.updatePatientProfile(tPatient))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tPatient);

      // Assert
      expect(result, isA<Left<Failure, PatientEntity>>());
      verify(mockRepository.updatePatientProfile(tPatient)).called(1);
    });
  });
}
