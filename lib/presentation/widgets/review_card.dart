import 'package:flutter/material.dart';
import 'package:app_sanitaria/domain/entities/review_entity.dart';
import 'package:app_sanitaria/presentation/widgets/rating_stars.dart';
import 'package:intl/intl.dart';

/// Card para exibir uma avaliação
class ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  final bool canDelete;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(review.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Nome + Data
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.teal.shade100,
                  child: Text(
                    review.patientName.isNotEmpty
                        ? review.patientName[0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      color: Colors.teal.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Nome e data
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Botão deletar (se permitido)
                if (canDelete && onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Deletar Avaliação'),
                          content: const Text(
                              'Deseja realmente deletar sua avaliação?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onDelete!();
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Deletar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Rating (estrelas)
            RatingStars(
              rating: review.rating,
              isInteractive: false,
              size: 20,
            ),

            const SizedBox(height: 12),

            // Comentário
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir resumo de avaliações (média + total)
class ReviewsSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;

  const ReviewsSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Número grande da média
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              RatingStars(
                rating: averageRating.round(),
                isInteractive: false,
                size: 20,
              ),
            ],
          ),

          const SizedBox(width: 24),

          // Detalhes
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$totalReviews avaliações',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalReviews > 0
                    ? 'Baseado em $totalReviews ${totalReviews == 1 ? "avaliação" : "avaliações"}'
                    : 'Nenhuma avaliação ainda',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
