abstract class AppException implements Exception {

  AppException({
    required this.message,
    required this.statusCode,
  });
  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  ValidationException(String message)
      : super(message: message, statusCode: 400);
}

class AuthenticationException extends AppException {
  AuthenticationException(String message)
      : super(message: message, statusCode: 401);
}

class AuthorizationException extends AppException {
  AuthorizationException(String message)
      : super(message: message, statusCode: 403);
}

class NotFoundException extends AppException {
  NotFoundException(String message)
      : super(message: message, statusCode: 404);
}

class ConflictException extends AppException {
  ConflictException(String message)
      : super(message: message, statusCode: 409);
}

class ServerException extends AppException {
  ServerException(String message)
      : super(message: message, statusCode: 500);
}
