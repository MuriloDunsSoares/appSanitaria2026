import 'package:app_sanitaria/domain/entities/conversation_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget: Feed de Últimas Conversas
///
/// Responsabilidade: Exibir lista de conversas recentes
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza a lista de conversas
/// - Composição: Usa _buildConversationItem para cada conversa
class ConversationsFeed extends StatelessWidget {
  const ConversationsFeed({
    super.key,
    required this.conversations,
    required this.onConversationTap,
    required this.onSeeAllTap,
  });
  final List<dynamic> conversations;
  final void Function(String userId, String userName) onConversationTap;
  final VoidCallback onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    if (conversations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Últimas Conversas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onSeeAllTap,
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...conversations.take(3).map((conversation) {
          return _buildConversationItem(
              context, conversation as ConversationEntity);
        }),
      ],
    );
  }

  Widget _buildConversationItem(
      BuildContext context, ConversationEntity conversation) {
    final lastMessage = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: hasUnread ? 2 : 1,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          conversation.otherUserName,
          style: TextStyle(
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          lastMessage?.text ?? 'Sem mensagens',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: hasUnread ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(conversation.updatedAt),
              style: TextStyle(
                fontSize: 12,
                color: hasUnread
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasUnread) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          onConversationTap(
            conversation.otherUserId,
            conversation.otherUserName,
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }
}
