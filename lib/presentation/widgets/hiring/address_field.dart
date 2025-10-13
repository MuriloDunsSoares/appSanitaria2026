import 'package:flutter/material.dart';

/// Widget: Campo de Endereço
///
/// Responsabilidade: TextFormField para endereço do serviço
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o campo de endereço
/// - Validação: Inclui validador
class AddressField extends StatelessWidget {
  const AddressField({
    super.key,
    required this.controller,
  });
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Endereço do Serviço'),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on),
            hintText: 'Rua, número, complemento',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Digite o endereço';
            }
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
