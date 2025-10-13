/// Entidade de Avaliação
///
/// Representa uma avaliação feita por um paciente sobre um profissional.
class ReviewEntity {
  const ReviewEntity({
    required this.id,
    required this.professionalId,
    required this.patientId,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewEntity.fromJson(Map<String, dynamic> json) {
    return ReviewEntity(
      id: json['id'] as String,
      professionalId: json['professionalId'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  final String id;
  final String professionalId;
  final String patientId;
  final String patientName;
  final int rating; // 1 a 5 estrelas
  final String comment;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'patientId': patientId,
      'patientName': patientName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReviewEntity copyWith({
    String? id,
    String? professionalId,
    String? patientId,
    String? patientName,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
