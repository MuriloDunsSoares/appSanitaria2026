/// Use Case: Obter conversas de um usuário.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/conversation_entity.dart';
import '../../repositories/chat_repository.dart';

/// Use Case para obter conversas do usuário.
class GetUserConversations extends UseCase<List<ConversationEntity>, String> {
  GetUserConversations(this.repository);
  final ChatRepository repository;

  @override
  Future<Either<Failure, List<ConversationEntity>>> call(
    String userId,
  ) async {
    return repository.getUserConversations(userId);
  }
}

/// Parâmetros para buscar por user ID.
class UserIdParams extends Equatable {
  const UserIdParams(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}
