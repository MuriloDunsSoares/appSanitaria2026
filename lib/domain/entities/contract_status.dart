/// Enum para status de contrato
///
/// Define os estados possíveis de um contrato de serviço.
enum ContractStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ContractStatus.pending:
        return 'Aguardando Confirmação';
      case ContractStatus.confirmed:
        return 'Confirmado';
      case ContractStatus.active:
        return 'Em Andamento';
      case ContractStatus.completed:
        return 'Finalizado';
      case ContractStatus.cancelled:
        return 'Cancelado';
    }
  }

  static ContractStatus fromString(String value) {
    return ContractStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContractStatus.pending,
    );
  }
}
