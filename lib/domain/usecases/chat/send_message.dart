/// Use Case: Enviar uma mensagem.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';

/// Parâmetros para enviar mensagem
class SendMessageParams extends Equatable {
  final String senderId;
  final String receiverId;
  final String content;

  const SendMessageParams({
    required this.senderId,
    required this.receiverId,
    required this.content,
  });

  @override
  List<Object?> get props => [senderId, receiverId, content];
}

/// Use Case para enviar mensagem.
class SendMessage extends UseCase<MessageEntity, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) async {
    // Validação
    if (params.content.trim().isEmpty) {
      return const Left(ValidationFailure('Conteúdo vazio'));
    }

    return await repository.sendMessage(
      senderId: params.senderId,
      receiverId: params.receiverId,
      content: params.content,
    );
  }
}




