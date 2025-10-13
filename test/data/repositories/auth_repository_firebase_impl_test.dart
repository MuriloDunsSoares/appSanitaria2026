import 'package:app_sanitaria/core/error/exceptions.dart';
import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/data/datasources/firebase_auth_datasource.dart';
import 'package:app_sanitaria/data/repositories/auth_repository_firebase_impl.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FirebaseAuthDataSource])
import 'auth_repository_firebase_impl_test.mocks.dart';

void main() {
  late AuthRepositoryFirebaseImpl repository;
  late MockFirebaseAuthDataSource mockFirebaseAuthDataSource;

  setUp(() {
    mockFirebaseAuthDataSource = MockFirebaseAuthDataSource();
    repository = AuthRepositoryFirebaseImpl(
      firebaseAuthDataSource: mockFirebaseAuthDataSource,
    );
  });

  final tPatient = PatientEntity(
    id: '1',
    nome: 'João Silva',
    email: 'joao@teste.com',
    password: '123456',
    telefone: '11999999999',
    dataNascimento: DateTime(1990),
    endereco: 'Rua Teste, 123',
    cidade: 'São Paulo',
    estado: 'SP',
    sexo: 'M',
    condicoesMedicas: 'Nenhuma',
    dataCadastro: DateTime(2025, 10, 7),
  );

  final tProfessional = ProfessionalEntity(
    id: '2',
    nome: 'Dr. João Silva',
    email: 'doutor@teste.com',
    password: '123456',
    telefone: '11999999999',
    dataNascimento: DateTime(1980),
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

  group('AuthRepositoryFirebaseImpl - login', () {
    test('deve fazer login com sucesso via Firebase/Hybrid', () async {
      // arrange
      when(mockFirebaseAuthDataSource.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => tPatient);

      // act
      final result = await repository.login(
        email: 'joao@teste.com',
        password: '123456',
      );

      // assert
      expect(result, Right<Failure, dynamic>(tPatient));
      verify(mockFirebaseAuthDataSource.login(
        email: 'joao@teste.com',
        password: '123456',
      ));
      verifyNoMoreInteractions(mockFirebaseAuthDataSource);
    });

    test('deve retornar InvalidCredentialsFailure quando credenciais inválidas',
        () async {
      // arrange
      when(mockFirebaseAuthDataSource.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(const InvalidCredentialsException('Senha incorreta'));

      // act
      final result = await repository.login(
        email: 'joao@teste.com',
        password: 'senha-errada',
      );

      // assert
      expect(result, const Left<Failure, dynamic>(InvalidCredentialsFailure()));
    });

    test('deve retornar UserNotFoundFailure quando usuário não existe',
        () async {
      // arrange
      when(mockFirebaseAuthDataSource.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(const UserNotFoundException('Usuário não encontrado'));

      // act
      final result = await repository.login(
        email: 'naoexiste@teste.com',
        password: '123456',
      );

      // assert
      expect(result, const Left<Failure, dynamic>(UserNotFoundFailure()));
    });

    test('deve retornar NetworkFailure quando sem conexão', () async {
      // arrange
      when(mockFirebaseAuthDataSource.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(const NetworkException('Sem conexão'));

      // act
      final result = await repository.login(
        email: 'joao@teste.com',
        password: '123456',
      );

      // assert
      expect(result, const Left<Failure, dynamic>(NetworkFailure()));
    });

    test('deve retornar StorageFailure quando ocorre erro genérico', () async {
      // arrange
      when(mockFirebaseAuthDataSource.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Erro inesperado'));

      // act
      final result = await repository.login(
        email: 'joao@teste.com',
        password: '123456',
      );

      // assert
      expect(result, const Left<Failure, dynamic>(StorageFailure()));
    });
  });

  group('AuthRepositoryFirebaseImpl - registerPatient', () {
    test('deve registrar paciente com sucesso', () async {
      // arrange
      when(mockFirebaseAuthDataSource.registerPatient(any))
          .thenAnswer((_) async => tPatient);

      // act
      final result = await repository.registerPatient(tPatient);

      // assert
      expect(result, Right<Failure, dynamic>(tPatient));
      verify(mockFirebaseAuthDataSource.registerPatient(tPatient));
      verifyNoMoreInteractions(mockFirebaseAuthDataSource);
    });

    test('deve retornar EmailAlreadyExistsFailure quando email já cadastrado',
        () async {
      // arrange
      when(mockFirebaseAuthDataSource.registerPatient(any))
          .thenThrow(const EmailAlreadyExistsException('Email já existe'));

      // act
      final result = await repository.registerPatient(tPatient);

      // assert
      expect(result, const Left<Failure, dynamic>(EmailAlreadyExistsFailure()));
    });

    test('deve retornar ValidationFailure quando dados inválidos', () async {
      // arrange
      when(mockFirebaseAuthDataSource.registerPatient(any))
          .thenThrow(const ValidationException('Email inválido'));

      // act
      final result = await repository.registerPatient(tPatient);

      // assert
      expect(result, const Left<Failure, dynamic>(ValidationFailure('Email inválido')));
    });

    test('deve retornar NetworkFailure quando sem conexão', () async {
      // arrange
      when(mockFirebaseAuthDataSource.registerPatient(any))
          .thenThrow(const NetworkException('Sem conexão'));

      // act
      final result = await repository.registerPatient(tPatient);

      // assert
      expect(result, const Left<Failure, dynamic>(NetworkFailure()));
    });
  });

  group('AuthRepositoryFirebaseImpl - registerProfessional', () {
    test('deve registrar profissional com sucesso', () async {
      // arrange
      when(mockFirebaseAuthDataSource.registerProfessional(any))
          .thenAnswer((_) async => tProfessional);

      // act
      final result = await repository.registerProfessional(tProfessional);

      // assert
      expect(result, Right<Failure, dynamic>(tProfessional));
      verify(mockFirebaseAuthDataSource.registerProfessional(tProfessional));
      verifyNoMoreInteractions(mockFirebaseAuthDataSource);
    });

    test('deve retornar EmailAlreadyExistsFailure quando email já cadastrado',
        () async {
      // arrange
      when(mockFirebaseAuthDataSource.registerProfessional(any))
          .thenThrow(const EmailAlreadyExistsException('Email já existe'));

      // act
      final result = await repository.registerProfessional(tProfessional);

      // assert
      expect(result, const Left<Failure, dynamic>(EmailAlreadyExistsFailure()));
    });
  });

  group('AuthRepositoryFirebaseImpl - logout', () {
    test('deve fazer logout com sucesso', () async {
      // arrange
      when(mockFirebaseAuthDataSource.logout()).thenAnswer((_) async => {});

      // act
      final result = await repository.logout();

      // assert
      expect(result, const Right<Failure, dynamic>(unit));
      verify(mockFirebaseAuthDataSource.logout());
    });

    test('deve retornar StorageFailure quando falha ao fazer logout', () async {
      // arrange
      when(mockFirebaseAuthDataSource.logout())
          .thenThrow(Exception('Erro ao fazer logout'));

      // act
      final result = await repository.logout();

      // assert
      expect(result, const Left<Failure, dynamic>(StorageFailure()));
    });
  });

  group('AuthRepositoryFirebaseImpl - getCurrentUser', () {
    test('deve retornar usuário atual quando autenticado', () async {
      // arrange
      when(mockFirebaseAuthDataSource.getCurrentUser())
          .thenAnswer((_) async => tPatient);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, Right<Failure, dynamic>(tPatient));
      verify(mockFirebaseAuthDataSource.getCurrentUser());
    });

    test('deve retornar UserNotFoundFailure quando não há usuário', () async {
      // arrange
      when(mockFirebaseAuthDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Left<Failure, dynamic>(UserNotFoundFailure()));
    });

    test('deve retornar StorageFailure quando ocorre erro', () async {
      // arrange
      when(mockFirebaseAuthDataSource.getCurrentUser())
          .thenThrow(Exception('Erro'));

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Left<Failure, dynamic>(StorageFailure()));
    });
  });

  group('AuthRepositoryFirebaseImpl - isAuthenticated', () {
    test('deve retornar true quando há usuário autenticado', () async {
      // arrange
      when(mockFirebaseAuthDataSource.getCurrentUser())
          .thenAnswer((_) async => tPatient);

      // act
      final result = await repository.isAuthenticated();

      // assert
      expect(result, const Right<Failure, dynamic>(true));
    });

    test('deve retornar false quando não há usuário autenticado', () async {
      // arrange
      when(mockFirebaseAuthDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.isAuthenticated();

      // assert
      expect(result, const Right<Failure, dynamic>(false));
    });
  });
}
