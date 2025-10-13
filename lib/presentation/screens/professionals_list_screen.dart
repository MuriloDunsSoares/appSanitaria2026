import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_sanitaria/presentation/widgets/patient_bottom_nav.dart';
import 'package:app_sanitaria/presentation/widgets/professional_card.dart';
import 'package:app_sanitaria/presentation/providers/professionals_provider_v2.dart';
import 'package:app_sanitaria/presentation/widgets/common/filters_bottom_sheet.dart';

/// Tela de Lista de Profissionais (Buscar)
///
/// Responsabilidades:
/// - Exibir lista de profissionais com busca e filtros
/// - Permitir favoritar profissionais
/// - Navegar para perfil detalhado do profissional
///
/// Princípios:
/// - Single Responsibility: Apenas UI de listagem
/// - Stateful: Gerencia filtros e busca local
/// - Integrado com ProfessionalsProvider (futuro)
///
/// Navigation:
/// - Inclui PatientBottomNav (índice 0 = Buscar)
/// - Aparece apenas para PACIENTES
class ProfessionalsListScreen extends ConsumerStatefulWidget {
  final String? initialSpecialty;
  final String? initialCity;
  
  const ProfessionalsListScreen({
    super.key,
    this.initialSpecialty,
    this.initialCity,
  });

  @override
  ConsumerState<ProfessionalsListScreen> createState() =>
      _ProfessionalsListScreenState();
}

class _ProfessionalsListScreenState
    extends ConsumerState<ProfessionalsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carregar profissionais ao iniciar e aplicar filtros iniciais
    Future.microtask(() {
      final notifier = ref.read(professionalsProviderV2.notifier);
      
      // Aplicar filtros iniciais vindos da navegação
      if (widget.initialCity != null) {
        notifier.setCity(widget.initialCity);
      }
      if (widget.initialSpecialty != null) {
        notifier.setSpecialty(widget.initialSpecialty);
      }
      
      // Carregar profissionais
      notifier.loadProfessionals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Mostra modal de filtros
  void _showFiltersModal() {
    final professionalsState = ref.read(professionalsProviderV2);
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FiltersBottomSheet(
        initialCity: professionalsState.selectedCity,
        initialSpecialty: professionalsState.selectedSpecialty,
        onApplyFilters: ({
          String? city,
          String? specialty,
          double? minPrice,
          double? maxPrice,
          int? minExperience,
          bool? availableNow,
        }) {
          ref.read(professionalsProviderV2.notifier).setCity(city);
          ref.read(professionalsProviderV2.notifier).setSpecialty(specialty);
          // TODO: Implementar filtros de preço, experiência e disponibilidade no provider
          ref.read(professionalsProviderV2.notifier).applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final professionalsState = ref.watch(professionalsProviderV2);
    final filteredProfessionals = professionalsState.filteredProfessionals;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Voltar para HOME ao clicar no botão voltar
          context.go('/home/patient');
        }
      },
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Buscar Profissionais'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            padding: const EdgeInsets.all(16),
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou especialidade...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFiltersModal,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                ref.read(professionalsProviderV2.notifier).setSearchQuery(value);
              },
            ),
          ),

          // Chips de filtros ativos
          if (professionalsState.selectedCity != null ||
              professionalsState.selectedSpecialty != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  if (professionalsState.selectedCity != null)
                    Chip(
                      label: Text(professionalsState.selectedCity!),
                      onDeleted: () {
                        ref.read(professionalsProviderV2.notifier).setCity(null);
                      },
                    ),
                  if (professionalsState.selectedSpecialty != null)
                    Chip(
                      label: Text(professionalsState.selectedSpecialty!),
                      onDeleted: () {
                        ref
                            .read(professionalsProviderV2.notifier)
                            .setSpecialty(null);
                      },
                    ),
                ],
              ),
            ),

          // Lista de profissionais
          Expanded(
            child: professionalsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : professionalsState.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              professionalsState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(professionalsProviderV2.notifier)
                                    .refresh();
                              },
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : filteredProfessionals.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum profissional encontrado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tente ajustar os filtros',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(professionalsProviderV2.notifier)
                                        .clearFilters();
                                    _searchController.clear();
                                  },
                                  child: const Text('Limpar Filtros'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(professionalsProviderV2.notifier)
                                  .refresh();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 80, // Espaço para bottom nav
                              ),
                              itemCount: filteredProfessionals.length,
                              itemBuilder: (context, index) {
                                final professional =
                                    filteredProfessionals[index];
                                return ProfessionalCard(
                                  professional: professional.toJson(),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),

        // Bottom Navigation (índice 0 = Buscar)
        bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
      ),
    );
  }
}
