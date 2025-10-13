import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/core/routes/app_router.dart';
import 'package:app_sanitaria/core/services/connectivity_service.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';

/// Tela de Login
///
/// Responsabilidades:
/// - Capturar email e senha do usuário
/// - Validar inputs antes de enviar
/// - Navegar para seleção de tipo de usuário (cadastro)
/// - Navegar para home após login bem-sucedido
///
/// Segue princípios:
/// - Single Responsibility: Apenas UI de login
/// - Stateful: Gerencia estado local do formulário
/// - Validações básicas de input
/// - Integrado com AuthProvider (Riverpod)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers para inputs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Form key para validação
  final _formKey = GlobalKey<FormState>();

  // Visibilidade da senha
  bool _obscurePassword = true;

  // Manter logado
  bool _keepLoggedIn = false;

  // Estado da conectividade
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivityChanges();
  }

  @override
  void dispose() {
    // Limpar controllers ao destruir widget (boa prática)
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Verifica conectividade inicial
  Future<void> _checkConnectivity() async {
    final connectivityService = ConnectivityService();
    final isConnected = await connectivityService.isConnected();
    setState(() {
      _isOnline = isConnected;
    });
  }

  /// Escuta mudanças na conectividade
  void _listenToConnectivityChanges() {
    final connectivityService = ConnectivityService();
    connectivityService.onConnectivityChanged.listen((results) {
      final isConnected = results.isNotEmpty && results.first != ConnectivityResult.none;
      setState(() {
        _isOnline = isConnected;
      });
    });
  }

  /// Valida e realiza login
  Future<void> _handleLogin() async {
    // Validar form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Verificar conectividade antes de tentar login
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você está offline. Este aplicativo requer conexão com internet.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Chamar login via AuthProvider com preferência de "manter logado"
    await ref.read(authProviderV2.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          keepLoggedIn: _keepLoggedIn,
        );
  }

  /// Navega para tela de seleção de tipo de usuário
  void _navigateToRegistration() {
    context.goToSelection();
  }

  // Funções de debug removidas - app agora é 100% Firebase

  @override
  Widget build(BuildContext context) {
    // Observar estado de autenticação
    ref.listen<AuthState>(authProviderV2, (previous, next) {
      // Navegar após login bem-sucedido
      if (next.isAuthenticated) {
        final userType = next.userType;
        if (userType == UserType.paciente) {
          context.goToHomePatient();
        } else if (userType == UserType.profissional) {
          context.goToHomeProfessional();
        }
      }

      // Mostrar erro se houver
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    // Observar estado de loading
    final authState = ref.watch(authProviderV2);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo/Ícone
                const Icon(
                  Icons.medical_services,
                  size: 80,
                  color: Color(0xFF667EEA),
                ),

                const SizedBox(height: 24),

                // Título
                const Text(
                  'App Sanitária',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtítulo
                const Text(
                  'Entre para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 48),

                // Campo de email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite seu email';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo de senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite sua senha';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Checkbox "Manter logado"
                Row(
                  children: [
                    Checkbox(
                      value: _keepLoggedIn,
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _keepLoggedIn = value ?? false;
                              });
                            },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _keepLoggedIn = !_keepLoggedIn;
                                });
                              },
                        child: const Text(
                          'Manter logado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Botão de login
                ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Entrar'),
                ),

                const SizedBox(height: 16),

                // Indicador de conectividade
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isOnline ? Colors.green : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOnline ? Icons.wifi : Icons.wifi_off,
                        color: _isOnline ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOnline ? 'Conectado' : 'Offline',
                        style: TextStyle(
                          color: _isOnline ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Link para cadastro
                TextButton(
                  onPressed: isLoading ? null : _navigateToRegistration,
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
