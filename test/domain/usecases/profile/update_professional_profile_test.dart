/// Testes para UpdateProfessionalProfile Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';
import 'package:app_sanitaria/domain/repositories/profile_repository.dart';
import 'package:app_sanitaria/domain/usecases/profile/update_professional_profile.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late UpdateProfessionalProfile useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = UpdateProfessionalProfile(mockRepository);
  });

  group('UpdateProfessionalProfile', () {
    final tProfessional = ProfessionalEntity(
      id: 'prof123',
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
      formacao: 'Técnico em Enfermagem',
      certificados: 'COREN 123456-SP',
      experiencia: 10,
      biografia: 'Técnico especializado',
      avaliacao: 4.8,
      hourlyRate: 80,
    );

    test('deve atualizar perfil do profissional com sucesso', () async {
      // Arrange
      when(mockRepository.updateProfessionalProfile(tProfessional))
          .thenAnswer((_) async => Right(tProfessional));

      // Act
      final result = await useCase(tProfessional);

      // Assert
      expect(result, isA<Right<Failure, ProfessionalEntity>>());
      verify(mockRepository.updateProfessionalProfile(tProfessional)).called(1);
    });

    test('deve retornar StorageFailure quando falha', () async {
      // Arrange
      when(mockRepository.updateProfessionalProfile(tProfessional))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tProfessional);

      // Assert
      expect(result, isA<Left<Failure, ProfessionalEntity>>());
    });
  });
}
