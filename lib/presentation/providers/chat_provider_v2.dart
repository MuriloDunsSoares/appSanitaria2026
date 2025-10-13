/// ChatProvider migrado para Clean Architecture com Use Cases.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_sanitaria/core/di/injection_container.dart';
import 'package:app_sanitaria/domain/entities/conversation_entity.dart';
import 'package:app_sanitaria/domain/entities/message_entity.dart';
import 'package:app_sanitaria/domain/usecases/chat/get_messages.dart';
import 'package:app_sanitaria/domain/usecases/chat/get_user_conversations.dart';
import 'package:app_sanitaria/domain/usecases/chat/mark_messages_as_read.dart';
import 'package:app_sanitaria/domain/usecases/chat/send_message.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';

/// Estado do chat (Clean Architecture)
class ChatState {
  final List<ConversationEntity> conversations;
  final Map<String, List<MessageEntity>> messages;
  final bool isLoading;
  final String? errorMessage;
  final int totalUnreadCount;

  ChatState({
    this.conversations = const [],
    this.messages = const {},
    this.isLoading = false,
    this.errorMessage,
    this.totalUnreadCount = 0,
  });

  ChatState copyWith({
    List<ConversationEntity>? conversations,
    Map<String, List<MessageEntity>>? messages,
    bool? isLoading,
    String? errorMessage,
    int? totalUnreadCount,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
    );
  }
}

/// ChatNotifier V2 - Clean Architecture
class ChatNotifierV2 extends StateNotifier<ChatState> {
  final GetUserConversations _getUserConversations;
  final GetMessages _getMessages;
  final SendMessage _sendMessage;
  final MarkMessagesAsRead _markMessagesAsRead;
  final String? _currentUserId;

  ChatNotifierV2({
    required GetUserConversations getUserConversations,
    required GetMessages getMessages,
    required SendMessage sendMessage,
    required MarkMessagesAsRead markMessagesAsRead,
    required String? currentUserId,
  })  : _getUserConversations = getUserConversations,
        _getMessages = getMessages,
        _sendMessage = sendMessage,
        _markMessagesAsRead = markMessagesAsRead,
        _currentUserId = currentUserId,
        super(ChatState()) {
    if (_currentUserId != null) loadConversations();
  }

  /// Carrega conversas do usuário
  Future<void> loadConversations() async {
    if (_currentUserId == null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getUserConversations.call(_currentUserId!);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar conversas',
      ),
      (conversations) {
        final totalUnread = conversations.fold<int>(
          0,
          (sum, conv) => sum + conv.unreadCount,
        );

        state = state.copyWith(
          conversations: conversations,
          isLoading: false,
          totalUnreadCount: totalUnread,
        );
      },
    );
  }

  /// Carrega mensagens de uma conversa
  Future<void> loadMessages(String conversationId) async {
    // Extrair userId1 e userId2 do conversationId (formato: userId1_userId2)
    final userIds = conversationId.split('_');
    if (userIds.length != 2) return;
    
    final result = await _getMessages.call(
      GetMessagesParams(userId1: userIds[0], userId2: userIds[1]),
    );

    result.fold(
      (failure) => null,
      (messages) {
        final newMessages = Map<String, List<MessageEntity>>.from(state.messages);
        newMessages[conversationId] = messages;
        state = state.copyWith(messages: newMessages);
      },
    );
  }

  /// Envia mensagem
  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String text,
  }) async {
    if (_currentUserId == null || text.trim().isEmpty) return false;

    final result = await _sendMessage.call(
      SendMessageParams(
        senderId: senderId,
        receiverId: receiverId,
        content: text.trim(),
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: 'Erro ao enviar mensagem');
        return false;
      },
      (sentMessage) {
        // Atualizar localmente
        final newMessages = Map<String, List<MessageEntity>>.from(state.messages);
        final conversationMessages = List<MessageEntity>.from(
          newMessages[conversationId] ?? [],
        );
        conversationMessages.add(sentMessage);
        newMessages[conversationId] = conversationMessages;
        
        state = state.copyWith(messages: newMessages);
        loadConversations(); // Atualizar lista de conversas
        return true;
      },
    );
  }

  /// Marca mensagens como lidas
  Future<void> markAsRead(String conversationId) async {
    if (_currentUserId == null) return;

    await _markMessagesAsRead.call(MarkAsReadParams(
      conversationId: conversationId,
      userId: _currentUserId!,
    ));

    // Atualizar contagem local
    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == conversationId) {
        return conv.copyWith(unreadCount: 0);
      }
      return conv;
    }).toList();

    final newUnreadCount = updatedConversations.fold<int>(
      0,
      (sum, conv) => sum + conv.unreadCount,
    );

    state = state.copyWith(
      conversations: updatedConversations,
      totalUnreadCount: newUnreadCount,
    );
  }

  /// Inicia uma nova conversa entre dois usuários
  Future<String> startConversation(String userId, String otherUserId) async {
    // Gerar ID da conversa (ordenado para ser consistente)
    final ids = [userId, otherUserId]..sort();
    final conversationId = '${ids[0]}_${ids[1]}';
    
    // Carregar mensagens (cria conversa se não existir)
    await loadMessages(conversationId);
    
    return conversationId;
  }
}

/// Provider para ChatNotifierV2
final chatProviderV2 = StateNotifierProvider<ChatNotifierV2, ChatState>((ref) {
  final userId = ref.watch(authProviderV2).userId;
  
  return ChatNotifierV2(
    getUserConversations: getIt<GetUserConversations>(),
    getMessages: getIt<GetMessages>(),
    sendMessage: getIt<SendMessage>(),
    markMessagesAsRead: getIt<MarkMessagesAsRead>(),
    currentUserId: userId,
  );
});

