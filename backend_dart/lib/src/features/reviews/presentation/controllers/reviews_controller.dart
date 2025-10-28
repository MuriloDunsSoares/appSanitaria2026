import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../../core/exceptions.dart';
import '../../../../core/logger.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../domain/services/reviews_service.dart';

class ReviewsController {
  final authService = AuthService.instance;
  final reviewsService = ReviewsService.instance;
  final logger = AppLogger.instance;

  /// POST /api/v1/reviews/{professionalId}/aggregate
  /// Calculates and updates average rating for a professional
  Future<Response> aggregateAverageRating(
    Request request,
    String professionalId,
  ) async {
    try {
      logger.info('📥 POST /reviews/$professionalId/aggregate');

      // 1. Validate JWT token
      final authHeader = request.headers['authorization'];
      if (authHeader == null || authHeader.isEmpty) {
        return _unauthorized('JWT token requerido');
      }

      final userId = await authService.validateToken(authHeader);
      logger.debug('✅ Token validated for user: $userId');

      // 2. Validate professional ID format
      if (professionalId.isEmpty) {
        return _badRequest('professionalId não pode estar vazio');
      }

      // 3. Call service to calculate and update
      final result = await reviewsService.calculateAverageRating(professionalId);

      logger.info(
        '✅ Average rating calculated: ${result['averageRating']} for $professionalId',
      );

      // 4. Return success response
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': result,
        }),
        headers: {'content-type': 'application/json'},
      );
    } on AuthenticationException catch (e) {
      logger.warning('🔐 Authentication failed: ${e.message}');
      return _unauthorized(e.message);
    } on NotFoundException catch (e) {
      logger.warning('🔍 Not found: ${e.message}');
      return _notFound(e.message);
    } on ValidationException catch (e) {
      logger.warning('⚠️ Validation error: ${e.message}');
      return _badRequest(e.message);
    } on AppException catch (e) {
      logger.error('❌ App exception', e);
      return _error(e.message, statusCode: e.statusCode);
    } catch (e) {
      logger.error('❌ Unexpected error', e);
      return _internalError('Erro ao calcular avaliação média');
    }
  }

  // ==================== Response Helpers ====================

  Response _ok(Map<String, dynamic> data) {
    return Response.ok(
      jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _created(Map<String, dynamic> data) {
    return Response(
      201,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _badRequest(String message) {
    return Response(
      400,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _unauthorized(String message) {
    return Response(
      401,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _forbidden(String message) {
    return Response(
      403,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _notFound(String message) {
    return Response(
      404,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _conflict(String message) {
    return Response(
      409,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _internalError(String message) {
    return Response(
      500,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json'},
    );
  }

  Response _error(String message, {required int statusCode}) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json'},
    );
  }
}
