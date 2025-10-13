import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/profile_provider.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/presentation/widgets/profile_image_picker.dart';

/// Tela de Perfil (Minha Conta)
///
/// Responsabilidades:
/// - Exibir informações do usuário autenticado
/// - Permitir edição de dados pessoais
/// - Fazer logout
///
/// Princípios:
/// - Single Responsibility: Apenas UI de perfil
/// - Stateful: Gerencia edição de dados
/// - Integrado com AuthProvider
///
/// Navigation:
/// - Tela FULLSCREEN (sem bottom nav, sem floating buttons)
/// - Acessível por PACIENTES e PROFISSIONAIS
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  /// Carrega foto de perfil do usuário
  Future<void> _loadProfileImage() async {
    final authState = ref.read(authProviderV2);
    final userId = authState.user?.id;

    if (userId != null) {
      await ref.read(profileProvider.notifier).loadProfileImage(userId);
      final profileState = ref.read(profileProvider);
      
      if (profileState.profileImagePath != null && mounted) {
        setState(() => _profileImagePath = profileState.profileImagePath);
      }
    }
  }

  /// Salva nova foto de perfil
  Future<void> _onImageSelected(String imagePath) async {
    final authState = ref.read(authProviderV2);
    final userId = authState.user?.id;

    if (userId != null) {
      await ref.read(profileProvider.notifier).saveProfileImage(userId, imagePath);
      setState(() => _profileImagePath = imagePath);
    }
  }

  /// Realiza logout
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProviderV2.notifier).logout();
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProviderV2);
    final user = authState.user;
    final userType = authState.userType;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Voltar para HOME ao clicar no botão voltar
          if (userType == UserType.paciente) {
            context.go('/home/patient');
          } else {
            context.go('/home/professional');
          }
        }
      },
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Tela acessada via bottom nav
        title: const Text('Minha Conta'),
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar com ProfileImagePicker
                  ProfileImagePicker(
                    initialImagePath: _profileImagePath,
                    onImageSelected: _onImageSelected,
                    size: 120,
                  ),

                  const SizedBox(height: 24),

                  // Nome
                  Text(
                    user.nome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Tipo de usuário
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: userType == UserType.paciente
                          ? Colors.green.shade100
                          : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userType == UserType.paciente
                          ? 'Paciente'
                          : 'Profissional',
                      style: TextStyle(
                        color: userType == UserType.paciente
                            ? Colors.green.shade900
                            : Colors.blue.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Card de informações
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: user.email,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.phone,
                            label: 'Telefone',
                            value: user.telefone,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.location_city,
                            label: 'Cidade',
                            value: _getUserLocation(user),
                          ),
                          if (userType == UserType.profissional) ...[
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.work,
                              label: 'Especialidade',
                              value: _getUserSpecialty(user),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão Meus Contratos
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/contracts');
                      },
                      icon: const Icon(Icons.description),
                      label: const Text('Meus Contratos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão Editar Perfil
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.go('/edit-profile');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Perfil'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  /// Constrói uma linha de informação
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey.shade600),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Obtém localização do usuário
  String _getUserLocation(UserEntity user) {
    if (user is PatientEntity) {
      return '${user.cidade} - ${user.estado}';
    } else if (user is ProfessionalEntity) {
      return '${user.cidade} - ${user.estado}';
    }
    return 'N/A';
  }

  /// Obtém especialidade do profissional
  String _getUserSpecialty(UserEntity user) {
    if (user is ProfessionalEntity) {
      return user.especialidade.toString().split('.').last;
    }
    return 'N/A';
  }
}
