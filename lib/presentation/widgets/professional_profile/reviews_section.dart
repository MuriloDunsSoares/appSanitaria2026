import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/reviews_provider_v2.dart';
import 'package:app_sanitaria/presentation/widgets/review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Widget: Seção de Avaliações
///
/// Responsabilidade: Exibir lista de avaliações + botão "Avaliar"
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza avaliações
/// - State Management: Usa Riverpod para acessar reviews
/// - Composição: Usa ReviewCard para cada avaliação
class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({
    super.key,
    required this.professionalId,
    required this.professionalName,
  });
  final String professionalId;
  final String professionalName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProviderV2);
    final currentUserId = authState.user?.id;
    final userType = authState.userType;
    final isPaciente = userType == UserType.paciente;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, isPaciente, currentUserId),
          const SizedBox(height: 12),
          _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    bool isPaciente,
    String? currentUserId,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Avaliações',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Botão "Avaliar" (apenas para pacientes)
        if (isPaciente &&
            currentUserId != null &&
            currentUserId != professionalId)
          ElevatedButton.icon(
            onPressed: () => _onEvaluateTap(context, ref, currentUserId),
            icon: const Icon(Icons.rate_review, size: 16),
            label: const Text('Avaliar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
      ],
    );
  }

  Future<void> _onEvaluateTap(
      BuildContext context, WidgetRef ref, String currentUserId) async {
    // Verificar se já avaliou
    final reviewsState = ref.read(reviewsProviderV2);
    final userReviews =
        reviewsState.reviewsByProfessional[professionalId] ?? [];
    final hasReviewed = userReviews.any((r) => r.patientId == currentUserId);

    if (hasReviewed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você já avaliou este profissional!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navegar para tela de avaliação
    if (context.mounted) {
      context.go(
        '/add-review?professionalId=$professionalId&professionalName=${Uri.encodeComponent(professionalName)}',
      );
    }
  }

  Widget _buildReviewsList() {
    return Consumer(
      builder: (context, ref, child) {
        final reviewsState = ref.watch(reviewsProviderV2);

        if (reviewsState.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final professionalReviews =
            reviewsState.reviewsByProfessional[professionalId] ?? [];

        if (professionalReviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nenhuma avaliação ainda. Seja o primeiro a avaliar!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Calcular média local
        final avgRating = professionalReviews.isEmpty
            ? 0.0
            : professionalReviews.map((r) => r.rating).reduce((a, b) => a + b) /
                professionalReviews.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Média de avaliações
            _buildAverageRating(context, avgRating, professionalReviews.length),
            const Divider(),

            // Lista de avaliações
            ...professionalReviews.map((review) => ReviewCard(review: review)),
          ],
        );
      },
    );
  }

  Widget _buildAverageRating(
      BuildContext context, double avgRating, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < avgRating.floor()
                    ? Icons.star
                    : (index < avgRating && avgRating < index + 1)
                        ? Icons.star_half
                        : Icons.star_border,
                color: index < avgRating.ceil() ? Colors.amber : Colors.grey,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${avgRating.toStringAsFixed(1)} ($count avaliações)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
