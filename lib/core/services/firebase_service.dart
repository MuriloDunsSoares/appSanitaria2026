import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import '../utils/app_logger.dart';

/// Serviço para inicialização e gerenciamento do Firebase
///
/// Responsável por:
/// - Inicializar Firebase Core
/// - Configurar Firebase Cloud Messaging (FCM)
/// - Gerenciar tokens de notificação push
class FirebaseService {
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  static final FirebaseService _instance = FirebaseService._internal();

  bool _initialized = false;
  String? _fcmToken;

  /// Retorna o token FCM atual
  String? get fcmToken => _fcmToken;

  /// Inicializa o Firebase
  ///
  /// Deve ser chamado no início do app, antes de qualquer
  /// operação com Firebase.
  Future<void> initialize() async {
    if (_initialized) {
      AppLogger.info('Firebase já foi inicializado');
      return;
    }

    try {
      AppLogger.info('Inicializando Firebase...');

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _initialized = true;
      AppLogger.info('✅ Firebase inicializado com sucesso');

      // ✅ OTIMIZAÇÃO: Configurar FCM em background para não bloquear UI
      // Aguarda o próximo frame antes de inicializar FCM
      _setupFCMLater();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao inicializar Firebase',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Configura FCM após o primeiro frame para não bloquear a UI
  void _setupFCMLater() {
    // Executa após o frame atual terminar
    Future.microtask(() async {
      try {
        await _setupFCM();
      } catch (e, stackTrace) {
        AppLogger.error('Erro ao configurar FCM em background',
            error: e, stackTrace: stackTrace);
      }
    });
  }

  /// Configura o Firebase Cloud Messaging (FCM)
  ///
  /// Solicita permissões e obtém o token FCM do dispositivo
  Future<void> _setupFCM() async {
    try {
      AppLogger.info('Configurando Firebase Cloud Messaging...');

      final messaging = FirebaseMessaging.instance;

      // Solicitar permissões (iOS)
      final settings = await messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.info('✅ Permissões de notificação concedidas');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        AppLogger.info('⚠️ Permissões de notificação provisórias concedidas');
      } else {
        AppLogger.info('❌ Permissões de notificação negadas');
        return;
      }

      // Obter token FCM
      _fcmToken = await messaging.getToken();
      if (_fcmToken != null) {
        AppLogger.info('✅ Token FCM obtido: ${_fcmToken!.substring(0, 20)}...');
      } else {
        AppLogger.info('⚠️ Não foi possível obter token FCM');
      }

      // Listener para quando o token mudar
      messaging.onTokenRefresh.listen((newToken) {
        AppLogger.info('Token FCM atualizado');
        _fcmToken = newToken;
        // TODO: Atualizar token no Firestore
      });

      // Configurar handlers de mensagens
      _setupMessageHandlers();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao configurar FCM',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Configura os handlers para mensagens FCM
  void _setupMessageHandlers() {
    // Mensagem recebida quando app está em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info(
          'Mensagem recebida (foreground): ${message.notification?.title}');
      // TODO: Mostrar notificação local ou atualizar UI
    });

    // Mensagem clicada quando app estava em background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info(
          'Mensagem clicada (background): ${message.notification?.title}');
      // TODO: Navegar para tela específica
    });

    // Handler para mensagens em background (função top-level)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Atualiza o token FCM do usuário no Firestore
  ///
  /// [userId] ID do usuário logado
  Future<void> updateUserFCMToken(String userId) async {
    if (_fcmToken == null) {
      AppLogger.info('⚠️ Token FCM não disponível para atualizar');
      return;
    }

    try {
      // TODO: Implementar atualização no Firestore
      AppLogger.info('Token FCM atualizado para usuário $userId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar token FCM',
          error: e, stackTrace: stackTrace);
    }
  }
}

/// Handler para mensagens recebidas em background
///
/// IMPORTANTE: Esta função DEVE ser top-level (fora de classes)
/// para funcionar corretamente com FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.info(
      'Mensagem recebida (background): ${message.notification?.title}');
}
