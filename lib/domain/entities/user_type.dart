/// Enum para tipos de usuário
enum UserType {
  patient('paciente'),
  professional('profissional');

  final String name;
  const UserType(this.name);

  static UserType fromString(String type) {
    return UserType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => UserType.patient,
    );
  }
}

