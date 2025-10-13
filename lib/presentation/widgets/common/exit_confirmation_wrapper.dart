import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget: Exit Confirmation Wrapper
///
/// Responsabilidade: Controlar o comportamento do botão voltar do Android APENAS na tela HOME
///
/// Princípios aplicados:
/// - User Experience: Evita saída acidental do app
/// - Single Responsibility: Apenas gerencia confirmação de saída
///
/// Funcionamento:
/// - APENAS na tela HOME, quando usuário clica em voltar
///   → Mostra diálogo de confirmação antes de sair
///
/// Uso:
/// ```dart
/// ExitConfirmationWrapper(
///   child: Scaffold(...),
/// )
/// ```
class ExitConfirmationWrapper extends StatelessWidget {
  final Widget child;

  const ExitConfirmationWrapper({
    super.key,
    required this.child,
  });

  Future<void> _handleBackButton(BuildContext context) async {
    // Mostra diálogo de confirmação
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do App'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      // Fecha o app
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _handleBackButton(context);
        }
      },
      child: child,
    );
  }
}

