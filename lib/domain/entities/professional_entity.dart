import 'user_entity.dart';
import 'speciality.dart';

/// Entidade específica para Profissionais de Saúde
///
/// Estende UserEntity com campos específicos de profissionais como
/// especialidade, formação, certificados, experiência e avaliação.
class ProfessionalEntity extends UserEntity {
  final Speciality especialidade;
  final String formacao;
  final String certificados;
  final int experiencia; // Anos de experiência
  final String biografia; // Descrição do profissional
  final double avaliacao;
  final double hourlyRate;
  final double? averageRating;

  // Getters para compatibilidade
  String get name => nome;
  Speciality get speciality => especialidade;
  String get city => cidade;

  const ProfessionalEntity({
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
    required this.especialidade,
    required this.formacao,
    required this.certificados,
    required this.experiencia,
    this.biografia = '',
    required this.avaliacao,
    this.hourlyRate = 0.0,
    this.averageRating,
  }) : super(tipo: UserType.profissional);

  @override
  List<Object?> get props => [
        ...super.props,
        especialidade,
        formacao,
        certificados,
        experiencia,
        biografia,
        avaliacao,
        hourlyRate,
        averageRating,
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
      'type': UserType.profissional.name,
      'dataCadastro': dataCadastro.toIso8601String(),
      'especialidade': especialidade.name,
      'formacao': formacao,
      'certificados': certificados,
      'experiencia': experiencia,
      'biografia': biografia,
      'avaliacao': avaliacao,
      'hourlyRate': hourlyRate,
      'averageRating': averageRating,
    };
  }

  /// Deserialização de JSON (Map)
  factory ProfessionalEntity.fromJson(Map<String, dynamic> json) {
    return ProfessionalEntity(
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
      especialidade: json['especialidade'] != null
          ? Speciality.values.firstWhere(
              (e) => e.name == json['especialidade'],
              orElse: () => Speciality.cuidadores,
            )
          : Speciality.cuidadores,
      formacao: (json['formacao'] as String?) ?? '',
      certificados: (json['certificados'] as String?) ?? '',
      experiencia: json['experiencia'] is int 
          ? json['experiencia'] as int 
          : int.tryParse(json['experiencia']?.toString() ?? '0') ?? 0,
      biografia: (json['biografia'] as String?) ?? '',
      avaliacao: (json['avaliacao'] as num?)?.toDouble() ?? 0.0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
    );
  }
}
