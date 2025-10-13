import 'package:equatable/equatable.dart';

/// Entidade base para todos os usuários do sistema
///
/// Representa um usuário genérico que pode ser tanto um profissional
/// quanto um paciente. Esta é a entidade do domínio (regras de negócio puras).
abstract class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.nome,
    required this.email,
    required this.password,
    required this.telefone,
    required this.dataNascimento,
    required this.endereco,
    required this.cidade,
    required this.estado,
    required this.sexo,
    required this.tipo,
    required this.dataCadastro,
  });
  final String id;
  final String nome;
  final String email;
  final String password;
  final String telefone;
  final DateTime dataNascimento;
  final String endereco;
  final String cidade;
  final String estado;
  final String sexo;
  final UserType tipo;
  final DateTime dataCadastro;

  /// Calcula idade a partir da data de nascimento
  int get idade {
    final now = DateTime.now();
    int age = now.year - dataNascimento.year;
    if (now.month < dataNascimento.month ||
        (now.month == dataNascimento.month && now.day < dataNascimento.day)) {
      age--;
    }
    return age;
  }

  /// Getter para compatibilidade com código que usa `user.type`
  UserType get type => tipo;

  @override
  List<Object?> get props => [
        id,
        nome,
        email,
        password,
        telefone,
        dataNascimento,
        endereco,
        cidade,
        estado,
        sexo,
        idade,
        tipo,
        dataCadastro,
      ];
}

/// Enum para tipos de usuário
enum UserType {
  profissional,
  paciente;

  String get displayName {
    switch (this) {
      case UserType.profissional:
        return 'Profissional';
      case UserType.paciente:
        return 'Paciente';
    }
  }
}
