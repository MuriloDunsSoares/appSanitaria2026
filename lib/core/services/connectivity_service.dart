import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Serviço para verificação de conectividade com a internet
///
/// Responsável por:
/// - Monitorar estado da conexão (online/offline)
/// - Fornecer stream de mudanças de conectividade
/// - Verificar se há conexão disponível
class ConnectivityService {
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();
  static final ConnectivityService _instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  ConnectivityResult? _lastResult;

  /// Stream que emite mudanças no estado da conectividade
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Verifica se há conexão com a internet disponível
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _lastResult = result.isNotEmpty ? result.first : ConnectivityResult.none;

      // Considera conectado se não for none
      return _lastResult != ConnectivityResult.none;
    } catch (e) {
      debugPrint('Erro ao verificar conectividade: $e');
      return false;
    }
  }

  /// Retorna o último resultado conhecido da conectividade
  ConnectivityResult? get lastResult => _lastResult;

  /// Verifica se está conectado especificamente via Wi-Fi
  Future<bool> isConnectedViaWifi() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Verifica se está conectado via dados móveis
  Future<bool> isConnectedViaMobile() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile);
  }

  /// Inicializa o serviço (chamar no main se necessário)
  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _lastResult = result.isNotEmpty ? result.first : ConnectivityResult.none;
  }
}
