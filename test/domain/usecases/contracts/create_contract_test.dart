/// Testes para CreateContract Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/contract_entity.dart';
import 'package:app_sanitaria/domain/entities/contract_status.dart';
import 'package:app_sanitaria/domain/repositories/contracts_repository.dart';
import 'package:app_sanitaria/domain/usecases/contracts/create_contract.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ContractsRepository])
void main() {
  late CreateContract useCase;
  late MockContractsRepository mockRepository;

  setUp(() {
    mockRepository = MockContractsRepository();
    useCase = CreateContract(mockRepository);
  });

  group('CreateContract', () {
    final tContract = ContractEntity(
      id: '',
      patientId: 'patient123',
      professionalId: 'prof456',
      patientName: 'Maria Silva',
      professionalName: 'João Santos',
      serviceType: 'Cuidados domiciliares',
      period: 'Semanal',
      duration: 40,
      date: DateTime(2025, 10, 15),
      time: '08:00',
      address: 'Rua das Flores, 123 - São Paulo/SP',
      observations: 'Paciente com mobilidade reduzida',
      status: ContractStatus.pending,
      totalValue: 3000.0,
      createdAt: DateTime(2025, 10, 9),
    );

    final tCreatedContract = ContractEntity(
      id: 'contract123',
      patientId: tContract.patientId,
      professionalId: tContract.professionalId,
      patientName: tContract.patientName,
      professionalName: tContract.professionalName,
      serviceType: tContract.serviceType,
      period: tContract.period,
      duration: tContract.duration,
      date: tContract.date,
      time: tContract.time,
      address: tContract.address,
      observations: tContract.observations,
      status: tContract.status,
      totalValue: tContract.totalValue,
      createdAt: tContract.createdAt,
    );

    test('deve criar contrato com sucesso', () async {
      // Arrange
      final params = CreateContractParams(tContract);
      
      when(mockRepository.createContract(tContract))
          .thenAnswer((_) async => Right(tCreatedContract));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, isA<Right<Failure, ContractEntity>>());
      result.fold(
        (failure) => fail('Deveria retornar contrato criado'),
        (contract) {
          expect(contract.id, isNotEmpty);
          expect(contract.patientId, 'patient123');
          expect(contract.professionalId, 'prof456');
          expect(contract.status, ContractStatus.pending);
        },
      );

      verify(mockRepository.createContract(tContract)).called(1);
    });

    test('deve retornar StorageFailure quando falha ao criar', () async {
      // Arrange
      final params = CreateContractParams(tContract);
      
      when(mockRepository.createContract(tContract))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, isA<Left<Failure, ContractEntity>>());
      verify(mockRepository.createContract(tContract)).called(1);
    });
  });
}
