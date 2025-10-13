import 'package:flutter/material.dart';
import 'package:app_sanitaria/core/constants/app_constants.dart';

/// Widget: Modal de Filtros Reutilizável
///
/// Responsabilidade: Exibir modal padronizado com filtros para profissionais
///
/// Filtros disponíveis:
/// - Especialidade
/// - Preço (faixa de valores)
/// - Experiência (anos)
/// - Localização (cidade)
/// - Disponibilidade
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o modal de filtros
/// - DRY: Reutilizável em múltiplas telas
/// - State Management: Usa StatefulWidget para gerenciar seleções
class FiltersBottomSheet extends StatefulWidget {
  final String? initialCity;
  final String? initialSpecialty;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final int? initialMinExperience;
  final bool? initialAvailableNow;
  final void Function({
    String? city,
    String? specialty,
    double? minPrice,
    double? maxPrice,
    int? minExperience,
    bool? availableNow,
  }) onApplyFilters;

  const FiltersBottomSheet({
    super.key,
    this.initialCity,
    this.initialSpecialty,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialMinExperience,
    this.initialAvailableNow,
    required this.onApplyFilters,
  });

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  String? _selectedCity;
  String? _selectedSpecialty;
  double _minPrice = 0;
  double _maxPrice = 500;
  int _minExperience = 0;
  bool _availableNow = false;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
    _selectedSpecialty = widget.initialSpecialty;
    _minPrice = widget.initialMinPrice ?? 0;
    _maxPrice = widget.initialMaxPrice ?? 500;
    _minExperience = widget.initialMinExperience ?? 0;
    _availableNow = widget.initialAvailableNow ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSpecialtyFilter(),
            const SizedBox(height: 16),
            _buildPriceFilter(),
            const SizedBox(height: 16),
            _buildExperienceFilter(),
            const SizedBox(height: 16),
            _buildCityFilter(),
            const SizedBox(height: 16),
            _buildAvailabilityFilter(),
            const SizedBox(height: 24),
            _buildActionButtons(),
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
        Row(
          children: [
            const Icon(Icons.attach_money, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Preço: R\$ ${_minPrice.toStringAsFixed(0)} - R\$ ${_maxPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 500,
          divisions: 50,
          labels: RangeLabels(
            'R\$ ${_minPrice.toStringAsFixed(0)}',
            'R\$ ${_maxPrice.toStringAsFixed(0)}',
          ),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExperienceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              'Experiência mínima: $_minExperience ${_minExperience == 1 ? 'ano' : 'anos'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          value: _minExperience.toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          label: '$_minExperience ${_minExperience == 1 ? 'ano' : 'anos'}',
          onChanged: (value) {
            setState(() {
              _minExperience = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildCityFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCity,
      decoration: const InputDecoration(
        labelText: 'Localização',
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

  Widget _buildAvailabilityFilter() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Disponível agora',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: _availableNow,
            onChanged: (value) {
              setState(() {
                _availableNow = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedCity = null;
                _selectedSpecialty = null;
                _minPrice = 0;
                _maxPrice = 500;
                _minExperience = 0;
                _availableNow = false;
              });
              widget.onApplyFilters(
                city: null,
                specialty: null,
                minPrice: null,
                maxPrice: null,
                minExperience: null,
                availableNow: null,
              );
              Navigator.pop(context);
            },
            child: const Text('Limpar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(
                city: _selectedCity,
                specialty: _selectedSpecialty,
                minPrice: _minPrice > 0 ? _minPrice : null,
                maxPrice: _maxPrice < 500 ? _maxPrice : null,
                minExperience: _minExperience > 0 ? _minExperience : null,
                availableNow: _availableNow ? true : null,
              );
              Navigator.pop(context);
            },
            child: const Text('Aplicar Filtros'),
          ),
        ),
      ],
    );
  }
}

