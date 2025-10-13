import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firestore_collections.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

/// DataSource para chat usando Firestore (Real-time)
///
/// Responsável por:
/// - Enviar e receber mensagens em tempo real
/// - Gerenciar conversas
/// - Sincronizar mensagens entre dispositivos
/// - Marcar mensagens como lidas
class FirebaseChatDataSource {
  FirebaseChatDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  // ==================== CONVERSAS ====================

  /// Obtém todas as conversas de um usuário (Stream em tempo real)
  ///
  /// Retorna um Stream que atualiza automaticamente quando
  /// novas mensagens chegam
  Stream<List<ConversationEntity>> getUserConversationsStream(
    String userId,
  ) {
    try {
      return _firestore
          .collection(FirestoreCollections.conversations)
          .where(
            FirestoreCollections.participants,
            arrayContains: userId,
          )
          .orderBy(FirestoreCollections.updatedAt, descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return ConversationEntity.fromMap(data, userId);
        }).toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar conversas',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtém uma conversa específica entre dois usuários
  Future<ConversationEntity?> getConversationBetween(
    String userId1,
    String userId2,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.conversations)
          .where(
            FirestoreCollections.participants,
            arrayContains: userId1,
          )
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(
          data[FirestoreCollections.participants] as List,
        );

        if (participants.contains(userId2)) {
          return ConversationEntity.fromMap(data, userId1);
        }
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar conversa',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Cria uma nova conversa entre dois usuários
  Future<ConversationEntity> createConversation(
    String userId1,
    String userId2,
    String user1Name,
    String user2Name,
    String? user2Specialty,
  ) async {
    try {
      AppLogger.info('Criando conversa: $userId1 <-> $userId2');

      final conversationId = '$userId1-$userId2';
      final now = DateTime.now();

      final conversationData = {
        FirestoreCollections.id: conversationId,
        FirestoreCollections.participants: [userId1, userId2],
        FirestoreCollections.createdAt: FieldValue.serverTimestamp(),
        FirestoreCollections.updatedAt: FieldValue.serverTimestamp(),
        '${userId1}_unread': 0,
        '${userId2}_unread': 0,
      };

      await _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .set(conversationData);

      AppLogger.info('✅ Conversa criada: $conversationId');

      return ConversationEntity(
        id: conversationId,
        participants: [userId1, userId2],
        otherUserId: userId2,
        otherUserName: user2Name,
        otherUserSpecialty: user2Specialty,
        updatedAt: now,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao criar conversa',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao criar conversa: $e');
    }
  }

  // ==================== MENSAGENS ====================

  /// Obtém mensagens de uma conversa (Stream em tempo real)
  ///
  /// Retorna um Stream que atualiza automaticamente quando
  /// novas mensagens são enviadas
  Stream<List<MessageEntity>> getMessagesStream(String conversationId) {
    try {
      return _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .collection(FirestoreCollections.messages)
          .orderBy(FirestoreCollections.timestamp, descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageEntity.fromMap(doc.data());
        }).toList();
      });
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar mensagens',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Envia uma nova mensagem
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String text,
  }) async {
    try {
      AppLogger.info('Enviando mensagem: $conversationId');

      final messageId = _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .collection(FirestoreCollections.messages)
          .doc()
          .id;

      final now = Timestamp.now();

      final messageData = {
        FirestoreCollections.id: messageId,
        FirestoreCollections.conversationId: conversationId,
        FirestoreCollections.senderId: senderId,
        FirestoreCollections.senderName: senderName,
        FirestoreCollections.receiverId: receiverId,
        FirestoreCollections.text: text,
        FirestoreCollections.timestamp: now,
        FirestoreCollections.isRead: false,
      };

      // Salvar mensagem
      await _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .collection(FirestoreCollections.messages)
          .doc(messageId)
          .set(messageData);

      // Atualizar conversa
      await _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .update({
        FirestoreCollections.lastMessage: messageData,
        FirestoreCollections.updatedAt: now,
        '${receiverId}_unread': FieldValue.increment(1),
      });

      AppLogger.info('✅ Mensagem enviada: $messageId');

      return MessageEntity(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        text: text,
        timestamp: now.toDate(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao enviar mensagem',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao enviar mensagem: $e');
    }
  }

  /// Marca todas as mensagens de uma conversa como lidas
  Future<void> markMessagesAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      // Resetar contador de não lidas
      await _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .update({
        '${userId}_unread': 0,
      });

      // Marcar mensagens como lidas
      final messagesSnapshot = await _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .collection(FirestoreCollections.messages)
          .where(FirestoreCollections.receiverId, isEqualTo: userId)
          .where(FirestoreCollections.isRead, isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (final doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {FirestoreCollections.isRead: true});
      }

      await batch.commit();

      AppLogger.info('Mensagens marcadas como lidas: $conversationId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao marcar mensagens como lidas',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Deleta uma conversa (e todas as mensagens)
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Deletar mensagens
      final messagesSnapshot = await _firestore
          .collection(FirestoreCollections.conversations)
          .doc(conversationId)
          .collection(FirestoreCollections.messages)
          .get();

      final batch = _firestore.batch();

      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Deletar conversa
      batch.delete(
        _firestore
            .collection(FirestoreCollections.conversations)
            .doc(conversationId),
      );

      await batch.commit();

      AppLogger.info('✅ Conversa deletada: $conversationId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao deletar conversa',
          error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao deletar conversa: $e');
    }
  }
}
