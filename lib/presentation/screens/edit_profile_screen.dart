import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/speciality.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela de Edição de Perfil
///
/// Responsabilidades:
/// - Permitir edição de dados pessoais do usuário
/// - Validar dados inseridos
/// - Salvar alterações via Use Cases
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas edição de perfil
/// - Separation of Concerns: UI separada da lógica de negócio
/// - Clean Architecture: Usa Use Cases para operações
/// - SOLID: Dependency Injection via Provider
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;
  late TextEditingController _especialidadeController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _especialidadeController.dispose();
    super.dispose();
  }

  /// Inicializa os controllers com dados atuais do usuário
  void _initializeControllers() {
    final authState = ref.read(authProviderV2);
    final user = authState.user;

    if (user != null) {
      _nomeController = TextEditingController(text: user.nome);
      _emailController = TextEditingController(text: user.email);
      _telefoneController = TextEditingController(text: user.telefone);

      if (user is PatientEntity) {
        _cidadeController = TextEditingController(text: user.cidade);
        _estadoController = TextEditingController(text: user.estado);
        _especialidadeController = TextEditingController();
      } else if (user is ProfessionalEntity) {
        _cidadeController = TextEditingController(text: user.cidade);
        _estadoController = TextEditingController(text: user.estado);
        _especialidadeController = TextEditingController(
            text: user.especialidade.toString().split('.').last);
      }
    } else {
      // Fallback para caso de erro
      _nomeController = TextEditingController();
      _emailController = TextEditingController();
      _telefoneController = TextEditingController();
      _cidadeController = TextEditingController();
      _estadoController = TextEditingController();
      _especialidadeController = TextEditingController();
    }
  }

  /// Valida e salva o perfil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = ref.read(authProviderV2);
      final user = authState.user;
      final userType = authState.userType;

      if (user == null) {
        setState(() => _errorMessage = 'Usuário não encontrado');
        return;
      }

      UserEntity updatedUser;

      if (userType == UserType.paciente) {
        // Para pacientes, precisamos dos dados obrigatórios
        // Como estamos editando um usuário existente, vamos buscar dados adicionais se necessário
        final patient = user as PatientEntity;
        updatedUser = PatientEntity(
          id: user.id,
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          password: patient.password, // Mantém a senha existente
          telefone: _telefoneController.text.trim(),
          dataNascimento: patient.dataNascimento, // Mantém dados existentes
          endereco: patient.endereco,
          cidade: _cidadeController.text.trim(),
          estado: _estadoController.text.trim(),
          sexo: patient.sexo,
          dataCadastro: patient.dataCadastro,
          condicoesMedicas: patient.condicoesMedicas,
        );
      } else {
        // Para profissionais, precisamos dos dados obrigatórios
        final professional = user as ProfessionalEntity;
        updatedUser = ProfessionalEntity(
          id: user.id,
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          password: professional.password, // Mantém a senha existente
          telefone: _telefoneController.text.trim(),
          dataNascimento:
              professional.dataNascimento, // Mantém dados existentes
          endereco: professional.endereco,
          cidade: _cidadeController.text.trim(),
          estado: _estadoController.text.trim(),
          sexo: professional.sexo,
          dataCadastro: professional.dataCadastro,
          especialidade:
              _parseEspecialidade(_especialidadeController.text.trim()) ??
                  Speciality.cuidadores,
          formacao: professional.formacao,
          certificados: professional.certificados,
          experiencia: professional.experiencia,
          avaliacao: professional.avaliacao,
          hourlyRate: professional.hourlyRate,
          averageRating: professional.averageRating,
          biografia: professional.biografia,
        );
      }

      // Usa o provider de atualização de perfil
      final result = await ref.read(profileUpdateProvider(updatedUser).future);

      if (result == true) {
        // Atualiza o provider de auth com os novos dados
        ref.read(authProviderV2.notifier).updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
          );
          context.pop();
        }
      } else {
        setState(() => _errorMessage = 'Erro ao salvar perfil');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erro ao salvar perfil: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Valida e converte especialidade para enum
  Speciality? _parseEspecialidade(String especialidade) {
    return Speciality.fromString(especialidade.trim());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProviderV2);
    final userType = authState.userType;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Voltar para a tela de Perfil ao clicar no botão voltar
          context.go('/profile');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mensagem de erro
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),

                // Campo Nome
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email é obrigatório';
                    }
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo Telefone
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Telefone é obrigatório';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo Cidade
                TextFormField(
                  controller: _cidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Cidade',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Cidade é obrigatória';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Campo Estado
                TextFormField(
                  controller: _estadoController,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    prefixIcon: Icon(Icons.map),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Estado é obrigatório';
                    }
                    return null;
                  },
                ),

                // Campo Especialidade (apenas para profissionais)
                if (userType == UserType.profissional) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _especialidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Especialidade',
                      prefixIcon: Icon(Icons.work),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Especialidade é obrigatória';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 32),

                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Salvar Alterações'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
