/// Failures representam erros no **Domain Layer**.
///
/// Estas classes são abstratas e imutáveis, seguindo o padrão de programação
/// funcional. Devem ser usadas como retorno em Either<Failure, Success>.
///
/// **Convenção:**
/// - Failures NÃO devem conter stack traces ou detalhes de implementação
/// - São "value objects" que representam tipos de erros de negócio
/// - Repositories convertem Exceptions (data layer) em Failures (domain layer)
library;

import 'package:equatable/equatable.dart';

/// Classe base abstrata para todos os Failures do domínio.
///
/// **Por que Equatable?**
/// - Permite comparação por valor (não referência)
/// - Facilita testes unitários (expect(failure, equals(expectedFailure)))
/// - Performance otimizada para comparações
abstract class Failure extends Equatable {
  const Failure(this.message);

  /// Mensagem legível ao usuário (internacionalizada).
  final String message;

  @override
  List<Object?> get props => [message];
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ AUTH FAILURES
// ════════════════════════════════════════════════════════════════════════════

/// Credenciais inválidas (email/senha incorretos).
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure()
      : super('Email ou senha incorretos. Verifique e tente novamente.');
}

/// Usuário não encontrado no sistema.
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure()
      : super('Usuário não encontrado. Verifique o email informado.');
}

/// Email já cadastrado no sistema.
class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure()
      : super('Este email já está cadastrado. Tente fazer login.');
}

/// Sessão expirada ou token inválido.
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure()
      : super('Sua sessão expirou. Faça login novamente.');
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ VALIDATION FAILURES
// ════════════════════════════════════════════════════════════════════════════

/// Dados de entrada inválidos (ex: email malformado, campos obrigatórios vazios).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ STORAGE FAILURES
// ════════════════════════════════════════════════════════════════════════════

/// Erro ao acessar armazenamento de dados (Firebase Firestore).
class StorageFailure extends Failure {
  const StorageFailure(
      [super.message =
          'Erro ao conectar com o servidor. Verifique sua conexão.']);
}

/// Recurso não encontrado no armazenamento.
class NotFoundFailure extends Failure {
  const NotFoundFailure(String resource) : super('$resource não encontrado(a)');
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ NETWORK FAILURES (preparado para futuro)
// ════════════════════════════════════════════════════════════════════════════

/// Erro de conexão com servidor (timeout, sem internet, etc).
class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message =
          'Erro de conexão. Verifique sua internet e tente novamente.']);
}

/// Erro interno do servidor (5xx).
class ServerFailure extends Failure {
  const ServerFailure()
      : super('Erro no servidor. Tente novamente em alguns instantes.');
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ GENERIC FAILURES
// ════════════════════════════════════════════════════════════════════════════

/// Erro inesperado não mapeado.
///
/// **ATENÇÃO:** Use este failure apenas como fallback. Idealmente, todos os
/// erros devem ter um failure específico para melhor tratamento na UI.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(
      [super.message = 'Erro inesperado. Tente novamente.']);
}
