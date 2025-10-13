import 'package:app_sanitaria/core/routes/app_router.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tela de Cadastro de Paciente
///
/// Responsabilidades:
/// - Formulário para cadastro de paciente
/// - Validação de campos obrigatórios
/// - Envio de dados para AuthProvider
///
/// Campos:
/// - Dados pessoais: nome, email, senha, telefone, data nascimento, sexo
/// - Endereço: rua, cidade, estado
class PatientRegistrationScreen extends ConsumerStatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  ConsumerState<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends ConsumerState<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  // Dropdowns
  String? _selectedGender;
  String? _selectedState;

  // Password visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  /// Calcula idade com base na data de nascimento
  int _calculateAge(String birthDate) {
    try {
      final parts = birthDate.split('-');
      if (parts.length != 3) return 0;

      final birth = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  /// Realiza cadastro
  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Converter data do formato dd/MM/yyyy para DateTime
    final birthDateParts = _birthDateController.text.split('/');
    final birthDate = DateTime(
      int.parse(birthDateParts[2]), // ano
      int.parse(birthDateParts[1]), // mês
      int.parse(birthDateParts[0]), // dia
    );

    final patient = PatientEntity(
      id: '', // Será gerado no backend
      nome: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      telefone: _phoneController.text.trim(),
      dataNascimento: birthDate,
      endereco: _addressController.text.trim(),
      cidade: _cityController.text.trim(),
      estado: _selectedState!,
      sexo: _selectedGender!,
      dataCadastro: DateTime.now(),
      // idade é calculada automaticamente via getter
    );

    await ref.read(authProviderV2.notifier).registerPatient(patient);
  }

  @override
  Widget build(BuildContext context) {
    // Observar estado de autenticação
    ref.listen<AuthState>(authProviderV2, (previous, next) {
      if (next.isAuthenticated) {
        context.goToHomePatient();
      }

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final authState = ref.watch(authProviderV2);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro Paciente'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                const Text(
                  'Complete seu cadastro',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preencha todos os campos abaixo',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // === DADOS PESSOAIS ===
                _buildSectionTitle('Dados Pessoais'),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    if (value.split(' ').length < 2) {
                      return 'Digite nome e sobrenome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email é obrigatório';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha *',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Senha é obrigatória';
                    }
                    if (value.length < 6) {
                      return 'Senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme sua senha';
                    }
                    if (value != _passwordController.text) {
                      return 'Senhas não conferem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone *',
                    prefixIcon: Icon(Icons.phone),
                    hintText: '(84) 98765-4321',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Telefone é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento *',
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: 'dd/mm/aaaa',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  onChanged: (value) {
                    // Auto-complete "/" após dd e mm
                    if (value.length == 2 || value.length == 5) {
                      if (!value.endsWith('/')) {
                        _birthDateController.text = '$value/';
                        _birthDateController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset: _birthDateController.text.length),
                        );
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Data de nascimento é obrigatória';
                    }
                    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                      return 'Formato inválido (dd/mm/aaaa)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Sexo *',
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'Masculino', child: Text('Masculino')),
                    DropdownMenuItem(
                        value: 'Feminino', child: Text('Feminino')),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) =>
                      value == null ? 'Selecione o sexo' : null,
                ),

                const SizedBox(height: 32),

                // === ENDEREÇO ===
                _buildSectionTitle('Endereço'),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Rua e Número *',
                    prefixIcon: Icon(Icons.home),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Endereço é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'Cidade *',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cidade é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedState,
                  decoration: const InputDecoration(
                    labelText: 'Estado *',
                    prefixIcon: Icon(Icons.map),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'AC', child: Text('AC')),
                    DropdownMenuItem(value: 'AL', child: Text('AL')),
                    DropdownMenuItem(value: 'AP', child: Text('AP')),
                    DropdownMenuItem(value: 'AM', child: Text('AM')),
                    DropdownMenuItem(value: 'BA', child: Text('BA')),
                    DropdownMenuItem(value: 'CE', child: Text('CE')),
                    DropdownMenuItem(value: 'DF', child: Text('DF')),
                    DropdownMenuItem(value: 'ES', child: Text('ES')),
                    DropdownMenuItem(value: 'GO', child: Text('GO')),
                    DropdownMenuItem(value: 'MA', child: Text('MA')),
                    DropdownMenuItem(value: 'MT', child: Text('MT')),
                    DropdownMenuItem(value: 'MS', child: Text('MS')),
                    DropdownMenuItem(value: 'MG', child: Text('MG')),
                    DropdownMenuItem(value: 'PA', child: Text('PA')),
                    DropdownMenuItem(value: 'PB', child: Text('PB')),
                    DropdownMenuItem(value: 'PR', child: Text('PR')),
                    DropdownMenuItem(value: 'PE', child: Text('PE')),
                    DropdownMenuItem(value: 'PI', child: Text('PI')),
                    DropdownMenuItem(value: 'RJ', child: Text('RJ')),
                    DropdownMenuItem(value: 'RN', child: Text('RN')),
                    DropdownMenuItem(value: 'RS', child: Text('RS')),
                    DropdownMenuItem(value: 'RO', child: Text('RO')),
                    DropdownMenuItem(value: 'RR', child: Text('RR')),
                    DropdownMenuItem(value: 'SC', child: Text('SC')),
                    DropdownMenuItem(value: 'SP', child: Text('SP')),
                    DropdownMenuItem(value: 'SE', child: Text('SE')),
                    DropdownMenuItem(value: 'TO', child: Text('TO')),
                  ],
                  onChanged: (value) => setState(() => _selectedState = value),
                  validator: (value) =>
                      value == null ? 'Selecione o estado' : null,
                ),

                const SizedBox(height: 32),

                // Botão de cadastro
                ElevatedButton(
                  onPressed: isLoading ? null : _handleRegistration,
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
                      : const Text('Cadastrar'),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Já tem conta? Fazer login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2196F3),
      ),
    );
  }
}
