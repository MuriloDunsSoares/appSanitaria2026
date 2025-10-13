import 'package:app_sanitaria/core/routes/app_router.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/chat_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/favorites_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/reviews_provider_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Card de Profissional na Lista
///
/// Responsabilidades:
/// - Exibir informações resumidas do profissional
/// - Botão de favoritar (integrado com FavoritesProvider)
/// - Navegação para perfil detalhado
///
/// Design:
/// - Foto/Avatar
/// - Nome + Avaliação
/// - Especialidade
/// - Cidade
/// - Botões de ação (Contatar + Favoritar)
///
/// **Performance:** Usa RatingsCacheProvider para evitar I/O em cada card
class ProfessionalCard extends ConsumerWidget {
  const ProfessionalCard({
    super.key,
    required this.professional,
  });
  final Map<String, dynamic> professional;

  /// Carrega a avaliação média do profissional (usando ReviewsProviderV2)
  double _getRating(WidgetRef ref, String professionalId) {
    if (professionalId.isEmpty) {
      return 0;
    }

    final reviewsState = ref.watch(reviewsProviderV2);
    return reviewsState.averageRatings[professionalId] ?? 0.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = (professional['nome'] ?? 'Nome não disponível') as String;
    final specialty =
        (professional['especialidade'] ?? 'Especialidade') as String;
    final city = (professional['cidade'] ?? 'Cidade') as String;
    final state = (professional['estado'] ?? '') as String;
    final professionalId = professional['id']?.toString() ?? '';

    // Observar estado de favoritos
    final favoritesState = ref.watch(favoritesProviderV2);
    final isFavorite = favoritesState.isFavorite(professionalId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (professionalId.isNotEmpty) {
            context.goToProfessionalProfile(professionalId);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar + Nome + Avaliação
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Nome + Especialidade
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Avaliação (OTIMIZADO COM CACHE)
                  Builder(
                    builder: (context) {
                      final rating = _getRating(ref, professionalId);
                      if (rating == 0) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Localização
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$city - $state',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  // TODO: Adicionar contador de avaliações
                  // const SizedBox.shrink(),
                ],
              ),

              const SizedBox(height: 12),

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: professionalId.isEmpty
                          ? null
                          : () async {
                              try {
                                // Obter ID do usuário atual
                                final authState = ref.read(authProviderV2);
                                final currentUserId = authState.user?.id ?? '';

                                // Iniciar conversa
                                await ref
                                    .read(chatProviderV2.notifier)
                                    .startConversation(
                                      currentUserId,
                                      professionalId,
                                    );

                                // Navegar para o chat
                                if (context.mounted) {
                                  context.goToChat(professionalId, name);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Erro ao iniciar conversa'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Contatar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: professionalId.isEmpty
                        ? null
                        : () {
                            ref
                                .read(favoritesProviderV2.notifier)
                                .toggleFavorite(professionalId);

                            // Feedback visual
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFavorite
                                      ? '❤️ Removido dos favoritos'
                                      : '⭐ Adicionado aos favoritos',
                                ),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isFavorite ? Colors.red : null,
                    ),
                    label: Text(isFavorite ? 'Favoritado' : 'Favoritar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      side: BorderSide(
                        color: isFavorite ? Colors.red : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
