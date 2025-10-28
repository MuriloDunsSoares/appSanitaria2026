import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../features/contracts/presentation/controllers/contracts_controller.dart';
import '../features/reviews/presentation/controllers/reviews_controller.dart';
import 'logger.dart';

Handler createRouter() {
  final logger = AppLogger.instance;
  final router = Router();

  // Initialize controllers
  final reviewsController = ReviewsController();
  final contractsController = ContractsController();

  logger.info('📍 Mounting routes...');

  // ==================== Health Check ====================
  router.get('/health', (Request request) {
    return Response.ok('Backend is running');
  });

  // ==================== Reviews Routes ====================
  
  /// POST /api/v1/reviews/{professionalId}/aggregate
  /// Calculate and update average rating for professional
  router.post(
    '/api/v1/reviews/<professionalId>/aggregate',
    reviewsController.aggregateAverageRating,
  );

  logger.info('✅ Route: POST /api/v1/reviews/<professionalId>/aggregate');

  // ==================== Contracts Routes ====================

  /// PATCH /api/v1/contracts/{contractId}/status
  /// Update contract status with validation
  router.patch(
    '/api/v1/contracts/<contractId>/status',
    contractsController.updateStatus,
  );

  logger.info('✅ Route: PATCH /api/v1/contracts/<contractId>/status');

  /// PATCH /api/v1/contracts/{contractId}/cancel
  /// Cancel a contract with reason
  router.patch(
    '/api/v1/contracts/<contractId>/cancel',
    contractsController.cancelContract,
  );

  logger.info('✅ Route: PATCH /api/v1/contracts/<contractId>/cancel');

  /// PATCH /api/v1/contracts/{contractId}
  /// Update contract fields (if pending)
  router.patch(
    '/api/v1/contracts/<contractId>',
    contractsController.updateContract,
  );

  logger.info('✅ Route: PATCH /api/v1/contracts/<contractId>');

  // ==================== 404 Handler ====================
  router.all('/<ignored|.*>', (Request request) {
    logger.warning('❌ Route not found: ${request.method} ${request.url.path}');
    return Response.notFound(
      '{"error": "Route not found: ${request.method} ${request.url.path}"}',
      headers: {'content-type': 'application/json'},
    );
  });

  logger.info('✅ All routes mounted successfully');

  return router.call;
}
