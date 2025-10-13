import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Configuração centralizada do Firebase
///
/// Implementa as melhores práticas da consultoria Firebase:
/// - Multi-tenant isolation
/// - Offline persistence
/// - Performance monitoring
/// - Error tracking
class FirebaseConfig {
  static late FirebaseFirestore _firestore;
  static late FirebaseAuth _auth;
  static late FirebaseStorage _storage;
  static late FirebaseAnalytics _analytics;

  /// Inicializa Firebase com todas as configurações recomendadas
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;
    _analytics = FirebaseAnalytics.instance;

    // Configurar Firestore (CONSULTORIA: Performance)
    _firestore.settings = const Settings(
      persistenceEnabled: true, // Cache offline
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Cache ilimitado
    );

    // Configurar Crashlytics (CONSULTORIA: Observabilidade)
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // Configurar Performance Monitoring (CONSULTORIA: Monitoramento)
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

    // Development: Usar emulators
    if (kDebugMode) {
      _useEmulators();
    }

    debugPrint('✅ Firebase initialized successfully');
  }

  /// Usa emulators locais para desenvolvimento
  static void _useEmulators() {
    try {
      _firestore.useFirestoreEmulator('localhost', 8080);
      _auth.useAuthEmulator('localhost', 9099);
      _storage.useStorageEmulator('localhost', 9199);
      debugPrint('🔧 Using Firebase Emulators');
    } catch (e) {
      debugPrint('⚠️ Emulators not available: $e');
    }
  }

  // ==================== GETTERS ====================

  static FirebaseFirestore get firestore => _firestore;
  static FirebaseAuth get auth => _auth;
  static FirebaseStorage get storage => _storage;
  static FirebaseAnalytics get analytics => _analytics;

  // ==================== MULTI-TENANT HELPERS ====================

  /// Retorna CollectionReference para uma coleção dentro de uma organização
  ///
  /// CONSULTORIA: Arquitetura Multi-Tenant
  /// - Isolamento completo entre organizações
  /// - Security Rules simples (RLS por organizationId)
  /// - Escalabilidade horizontal
  ///
  /// Exemplo:
  /// ```dart
  /// final contracts = FirebaseConfig.orgCollection('org_001', 'contracts');
  /// ```
  static CollectionReference orgCollection(
    String organizationId,
    String collectionName,
  ) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection(collectionName);
  }

  /// Retorna DocumentReference para um documento de organização
  static DocumentReference orgDocument(String organizationId) {
    return _firestore.collection('organizations').doc(organizationId);
  }

  // ==================== GLOBAL COLLECTIONS ====================

  /// Collection de userProfiles (global - usado para auth lookup)
  ///
  /// CONSULTORIA: Estrutura de dados
  /// userProfiles contém:
  /// - email (indexed)
  /// - organizationId (link para tenant)
  /// - role, status
  static CollectionReference get userProfilesCollection {
    return _firestore.collection('userProfiles');
  }

  /// Collection de auditLogs (global - compliance LGPD)
  static CollectionReference get auditLogsCollection {
    return _firestore.collection('auditLogs');
  }

  // ==================== ANALYTICS HELPERS ====================

  /// Log evento de analytics
  static Future<void> logEvent(
      String name, Map<String, Object>? parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  /// Define user ID para analytics
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Define user properties para analytics
  static Future<void> setUserProperties({
    required String userType,
    required String city,
    String? organizationId,
  }) async {
    await _analytics.setUserProperty(name: 'user_type', value: userType);
    await _analytics.setUserProperty(name: 'city', value: city);
    if (organizationId != null) {
      await _analytics.setUserProperty(
          name: 'organization_id', value: organizationId);
    }
  }
}
