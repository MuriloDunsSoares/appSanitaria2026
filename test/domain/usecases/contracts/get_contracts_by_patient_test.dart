/// Testes para GetContractsByPatient Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/contract_entity.dart';
import 'package:app_sanitaria/domain/entities/contract_status.dart';
import 'package:app_sanitaria/domain/repositories/contracts_repository.dart';
import 'package:app_sanitaria/domain/usecases/contracts/get_contracts_by_patient.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ContractsRepository])
void main() {
  late GetContractsByPatient useCase;
  late MockContractsRepository mockRepository;

  setUp(() {
    mockRepository = MockContractsRepository();
    useCase = GetContractsByPatient(mockRepository);
  });

  group('GetContractsByPatient', () {
    const tPatientId = 'patient123';
    
    final tContract1 = ContractEntity(
      id: 'contract1',
      patientId: tPatientId,
      professionalId: 'prof456',
      patientName: 'Maria Silva',
      professionalName: 'João Santos',
      serviceType: 'Cuidados domiciliares',
      period: 'Semanal',
      duration: 40,
      date: DateTime(2025, 10, 15),
      time: '08:00',
      address: 'Rua das Flores, 123',
      status: ContractStatus.active,
      totalValue: 3000.0,
      createdAt: DateTime(2025, 10, 1),
    );

    final tContract2 = ContractEntity(
      id: 'contract2',
      patientId: tPatientId,
      professionalId: 'prof789',
      patientName: 'Maria Silva',
      professionalName: 'Ana Costa',
      serviceType: 'Acompanhamento hospitalar',
      period: 'Mensal',
      duration: 160,
      date: DateTime(2025, 11, 1),
      time: '09:00',
      address: 'Hospital São Paulo',
      status: ContractStatus.confirmed,
      totalValue: 9600.0,
      createdAt: DateTime(2025, 10, 5),
    );

    final tContracts = [tContract1, tContract2];

    test('deve retornar lista de contratos do paciente', () async {
      // Arrange
      when(mockRepository.getContractsByPatient(tPatientId))
          .thenAnswer((_) async => Right(tContracts));

      // Act
      final result = await useCase(tPatientId);

      // Assert
      expect(result, isA<Right<Failure, List<ContractEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar contratos'),
        (contracts) {
          expect(contracts.length, 2);
          expect(contracts[0].patientId, tPatientId);
          expect(contracts[1].patientId, tPatientId);
        },
      );

      verify(mockRepository.getContractsByPatient(tPatientId)).called(1);
    });

    test('deve retornar lista vazia quando paciente não tem contratos', () async {
      // Arrange
      when(mockRepository.getContractsByPatient(tPatientId))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(tPatientId);

      // Assert
      expect(result, isA<Right<Failure, List<ContractEntity>>>());
      verify(mockRepository.getContractsByPatient(tPatientId)).called(1);
    });

    test('deve retornar StorageFailure quando ocorre erro', () async {
      // Arrange
      when(mockRepository.getContractsByPatient(tPatientId))
          .thenAnswer((_) async => const Left(StorageFailure()));

      // Act
      final result = await useCase(tPatientId);

      // Assert
      expect(result, isA<Left<Failure, List<ContractEntity>>>());
      verify(mockRepository.getContractsByPatient(tPatientId)).called(1);
    });
  });
}
