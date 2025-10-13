import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firestore_collections.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/contract_entity.dart';

/// DataSource para contratos usando Firestore
///
/// Responsável por:
/// - Criar contratos
/// - Buscar contratos por usuário
/// - Atualizar status de contratos
class FirebaseContractsDataSource {
  FirebaseContractsDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  /// Cria um novo contrato
  Future<ContractEntity> createContract(ContractEntity contract) async {
    try {
      AppLogger.info(
          'Criando contrato: ${contract.patientId} -> ${contract.professionalId}');

      final contractId =
          _firestore.collection(FirestoreCollections.contracts).doc().id;

      final contractData = contract.toJson();
      contractData[FirestoreCollections.id] = contractId;
      contractData[FirestoreCollections.createdAt] =
          FieldValue.serverTimestamp();
      contractData[FirestoreCollections.updatedAt] =
          FieldValue.serverTimestamp();

      await _firestore
          .collection(FirestoreCollections.contracts)
          .doc(contractId)
          .set(contractData);

      AppLogger.info('✅ Contrato criado: $contractId');

      // Retornar entidade com ID atualizado
      return ContractEntity.fromJson({...contract.toJson(), 'id': contractId});
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar contrato',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao criar contrato: $e');
    }
  }

  /// Obtém todos os contratos de um usuário (paciente ou profissional)
  Future<List<ContractEntity>> getContractsByUser(String userId) async {
    try {
      AppLogger.info('Buscando contratos: $userId');

      // Buscar contratos onde userId é paciente OU profissional
      final patientSnapshot = await _firestore
          .collection(FirestoreCollections.contracts)
          .where(FirestoreCollections.patientId, isEqualTo: userId)
          .orderBy(FirestoreCollections.createdAt, descending: true)
          .get();

      final professionalSnapshot = await _firestore
          .collection(FirestoreCollections.contracts)
          .where(FirestoreCollections.professionalId, isEqualTo: userId)
          .orderBy(FirestoreCollections.createdAt, descending: true)
          .get();

      final contracts = <ContractEntity>[];

      for (final doc in patientSnapshot.docs) {
        contracts.add(ContractEntity.fromJson(doc.data()));
      }

      for (final doc in professionalSnapshot.docs) {
        contracts.add(ContractEntity.fromJson(doc.data()));
      }

      // Ordenar por data (mais recentes primeiro)
      contracts.sort((a, b) => b.date.compareTo(a.date));

      AppLogger.info('✅ ${contracts.length} contratos encontrados');

      return contracts;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar contratos',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao buscar contratos: $e');
    }
  }

  /// Obtém todos os contratos
  Future<List<ContractEntity>> getAllContracts() async {
    try {
      AppLogger.info('Buscando todos os contratos');

      final snapshot = await _firestore
          .collection(FirestoreCollections.contracts)
          .orderBy(FirestoreCollections.createdAt, descending: true)
          .get();

      final contracts = snapshot.docs
          .map((doc) => ContractEntity.fromJson(doc.data()))
          .toList();

      AppLogger.info('✅ ${contracts.length} contratos encontrados');

      return contracts;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar todos os contratos',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao buscar todos os contratos: $e');
    }
  }

  /// Obtém contratos por paciente
  Future<List<ContractEntity>> getContractsByPatient(String patientId) async {
    try {
      AppLogger.info('Buscando contratos do paciente: $patientId');

      final snapshot = await _firestore
          .collection(FirestoreCollections.contracts)
          .where(FirestoreCollections.patientId, isEqualTo: patientId)
          .orderBy(FirestoreCollections.createdAt, descending: true)
          .get();

      final contracts = snapshot.docs
          .map((doc) => ContractEntity.fromJson(doc.data()))
          .toList();

      AppLogger.info('✅ ${contracts.length} contratos do paciente encontrados');

      return contracts;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar contratos do paciente',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao buscar contratos do paciente: $e');
    }
  }

  /// Obtém contratos por profissional
  Future<List<ContractEntity>> getContractsByProfessional(
      String professionalId) async {
    try {
      AppLogger.info('Buscando contratos do profissional: $professionalId');

      final snapshot = await _firestore
          .collection(FirestoreCollections.contracts)
          .where(FirestoreCollections.professionalId, isEqualTo: professionalId)
          .orderBy(FirestoreCollections.createdAt, descending: true)
          .get();

      final contracts = snapshot.docs
          .map((doc) => ContractEntity.fromJson(doc.data()))
          .toList();

      AppLogger.info(
          '✅ ${contracts.length} contratos do profissional encontrados');

      return contracts;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar contratos do profissional',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao buscar contratos do profissional: $e');
    }
  }

  /// Obtém um contrato por ID
  Future<ContractEntity?> getContractById(String contractId) async {
    try {
      AppLogger.info('Buscando contrato: $contractId');

      final doc = await _firestore
          .collection(FirestoreCollections.contracts)
          .doc(contractId)
          .get();

      if (!doc.exists) {
        AppLogger.info('⚠️ Contrato não encontrado: $contractId');
        return null;
      }

      return ContractEntity.fromJson(doc.data()!);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar contrato',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Atualiza o status de um contrato
  Future<void> updateContractStatus(
    String contractId,
    String newStatus,
  ) async {
    try {
      AppLogger.info('Atualizando status: $contractId -> $newStatus');

      await _firestore
          .collection(FirestoreCollections.contracts)
          .doc(contractId)
          .update({
        FirestoreCollections.status: newStatus,
        FirestoreCollections.updatedAt: FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Status atualizado: $contractId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar status',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao atualizar status: $e');
    }
  }

  /// Atualiza um contrato
  Future<void> updateContract(ContractEntity contract) async {
    try {
      AppLogger.info('Atualizando contrato: ${contract.id}');

      final contractData = contract.toJson();
      contractData[FirestoreCollections.updatedAt] =
          FieldValue.serverTimestamp();

      await _firestore
          .collection(FirestoreCollections.contracts)
          .doc(contract.id)
          .update(contractData);

      AppLogger.info('✅ Contrato atualizado: ${contract.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar contrato',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao atualizar contrato: $e');
    }
  }

  /// Deleta um contrato
  Future<void> deleteContract(String contractId) async {
    try {
      AppLogger.info('Deletando contrato: $contractId');

      await _firestore
          .collection(FirestoreCollections.contracts)
          .doc(contractId)
          .delete();

      AppLogger.info('✅ Contrato deletado: $contractId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao deletar contrato',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao deletar contrato: $e');
    }
  }
}
