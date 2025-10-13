import 'package:flutter/material.dart';
import 'package:app_sanitaria/core/constants/app_constants.dart';

/// Widget: Modal de Filtros
///
/// Responsabilidade: Exibir modal com filtros de cidade e especialidade
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o modal de filtros
/// - State Management: Usa StatefulWidget para gerenciar seleções
class FiltersModal extends StatefulWidget {
  final Function({String? specialty, String? city}) onApplyFilters;

  const FiltersModal({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<FiltersModal> createState() => _FiltersModalState();
}

class _FiltersModalState extends State<FiltersModal> {
  String? _selectedCity;
  String? _selectedSpecialty;
  double? _maxPrice;
  int? _minExperience;
  String? _availability;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCityFilter(),
            const SizedBox(height: 16),
            _buildSpecialtyFilter(),
            const SizedBox(height: 16),
            _buildPriceFilter(),
            const SizedBox(height: 16),
            _buildExperienceFilter(),
            const SizedBox(height: 16),
            _buildAvailabilityFilter(),
            const SizedBox(height: 24),
            _buildApplyButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filtros',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildCityFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCity,
      decoration: const InputDecoration(
        labelText: 'Cidade',
        prefixIcon: Icon(Icons.location_city),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Todas as cidades'),
        ),
        ...AppConstants.capitalsBrazil.keys.map((city) {
          final state = AppConstants.capitalsBrazil[city]!;
          return DropdownMenuItem(
            value: city,
            child: Text('$city - $state'),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCity = value;
        });
      },
    );
  }

  Widget _buildSpecialtyFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedSpecialty,
      decoration: const InputDecoration(
        labelText: 'Especialidade',
        prefixIcon: Icon(Icons.work),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Todas as especialidades'),
        ),
        ...AppConstants.professionalSpecialties.map((specialty) {
          return DropdownMenuItem(
            value: specialty,
            child: Text(specialty),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSpecialty = value;
        });
      },
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preço máximo por hora',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _maxPrice ?? 200.0,
          min: 50.0,
          max: 500.0,
          divisions: 18,
          label: _maxPrice != null ? 'R\$ ${_maxPrice!.toStringAsFixed(0)}' : 'R\$ 200',
          onChanged: (value) {
            setState(() {
              _maxPrice = value;
            });
          },
        ),
        Text(
          _maxPrice != null ? 'Até R\$ ${_maxPrice!.toStringAsFixed(0)}/hora' : 'Qualquer preço',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildExperienceFilter() {
    return DropdownButtonFormField<int>(
      initialValue: _minExperience,
      decoration: const InputDecoration(
        labelText: 'Experiência mínima',
        prefixIcon: Icon(Icons.work_history),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: null,
          child: Text('Qualquer experiência'),
        ),
        DropdownMenuItem(
          value: 1,
          child: Text('Mínimo 1 ano'),
        ),
        DropdownMenuItem(
          value: 2,
          child: Text('Mínimo 2 anos'),
        ),
        DropdownMenuItem(
          value: 3,
          child: Text('Mínimo 3 anos'),
        ),
        DropdownMenuItem(
          value: 5,
          child: Text('Mínimo 5 anos'),
        ),
        DropdownMenuItem(
          value: 10,
          child: Text('Mínimo 10 anos'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _minExperience = value;
        });
      },
    );
  }

  Widget _buildAvailabilityFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _availability,
      decoration: const InputDecoration(
        labelText: 'Disponibilidade',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: null,
          child: Text('Qualquer disponibilidade'),
        ),
        DropdownMenuItem(
          value: 'imediato',
          child: Text('Disponível agora'),
        ),
        DropdownMenuItem(
          value: 'hoje',
          child: Text('Disponível hoje'),
        ),
        DropdownMenuItem(
          value: 'semana',
          child: Text('Disponível esta semana'),
        ),
        DropdownMenuItem(
          value: 'mes',
          child: Text('Disponível este mês'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _availability = value;
        });
      },
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          widget.onApplyFilters(
            specialty: _selectedSpecialty,
            city: _selectedCity,
          );
          // TODO: Passar novos filtros (preço, experiência, disponibilidade)
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Aplicar Filtros'),
      ),
    );
  }
}

