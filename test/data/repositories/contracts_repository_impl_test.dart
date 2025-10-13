import 'package:app_sanitaria/core/error/exceptions.dart';
import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/data/datasources/firebase_contracts_datasource.dart';
import 'package:app_sanitaria/data/repositories/contracts_repository_impl.dart';
import 'package:app_sanitaria/domain/entities/contract_entity.dart';
import 'package:app_sanitaria/domain/entities/contract_status.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([FirebaseContractsDataSource])
import 'contracts_repository_impl_test.mocks.dart';

void main() {
  late ContractsRepositoryImpl repository;
  late MockFirebaseContractsDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockFirebaseContractsDataSource();
    repository = ContractsRepositoryImpl(dataSource: mockDataSource);
  });

  final tContract1 = ContractEntity(
    id: '1',
    professionalId: 'prof-1',
    patientId: 'patient-1',
    service: 'Consulta médica',
    period: 'Diário',
    time: '09:00',
    address: 'Rua Teste, 123',
    date: DateTime(2025, 10, 15),
    duration: 60,
    price: 150,
    createdAt: DateTime(2025, 10, 7),
  );

  final tContract2 = ContractEntity(
    id: '2',
    professionalId: 'prof-2',
    patientId: 'patient-1',
    service: 'Fisioterapia',
    period: 'Semanal',
    time: '14:00',
    address: 'Av. Principal, 456',
    date: DateTime(2025, 10, 20),
    duration: 90,
    price: 200,
    status: ContractStatus.confirmed,
    createdAt: DateTime(2025, 10, 8),
  );

  group('ContractsRepositoryImpl', () {
    group('createContract', () {
      test('deve criar contrato com sucesso', () async {
        // arrange
        when(mockDataSource.createContract(any))
            .thenAnswer((_) async => tContract1);

        // act
        final result = await repository.createContract(tContract1);

        // assert
        expect(result, Right<Failure, dynamic>(tContract1));
        verify(mockDataSource.createContract(tContract1));
      });

      test('deve retornar StorageFailure quando ocorre erro ao criar',
          () async {
        // arrange
        when(mockDataSource.createContract(any))
            .thenThrow(const LocalStorageException('Erro ao criar contrato'));

        // act
        final result = await repository.createContract(tContract1);

        // assert
        expect(result, const Left<Failure, dynamic>(StorageFailure('Erro ao criar contrato')));
      });
    });

    group('getContractsByPatient', () {
      test('deve retornar lista de contratos do paciente', () async {
        // arrange
        const patientId = 'patient-1';
        when(mockDataSource.getContractsByPatient(patientId))
            .thenAnswer((_) async => [tContract1, tContract2]);

        // act
        final result = await repository.getContractsByPatient(patientId);

        // assert
        expect(result, Right<Failure, dynamic>([tContract1, tContract2]));
        verify(mockDataSource.getContractsByPatient(patientId));
      });

      test('deve retornar lista vazia quando não houver contratos', () async {
        // arrange
        const patientId = 'patient-sem-contratos';
        when(mockDataSource.getContractsByPatient(patientId))
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getContractsByPatient(patientId);

        // assert
        expect(result, const Right<Failure, dynamic>(<dynamic>[]));
      });

      test('deve retornar StorageFailure quando ocorre erro', () async {
        // arrange
        const patientId = 'patient-1';
        when(mockDataSource.getContractsByPatient(patientId))
            .thenThrow(const LocalStorageException('Erro'));

        // act
        final result = await repository.getContractsByPatient(patientId);

        // assert
        expect(result, const Left<Failure, dynamic>(StorageFailure('Erro')));
      });
    });

    group('getContractsByProfessional', () {
      test('deve retornar lista de contratos do profissional', () async {
        // arrange
        const professionalId = 'prof-1';
        when(mockDataSource.getContractsByProfessional(professionalId))
            .thenAnswer((_) async => [tContract1]);

        // act
        final result =
            await repository.getContractsByProfessional(professionalId);

        // assert
        expect(result, Right<Failure, dynamic>([tContract1]));
        verify(mockDataSource.getContractsByProfessional(professionalId));
      });

      test('deve retornar lista vazia quando não houver contratos', () async {
        // arrange
        const professionalId = 'prof-sem-contratos';
        when(mockDataSource.getContractsByProfessional(professionalId))
            .thenAnswer((_) async => []);

        // act
        final result =
            await repository.getContractsByProfessional(professionalId);

        // assert
        expect(result, const Right<Failure, dynamic>(<dynamic>[]));
      });

      test('deve retornar StorageFailure quando ocorre erro', () async {
        // arrange
        const professionalId = 'prof-1';
        when(mockDataSource.getContractsByProfessional(professionalId))
            .thenThrow(const LocalStorageException('Erro'));

        // act
        final result =
            await repository.getContractsByProfessional(professionalId);

        // assert
        expect(result, const Left<Failure, dynamic>(StorageFailure('Erro')));
      });
    });

    group('updateContractStatus', () {
      test('deve atualizar status com sucesso', () async {
        // arrange
        const contractId = '1';
        const newStatus = ContractStatus.confirmed;
        when(mockDataSource.getContractById(contractId))
            .thenAnswer((_) async => tContract1);
        when(mockDataSource.updateContract(any)).thenAnswer((_) async => {});

        // act
        final result =
            await repository.updateContractStatus(contractId, newStatus);

        // assert
        result.fold(
          (failure) => fail('Should return Right'),
          (contract) {
            expect(contract.id, tContract1.id);
            expect(contract.status, newStatus);
          },
        );
        verify(mockDataSource.getContractById(contractId));
        verify(mockDataSource.updateContract(any));
      });

      test('deve retornar NotFoundFailure quando contrato não existe',
          () async {
        // arrange
        const contractId = 'nao-existe';
        const newStatus = ContractStatus.confirmed;
        when(mockDataSource.getContractById(contractId))
            .thenAnswer((_) async => null);

        // act
        final result =
            await repository.updateContractStatus(contractId, newStatus);

        // assert
        expect(result,
            const Left<Failure, ContractEntity>(NotFoundFailure('Contrato')));
      });

      test('deve retornar StorageFailure quando ocorre erro', () async {
        // arrange
        const contractId = '1';
        const newStatus = ContractStatus.cancelled;
        when(mockDataSource.getContractById(contractId))
            .thenThrow(const LocalStorageException('Erro'));

        // act
        final result =
            await repository.updateContractStatus(contractId, newStatus);

        // assert
        expect(result, const Left<Failure, ContractEntity>(StorageFailure()));
      });
    });
  });
}
