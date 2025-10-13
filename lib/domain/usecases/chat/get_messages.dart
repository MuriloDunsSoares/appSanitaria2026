/// Use Case: Obter mensagens de uma conversa.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';

/// Parâmetros para buscar mensagens entre dois usuários
class GetMessagesParams extends Equatable {
  const GetMessagesParams({
    required this.userId1,
    required this.userId2,
  });
  final String userId1;
  final String userId2;

  @override
  List<Object?> get props => [userId1, userId2];
}

/// Use Case para obter mensagens.
class GetMessages extends UseCase<List<MessageEntity>, GetMessagesParams> {
  GetMessages(this.repository);
  final ChatRepository repository;

  @override
  Future<Either<Failure, List<MessageEntity>>> call(
    GetMessagesParams params,
  ) async {
    return repository.getMessages(
      userId1: params.userId1,
      userId2: params.userId2,
    );
  }
}

/// Parâmetros para buscar por conversation ID.
class ConversationIdParams extends Equatable {
  const ConversationIdParams(this.conversationId);
  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}
