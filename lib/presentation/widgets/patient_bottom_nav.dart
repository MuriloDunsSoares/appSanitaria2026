import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom Navigation Bar para PACIENTES
///
/// Responsabilidades:
/// - Exibir 5 botões de navegação: Buscar, Conversas, Meus Contratos, Favoritos, Perfil
/// - Destacar botão ativo baseado na rota atual
/// - Navegar entre telas principais do paciente
///
/// Princípios:
/// - Single Responsibility: Apenas UI de navegação inferior
/// - Stateless: Recebe índice ativo como parâmetro
/// - Reutilizável: Pode ser usado em múltiplas telas
///
/// Aparece em:
/// - Home Patient Screen
/// - Professional List Screen (Buscar)
/// - Conversations Screen
/// - Contracts Screen (Meus Contratos)
/// - Favorites Screen
///
/// NÃO aparece em:
/// - Profile Screen (fullscreen)
/// - Individual Chat
/// - Professional Profile Detail
class PatientBottomNav extends StatelessWidget {
  const PatientBottomNav({
    super.key,
    required this.currentIndex,
  });

  /// Índice do botão atualmente ativo (0-4)
  /// 0 = Buscar, 1 = Conversas, 2 = Meus Contratos, 3 = Favoritos, 4 = Perfil
  final int currentIndex;

  /// Navega para a tela correspondente ao índice
  void _onTap(BuildContext context, int index) {
    // Evitar renavegar para a mesma tela
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        // Buscar (Professional List)
        context.go('/professionals');
        break;
      case 1:
        // Conversas
        context.go('/conversations');
        break;
      case 2:
        // Meus Contratos
        context.go('/contracts');
        break;
      case 3:
        // Favoritos
        context.go('/favorites');
        break;
      case 4:
        // Perfil
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                icon: Icons.search,
                label: 'Buscar',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                icon: Icons.chat_bubble_outline,
                label: 'Conversas',
              ),
              _buildNavItem(
                context: context,
                index: 2,
                icon: Icons.description_outlined,
                label: 'Contratos',
              ),
              _buildNavItem(
                context: context,
                index: 3,
                icon: Icons.favorite_border,
                label: 'Favoritos',
              ),
              _buildNavItem(
                context: context,
                index: 4,
                icon: Icons.person_outline,
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói um item individual da barra de navegação
  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = index == currentIndex;
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () => _onTap(context, index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? activeColor : inactiveColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
