import 'package:flutter/material.dart';
import 'package:app_sanitaria/domain/entities/conversation_entity.dart';
import 'package:app_sanitaria/core/routes/app_router.dart';
import 'package:intl/intl.dart';

/// Card de Conversa na Lista
///
/// Exibe:
/// - Avatar do outro usuário
/// - Nome + especialidade (se houver)
/// - Última mensagem
/// - Horário da última mensagem
/// - Badge de mensagens não lidas
class ConversationCard extends StatelessWidget {
  final ConversationEntity conversation;
  final VoidCallback? onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    final lastMessage = conversation.lastMessage;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: hasUnread ? 3 : 1,
      child: InkWell(
        onTap: onTap ??
            () {
              context.goToChat(
                conversation.otherUserId,
                conversation.otherUserName,
              );
            },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // Status online (placeholder)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome + Horário
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherUserName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  hasUnread ? FontWeight.bold : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMessage != null)
                          Text(
                            _formatTime(lastMessage.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: hasUnread
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade600,
                              fontWeight: hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),

                    // Especialidade (se houver)
                    if (conversation.otherUserSpecialty != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        conversation.otherUserSpecialty!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 4),

                    // Última mensagem
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage?.text ?? 'Sem mensagens',
                            style: TextStyle(
                              fontSize: 14,
                              color: hasUnread
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Badge de não lidas
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              conversation.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formata o horário da mensagem
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      // Hoje: mostra hora
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      // Ontem
      return 'Ontem';
    } else if (difference.inDays < 7) {
      // Esta semana: mostra dia da semana
      return DateFormat('EEE').format(time);
    } else {
      // Mais antigo: mostra data
      return DateFormat('dd/MM').format(time);
    }
  }
}
