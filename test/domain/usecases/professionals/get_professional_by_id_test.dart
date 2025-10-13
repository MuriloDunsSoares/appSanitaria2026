/// Testes para GetProfessionalById Use Case
/// 
/// Objetivo: Validar busca de profissional específico por ID
/// Regras de negócio:
/// - Deve retornar profissional quando ID existe
/// - Deve retornar NotFoundFailure quando ID não existe
/// - Deve retornar StorageFailure se erro ao buscar
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';
import 'package:app_sanitaria/domain/repositories/professionals_repository.dart';
import 'package:app_sanitaria/domain/usecases/professionals/get_professional_by_id.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

// Gerar mock: dart run build_runner build
@GenerateMocks([ProfessionalsRepository])
void main() {
  late GetProfessionalById useCase;
  late MockProfessionalsRepository mockRepository;

  setUp(() {
    mockRepository = MockProfessionalsRepository();
    useCase = GetProfessionalById(mockRepository);
  });

  group('GetProfessionalById', () {
    // Dados REALISTAS para testes
    const tProfessionalId = 'prof123';
    
    final tProfessional = ProfessionalEntity(
      id: tProfessionalId,
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
      biografia: 'Técnico em enfermagem com 10 anos de experiência em cuidados domiciliares e hospitalares. Especializado em cuidados paliativos.',
      avaliacao: 4.8,
      hourlyRate: 75.0,
      averageRating: 4.8,
    );

    test('deve retornar profissional quando ID existe', () async {
      // Arrange
      when(mockRepository.getProfessionalById(tProfessionalId))
          .thenAnswer((_) async => Right(tProfessional));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Right<Failure, ProfessionalEntity>>());
      result.fold(
        (failure) => fail('Deveria retornar profissional'),
        (professional) {
          expect(professional.id, tProfessionalId);
          expect(professional.nome, 'João Santos');
          expect(professional.email, 'joao.santos@email.com');
          expect(professional.especialidade, Speciality.tecnicosEnfermagem);
          expect(professional.experiencia, 10);
          expect(professional.biografia, contains('cuidados paliativos'));
          expect(professional.hourlyRate, 75.0);
          expect(professional.averageRating, 4.8);
        },
      );

      verify(mockRepository.getProfessionalById(tProfessionalId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar NotFoundFailure quando profissional não existe', () async {
      // Arrange
      const tInvalidId = 'prof_nao_existe';
      
      when(mockRepository.getProfessionalById(tInvalidId))
          .thenAnswer((_) async => const Left(NotFoundFailure('Profissional')));

      // Act
      final result = await useCase(tInvalidId);

      // Assert
      expect(result, isA<Left<Failure, ProfessionalEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
        },
        (professional) => fail('Deveria retornar NotFoundFailure'),
      );

      verify(mockRepository.getProfessionalById(tInvalidId)).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro ao buscar profissional', () async {
      // Arrange
      when(mockRepository.getProfessionalById(tProfessionalId))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Left<Failure, ProfessionalEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (professional) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.getProfessionalById(tProfessionalId)).called(1);
    });

    test('deve buscar profissional com ID vazio sem erro', () async {
      // Arrange
      const tEmptyId = '';
      
      when(mockRepository.getProfessionalById(tEmptyId))
          .thenAnswer((_) async => const Left(NotFoundFailure('Profissional')));

      // Act
      final result = await useCase(tEmptyId);

      // Assert
      expect(result, isA<Left<Failure, ProfessionalEntity>>());

      verify(mockRepository.getProfessionalById(tEmptyId)).called(1);
    });
  });
}
