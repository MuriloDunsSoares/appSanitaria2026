import 'package:flutter/material.dart';

/// Widget: Barra de Busca da Home do Paciente
///
/// Responsabilidade: Campo de busca simples
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza a barra de busca
/// - Delegação: Callbacks para ações externas
class PatientHomeSearchBar extends StatelessWidget {
  const PatientHomeSearchBar({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    return _buildSearchField();
  }

  /// Campo de busca
  Widget _buildSearchField() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Encontre cuidadores em sua região...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF667EEA)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: onSearchChanged,
        onSubmitted: onSearchSubmitted,
      ),
    );
  }
}
