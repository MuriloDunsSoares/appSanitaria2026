import 'package:app_sanitaria/core/utils/app_logger.dart';
import 'package:app_sanitaria/domain/entities/message_entity.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/chat_provider_v2.dart';
import 'package:app_sanitaria/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela de Chat Individual
///
/// Responsabilidades:
/// - Exibir conversa 1-on-1 com outro usuário
/// - Enviar e receber mensagens em tempo real
/// - Mostrar status de leitura
/// - Upload de imagens/arquivos
///
/// Princípios:
/// - Single Responsibility: Apenas UI de chat individual
/// - Stateful: Gerencia mensagens e input
/// - Integrado com ChatProvider (futuro)
///
/// Navigation:
/// - Tela fullscreen (sem bottom nav, sem floating buttons)
/// - Acessível por PACIENTES e PROFISSIONAIS
class IndividualChatScreen extends ConsumerStatefulWidget {
  const IndividualChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });
  final String otherUserId;
  final String otherUserName;

  @override
  ConsumerState<IndividualChatScreen> createState() =>
      _IndividualChatScreenState();
}

class _IndividualChatScreenState extends ConsumerState<IndividualChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _conversationId;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  /// Inicializa ou busca conversa existente
  Future<void> _initializeChat() async {
    try {
      // Buscar ou criar conversa
      final authState = ref.read(authProviderV2);
      final currentUserId = authState.user?.id ?? '';
      final convId = await ref.read(chatProviderV2.notifier).startConversation(
            currentUserId,
            widget.otherUserId,
          );

      if (mounted) {
        setState(() {
          _conversationId = convId;
          _isInitializing = false;
        });

        // Carregar mensagens
        await ref.read(chatProviderV2.notifier).loadMessages(convId);

        // Marcar como lidas
        await ref.read(chatProviderV2.notifier).markAsRead(convId);

        // Scroll para o fim
        _scrollToBottom();
      }
    } catch (e) {
      AppLogger.error('Erro ao inicializar chat: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  /// Envia mensagem
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _conversationId == null) return;

    try {
      // Limpar input imediatamente
      _messageController.clear();

      // Pegar dados do usuário atual
      final authState = ref.read(authProviderV2);
      final currentUser = authState.user;
      final senderId = currentUser?.id ?? '';
      final senderName = currentUser?.nome ?? 'Usuário';

      // Enviar mensagem
      await ref.read(chatProviderV2.notifier).sendMessage(
            conversationId: _conversationId!,
            senderId: senderId,
            senderName: senderName,
            receiverId: widget.otherUserId,
            receiverName: widget.otherUserName,
            text: text,
          );

      // Scroll para o fim
      _scrollToBottom();
    } catch (e) {
      AppLogger.error('Erro ao enviar mensagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar mensagem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Scroll para o final da lista
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProviderV2);
    final messages = _conversationId != null
        ? (chatState.messages[_conversationId!] ?? <MessageEntity>[])
        : <MessageEntity>[];

    // Pegar ID do usuário atual
    final authState = ref.watch(authProviderV2);
    final currentUserId = authState.user?.id ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Voltar para a tela de conversas
          context.go('/conversations');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child:
                    Icon(Icons.person, size: 20, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Menu de opções
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Lista de mensagens
            Expanded(
              child: _isInitializing
                  ? const Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Conversa com ${widget.otherUserName}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Envie a primeira mensagem!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId == currentUserId;

                            return MessageBubble(
                              message: message,
                              isMe: isMe,
                            );
                          },
                        ),
            ),

            // Input de mensagem
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Anexos em desenvolvimento...'),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Digite uma mensagem...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
