/// Enum para especialidades de profissionais
///
/// Define as especialidades suportadas pelo sistema.
/// Facilita validação e evita strings mágicas.
enum Speciality {
  cuidadores('Cuidadores'),
  tecnicosEnfermagem('Técnicos de enfermagem'),
  enfermeiros('Enfermeiros'),
  acompanhantesHospital('Acompanhantes hospital'),
  acompanhanteDomiciliar('Acompanhante Domiciliar');

  final String displayName;

  const Speciality(this.displayName);

  /// Converte string para enum (case-insensitive)
  static Speciality? fromString(String value) {
    final normalized = value.toLowerCase().trim();

    for (final specialty in Speciality.values) {
      if (specialty.displayName.toLowerCase() == normalized) {
        return specialty;
      }
    }

    return null;
  }
}
