import '../../repositories/onboarding_repository.dart';

/// Use Case: Marcar onboarding como completo
///
/// **Responsabilidade Única:**
/// Persistir localmente que o usuário completou o processo
/// de onboarding, garantindo que não seja exibido novamente.
///
/// **Regras de Negócio:**
/// - Deve ser chamado apenas ao concluir todas as telas
/// - Persiste versão do onboarding para controle de updates
/// - Não deve falhar silenciosamente (throw exceptions)
///
/// **Fluxo:**
/// ```
/// Usuário clica "Começar" na última tela
///   ↓
/// CompleteOnboarding()
///   ↓
/// Repository persiste flag
///   ↓
/// Navega para tela de seleção
/// ```
///
/// **Padrão:** Use Case Pattern (Clean Architecture)
class CompleteOnboarding {

  CompleteOnboarding(this.repository);
  final OnboardingRepository repository;

  /// Executa o use case
  ///
  /// Marca o onboarding como completo e persiste localmente.
  ///
  /// **Exemplo:**
  /// ```dart
  /// final completeOnboarding = getIt<CompleteOnboarding>();
  /// await completeOnboarding();
  /// context.go('/selection');
  /// ```
  ///
  /// **Exceções:**
  /// Pode lançar exceções se falhar ao persistir dados.
  Future<void> call() async {
    await repository.completeOnboarding();
  }
}
