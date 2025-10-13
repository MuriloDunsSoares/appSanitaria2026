import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget: Card de Resumo do Pedido
///
/// Responsabilidade: Exibir resumo das seleções do usuário
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o resumo
/// - Composição: Usa _buildSummaryRow para cada linha
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.service,
    required this.period,
    required this.duration,
    required this.date,
    required this.time,
    this.address,
  });
  final String service;
  final String period;
  final int duration;
  final DateTime date;
  final String time;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Divider(height: 20),
          _buildSummaryRow('Serviço:', service),
          _buildSummaryRow('Período:', period),
          _buildSummaryRow('Duração:', '$duration horas/dia'),
          _buildSummaryRow('Data:', DateFormat('dd/MM/yyyy').format(date)),
          _buildSummaryRow('Horário:', time),
          if (address != null && address!.isNotEmpty)
            _buildSummaryRow('Endereço:', address!),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.receipt_long, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          'Resumo do Pedido',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
