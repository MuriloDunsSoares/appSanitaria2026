/// Exceptions representam erros no **Data Layer**.
///
/// Estas classes são usadas internamente nos datasources/repositories e
/// devem ser convertidas em [Failure] antes de retornar ao domain layer.
///
/// **Convenção:**
/// - Exceptions SÃO exceptions do Dart (extends Exception)
/// - Podem conter stack traces e detalhes técnicos
/// - NUNCA devem vazar para a camada de apresentação
/// - Repositories fazem a conversão: Exception → Failure
library;

// ════════════════════════════════════════════════════════════════════════════
// ✅ AUTH EXCEPTIONS
// ════════════════════════════════════════════════════════════════════════════

/// Credenciais inválidas durante autenticação.
class InvalidCredentialsException implements Exception {
  final String message;
  const InvalidCredentialsException([this.message = 'Invalid credentials']);

  @override
  String toString() => 'InvalidCredentialsException: $message';
}

/// Usuário não encontrado no datasource.
class UserNotFoundException implements Exception {
  final String email;
  const UserNotFoundException(this.email);

  @override
  String toString() => 'UserNotFoundException: User with email $email not found';
}

/// Email já existe no sistema.
class EmailAlreadyExistsException implements Exception {
  final String message;
  const EmailAlreadyExistsException([this.message = 'Email already registered']);

  @override
  String toString() => 'EmailAlreadyExistsException: $message';
}

/// Erro genérico de autenticação.
class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException([this.message = 'Authentication error']);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Erro de validação de dados.
class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Validation error']);

  @override
  String toString() => 'ValidationException: $message';
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ STORAGE EXCEPTIONS
// ════════════════════════════════════════════════════════════════════════════

/// Erro genérico de armazenamento local.
class LocalStorageException implements Exception {
  final String message;
  final dynamic originalError;

  const LocalStorageException(this.message, [this.originalError]);

  @override
  String toString() => 'LocalStorageException: $message'
      '${originalError != null ? ' (Original: $originalError)' : ''}';
}

/// Erro genérico de armazenamento (local ou remoto - Firebase/Firestore).
class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Storage error']);

  @override
  String toString() => 'StorageException: $message';
}

/// Recurso não encontrado no storage.
class NotFoundException implements Exception {
  final String resource;
  final String id;

  const NotFoundException(this.resource, this.id);

  @override
  String toString() => 'NotFoundException: $resource with id $id not found';
}

/// Erro ao serializar/deserializar JSON.
class SerializationException implements Exception {
  final String message;
  final dynamic originalError;

  const SerializationException(this.message, [this.originalError]);

  @override
  String toString() => 'SerializationException: $message'
      '${originalError != null ? ' (Original: $originalError)' : ''}';
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ NETWORK EXCEPTIONS (preparado para futuro)
// ════════════════════════════════════════════════════════════════════════════

/// Erro de conexão com servidor.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, [this.statusCode]);

  @override
  String toString() => 'NetworkException: $message'
      '${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

/// Timeout de requisição.
class TimeoutException implements Exception {
  final String operation;

  const TimeoutException(this.operation);

  @override
  String toString() => 'TimeoutException: Operation "$operation" timed out';
}

/// Exception lançada quando tenta usar o app offline
class OfflineModeException implements Exception {
  final String message;
  const OfflineModeException([this.message = 'App requer conexão com internet']);

  @override
  String toString() => 'OfflineModeException: $message';
}

