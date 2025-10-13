import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget: Seletor de Data e Horário
///
/// Responsabilidade: Cards clicáveis para selecionar data e horário
///
/// Princípios aplicados:
/// - Single Responsibility: Renderiza seletores de data/hora
/// - Delegação: Callbacks para ações externas
class DateTimeSelector extends StatelessWidget {
  const DateTimeSelector({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateTap,
    required this.onTimeTap,
  });
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Data e Horário'),
        const SizedBox(height: 12),
        _buildDateCard(context),
        const SizedBox(height: 8),
        _buildTimeCard(context),
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

  Widget _buildDateCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.calendar_today,
            color: Theme.of(context).colorScheme.primary),
        title: const Text('Data de Início'),
        subtitle: Text(
          selectedDate != null
              ? DateFormat('dd/MM/yyyy - EEEE', 'pt_BR').format(selectedDate!)
              : 'Selecione uma data',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onDateTap,
      ),
    );
  }

  Widget _buildTimeCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.access_time,
            color: Theme.of(context).colorScheme.primary),
        title: const Text('Horário de Início'),
        subtitle: Text(
          selectedTime != null
              ? selectedTime!.format(context)
              : 'Selecione um horário',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTimeTap,
      ),
    );
  }
}
