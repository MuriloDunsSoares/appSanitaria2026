import 'package:flutter/material.dart';

/// Widget: Seletor de Período e Duração
///
/// Responsabilidade: Chips de período (Diário/Semanal/Mensal) + slider de horas
///
/// Princípios aplicados:
/// - Single Responsibility: Renderiza período e duração
/// - Composição: Combina chips e slider
class PeriodDurationSelector extends StatelessWidget {
  const PeriodDurationSelector({
    super.key,
    required this.selectedPeriod,
    required this.selectedDuration,
    required this.periods,
    required this.onPeriodChanged,
    required this.onDurationChanged,
  });
  final String selectedPeriod;
  final int selectedDuration;
  final List<String> periods;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Período e Duração'),
        const SizedBox(height: 12),
        _buildPeriodChips(),
        const SizedBox(height: 16),
        _buildDurationSlider(),
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

  Widget _buildPeriodChips() {
    return Wrap(
      spacing: 8,
      children: periods.map((period) {
        return ChoiceChip(
          label: Text(period),
          selected: selectedPeriod == period,
          onSelected: (selected) {
            if (selected) {
              onPeriodChanged(period);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horas por dia: $selectedDuration horas',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Slider(
          value: selectedDuration.toDouble(),
          min: 4,
          max: 24,
          divisions: 4,
          label: '$selectedDuration horas',
          onChanged: (value) => onDurationChanged(value.toInt()),
        ),
      ],
    );
  }
}
