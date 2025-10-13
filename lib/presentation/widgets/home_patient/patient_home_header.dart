import 'package:flutter/material.dart';

/// Widget: Header da Home do Paciente
///
/// Responsabilidade: Exibir saudação personalizada e seletor de localização
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o header
/// - Composição: Widget reutilizável e testável
class PatientHomeHeader extends StatelessWidget {
  final String userName;
  final String selectedCity;
  final VoidCallback onCityTap;

  const PatientHomeHeader({
    super.key,
    required this.userName,
    required this.selectedCity,
    required this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreeting(),
          const SizedBox(height: 15),
          _buildLocationSelector(),
        ],
      ),
    );
  }

  /// Saudação personalizada
  Widget _buildGreeting() {
    return Row(
      children: [
        const Text('👋', style: TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Seletor de localização
  Widget _buildLocationSelector() {
    return InkWell(
      onTap: onCityTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📍', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              selectedCity,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '[trocar]',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF667EEA),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


