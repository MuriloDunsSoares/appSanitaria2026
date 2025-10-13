import 'package:app_sanitaria/core/routes/app_router.dart';
import 'package:flutter/material.dart';

/// Tela de Seleção de Tipo de Usuário
///
/// Responsabilidades:
/// - Permitir escolha entre Profissional e Paciente
/// - Navegar para tela de cadastro apropriada
///
/// Princípios:
/// - Single Responsibility: Apenas seleção de tipo
/// - Stateless: Não precisa de estado interno
/// - UI simples e clara
class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  /// Navega para cadastro de profissional
  void _navigateToProfessionalRegistration(BuildContext context) {
    context.goToRegisterProfessional();
  }

  /// Navega para cadastro de paciente
  void _navigateToPatientRegistration(BuildContext context) {
    context.goToRegisterPatient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar/Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: const Icon(
                  Icons.medical_services,
                  size: 60,
                  color: Color(0xFF667EEA),
                ),
              ),

              const SizedBox(height: 32),

              // Título
              const Text(
                'Como deseja se cadastrar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 48),

              // Card Profissional
              _SelectionCard(
                icon: Icons.work,
                title: 'Sou Profissional',
                subtitle: 'Ofereço serviços de saúde',
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                onTap: () => _navigateToProfessionalRegistration(context),
              ),

              const SizedBox(height: 16),

              // Card Paciente
              _SelectionCard(
                icon: Icons.person,
                title: 'Sou Paciente',
                subtitle: 'Busco profissionais de saúde',
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                onTap: () => _navigateToPatientRegistration(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget reutilizável para card de seleção
///
/// Princípio DRY: Evita duplicação de código
class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
