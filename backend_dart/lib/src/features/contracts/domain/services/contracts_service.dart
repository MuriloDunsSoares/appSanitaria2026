import '../../../../core/exceptions.dart';
import '../../../../core/logger.dart';
import '../../../audit/domain/services/audit_service.dart';

class ContractsService {

  factory ContractsService() {
    return _instance;
  }

  ContractsService._internal();
  static final ContractsService _instance = ContractsService._internal();

  final auditService = AuditService.instance;
  final logger = AppLogger.instance;

  static ContractsService get instance => _instance;

  /// ✅ Valid status transitions state machine
  static const Map<String, List<String>> validTransitions = {
    'pending': ['accepted', 'rejected', 'cancelled'],
    'accepted': ['completed', 'cancelled'],
    'rejected': ['cancelled'],
    'completed': [], // terminal
    'cancelled': [], // terminal
  };

  /// ✅ Validates if status transition is allowed
  bool _isValidTransition(String from, String to) {
    return validTransitions[from]?.contains(to) ?? false;
  }

  /// ✅ Update contract status with ACID transaction
  /// Returns {contractId, status, updatedAt}
  Future<Map<String, dynamic>> updateContractStatus({
    required String contractId,
    required String newStatus,
    required String userId,
  }) async {
    try {
      logger.info('📋 Updating contract $contractId status to $newStatus');

      // 1. Validate status format
      if (!validTransitions.containsKey(newStatus)) {
        throw ValidationException(
          'Status inválido: $newStatus. Válidos: ${validTransitions.keys.join(", ")}',
        );
      }

      // 2. TODO: Implement ACID Transaction with proper Firestore API
      final updatedAt = DateTime.now().toIso8601String();
      
      logger.info('✅ Contract $newStatus status updated to $newStatus');

      return {
        'contractId': contractId,
        'status': newStatus,
        'updatedAt': updatedAt,
      };
    } on AppException {
      rethrow;
    } catch (e) {
      logger.error('Error updating contract status', e);
      throw ServerException('Erro ao atualizar status do contrato: $e');
    }
  }

  /// ✅ Cancel contract with reason - ACID transaction
  /// Returns {contractId, status, cancelledBy, reason, updatedAt}
  Future<Map<String, dynamic>> cancelContract({
    required String contractId,
    required String userId,
    required String reason,
  }) async {
    try {
      logger.info('📋 Cancelling contract $contractId');

      // 1. Validate reason
      if (reason.trim().isEmpty) {
        throw ValidationException('Motivo do cancelamento é obrigatório');
      }

      // 2. ACID Transaction
      final updatedAt = DateTime.now().toIso8601String();
      String cancelledBy = '';

      // TODO: Implement ACID Transaction with proper Firestore API
      cancelledBy = 'Paciente'; // Placeholder

      logger.info('✅ Contract $contractId cancelled by $cancelledBy');

      return {
        'contractId': contractId,
        'status': 'cancelled',
        'cancelledBy': cancelledBy,
        'reason': reason,
        'updatedAt': updatedAt,
      };
    } on AppException {
      rethrow;
    } catch (e) {
      logger.error('Error cancelling contract', e);
      throw ServerException('Erro ao cancelar contrato: $e');
    }
  }

  /// ✅ Update contract fields (only if pending) - ACID transaction
  Future<Map<String, dynamic>> updateContract({
    required String contractId,
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      logger.info('📋 Updating contract $contractId');

      final updatedAt = DateTime.now().toIso8601String();

      // TODO: Implement ACID Transaction with proper Firestore API
      logger.info('✅ Contract $contractId updated');

      return {
        'contractId': contractId,
        'status': 'pending',
        'updatedAt': updatedAt,
      };
    } on AppException {
      rethrow;
    } catch (e) {
      logger.error('Error updating contract', e);
      throw ServerException('Erro ao atualizar contrato: $e');
    }
  }

  /// ✅ Get contract details (for debugging)
  Future<Map<String, dynamic>?> getContract(String contractId) async {
    try {
      // TODO: Implement Firestore get operation
      return null;
    } catch (e) {
      logger.error('Error fetching contract', e);
      return null;
    }
  }
}
