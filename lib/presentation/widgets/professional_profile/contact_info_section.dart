import 'package:flutter/material.dart';

/// Widget: Seção de Informações de Contato
///
/// Responsabilidade: Exibir cidade, telefone e email do profissional
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza informações de contato
/// - Composição: Usa _buildInfoRow internamente
class ContactInfoSection extends StatelessWidget {
  const ContactInfoSection({
    super.key,
    required this.city,
    required this.phone,
    required this.email,
  });
  final String city;
  final String phone;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.location_on, city),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.phone, phone),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.email, email),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
