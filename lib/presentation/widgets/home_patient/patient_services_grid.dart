import 'package:flutter/material.dart';
import 'service_card.dart';

/// Widget: Grid de Serviços para Pacientes
///
/// Responsabilidade: Exibir grid de 4 cards de serviços
///
/// Princípios aplicados:
/// - Single Responsibility: Organiza os cards em grid
/// - Composição: Usa ServiceCard para cada item
class PatientServicesGrid extends StatelessWidget {
  final Function(String specialty) onServiceTap;

  const PatientServicesGrid({
    super.key,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do que você precisa?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        _buildServicesGrid(),
      ],
    );
  }

  Widget _buildServicesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        ServiceCard(
          title: 'Cuidadores',
          emoji: '🧓',
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          onTap: () => onServiceTap('Cuidadores'),
        ),
        ServiceCard(
          title: 'Técnicos de\nenfermagem',
          emoji: '💉',
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
          onTap: () => onServiceTap('Técnicos de enfermagem'),
        ),
        ServiceCard(
          title: 'Acompanhantes\nhospitalares',
          emoji: '🏥',
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
          ),
          onTap: () => onServiceTap('Acompanhantes hospital'),
        ),
        ServiceCard(
          title: 'Acompanhante\nDomiciliar',
          emoji: '🏠',
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
          ),
          onTap: () => onServiceTap('Acompanhante Domiciliar'),
        ),
      ],
    );
  }
}


