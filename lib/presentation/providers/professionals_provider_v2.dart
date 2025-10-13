/// ProfessionalsProvider migrado para Clean Architecture com Use Cases.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_sanitaria/core/di/injection_container.dart';
import 'package:app_sanitaria/core/usecases/usecase.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/usecases/professionals/get_all_professionals.dart';
import 'package:app_sanitaria/domain/usecases/professionals/search_professionals.dart'
    show SearchProfessionals, SearchProfessionalsParams;

/// Estado da lista de profissionais (Clean Architecture)
class ProfessionalsState {
  final List<ProfessionalEntity> professionals;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedCity;
  final String? selectedSpecialty;

  ProfessionalsState({
    this.professionals = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCity,
    this.selectedSpecialty,
  });

  ProfessionalsState copyWith({
    List<ProfessionalEntity>? professionals,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? selectedCity,
    String? selectedSpecialty,
  }) {
    return ProfessionalsState(
      professionals: professionals ?? this.professionals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedSpecialty: selectedSpecialty ?? this.selectedSpecialty,
    );
  }

  /// Retorna lista filtrada baseado nos critérios atuais
  List<ProfessionalEntity> get filteredProfessionals {
    var filtered = professionals;

    // Filtro por busca (nome ou especialidade)
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((prof) {
        final name = prof.nome.toLowerCase();
        final specialty = prof.especialidade.displayName.toLowerCase();
        return name.contains(query) || specialty.contains(query);
      }).toList();
    }

    // Filtro por cidade
    if (selectedCity != null && selectedCity!.isNotEmpty) {
      filtered = filtered.where((prof) => prof.cidade == selectedCity).toList();
    }

    // Filtro por especialidade
    if (selectedSpecialty != null && selectedSpecialty!.isNotEmpty) {
      filtered = filtered
          .where((prof) => prof.especialidade.displayName == selectedSpecialty)
          .toList();
    }

    return filtered;
  }
}

/// ProfessionalsNotifier V2 - Clean Architecture
class ProfessionalsNotifierV2 extends StateNotifier<ProfessionalsState> {
  final GetAllProfessionals _getAllProfessionals;
  final SearchProfessionals _searchProfessionals;

  ProfessionalsNotifierV2({
    required GetAllProfessionals getAllProfessionals,
    required SearchProfessionals searchProfessionals,
  })  : _getAllProfessionals = getAllProfessionals,
        _searchProfessionals = searchProfessionals,
        super(ProfessionalsState());

  /// Carrega todos os profissionais
  Future<void> loadProfessionals() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getAllProfessionals.call(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar profissionais',
      ),
      (professionals) => state = state.copyWith(
        professionals: professionals,
        isLoading: false,
      ),
    );
  }

  /// Busca profissionais por query
  Future<void> searchProfessionals(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);

    if (query.isEmpty) {
      await loadProfessionals();
      return;
    }

    final result = await _searchProfessionals.call(
      SearchProfessionalsParams(searchQuery: query),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro na busca',
      ),
      (professionals) => state = state.copyWith(
        professionals: professionals,
        isLoading: false,
      ),
    );
  }

  /// Atualiza filtro de cidade
  void setCity(String? city) {
    state = state.copyWith(selectedCity: city);
  }

  /// Atualiza filtro de especialidade
  void setSpecialty(String? specialty) {
    state = state.copyWith(selectedSpecialty: specialty);
  }

  /// Limpa todos os filtros
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCity: null,
      selectedSpecialty: null,
    );
  }

  /// Atualiza query de busca
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Aplica filtros
  Future<void> applyFilters() async {
    await loadProfessionals();
  }

  /// Atualiza lista (refresh)
  Future<void> refresh() async {
    await loadProfessionals();
  }
}

/// Provider para ProfessionalsNotifierV2
final professionalsProviderV2 =
    StateNotifierProvider<ProfessionalsNotifierV2, ProfessionalsState>((ref) {
  return ProfessionalsNotifierV2(
    getAllProfessionals: getIt<GetAllProfessionals>(),
    searchProfessionals: getIt<SearchProfessionals>(),
  );
});

