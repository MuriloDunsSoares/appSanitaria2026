import 'package:flutter/material.dart';

/// Widget: Botão Publicar Anúncio
///
/// Responsabilidade: Botão para publicar anúncios (funcionalidade futura)
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o botão
/// - Open/Closed: Fácil de estender quando a funcionalidade for implementada
class PublishAdButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PublishAdButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF667EEA),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF667EEA), width: 2),
        ),
        elevation: 2,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, size: 24),
          SizedBox(width: 8),
          Text(
            'Publicar um anúncio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


