/// Testes para GetProfessionalsBySpeciality Use Case
///
/// Objetivo: Validar busca de profissionais por especialidade
/// Regras de negócio:
/// - Deve retornar apenas profissionais da especialidade solicitada
/// - Lista pode ser vazia (nenhum profissional naquela especialidade)
/// - Deve retornar StorageFailure se erro ao buscar
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';
import 'package:app_sanitaria/domain/repositories/professionals_repository.dart';
import 'package:app_sanitaria/domain/usecases/professionals/get_professionals_by_speciality.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

// Gerar mock: dart run build_runner build
@GenerateMocks([ProfessionalsRepository])
void main() {
  late GetProfessionalsBySpeciality useCase;
  late MockProfessionalsRepository mockRepository;

  setUp(() {
    mockRepository = MockProfessionalsRepository();
    useCase = GetProfessionalsBySpeciality(mockRepository);
  });

  group('GetProfessionalsBySpeciality', () {
    // Dados REALISTAS para testes
    final tProfessional1 = ProfessionalEntity(
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
      formacao: 'Técnico em Enfermagem - SENAC 2010',
      certificados: 'COREN 123456-SP',
      experiencia: 10,
      biografia: 'Técnico especializado em cuidados domiciliares.',
      avaliacao: 4.8,
      hourlyRate: 75,
      averageRating: 4.8,
    );

    final tProfessional2 = ProfessionalEntity(
      id: 'prof456',
      nome: 'Maria Fernandes',
      email: 'maria.fernandes@email.com',
      password: 'senha456',
      telefone: '(11) 98765-4321',
      dataNascimento: DateTime(1988, 7, 15),
      endereco: 'Rua Augusta, 500',
      cidade: 'São Paulo',
      estado: 'SP',
      sexo: 'Feminino',
      dataCadastro: DateTime(2024, 7, 10),
      especialidade: Speciality.tecnicosEnfermagem,
      formacao: 'Técnico em Enfermagem - UNIFESP 2012',
      certificados: 'COREN 789012-SP',
      experiencia: 8,
      biografia: 'Técnica com experiência em pediatria.',
      avaliacao: 4.9,
      hourlyRate: 70,
      averageRating: 4.9,
    );

    final tTecnicosEnfermagem = [tProfessional1, tProfessional2];
    const tSpeciality = Speciality.tecnicosEnfermagem;

    test(
        'deve retornar lista de profissionais da especialidade quando existem profissionais',
        () async {
      // Arrange
      when(mockRepository.getProfessionalsBySpeciality(tSpeciality))
          .thenAnswer((_) async => Right(tTecnicosEnfermagem));

      // Act
      final result = await useCase(tSpeciality);

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista de profissionais'),
        (professionals) {
          expect(professionals.length, 2);

          // Todos devem ser da especialidade solicitada
          expect(professionals[0].especialidade, Speciality.tecnicosEnfermagem);
          expect(professionals[1].especialidade, Speciality.tecnicosEnfermagem);

          // Verificar dados específicos
          expect(professionals[0].nome, 'João Santos');
          expect(professionals[0].experiencia, 10);
          expect(professionals[1].nome, 'Maria Fernandes');
          expect(professionals[1].experiencia, 8);
        },
      );

      verify(mockRepository.getProfessionalsBySpeciality(tSpeciality))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
        'deve retornar lista vazia quando não existem profissionais da especialidade',
        () async {
      // Arrange
      const tSpecialityVazia = Speciality.enfermeiros;

      when(mockRepository.getProfessionalsBySpeciality(tSpecialityVazia))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(tSpecialityVazia);

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista vazia'),
        (professionals) {
          expect(professionals, isEmpty);
        },
      );

      verify(mockRepository.getProfessionalsBySpeciality(tSpecialityVazia))
          .called(1);
    });

    test(
        'deve retornar StorageFailure quando ocorre erro ao buscar profissionais',
        () async {
      // Arrange
      when(mockRepository.getProfessionalsBySpeciality(tSpeciality))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tSpeciality);

      // Assert
      expect(result, isA<Left<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (professionals) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.getProfessionalsBySpeciality(tSpeciality))
          .called(1);
    });

    test('deve funcionar corretamente para cada tipo de especialidade',
        () async {
      // Arrange - Teste com Cuidadores
      const tCuidadores = Speciality.cuidadores;
      final tCuidadorProfessional = ProfessionalEntity(
        id: 'prof789',
        nome: 'Ana Costa',
        email: 'ana.costa@email.com',
        password: 'senha789',
        telefone: '(11) 99876-5432',
        dataNascimento: DateTime(1990, 5, 10),
        endereco: 'Rua da Consolação, 800',
        cidade: 'São Paulo',
        estado: 'SP',
        sexo: 'Feminino',
        dataCadastro: DateTime(2024, 8),
        especialidade: Speciality.cuidadores,
        formacao: 'Curso de Cuidador de Idosos',
        certificados: 'Certificado Nacional',
        experiencia: 5,
        biografia: 'Cuidadora especializada em idosos.',
        avaliacao: 5,
        hourlyRate: 60,
        averageRating: 5,
      );

      when(mockRepository.getProfessionalsBySpeciality(tCuidadores))
          .thenAnswer((_) async => Right([tCuidadorProfessional]));

      // Act
      final result = await useCase(tCuidadores);

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar cuidadores'),
        (professionals) {
          expect(professionals.length, 1);
          expect(professionals[0].especialidade, Speciality.cuidadores);
        },
      );

      verify(mockRepository.getProfessionalsBySpeciality(tCuidadores))
          .called(1);
    });
  });
}
