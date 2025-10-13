import 'package:flutter/material.dart';

/// Widget: Header do Profissional
///
/// Responsabilidade: Saudação e subtítulo
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza a saudação
/// - Reusabilidade: Simples e direto
class ProfessionalHeader extends StatelessWidget {
  const ProfessionalHeader({
    super.key,
    required this.firstName,
  });
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá, $firstName! 👋',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gerencie seu perfil profissional',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
