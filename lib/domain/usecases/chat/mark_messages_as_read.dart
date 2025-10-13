/// Use Case: Marcar mensagens como lidas.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/chat_repository.dart';

/// Use Case para marcar mensagens como lidas.
class MarkMessagesAsRead extends UseCase<Unit, MarkAsReadParams> {
  final ChatRepository repository;

  MarkMessagesAsRead(this.repository);

  @override
  Future<Either<Failure, Unit>> call(MarkAsReadParams params) async {
    return await repository.markMessagesAsRead(
      conversationId: params.conversationId,
      userId: params.userId,
    );
  }
}

/// Parâmetros para marcar como lido.
class MarkAsReadParams extends Equatable {
  final String conversationId;
  final String userId;

  const MarkAsReadParams({
    required this.conversationId,
    required this.userId,
  });

  @override
  List<Object?> get props => [conversationId, userId];
}

/// Alias para MarkAsReadParams (compatibilidade com testes)
typedef MarkMessagesAsReadParams = MarkAsReadParams;




