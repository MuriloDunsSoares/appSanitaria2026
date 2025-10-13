import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:app_sanitaria/core/error/exceptions.dart';
import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/data/datasources/firebase_professionals_datasource.dart';
import 'package:app_sanitaria/data/repositories/professionals_repository_impl.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';

@GenerateMocks([FirebaseProfessionalsDataSource])
import 'professionals_repository_impl_test.mocks.dart';

void main() {
  late ProfessionalsRepositoryImpl repository;
  late MockFirebaseProfessionalsDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockFirebaseProfessionalsDataSource();
    repository = ProfessionalsRepositoryImpl(
      firebaseProfessionalsDataSource: mockDataSource,
    );
  });

  final tProfessional1 = ProfessionalEntity(
    id: '1',
    nome: 'Dr. João Silva',
    email: 'joao@teste.com',
    password: '123456',
    telefone: '11999999999',
    dataNascimento: DateTime(1980, 1, 1),
    endereco: 'Rua Teste, 123',
    cidade: 'São Paulo',
    estado: 'SP',
    sexo: 'M',
    especialidade: Speciality.enfermeiros,
    experiencia: 10,
    avaliacao: 4.5,
    certificados: 'COREN-SP-123456',
    formacao: 'Enfermagem',
    biografia: 'Enfermeiro experiente',
    dataCadastro: DateTime(2025, 10, 7),
  );

  final tProfessional2 = ProfessionalEntity(
    id: '2',
    nome: 'Dra. Maria Santos',
    email: 'maria@teste.com',
    password: '123456',
    telefone: '11988888888',
    dataNascimento: DateTime(1985, 5, 15),
    endereco: 'Av. Brasil, 456',
    cidade: 'Rio de Janeiro',
    estado: 'RJ',
    sexo: 'F',
    especialidade: Speciality.tecnicosEnfermagem,
    experiencia: 8,
    avaliacao: 4.8,
    certificados: 'COREN-RJ-789012',
    formacao: 'Técnico em Enfermagem',
    biografia: 'Técnica especializada',
    dataCadastro: DateTime(2025, 10, 6),
  );

  group('ProfessionalsRepositoryImpl - getAllProfessionals', () {
    test('deve retornar lista de profissionais quando há profissionais cadastrados', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => [tProfessional1, tProfessional2]);

      // act
      final result = await repository.getAllProfessionals();

      // assert
      expect(result, Right([tProfessional1, tProfessional2]));
      verify(mockDataSource.getAllProfessionals());
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve retornar lista vazia quando não há profissionais cadastrados', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => []);

      // act
      final result = await repository.getAllProfessionals();

      // assert
      expect(result, const Right([]));
      verify(mockDataSource.getAllProfessionals());
    });

    test('deve retornar StorageFailure quando ocorre LocalStorageException', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenThrow(const LocalStorageException('Erro ao buscar profissionais'));

      // act
      final result = await repository.getAllProfessionals();

      // assert
      expect(result, const Left(StorageFailure()));
      verify(mockDataSource.getAllProfessionals());
    });

    test('deve retornar UnexpectedFailure quando ocorre exceção inesperada', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenThrow(Exception('Erro inesperado'));

      // act
      final result = await repository.getAllProfessionals();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<UnexpectedFailure>()),
        (_) => fail('Deveria retornar failure'),
      );
    });
  });

  group('ProfessionalsRepositoryImpl - getProfessionalById', () {
    test('deve retornar profissional quando ID existe', () async {
      // arrange
      const professionalId = '1';
      when(mockDataSource.getProfessionalById(professionalId))
          .thenAnswer((_) async => tProfessional1);

      // act
      final result = await repository.getProfessionalById(professionalId);

      // assert
      expect(result, Right(tProfessional1));
      verify(mockDataSource.getProfessionalById(professionalId));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('deve retornar NotFoundFailure quando profissional não existe', () async {
      // arrange
      const professionalId = 'nao-existe';
      when(mockDataSource.getProfessionalById(professionalId))
          .thenThrow(const NotFoundException('Profissional', 'nao-existe'));

      // act
      final result = await repository.getProfessionalById(professionalId);

      // assert
      expect(result, const Left(NotFoundFailure('Profissional')));
      verify(mockDataSource.getProfessionalById(professionalId));
    });

    test('deve retornar StorageFailure quando ocorre LocalStorageException', () async {
      // arrange
      const professionalId = '1';
      when(mockDataSource.getProfessionalById(professionalId))
          .thenThrow(const LocalStorageException('Erro'));

      // act
      final result = await repository.getProfessionalById(professionalId);

      // assert
      expect(result, const Left(StorageFailure()));
    });
  });

  group('ProfessionalsRepositoryImpl - searchProfessionals', () {
    test('deve retornar todos profissionais quando não há filtros', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => [tProfessional1, tProfessional2]);

      // act
      final result = await repository.searchProfessionals();

      // assert
      expect(result, Right([tProfessional1, tProfessional2]));
      verify(mockDataSource.getAllProfessionals());
    });

    test('deve filtrar profissionais por especialidade', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => [tProfessional1, tProfessional2]);

      // act
      final result = await repository.searchProfessionals(
        speciality: Speciality.enfermeiros,
      );

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Deveria retornar lista'),
        (professionals) {
          expect(professionals.length, 1);
          expect(professionals.first.especialidade, Speciality.enfermeiros);
        },
      );
    });

    test('deve filtrar profissionais por cidade', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => [tProfessional1, tProfessional2]);

      // act
      final result = await repository.searchProfessionals(
        city: 'São Paulo',
      );

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Deveria retornar lista'),
        (professionals) {
          expect(professionals.length, 1);
          expect(professionals.first.cidade, 'São Paulo');
        },
      );
    });

    test('deve retornar lista vazia quando não encontrar resultados', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => [tProfessional1, tProfessional2]);

      // act
      final result = await repository.searchProfessionals(
        city: 'Brasília',
      );

      // assert
      expect(result, const Right([]));
    });
  });

  group('ProfessionalsRepositoryImpl - getProfessionalsBySpeciality', () {
    test('deve retornar profissionais da especialidade solicitada', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => [tProfessional1, tProfessional2]);

      // act
      final result = await repository.getProfessionalsBySpeciality(
        Speciality.enfermeiros,
      );

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Deveria retornar lista'),
        (professionals) {
          expect(professionals.length, 1);
          expect(professionals.first.especialidade, Speciality.enfermeiros);
        },
      );
      verify(mockDataSource.getAllProfessionals());
    });

    test('deve retornar lista vazia quando não há profissionais da especialidade', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => [tProfessional1, tProfessional2]);

      // act
      final result = await repository.getProfessionalsBySpeciality(
        Speciality.cuidadores,
      );

      // assert
      expect(result, const Right([]));
    });
  });

  group('ProfessionalsRepositoryImpl - getProfessionalsByCity', () {
    test('deve retornar profissionais da cidade solicitada', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => [tProfessional1, tProfessional2]);

      // act
      final result = await repository.getProfessionalsByCity('São Paulo');

      // assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Deveria retornar lista'),
        (professionals) {
          expect(professionals.length, 1);
          expect(professionals.first.cidade, 'São Paulo');
        },
      );
      verify(mockDataSource.getAllProfessionals());
    });

    test('deve retornar lista vazia quando não há profissionais na cidade', () async {
      // arrange
      when(mockDataSource.getAllProfessionals())
          .thenAnswer((_) async => [tProfessional1, tProfessional2]);

      // act
      final result = await repository.getProfessionalsByCity('Brasília');

      // assert
      expect(result, const Right([]));
    });
  });
}
