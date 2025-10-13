import 'package:flutter/material.dart';

/// Widget: Seletor de Tipo de Serviço
///
/// Responsabilidade: Dropdown para selecionar o tipo de serviço
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o dropdown
/// - Validação: Inclui validador de formulário
class ServiceTypeSelector extends StatelessWidget {
  final String? selectedService;
  final ValueChanged<String?> onChanged;
  final List<String> services;

  const ServiceTypeSelector({
    super.key,
    required this.selectedService,
    required this.onChanged,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tipo de Serviço'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selectedService,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.medical_services),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          hint: const Text('Selecione o serviço'),
          items: services.map((service) {
            return DropdownMenuItem(
              value: service,
              child: Text(service),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) return 'Selecione um serviço';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}


