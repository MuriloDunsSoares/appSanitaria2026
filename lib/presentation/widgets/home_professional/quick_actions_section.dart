import 'package:flutter/material.dart';
import 'action_card.dart';

/// Widget: Seção de Ações Rápidas
///
/// Responsabilidade: Exibir lista de ações rápidas (Editar Perfil, Ajuda)
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza a seção de ações
/// - Composição: Usa ActionCard
class QuickActionsSection extends StatelessWidget {
  final VoidCallback onEditProfileTap;
  final VoidCallback onHelpTap;

  const QuickActionsSection({
    super.key,
    required this.onEditProfileTap,
    required this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ActionCard(
          icon: Icons.edit,
          title: 'Editar Perfil',
          subtitle: 'Atualize suas informações profissionais',
          onTap: onEditProfileTap,
        ),
        const SizedBox(height: 12),
        ActionCard(
          icon: Icons.help_outline,
          title: 'Ajuda e Suporte',
          subtitle: 'Tire suas dúvidas',
          onTap: onHelpTap,
        ),
      ],
    );
  }
}


