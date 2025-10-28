/// ContractsProvider migrado para Clean Architecture com Use Cases.
library;

import 'package:app_sanitaria/core/di/injection_container.dart';
import 'package:app_sanitaria/domain/entities/contract_entity.dart';
import 'package:app_sanitaria/domain/entities/contract_status.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/domain/usecases/contracts/create_contract.dart';
import 'package:app_sanitaria/domain/usecases/contracts/get_contracts_by_patient.dart';
import 'package:app_sanitaria/domain/usecases/contracts/get_contracts_by_professional.dart';
import 'package:app_sanitaria/domain/usecases/contracts/update_contract_status.dart';
import 'package:app_sanitaria/domain/usecases/contracts/cancel_contract.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado dos contratos (Clean Architecture)
class ContractsState {
  ContractsState({
    this.contracts = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  final List<ContractEntity> contracts;
  final bool isLoading;
  final String? errorMessage;

  ContractsState copyWith({
    List<ContractEntity>? contracts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ContractsState(
      contracts: contracts ?? this.contracts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ContractsNotifier V2 - Clean Architecture
class ContractsNotifierV2 extends StateNotifier<ContractsState> {
  ContractsNotifierV2({
    required CreateContract createContract,
    required GetContractsByPatient getContractsByPatient,
    required GetContractsByProfessional getContractsByProfessional,
    required UpdateContractStatus updateContractStatus,
    required CancelContract cancelContract,
    required String? userId,
    required bool isProfessional,
  })  : _createContract = createContract,
        _getContractsByPatient = getContractsByPatient,
        _getContractsByProfessional = getContractsByProfessional,
        _updateContractStatus = updateContractStatus,
        _cancelContract = cancelContract,
        _userId = userId,
        _isProfessional = isProfessional,
        super(ContractsState()) {
    if (_userId != null) loadContracts();
  }
  final CreateContract _createContract;
  final GetContractsByPatient _getContractsByPatient;
  final GetContractsByProfessional _getContractsByProfessional;
  final UpdateContractStatus _updateContractStatus;
  final CancelContract _cancelContract;
  final String? _userId;
  final bool _isProfessional;

  /// Carrega contratos do usuário
  Future<void> loadContracts() async {
    if (_userId == null) return;

    state = state.copyWith(isLoading: true);

    final result = _isProfessional
        ? await _getContractsByProfessional.call(_userId!)
        : await _getContractsByPatient.call(_userId!);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar contratos',
      ),
      (contracts) => state = state.copyWith(
        contracts: contracts,
        isLoading: false,
      ),
    );
  }

  /// Cria novo contrato
  Future<bool> createContract(ContractEntity contract) async {
    state = state.copyWith(isLoading: true);

    final result = await _createContract.call(CreateContractParams(contract));

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao criar contrato',
        );
        return false;
      },
      (createdContract) {
        loadContracts();
        return true;
      },
    );
  }

  /// Atualiza status do contrato
  Future<bool> updateContractStatus(
      String contractId, ContractStatus newStatus) async {
    final result = await _updateContractStatus.call(
      UpdateContractStatusParams(
        contractId: contractId,
        newStatus: newStatus,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: 'Erro ao atualizar status');
        return false;
      },
      (updatedContract) {
        // Atualizar localmente
        final updatedContracts = state.contracts.map((c) {
          return c.id == contractId ? updatedContract : c;
        }).toList();

        state = state.copyWith(contracts: updatedContracts);
        return true;
      },
    );
  }

  /// Cancela um contrato
  Future<bool> cancelContract(String contractId) async {
    if (_userId == null) return false;
    
    final result = await _cancelContract.call(
      CancelContractParams(
        contractId: contractId,
        currentUserId: _userId!,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: 'Erro ao cancelar contrato');
        return false;
      },
      (cancelledContract) {
        // Atualizar localmente
        final updatedContracts = state.contracts.map((c) {
          return c.id == contractId ? cancelledContract : c;
        }).toList();

        state = state.copyWith(contracts: updatedContracts);
        return true;
      },
    );
  }

  /// Obtém contrato por ID
  ContractEntity? getContractById(String contractId) {
    try {
      return state.contracts.firstWhere((c) => c.id == contractId);
    } catch (e) {
      return null;
    }
  }
}

/// Provider para ContractsNotifierV2
final contractsProviderV2 =
    StateNotifierProvider<ContractsNotifierV2, ContractsState>((ref) {
  final authState = ref.watch(authProviderV2);

  return ContractsNotifierV2(
    createContract: getIt<CreateContract>(),
    getContractsByPatient: getIt<GetContractsByPatient>(),
    getContractsByProfessional: getIt<GetContractsByProfessional>(),
    updateContractStatus: getIt<UpdateContractStatus>(),
    cancelContract: getIt<CancelContract>(),
    userId: authState.userId,
    isProfessional: authState.userType == UserType.profissional,
  );
});
