import 'package:app_sanitaria/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Widget: Modal de Seleção de Cidade
///
/// Responsabilidade: Exibir modal com lista de cidades brasileiras
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o modal de cidades
/// - State Management: Usa StatefulBuilder para busca local
class CitySelectorModal extends StatefulWidget {
  const CitySelectorModal({
    super.key,
    required this.onCitySelected,
  });
  final void Function(String city) onCitySelected;

  @override
  State<CitySelectorModal> createState() => _CitySelectorModalState();
}

class _CitySelectorModalState extends State<CitySelectorModal> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCities = AppConstants.capitalsBrazil.keys.toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = AppConstants.capitalsBrazil.keys.toList();
      } else {
        _filteredCities = AppConstants.capitalsBrazil.keys
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 16),
              _buildCitiesList(scrollController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Selecione a cidade',
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar cidade...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: _filterCities,
    );
  }

  Widget _buildCitiesList(ScrollController scrollController) {
    return Expanded(
      child: ListView(
        controller: scrollController,
        children: [
          _buildAllCitiesOption(),
          const Divider(),
          ..._filteredCities.map(_buildCityItem),
        ],
      ),
    );
  }

  Widget _buildAllCitiesOption() {
    return ListTile(
      title: const Text('Todas as cidades'),
      leading: const Icon(Icons.public),
      onTap: () {
        widget.onCitySelected('Todas as cidades');
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCityItem(String city) {
    final state = AppConstants.capitalsBrazil[city]!;
    return ListTile(
      title: Text(city),
      subtitle: Text(state),
      leading: const Icon(Icons.location_city),
      onTap: () {
        widget.onCitySelected('$city - $state');
        Navigator.pop(context);
      },
    );
  }
}
