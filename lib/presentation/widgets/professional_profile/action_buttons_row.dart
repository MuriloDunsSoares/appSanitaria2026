import 'package:flutter/material.dart';

/// Widget: Row de Botões de Ação (Contratar e Chat)
///
/// Responsabilidade: Botões de ação principais do perfil
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza os botões de ação
/// - Delegação: Callbacks para as ações
class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({
    super.key,
    required this.onHireTap,
    required this.onChatTap,
  });
  final VoidCallback onHireTap;
  final VoidCallback onChatTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onHireTap,
              icon: const Icon(Icons.handshake),
              label: const Text('Contratar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onChatTap,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
