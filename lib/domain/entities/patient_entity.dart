import 'user_entity.dart';

/// Entidade específica para Pacientes
///
/// Estende UserEntity com campos específicos de pacientes
/// como condições médicas, medicações, tipo sanguíneo e alergias.
class PatientEntity extends UserEntity {
  final String condicoesMedicas;

  const PatientEntity({
    required super.id,
    required super.nome,
    required super.email,
    required super.password,
    required super.telefone,
    required super.dataNascimento,
    required super.endereco,
    required super.cidade,
    required super.estado,
    required super.sexo,
    required super.dataCadastro,
    this.condicoesMedicas = '',
  }) : super(tipo: UserType.paciente);

  @override
  List<Object?> get props => [
        ...super.props,
        condicoesMedicas,
      ];

  /// Serialização para JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'password': password,
      'telefone': telefone,
      'dataNascimento': dataNascimento.toIso8601String(),
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'sexo': sexo,
      'idade': idade,
      'type': UserType.paciente.name,
      'dataCadastro': dataCadastro.toIso8601String(),
      'condicoesMedicas': condicoesMedicas,
    };
  }

  /// Deserialização de JSON (Map)
  factory PatientEntity.fromJson(Map<String, dynamic> json) {
    return PatientEntity(
      id: (json['id'] as String?) ?? '',
      nome: (json['nome'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      password: (json['password'] as String?) ?? '',
      telefone: (json['telefone'] as String?) ?? '',
      dataNascimento: json['dataNascimento'] != null 
          ? DateTime.parse(json['dataNascimento'] as String)
          : DateTime.now(),
      endereco: (json['endereco'] as String?) ?? '',
      cidade: (json['cidade'] as String?) ?? '',
      estado: (json['estado'] as String?) ?? '',
      sexo: (json['sexo'] as String?) ?? '',
      dataCadastro: json['dataCadastro'] != null
          ? DateTime.parse(json['dataCadastro'] as String)
          : DateTime.now(),
      condicoesMedicas: (json['condicoesMedicas'] as String?) ?? '',
    );
  }
}
