import '../core/logger.dart';

class FirebaseConfig {
  static bool _initialized = false;

  static Future<void> initialize() async {
    try {
      final logger = AppLogger.instance;
      logger.info('🔥 Initializing Firebase Admin SDK...');

      // Note: In production, use service account JSON
      // For local dev, ensure GOOGLE_APPLICATION_CREDENTIALS is set
      // firebase_admin.initializeApp() is called automatically in most cases
      
      _initialized = true;
      logger.info('✅ Firebase initialized successfully');
    } catch (e) {
      AppLogger.instance.error('❌ Firebase initialization failed', e);
      rethrow;
    }
  }

  static bool get isInitialized => _initialized;

  // Placeholder for future Firestore instance
  static dynamic get firestore {
    if (!_initialized) {
      throw StateError('Firebase has not been initialized. Call initialize() first.');
    }
    // Return Firestore instance when firebase_admin provides proper API
    return null;
  }
}
