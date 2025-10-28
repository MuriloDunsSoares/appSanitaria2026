import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../../core/exceptions.dart';
import '../../../../core/logger.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../domain/services/contracts_service.dart';

class ContractsController {
  final authService = AuthService.instance;
  final contractsService = ContractsService.instance;
  final logger = AppLogger.instance;

  /// PATCH /api/v1/contracts/{contractId}/status
  /// Updates contract status with validation
  Future<Response> updateStatus(
    Request request,
    String contractId,
  ) async {
    try {
      logger.info('📥 PATCH /contracts/$contractId/status');

      // 1. Validate JWT token
      final authHeader = request.headers['authorization'];
      if (authHeader == null || authHeader.isEmpty) {
        return _unauthorized('JWT token requerido');
      }

      final userId = await authService.validateToken(authHeader);
      logger.debug('✅ Token validated for user: $userId');

      // 2. Parse request body
      final body = await request.readAsString();
      if (body.isEmpty) {
        return _badRequest('Body não pode estar vazio');
      }

      final params = jsonDecode(body) as Map<String, dynamic>;
      final newStatus = params['newStatus'] as String?;

      if (newStatus == null || newStatus.isEmpty) {
        return _badRequest('newStatus é obrigatório');
      }

      // 3. Call service
      final result = await contractsService.updateContractStatus(
        contractId: contractId,
        newStatus: newStatus,
        userId: userId,
      );

      logger.info('✅ Contract status updated: $contractId → $newStatus');

      return _ok({
        'success': true,
        'data': result,
      });
    } on AuthenticationException catch (e) {
      logger.warning('🔐 Authentication failed: ${e.message}');
      return _unauthorized(e.message);
    } on AuthorizationException catch (e) {
      logger.warning('🛑 Authorization failed: ${e.message}');
      return _forbidden(e.message);
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
      return _internalError('Erro ao atualizar status do contrato');
    }
  }

  /// PATCH /api/v1/contracts/{contractId}/cancel
  /// Cancels a contract with reason
  Future<Response> cancelContract(
    Request request,
    String contractId,
  ) async {
    try {
      logger.info('📥 PATCH /contracts/$contractId/cancel');

      // 1. Validate JWT token
      final authHeader = request.headers['authorization'];
      if (authHeader == null || authHeader.isEmpty) {
        return _unauthorized('JWT token requerido');
      }

      final userId = await authService.validateToken(authHeader);
      logger.debug('✅ Token validated for user: $userId');

      // 2. Parse request body
      final body = await request.readAsString();
      if (body.isEmpty) {
        return _badRequest('Body não pode estar vazio');
      }

      final params = jsonDecode(body) as Map<String, dynamic>;
      final reason = params['reason'] as String?;

      if (reason == null || reason.isEmpty) {
        return _badRequest('reason é obrigatório');
      }

      // 3. Call service
      final result = await contractsService.cancelContract(
        contractId: contractId,
        userId: userId,
        reason: reason,
      );

      logger.info('✅ Contract cancelled: $contractId');

      return _ok({
        'success': true,
        'data': result,
      });
    } on AuthenticationException catch (e) {
      logger.warning('🔐 Authentication failed: ${e.message}');
      return _unauthorized(e.message);
    } on AuthorizationException catch (e) {
      logger.warning('🛑 Authorization failed: ${e.message}');
      return _forbidden(e.message);
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
      return _internalError('Erro ao cancelar contrato');
    }
  }

  /// PATCH /api/v1/contracts/{contractId}
  /// Updates contract fields (only if pending)
  Future<Response> updateContract(
    Request request,
    String contractId,
  ) async {
    try {
      logger.info('📥 PATCH /contracts/$contractId');

      // 1. Validate JWT token
      final authHeader = request.headers['authorization'];
      if (authHeader == null || authHeader.isEmpty) {
        return _unauthorized('JWT token requerido');
      }

      final userId = await authService.validateToken(authHeader);
      logger.debug('✅ Token validated for user: $userId');

      // 2. Parse request body
      final body = await request.readAsString();
      if (body.isEmpty) {
        return _badRequest('Body não pode estar vazio');
      }

      final updates = jsonDecode(body) as Map<String, dynamic>;

      // 3. Call service
      final result = await contractsService.updateContract(
        contractId: contractId,
        userId: userId,
        updates: updates,
      );

      logger.info('✅ Contract updated: $contractId');

      return _ok({
        'success': true,
        'data': result,
      });
    } on AuthenticationException catch (e) {
      logger.warning('🔐 Authentication failed: ${e.message}');
      return _unauthorized(e.message);
    } on AuthorizationException catch (e) {
      logger.warning('🛑 Authorization failed: ${e.message}');
      return _forbidden(e.message);
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
      return _internalError('Erro ao atualizar contrato');
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
