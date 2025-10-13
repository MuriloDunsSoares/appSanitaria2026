/// Implementação do ChatRepository usando Firebase 100% (real-time).
library;

import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/firebase_chat_datasource.dart';

/// Implementação do repositório de chat usando Firebase 100%.
///
/// **Características:**
/// - Usa apenas `FirebaseChatDataSource` (Cloud Firestore)
/// - Firestore Streams para updates em tempo real
/// - Mensagens sincronizam automaticamente entre dispositivos
/// - Persistência automática pelo Firestore (cache offline)
class ChatRepositoryFirebaseImpl implements ChatRepository {
  final FirebaseChatDataSource firebaseChatDataSource;

  ChatRepositoryFirebaseImpl({
    required this.firebaseChatDataSource,
  });

  @override
  Future<Either<Failure, List<ConversationEntity>>> getUserConversations(
    String userId,
  ) async {
    try {
      final conversations = await firebaseChatDataSource
          .getUserConversationsStream(userId)
          .first;
      return Right(conversations);
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> getConversationBetween(
    String userId1,
    String userId2,
  ) async {
    try {
      final conversation = await firebaseChatDataSource.getConversationBetween(
        userId1,
        userId2,
      );
      
      if (conversation == null) {
        return const Left(NotFoundFailure('Conversa não encontrada'));
      }
      
      return Right(conversation);
    } on NotFoundException {
      return const Left(NotFoundFailure('Conversa não encontrada'));
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String userId1,
    required String userId2,
  }) async {
    try {
      // Criar conversationId a partir dos dois userIds
      final conversationId = '$userId1-$userId2';
      // Pegar snapshot inicial do stream
      final messages = await firebaseChatDataSource
          .getMessagesStream(conversationId)
          .first
          .timeout(const Duration(seconds: 3));
      return Right(messages);
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      // Criar conversationId
      final conversationId = '$senderId-$receiverId';
      final sentMessage = await firebaseChatDataSource.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: '', // Será preenchido pelo datasource se necessário
        receiverId: receiverId,
        text: content,
      );
      return Right(sentMessage);
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> startConversation({
    required String userId1,
    required String userId2,
    required String user1Name,
    required String user2Name,
    String? user2Specialty,
  }) async {
    try {
      final conversation = await firebaseChatDataSource.createConversation(
        userId1,
        userId2,
        user1Name,
        user2Name,
        user2Specialty,
      );
      return Right(conversation);
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await firebaseChatDataSource.markMessagesAsRead(conversationId, userId);
      return const Right(unit);
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> saveConversation(
    ConversationEntity conversation,
  ) async {
    try {
      // Criar conversa no Firestore
      final created = await firebaseChatDataSource.createConversation(
        conversation.participants[0],
        conversation.participants[1],
        conversation.otherUserName,
        conversation.otherUserName,
        conversation.otherUserSpecialty,
      );
      return Right(created);
    } catch (_) {
      return const Left(StorageFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      final conversations = await firebaseChatDataSource
          .getUserConversationsStream(userId)
          .first;
      final totalUnread = conversations.fold<int>(
        0,
        (sum, conv) => sum + conv.unreadCount,
      );
      return Right(totalUnread);
    } catch (_) {
      return const Left(StorageFailure());
    }
  }
}

