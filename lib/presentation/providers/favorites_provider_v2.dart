/// FavoritesProvider migrado para Clean Architecture com Use Cases.
library;

import 'package:app_sanitaria/core/di/injection_container.dart';
import 'package:app_sanitaria/core/utils/app_logger.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/usecases/favorites/get_favorites.dart';
import 'package:app_sanitaria/domain/usecases/favorites/toggle_favorite.dart';
import 'package:app_sanitaria/domain/usecases/professionals/get_professionals_by_ids.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado dos favoritos (Clean Architecture)
class FavoritesState {
  FavoritesState({
    this.favoriteIds = const [],
    this.isLoading = false,
    this.errorMessage,
  });
  final List<String> favoriteIds;
  final bool isLoading;
  final String? errorMessage;

  /// Getter para count
  int get count => favoriteIds.length;

  FavoritesState copyWith({
    List<String>? favoriteIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  bool isFavorite(String professionalId) =>
      favoriteIds.contains(professionalId);
}

/// FavoritesNotifier V2 - Clean Architecture
class FavoritesNotifierV2 extends StateNotifier<FavoritesState> {
  FavoritesNotifierV2({
    required GetFavorites getFavorites,
    required ToggleFavorite toggleFavorite,
    required GetProfessionalsByIds getProfessionalsByIds,
    required String? userId,
  })  : _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        _getProfessionalsByIds = getProfessionalsByIds,
        _userId = userId,
        super(FavoritesState()) {
    if (_userId != null) loadFavorites();
  }
  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;
  final GetProfessionalsByIds _getProfessionalsByIds;
  final String? _userId;

  /// Carrega favoritos do usuário
  Future<void> loadFavorites() async {
    if (_userId == null) {
      AppLogger.warning('⚠️ Tentando carregar favoritos sem userId');
      return;
    }

    AppLogger.info('📋 Carregando favoritos para userId: $_userId');
    state = state.copyWith(isLoading: true);

    final result = await _getFavorites.call(_userId!);

    result.fold(
      (failure) {
        AppLogger.error('❌ Erro ao carregar favoritos: $failure');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar favoritos',
        );
      },
      (favorites) {
        AppLogger.info(
            '✅ ${favorites.length} favoritos carregados: $favorites');
        state = state.copyWith(
          favoriteIds: favorites,
          isLoading: false,
        );
      },
    );
  }

  /// Toggle favorito
  Future<void> toggleFavorite(String professionalId) async {
    if (_userId == null) {
      AppLogger.warning('⚠️ Tentando toggle favorito sem userId');
      return;
    }

    AppLogger.info('🔄 Toggle favorito: $_userId -> $professionalId');

    final result = await _toggleFavorite.call(
      ToggleFavoriteParams(
        patientId: _userId!,
        professionalId: professionalId,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error('❌ Erro ao toggle favorito: $failure');
        state = state.copyWith(
          errorMessage: 'Erro ao atualizar favorito',
        );
      },
      (success) {
        // Toggle local
        final newFavorites = List<String>.from(state.favoriteIds);
        if (newFavorites.contains(professionalId)) {
          AppLogger.info('➖ Removendo favorito: $professionalId');
          newFavorites.remove(professionalId);
        } else {
          AppLogger.info('➕ Adicionando favorito: $professionalId');
          newFavorites.add(professionalId);
        }
        state = state.copyWith(favoriteIds: newFavorites);
        AppLogger.info(
            '✅ Estado atualizado. Total favoritos: ${newFavorites.length}');
      },
    );
  }

  /// Retorna lista de profissionais favoritos
  Future<List<ProfessionalEntity>> getFavoriteProfessionals() async {
    AppLogger.info(
        '🔍 Buscando profissionais favoritos. IDs: ${state.favoriteIds}');

    if (state.favoriteIds.isEmpty) {
      AppLogger.info('⚠️ Nenhum ID de favorito encontrado');
      return [];
    }

    final result = await _getProfessionalsByIds.call(
      GetProfessionalsByIdsParams(state.favoriteIds),
    );

    return result.fold(
      (failure) {
        AppLogger.error('❌ Erro ao buscar profissionais favoritos: $failure');
        return [];
      },
      (professionals) {
        AppLogger.info(
            '✅ ${professionals.length} profissionais favoritos retornados');
        return professionals;
      },
    );
  }

  /// Limpa todos os favoritos
  Future<void> clearAllFavorites() async {
    if (_userId == null) return;

    // Limpar no Firebase primeiro
    for (final professionalId in state.favoriteIds) {
      await _toggleFavorite.call(
        ToggleFavoriteParams(
          patientId: _userId!,
          professionalId: professionalId,
        ),
      );
    }

    // Limpar estado local
    state = state.copyWith(favoriteIds: []);
  }
}

/// Provider para FavoritesNotifierV2
final favoritesProviderV2 =
    StateNotifierProvider<FavoritesNotifierV2, FavoritesState>((ref) {
  // Obter userId do authProviderV2
  final userId = ref.watch(authProviderV2).userId;

  return FavoritesNotifierV2(
    getFavorites: getIt<GetFavorites>(),
    toggleFavorite: getIt<ToggleFavorite>(),
    getProfessionalsByIds: getIt<GetProfessionalsByIds>(),
    userId: userId,
  );
});
