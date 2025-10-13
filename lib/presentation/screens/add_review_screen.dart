import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_sanitaria/presentation/providers/reviews_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/presentation/widgets/rating_stars.dart';
import 'package:app_sanitaria/domain/entities/review_entity.dart';

/// Tela para adicionar avaliação de um profissional
class AddReviewScreen extends ConsumerStatefulWidget {
  final String professionalId;
  final String professionalName;

  const AddReviewScreen({
    super.key,
    required this.professionalId,
    required this.professionalName,
  });

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authState = ref.read(authProviderV2);
    final currentUser = authState.user;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Usuário não autenticado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }

    final review = ReviewEntity(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      professionalId: widget.professionalId,
      patientId: currentUser.id,
      patientName: currentUser.nome,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await ref.read(reviewsProviderV2.notifier).addReview(review);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true); // Retorna true indicando sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avaliação enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar avaliação. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Profissional'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nome do profissional
              Text(
                'Avaliando',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.professionalName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Rating
              Center(
                child: Column(
                  children: [
                    Text(
                      'Como foi sua experiência?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RatingStars(
                      rating: _rating,
                      isInteractive: true,
                      size: 48,
                      onRatingChanged: (rating) {
                        setState(() => _rating = rating);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRatingLabel(_rating),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(_rating),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Comentário
              Text(
                'Deixe um comentário',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                maxLines: 6,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText:
                      'Conte mais sobre sua experiência com este profissional...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, escreva um comentário';
                  }
                  if (value.trim().length < 10) {
                    return 'O comentário deve ter pelo menos 10 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Botão Enviar
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enviar Avaliação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Muito Ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Regular';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    if (rating <= 2) return Colors.red;
    if (rating == 3) return Colors.orange;
    return Colors.green;
  }
}
