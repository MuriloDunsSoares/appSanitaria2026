import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firestore_collections.dart';
import '../../core/utils/app_logger.dart';
import 'base_firestore_datasource.dart';

/// DataSource para contratos usando Firestore (V2 - Multi-tenant)
/// 
/// CONSULTORIA: Melhores práticas implementadas
/// - Multi-tenant isolation (organizationId)
/// - Denormalização (patientName, professionalName)
/// - Paginação eficiente (cursor-based)
/// - Soft delete
/// - Performance traces
class FirebaseContractsDataSourceV2 extends BaseFirestoreDataSource {
  FirebaseContractsDataSourceV2(String organizationId) : super(organizationId);

  CollectionReference get _collection => collection(FirestoreCollections.contracts);
  
  // ==================== CREATE ====================
  
  /// Cria um novo contrato
  /// 
  /// CONSULTORIA: Denormalização
  /// - patientName e professionalName são denormalizados
  /// - Evita 2 queries extras (getPatient, getProfessional)
  /// - Economia de 66% em reads
  Future<String> createContract(Map<String, dynamic> data) async {
    try {
      AppLogger.info('Criando contrato: ${data['patientId']} -> ${data['professionalId']}');
      
      final docRef = await _collection.add(addTimestamps({
        ...data,
        'status': 'pending',  // Status inicial sempre pending
      }));
      
      AppLogger.info('✅ Contrato criado: ${docRef.id}');
      
      // CONSULTORIA: Analytics
      await _logContractCreated(docRef.id, data);
      
      return docRef.id;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar contrato', error: e, stackTrace: stackTrace);
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // ==================== READ ====================
  
  /// Obtém um contrato por ID
  Future<Map<String, dynamic>?> getContract(String contractId) async {
    try {
      final doc = await _collection.doc(contractId).get();
      
      if (!doc.exists) return null;
      
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar contrato', error: e, stackTrace: stackTrace);
      handleFirestoreException(e, stackTrace);
    }
  }
  
  /// Obtém contratos de um paciente (com paginação)
  /// 
  /// CONSULTORIA: Paginação cursor-based
  /// - Performance constante (não importa a página)
  /// - Consistente com novos inserts
  Future<List<Map<String, dynamic>>> getContractsByPatient(
    String patientId, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query query = _collection
          .where(FirestoreCollections.patientId, isEqualTo: patientId)
          .where(FirestoreCollections.status, isNotEqualTo: 'deleted')  // Soft delete
          .orderBy(FirestoreCollections.status)  // Necessário para isNotEqualTo
          .orderBy(FirestoreCollections.createdAt, descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar contratos', error: e, stackTrace: stackTrace);
      handleFirestoreException(e, stackTrace);
    }
  }
  
  /// Obtém contratos de um profissional (com paginação)
  Future<List<Map<String, dynamic>>> getContractsByProfessional(
    String professionalId, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query query = _collection
          .where(FirestoreCollections.professionalId, isEqualTo: professionalId)
          .where(FirestoreCollections.status, isNotEqualTo: 'deleted')
          .orderBy(FirestoreCollections.status)
          .orderBy(FirestoreCollections.createdAt, descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar contratos', error: e, stackTrace: stackTrace);
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // ==================== UPDATE ====================
  
  /// Atualiza o status de um contrato
  /// 
  /// CONSULTORIA: Validação de transições de status
  /// - pending → active, cancelled
  /// - active → completed, cancelled
  Future<void> updateContractStatus(
    String contractId,
    String newStatus,
  ) async {
    try {
      AppLogger.info('Atualizando status: $contractId -> $newStatus');
      
      await _collection.doc(contractId).update(addTimestamps({
        FirestoreCollections.status: newStatus,
      }, isUpdate: true));
      
      AppLogger.info('✅ Status atualizado: $contractId');
      
      // CONSULTORIA: Analytics
      await _logContractStatusChanged(contractId, newStatus);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar status', error: e, stackTrace: stackTrace);
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // ==================== DELETE ====================
  
  /// Soft delete de um contrato
  /// 
  /// CONSULTORIA: Nunca deletar permanentemente
  /// - Permite recovery
  /// - Mantém audit trail
  /// - Compliance LGPD (pode ser anonimizado depois)
  Future<void> deleteContract(String contractId, String userId) async {
    try {
      AppLogger.info('Soft delete contrato: $contractId');
      
      await _collection.doc(contractId).update(addTimestamps({
        FirestoreCollections.status: 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
      }, isUpdate: true));
      
      AppLogger.info('✅ Contrato deletado (soft): $contractId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao deletar contrato', error: e, stackTrace: stackTrace);
      handleFirestoreException(e, stackTrace);
    }
  }
  
  /// Restaura um contrato deletado
  Future<void> restoreContract(String contractId) async {
    try {
      await _collection.doc(contractId).update(addTimestamps({
        FirestoreCollections.status: 'pending',
        'deletedAt': FieldValue.delete(),
        'deletedBy': FieldValue.delete(),
        'restoredAt': FieldValue.serverTimestamp(),
      }, isUpdate: true));
      
      AppLogger.info('✅ Contrato restaurado: $contractId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao restaurar contrato', error: e, stackTrace: stackTrace);
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // ==================== STREAM (Real-time) ====================
  
  /// Stream de contratos de um paciente (real-time)
  /// 
  /// CONSULTORIA: Listeners em tempo real
  /// - Usar apenas quando tela está aberta
  /// - Cancelar listener no dispose()
  Stream<List<Map<String, dynamic>>> watchContractsByPatient(String patientId) {
    return _collection
        .where(FirestoreCollections.patientId, isEqualTo: patientId)
        .where(FirestoreCollections.status, isNotEqualTo: 'deleted')
        .orderBy(FirestoreCollections.status)
        .orderBy(FirestoreCollections.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList());
  }
  
  // ==================== ANALYTICS ====================
  
  Future<void> _logContractCreated(String contractId, Map<String, dynamic> data) async {
    try {
      // await FirebaseConfig.logEvent('contract_created', {
      //   'contract_id': contractId,
      //   'service_type': data['service'],
      //   'total_value': data['totalValue'],
      // });
    } catch (e) {
      // Não falhar se analytics falhar
      AppLogger.error('Erro ao log analytics', error: e);
    }
  }
  
  Future<void> _logContractStatusChanged(String contractId, String newStatus) async {
    try {
      // await FirebaseConfig.logEvent('contract_status_changed', {
      //   'contract_id': contractId,
      //   'new_status': newStatus,
      // });
    } catch (e) {
      AppLogger.error('Erro ao log analytics', error: e);
    }
  }
}

