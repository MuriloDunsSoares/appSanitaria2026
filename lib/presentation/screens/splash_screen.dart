import 'package:flutter/material.dart';

/// Splash Screen otimizada para inicialização
///
/// **Objetivo:** Mostrar feedback visual enquanto o app inicializa
/// **Otimização:** Widget leve que aparece IMEDIATAMENTE
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF2196F3), // Azul Material
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Ícone
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 64,
                  color: Color(0xFF2196F3),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Nome do App
              const Text(
                'AppSanitaria',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Conectando profissionais e pacientes',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Loading indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Inicializando...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

