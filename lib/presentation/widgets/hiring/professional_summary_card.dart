import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:flutter/material.dart';

/// Widget: Card de Resumo do Profissional
///
/// Responsabilidade: Exibir informações básicas do profissional no topo da tela
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o card do profissional
/// - Reusabilidade: Pode ser usado em outras telas
class ProfessionalSummaryCard extends StatelessWidget {
  const ProfessionalSummaryCard({
    super.key,
    required this.professional,
  });
  final ProfessionalEntity professional;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  professional.especialidade.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      professional.avaliacao.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
