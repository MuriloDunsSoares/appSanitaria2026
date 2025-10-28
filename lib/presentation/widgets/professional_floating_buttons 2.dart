import 'package:flutter/material.dart';
import 'package:app_sanitaria/core/routes/app_router.dart';

/// Botões Flutuantes para PROFISSIONAIS
///
/// Responsabilidades:
/// - Exibir 2 botões fixos no canto inferior esquerdo
/// - Botão superior: Perfil (👤)
/// - Botão inferior: Conversas (💬)
/// - Navegar para as telas correspondentes
///
/// Princípios:
/// - Single Responsibility: Apenas UI de navegação flutuante
/// - Stateless: Sem estado interno
/// - Reutilizável: Pode ser usado como overlay
///
/// Aparece em:
/// - Home Professional Screen APENAS
///
/// NÃO aparece em:
/// - Conversations Screen
/// - Profile Screen
/// - Outras telas
class ProfessionalFloatingButtons extends StatelessWidget {
  const ProfessionalFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      left: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botão Perfil (superior)
          FloatingActionButton(
            heroTag: 'professional_profile_btn',
            onPressed: () => context.goToProfile(),
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.person, size: 28),
          ),

          const SizedBox(height: 12),

          // Botão Conversas (inferior)
          FloatingActionButton(
            heroTag: 'professional_conversations_btn',
            onPressed: () => context.goToConversations(),
            backgroundColor: colorScheme.secondary,
            foregroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.chat_bubble, size: 28),
          ),
        ],
      ),
    );
  }
}
