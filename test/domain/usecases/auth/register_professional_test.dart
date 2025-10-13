/// Testes para RegisterProfessional Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';
import 'package:app_sanitaria/domain/repositories/auth_repository.dart';
import 'package:app_sanitaria/domain/usecases/auth/register_professional.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late RegisterProfessional useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterProfessional(mockRepository);
  });

  group('RegisterProfessional', () {
    final tProfessional = ProfessionalEntity(
      id: '',
      nome: 'João Santos',
      email: 'joao.santos@email.com',
      password: 'senha123',
      telefone: '(11) 91234-5678',
      dataNascimento: DateTime(1985, 3, 20),
      endereco: 'Av. Paulista, 1000',
      cidade: 'São Paulo',
      estado: 'SP',
      sexo: 'Masculino',
      dataCadastro: DateTime(2024, 6),
      especialidade: Speciality.tecnicosEnfermagem,
      formacao: 'Técnico em Enfermagem - SENAC 2010',
      certificados: 'COREN 123456-SP',
      experiencia: 10,
      biografia: 'Técnico especializado',
      avaliacao: 0,
      hourlyRate: 75,
    );

    final tRegisteredProfessional = ProfessionalEntity(
      id: 'prof123',
      nome: tProfessional.nome,
      email: tProfessional.email,
      password: tProfessional.password,
      telefone: tProfessional.telefone,
      dataNascimento: tProfessional.dataNascimento,
      endereco: tProfessional.endereco,
      cidade: tProfessional.cidade,
      estado: tProfessional.estado,
      sexo: tProfessional.sexo,
      dataCadastro: tProfessional.dataCadastro,
      especialidade: tProfessional.especialidade,
      formacao: tProfessional.formacao,
      certificados: tProfessional.certificados,
      experiencia: tProfessional.experiencia,
      biografia: tProfessional.biografia,
      avaliacao: tProfessional.avaliacao,
      hourlyRate: tProfessional.hourlyRate,
    );

    test('deve registrar profissional com sucesso', () async {
      // Arrange
      when(mockRepository.registerProfessional(tProfessional))
          .thenAnswer((_) async => Right(tRegisteredProfessional));

      // Act
      final result = await useCase(tProfessional);

      // Assert
      expect(result, isA<Right<Failure, ProfessionalEntity>>());
      result.fold(
        (failure) => fail('Deveria retornar profissional registrado'),
        (professional) {
          expect(professional.id, isNotEmpty);
          expect(professional.nome, 'João Santos');
          expect(professional.especialidade, Speciality.tecnicosEnfermagem);
        },
      );

      verify(mockRepository.registerProfessional(tProfessional)).called(1);
    });

    test('deve retornar ValidationFailure quando email já existe', () async {
      // Arrange
      when(mockRepository.registerProfessional(tProfessional)).thenAnswer(
          (_) async => const Left(ValidationFailure('Email já cadastrado')));

      // Act
      final result = await useCase(tProfessional);

      // Assert
      expect(result, isA<Left<Failure, ProfessionalEntity>>());
      verify(mockRepository.registerProfessional(tProfessional)).called(1);
    });
  });
}
