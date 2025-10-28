import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'src/config/firebase_config.dart';
import 'src/core/app_router.dart';
import 'src/core/logger.dart';

void main() async {
  // Initialize Firebase Admin SDK
  await FirebaseConfig.initialize();
  
  final logger = AppLogger.instance;
  logger.info('🚀 Initializing App Sanitária Backend...');

  // Create router
  final router = createRouter();

  // Create middleware pipeline
  var handler = router;
  handler = _loggingMiddleware(handler);
  handler = const Pipeline()
      .addMiddleware(corsHeaders())
      .addHandler(handler);

  // Start server
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  logger.info('✅ Backend running at http://${server.address.host}:${server.port}');
  logger.info('📊 Available endpoints:');
  logger.info('   POST   /api/v1/reviews/{professionalId}/aggregate');
  logger.info('   PATCH  /api/v1/contracts/{contractId}/status');
  logger.info('   PATCH  /api/v1/contracts/{contractId}/cancel');
}

// Logging middleware
Middleware _loggingMiddleware = (innerHandler) {
  return (request) async {
    final logger = AppLogger.instance;
    final stopwatch = Stopwatch()..start();
    
    final response = await innerHandler(request);
    
    stopwatch.stop();
    final duration = stopwatch.elapsedMilliseconds;
    
    logger.info(
      '${request.method} ${request.url.path} → ${response.statusCode} (${duration}ms)',
    );
    
    return response;
  };
};
