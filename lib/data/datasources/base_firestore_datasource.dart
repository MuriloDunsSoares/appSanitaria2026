import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_config.dart';
import '../../core/error/exceptions.dart';

/// Base DataSource abstrato para todas as operações Firestore
/// 
/// CONSULTORIA: Arquitetura limpa e reutilização de código
/// 
/// Fornece:
/// - Acesso ao Firestore
/// - Helper para coleções multi-tenant
/// - Tratamento padronizado de erros
/// - Logging consistente
abstract class BaseFirestoreDataSource {
  /// ID da organização (multi-tenant)
  final String? organizationId;
  
  BaseFirestoreDataSource([this.organizationId]);
  
  /// Firestore instance
  FirebaseFirestore get firestore => FirebaseConfig.firestore;
  
  /// Retorna collection dentro da organização (multi-tenant)
  /// 
  /// Se organizationId não fornecido, retorna collection global
  CollectionReference collection(String name) {
    if (organizationId != null) {
      return FirebaseConfig.orgCollection(organizationId!, name);
    }
    // Collection global (userProfiles, auditLogs)
    return firestore.collection(name);
  }
  
  /// Converte FirebaseException para StorageException
  Never handleFirestoreException(dynamic error, StackTrace stackTrace) {
    if (error is FirebaseException) {
      throw StorageException(
        error.message ?? 'Firebase error: ${error.code}',
      );
    }
    throw StorageException(
      error.toString(),
    );
  }
  
  /// Helper: Adiciona timestamps automáticos
  Map<String, dynamic> addTimestamps(Map<String, dynamic> data, {bool isUpdate = false}) {
    if (isUpdate) {
      data['updatedAt'] = FieldValue.serverTimestamp();
    } else {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
    }
    
    if (organizationId != null) {
      data['organizationId'] = organizationId;
    }
    
    return data;
  }
  
  /// Helper: Converte Timestamp para DateTime (null-safe)
  DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return null;
  }
}

