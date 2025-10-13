/// Testes para SearchProfessionals Use Case
///
/// Objetivo: Validar busca de profissionais por query (nome, cidade, especialidade)
/// Regras de negócio:
/// - Deve retornar profissionais que correspondem à query
/// - Busca deve ser case-insensitive
/// - Lista pode ser vazia (nenhum resultado)
/// - Deve retornar StorageFailure se erro ao buscar
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';
import 'package:app_sanitaria/domain/repositories/professionals_repository.dart';
import 'package:app_sanitaria/domain/usecases/professionals/search_professionals.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

// Gerar mock: dart run build_runner build
@GenerateMocks([ProfessionalsRepository])
void main() {
  late SearchProfessionals useCase;
  late MockProfessionalsRepository mockRepository;

  setUp(() {
    mockRepository = MockProfessionalsRepository();
    useCase = SearchProfessionals(mockRepository);
  });

  group('SearchProfessionals', () {
    // Dados REALISTAS para testes
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
      formacao: 'Técnico em Enfermagem - SENAC 2010',
      certificados: 'COREN 123456-SP',
      experiencia: 10,
      biografia: 'Técnico especializado em cuidados domiciliares.',
      avaliacao: 4.8,
      hourlyRate: 75,
      averageRating: 4.8,
    );

    test('deve retornar profissionais quando busca por nome', () async {
      // Arrange
      const tParams = SearchProfessionalsParams(searchQuery: 'João');

      when(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).thenAnswer((_) async => Right([tProfessional]));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar profissionais'),
        (professionals) {
          expect(professionals.length, 1);
          expect(professionals[0].nome, contains('João'));
        },
      );

      verify(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('deve retornar profissionais quando busca por cidade', () async {
      // Arrange
      const tParams = SearchProfessionalsParams(searchQuery: 'São Paulo');

      when(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).thenAnswer((_) async => Right([tProfessional]));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar profissionais'),
        (professionals) {
          expect(professionals.length, 1);
          expect(professionals[0].cidade, 'São Paulo');
        },
      );

      verify(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).called(1);
    });

    test('deve retornar profissionais quando busca por especialidade',
        () async {
      // Arrange
      const tParams = SearchProfessionalsParams(searchQuery: 'enfermagem');

      when(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).thenAnswer((_) async => Right([tProfessional]));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar profissionais'),
        (professionals) {
          expect(professionals.length, 1);
          expect(professionals[0].especialidade.displayName,
              contains('enfermagem'));
        },
      );

      verify(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).called(1);
    });

    test(
        'deve retornar lista vazia quando nenhum profissional corresponde à busca',
        () async {
      // Arrange
      const tParams = SearchProfessionalsParams(searchQuery: 'XYZ Inexistente');

      when(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista vazia'),
        (professionals) {
          expect(professionals, isEmpty);
        },
      );

      verify(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).called(1);
    });

    test('deve retornar lista vazia quando query está vazia', () async {
      // Arrange
      const tParams = SearchProfessionalsParams(searchQuery: '');

      when(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Right<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar lista vazia'),
        (professionals) {
          expect(professionals, isEmpty);
        },
      );

      verify(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro na busca', () async {
      // Arrange
      const tParams = SearchProfessionalsParams(searchQuery: 'João');

      when(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, isA<Left<Failure, List<ProfessionalEntity>>>());
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
        },
        (professionals) => fail('Deveria retornar StorageFailure'),
      );

      verify(mockRepository.searchProfessionals(
        searchQuery: anyNamed('searchQuery'),
        speciality: anyNamed('speciality'),
        city: anyNamed('city'),
        minRating: anyNamed('minRating'),
        maxPrice: anyNamed('maxPrice'),
        minPrice: anyNamed('minPrice'),
        minExperience: anyNamed('minExperience'),
        availableNow: anyNamed('availableNow'),
      )).called(1);
    });
  });
}
