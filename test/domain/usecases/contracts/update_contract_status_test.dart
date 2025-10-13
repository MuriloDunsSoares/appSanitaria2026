/// Testes para UpdateContractStatus Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/contract_entity.dart';
import 'package:app_sanitaria/domain/entities/contract_status.dart';
import 'package:app_sanitaria/domain/repositories/contracts_repository.dart';
import 'package:app_sanitaria/domain/usecases/contracts/update_contract_status.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ContractsRepository])
void main() {
  late UpdateContractStatus useCase;
  late MockContractsRepository mockRepository;

  setUp(() {
    mockRepository = MockContractsRepository();
    useCase = UpdateContractStatus(mockRepository);
  });

  group('UpdateContractStatus', () {
    const tContractId = 'contract123';
    const tNewStatus = ContractStatus.confirmed;
    
    final tUpdatedContract = ContractEntity(
      id: tContractId,
      patientId: 'patient123',
      professionalId: 'prof456',
      patientName: 'Maria Silva',
      professionalName: 'João Santos',
      serviceType: 'Cuidados domiciliares',
      period: 'Semanal',
      duration: 40,
      date: DateTime(2025, 10, 15),
      time: '08:00',
      address: 'Rua das Flores, 123',
      status: tNewStatus,
      totalValue: 3000.0,
      createdAt: DateTime(2025, 10, 1),
      updatedAt: DateTime(2025, 10, 9),
    );

    test('deve atualizar status do contrato com sucesso', () async {
      // Arrange
      final params = UpdateContractStatusParams(
        contractId: tContractId,
        newStatus: tNewStatus,
      );
      
      when(mockRepository.updateContractStatus(tContractId, tNewStatus))
          .thenAnswer((_) async => Right(tUpdatedContract));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, isA<Right<Failure, ContractEntity>>());
      result.fold(
        (failure) => fail('Deveria retornar contrato atualizado'),
        (contract) {
          expect(contract.id, tContractId);
          expect(contract.status, ContractStatus.confirmed);
        },
      );

      verify(mockRepository.updateContractStatus(tContractId, tNewStatus)).called(1);
    });

    test('deve retornar NotFoundFailure quando contrato não existe', () async {
      // Arrange
      final params = UpdateContractStatusParams(
        contractId: 'invalid_id',
        newStatus: tNewStatus,
      );
      
      when(mockRepository.updateContractStatus('invalid_id', tNewStatus))
          .thenAnswer((_) async => const Left(NotFoundFailure('Contrato')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, isA<Left<Failure, ContractEntity>>());
      verify(mockRepository.updateContractStatus('invalid_id', tNewStatus)).called(1);
    });
  });
}
