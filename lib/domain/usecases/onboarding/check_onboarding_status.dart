import '../../repositories/onboarding_repository.dart';

/// Use Case: Verificar se usuário completou onboarding
///
/// **Responsabilidade Única:**
/// Consultar o repository para determinar se o onboarding
/// já foi concluído pelo usuário.
///
/// **Regras de Negócio:**
/// - Usuário que nunca viu onboarding → retorna `false`
/// - Usuário que já completou → retorna `true`
/// - Usuário que resetou → retorna `false`
///
/// **Fluxo:**
/// ```
/// App inicia
///   ↓
/// CheckOnboardingStatus()
///   ↓
/// hasCompleted = true/false
///   ↓
/// Router decide: mostrar onboarding ou home
/// ```
///
/// **Padrão:** Use Case Pattern (Clean Architecture)
class CheckOnboardingStatus {

  CheckOnboardingStatus(this.repository);
  final OnboardingRepository repository;

  /// Executa o use case
  ///
  /// Retorna `true` se onboarding já foi completado,
  /// `false` caso contrário.
  ///
  /// **Exemplo:**
  /// ```dart
  /// final checkStatus = getIt<CheckOnboardingStatus>();
  /// final hasCompleted = await checkStatus();
  /// if (!hasCompleted) {
  ///   // Mostrar onboarding
  /// }
  /// ```
  Future<bool> call() async {
    return repository.hasCompletedOnboarding();
  }
}
