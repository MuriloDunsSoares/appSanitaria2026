import 'package:flutter/material.dart';

/// Widget para exibir e/ou selecionar rating com estrelas
///
/// Modos:
/// - Display: Apenas exibição (isInteractive = false)
/// - Interactive: Permite seleção (isInteractive = true)
class RatingStars extends StatefulWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.isInteractive = false,
    this.onRatingChanged,
    this.size = 24,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  });
  final int rating; // 0 a 5
  final bool isInteractive;
  final Function(int rating)? onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  void didUpdateWidget(RatingStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rating != oldWidget.rating) {
      setState(() {
        _currentRating = widget.rating;
      });
    }
  }

  void _onStarTap(int index) {
    if (!widget.isInteractive) return;

    final newRating = index + 1;
    setState(() => _currentRating = newRating);

    if (widget.onRatingChanged != null) {
      widget.onRatingChanged!(newRating);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < _currentRating;

        return GestureDetector(
          onTap: widget.isInteractive ? () => _onStarTap(index) : null,
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? widget.activeColor : widget.inactiveColor,
            size: widget.size,
          ),
        );
      }),
    );
  }
}

/// Widget para exibir média de avaliações com estrelas + número
class RatingDisplay extends StatelessWidget {
  const RatingDisplay({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.size = 20,
    this.showCount = true,
  });
  final double rating; // 0.0 a 5.0
  final int totalReviews;
  final double size;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Estrelas
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            // Estrela cheia
            return Icon(
              Icons.star,
              color: Colors.amber,
              size: size,
            );
          } else if (index < rating && rating - index >= 0.5) {
            // Meia estrela
            return Icon(
              Icons.star_half,
              color: Colors.amber,
              size: size,
            );
          } else {
            // Estrela vazia
            return Icon(
              Icons.star_border,
              color: Colors.grey,
              size: size,
            );
          }
        }),

        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '($totalReviews)',
            style: TextStyle(
              fontSize: size * 0.7,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}
