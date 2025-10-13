/// Testes para GetContractsByProfessional Use Case
library;

import 'package:app_sanitaria/core/error/failures.dart';
import 'package:app_sanitaria/domain/entities/contract_entity.dart';
import 'package:app_sanitaria/domain/entities/contract_status.dart';
import 'package:app_sanitaria/domain/repositories/contracts_repository.dart';
import 'package:app_sanitaria/domain/usecases/contracts/get_contracts_by_professional.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.mocks.dart';

@GenerateMocks([ContractsRepository])
void main() {
  late GetContractsByProfessional useCase;
  late MockContractsRepository mockRepository;

  setUp(() {
    mockRepository = MockContractsRepository();
    useCase = GetContractsByProfessional(mockRepository);
  });

  group('GetContractsByProfessional', () {
    const tProfessionalId = 'prof456';
    
    final tContract = ContractEntity(
      id: 'contract1',
      patientId: 'patient123',
      professionalId: tProfessionalId,
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

    test('deve retornar lista de contratos do profissional', () async {
      // Arrange
      when(mockRepository.getContractsByProfessional(tProfessionalId))
          .thenAnswer((_) async => Right([tContract]));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Right<Failure, List<ContractEntity>>>());
      result.fold(
        (failure) => fail('Deveria retornar contratos'),
        (contracts) {
          expect(contracts.length, 1);
          expect(contracts[0].professionalId, tProfessionalId);
        },
      );

      verify(mockRepository.getContractsByProfessional(tProfessionalId)).called(1);
    });

    test('deve retornar lista vazia', () async {
      // Arrange
      when(mockRepository.getContractsByProfessional(tProfessionalId))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(tProfessionalId);

      // Assert
      expect(result, isA<Right<Failure, List<ContractEntity>>>());
      verify(mockRepository.getContractsByProfessional(tProfessionalId)).called(1);
    });
  });
}
