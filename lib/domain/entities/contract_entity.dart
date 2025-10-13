import 'contract_status.dart';

/// Entidade de Contrato
///
/// Representa um contrato de serviço entre paciente e profissional.
/// Inclui todas as informações necessárias para gerenciar a contratação.
class ContractEntity {
  const ContractEntity({
    required this.id,
    required this.patientId,
    required this.professionalId,
    String? patientName,
    String? professionalName,
    String? serviceType,
    String? service,
    required this.period,
    required this.duration,
    required this.date,
    required this.time,
    required this.address,
    this.observations,
    this.status = ContractStatus.pending,
    double? totalValue,
    double? price,
    required this.createdAt,
    this.updatedAt,
  })  : patientName = patientName ?? '',
        professionalName = professionalName ?? '',
        serviceType = serviceType ?? service ?? '',
        totalValue = totalValue ?? price ?? 0.0;

  factory ContractEntity.fromJson(Map<String, dynamic> json) {
    return ContractEntity(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      professionalId: json['professionalId'] as String,
      patientName: json['patientName'] as String,
      professionalName: json['professionalName'] as String,
      serviceType: json['serviceType'] as String,
      period: json['period'] as String,
      duration: json['duration'] as int,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      address: json['address'] as String,
      observations: json['observations'] as String?,
      status: ContractStatus.fromString(json['status'] as String? ?? 'pending'),
      totalValue: (json['totalValue'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
  final String id;
  final String patientId;
  final String professionalId;
  final String patientName;
  final String professionalName;
  final String serviceType;
  final String period; // 'Diário', 'Semanal', 'Mensal'
  final int duration; // em horas
  final DateTime date;
  final String time; // formato "HH:mm"
  final String address;
  final String? observations;
  final ContractStatus status;
  final double totalValue;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Getter alias para service (compatibilidade)
  String get service => serviceType;

  /// Getter alias para price (compatibilidade)
  double get price => totalValue;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'professionalId': professionalId,
      'patientName': patientName,
      'professionalName': professionalName,
      'serviceType': serviceType,
      'period': period,
      'duration': duration,
      'date': date.toIso8601String(),
      'time': time,
      'address': address,
      'observations': observations,
      'status': status.name,
      'totalValue': totalValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ContractEntity copyWith({
    String? id,
    String? patientId,
    String? professionalId,
    String? patientName,
    String? professionalName,
    String? serviceType,
    String? period,
    int? duration,
    DateTime? date,
    String? time,
    String? address,
    String? observations,
    ContractStatus? status,
    double? totalValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContractEntity(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      professionalId: professionalId ?? this.professionalId,
      patientName: patientName ?? this.patientName,
      professionalName: professionalName ?? this.professionalName,
      serviceType: serviceType ?? this.serviceType,
      period: period ?? this.period,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      time: time ?? this.time,
      address: address ?? this.address,
      observations: observations ?? this.observations,
      status: status ?? this.status,
      totalValue: totalValue ?? this.totalValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Helper para obter label do status (mantido por compatibilidade)
String getContractStatusLabel(String status) {
  return ContractStatus.fromString(status).displayName;
}
