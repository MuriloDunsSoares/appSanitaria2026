import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_sanitaria/core/utils/app_logger.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/presentation/widgets/patient_bottom_nav.dart';
import 'package:app_sanitaria/presentation/widgets/professional_card.dart';
import 'package:app_sanitaria/presentation/providers/favorites_provider_v2.dart';

/// Tela de Favoritos
///
/// Responsabilidades:
/// - Exibir lista de profissionais favoritados pelo paciente
/// - Permitir remover dos favoritos
/// - Navegar para perfil detalhado do profissional
///
/// Princípios:
/// - Single Responsibility: Apenas UI de favoritos
/// - Stateful: Gerencia lista de favoritos
/// - Integrado com FavoritesProvider (futuro)
///
/// Navigation:
/// - Inclui PatientBottomNav (índice 2 = Favoritos)
/// - Aparece apenas para PACIENTES
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<ProfessionalEntity> _favoriteProfessionals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Carrega profissionais favoritos
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites =
          await ref.read(favoritesProviderV2.notifier).getFavoriteProfessionals();

      if (mounted) {
        setState(() {
          _favoriteProfessionals = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar favoritos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar mudanças nos favoritos para recarregar
    ref.listen<FavoritesState>(favoritesProviderV2, (previous, next) {
      if (previous?.favoriteIds != next.favoriteIds) {
        _loadFavorites();
      }
    });

    final favoritesState = ref.watch(favoritesProviderV2);
    final favoriteCount = favoritesState.count;

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
        title: Text('Favoritos${favoriteCount > 0 ? ' ($favoriteCount)' : ''}'),
        elevation: 0,
        actions: [
          if (favoriteCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpar Favoritos'),
                    content: const Text(
                      'Deseja remover todos os profissionais dos seus favoritos?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Limpar Tudo'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref
                      .read(favoritesProviderV2.notifier)
                      .clearAllFavorites();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Todos os favoritos foram removidos'),
                      ),
                    );
                  }
                }
              },
              tooltip: 'Limpar todos os favoritos',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteProfessionals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Seus Favoritos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum profissional favoritado ainda',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navegar para a tela de busca (índice 0 do PatientBottomNav)
                          context.go('/professionals');
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar Profissionais'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 80, // Espaço para bottom nav
                    ),
                    itemCount: _favoriteProfessionals.length,
                    itemBuilder: (context, index) {
                      final professional = _favoriteProfessionals[index];
                      return ProfessionalCard(
                        professional: professional.toJson(),
                      );
                    },
                  ),
                ),

        // Bottom Navigation (índice 2 = Favoritos)
        bottomNavigationBar: const PatientBottomNav(currentIndex: 2),
      ),
    );
  }
}
