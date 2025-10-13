import 'package:flutter/material.dart';

/// Widget: Campo de Observações
///
/// Responsabilidade: TextFormField para observações opcionais
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o campo de observações
/// - Opcional: Sem validador (campo opcional)
class ObservationsField extends StatelessWidget {
  final TextEditingController controller;

  const ObservationsField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Observações (Opcional)'),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Adicione detalhes importantes sobre o serviço...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
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


