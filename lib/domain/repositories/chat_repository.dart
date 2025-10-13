/// Interface do repositório de chat.
///
/// **Responsabilidades:**
/// - Gerenciar conversas entre usuários
/// - Enviar e receber mensagens
/// - Marcar mensagens como lidas
/// - Gerenciar lista de conversas ativas
library;

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

/// Contrato do repositório de chat.
abstract class ChatRepository {
  /// Retorna TODAS as conversas de um usuário.
  ///
  /// Retorna:
  /// - [Right(List<ConversationEntity>)]: lista de conversas (pode ser vazia)
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ConversationEntity>>> getUserConversations(
    String userId,
  );

  /// Retorna uma conversa entre dois usuários.
  ///
  /// Retorna:
  /// - [Right(ConversationEntity)]: conversa encontrada
  /// - [Left(NotFoundFailure)]: conversa não existe
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, ConversationEntity>> getConversationBetween(
    String user1Id,
    String user2Id,
  );

  /// Cria ou atualiza uma conversa.
  ///
  /// Retorna:
  /// - [Right(ConversationEntity)]: conversa salva com sucesso
  /// - [Left(StorageFailure)]: erro ao salvar
  Future<Either<Failure, ConversationEntity>> saveConversation(
    ConversationEntity conversation,
  );

  /// Retorna todas as mensagens entre dois usuários.
  ///
  /// Retorna:
  /// - [Right(List<MessageEntity>)]: mensagens ordenadas por data
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String userId1,
    required String userId2,
  });

  /// Envia uma nova mensagem.
  ///
  /// Retorna:
  /// - [Right(MessageEntity)]: mensagem enviada com sucesso
  /// - [Left(ValidationFailure)]: conteúdo inválido
  /// - [Left(StorageFailure)]: erro ao enviar
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  });

  /// Marca todas as mensagens de uma conversa como lidas.
  ///
  /// Retorna:
  /// - [Right(Unit)]: mensagens marcadas como lidas
  /// - [Left(StorageFailure)]: erro ao atualizar
  Future<Either<Failure, Unit>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  });

  /// Conta mensagens não lidas de um usuário.
  ///
  /// Retorna:
  /// - [Right(int)]: número de mensagens não lidas
  /// - [Left(StorageFailure)]: erro ao contar
  Future<Either<Failure, int>> getUnreadCount(String userId);
}
