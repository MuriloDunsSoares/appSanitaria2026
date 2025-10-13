/// Testes para GetAllProfessionals Use Case
/// 
/// Objetivo: Validar busca de todos os profissionais cadastrados
/// Regras de negócio:
/// - Deve retornar lista de profissionais ordenada
/// - Lista pode ser vazia (sistema novo)
/// - Deve retornar StorageFailure se erro ao buscar
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/core/usecases/usecase.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';
import 'package:app_sanitaria/domain/repositories/professionals_repository.dart';
import 'package:app_sanitaria/domain/usecases/professionals/get_all_professionals.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

// Gerar mock: dart run build_runner build
@GenerateMocks([ProfessionalsRepository])
void main() {
  late GetAllProfessionals useCase;
  late MockProfessionalsRepository mockRepository;

  setUp(() {
    mockRepository = MockProfessionalsRepository();
    useCase = GetAllProfessionals(mockRepository);
  });

  group('GetAllProfessionals', () {
    // Dados REALISTAS para testes
    final tProfessional1 = ProfessionalEntity(
      id: 'prof123',
      nome: 'João Santos',
      email: 'joao.santos@email.com',
      password: 'senha123',
      telefone: '(11) 91234-5678',
      dataNascimento: DateTime(1985, 3, 20), // 39 anos
      endereco: 'Av. Paulista, 1000',
      cidade: 'São Paulo',
      estado: 'SP',
      sexo: 'Masculino',
      dataCadastro: DateTime(2024, 6, 1),
      especialidade: Speciality.tecnicosEnfermagem,
      formacao: 'Técnico em Enfermagem - SENAC 2010',
      certificados: 'COREN 123456-SP',
      experiencia: 10,
      biografia: 'Técnico em enfermagem com 10 anos de experiência em cuidados domiciliares.',
      avaliacao: 4.8,
      hourlyRate: 75.0,
      averageRating: 4.8,
    );

    final tProfessional2 = ProfessionalEntity(
      id: 'prof456',
      nome: 'Ana Costa',
      email: 'ana.costa@email.com',
      password: 'senha456',
      telefone: '(11) 98765-4321',
      dataNascimento: DateTime(1990, 7, 15), // 34 anos
      endereco: 'Rua Augusta, 500',
      cidade: 'São Paulo',
      estado: 'SP',
      sexo: 'Feminino',
      dataCadastro: DateTime(2024, 8, 15),
      especialidade: Speciality.cuidadores,
      formacao: 'Curso de Cuidador de Idosos - 2015',
      certificados: 'Certificado Nacional de Cuidador',
      experiencia: 8,
      biografia: 'Cuidadora especializada em idosos com Alzheimer.',
      avaliacao: 5.0,
      hourlyRate: 60.0,
      averageRating: 5.0,
    );

    final tProfessional3 = ProfessionalEntity(
      id: 'prof789',
      nome: 'Carlos Oliveira',
      email: 'carlos.oliveira@email.com',
      password: 'senha789',
      telefone: '(11) 99876-5432',
      dataNascimento: DateTime(1988, 11, 5), // 36 anos
      endereco: 'Rua da Consolação, 800',
      cidade: 'São Paulo',
      estado: 'SP',
      sexo: 'Masculino',
      dataCadastro: DateTime(2024, 9, 10),
      especialidade: Speciality.acompanhantesHospital,
      formacao: 'Formação em Acompanhamento Hospitalar',
      certificados: 'Certificado de Acompanhante - 2018',
      experiencia: 6,
      biografia: 'Acompanhante hospitalar com experiência em UTI e pós-operatório.',
      avaliacao: 4.5,
      hourlyRate: 55.0,
      averageRating: 4.5,
    );

    final tProfessionals = [tProfessional1, tProfessional2, tProfessional3];

    test('deve retornar lista de todos os profissionais quando existem profissionais cadastrados', () async {
      // Arrange
      when(mockRepository.getAllProfessionals())
          .thenAnswer((_) async => Right(tProfessionals));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista de profissionais'),
        (professionals) {
          expect(professionals.length, 3);
          
          // Verificar primeiro profissional
          expect(professionals[0].nome, 'João Santos');
          expect(professionals[0].especialidade, Speciality.tecnicosEnfermagem);
          expect(professionals[0].experiencia, 10);
          expect(professionals[0].hourlyRate, 75.0);
          expect(professionals[0].cidade, 'São Paulo');
          
          // Verificar segundo profissional
          expect(professionals[1].nome, 'Ana Costa');
          expect(professionals[1].especialidade, Speciality.cuidadores);
          expect(professionals[1].avaliacao, 5.0);
          
          // Verificar terceiro profissional
          expect(professionals[2].nome, 'Carlos Oliveira');
          expect(professionals[2].especialidade, Speciality.acompanhantesHospital);
        },
      );

      verify(mockRepository.getAllProfessionals()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar lista vazia quando não existem profissionais cadastrados', () async {
      // Arrange
      when(mockRepository.getAllProfessionals())
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista vazia'),
        (professionals) {
          expect(professionals, isEmpty);
        },
      );

      verify(mockRepository.getAllProfessionals()).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro ao buscar profissionais', () async {
      // Arrange
      when(mockRepository.getAllProfessionals())
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, isA<Left<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (professionals) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.getAllProfessionals()).called(1);
    });
  });
}
