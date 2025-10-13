import 'package:app_sanitaria/domain/entities/message_entity.dart';

/// Entidade de Conversa
///
/// Representa uma conversa entre dois usuários
class ConversationEntity {
  ConversationEntity({
    required this.id,
    List<String>? participants,
    List<String>? participantIds,
    String? otherUserId,
    String? otherUserName,
    this.otherUserSpecialty,
    this.lastMessage,
    DateTime? lastMessageTime,
    this.unreadCount = 0,
    DateTime? updatedAt,
  })  : participants = participants ?? participantIds ?? [],
        otherUserId = otherUserId ?? '',
        otherUserName = otherUserName ?? 'Usuário',
        updatedAt = updatedAt ?? lastMessageTime ?? DateTime.now();

  /// Cria conversa a partir de Map
  factory ConversationEntity.fromMap(
    Map<String, dynamic> map,
    String currentUserId,
  ) {
    final participants = List<String>.from((map['participants'] ?? []) as List);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    return ConversationEntity(
      id: (map['id'] ?? '') as String,
      participants: participants,
      otherUserId: otherUserId,
      otherUserName: (map['otherUserName'] ?? 'Usuário') as String,
      otherUserSpecialty: map['otherUserSpecialty'] as String?,
      lastMessage: map['lastMessage'] != null
          ? MessageEntity.fromMap(map['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: (map['unreadCount'] ?? 0) as int,
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }
  final String id;
  final List<String> participants; // [userId1, userId2]
  final String otherUserId;
  final String otherUserName;
  final String? otherUserSpecialty;
  final MessageEntity? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  /// Converte conversa para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserSpecialty': otherUserSpecialty,
      'lastMessage': lastMessage?.toMap(),
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Alias para toMap (compatibilidade com datasources)
  Map<String, dynamic> toJson() => toMap();

  /// Alias para fromMap (compatibilidade com datasources)
  static ConversationEntity fromJson(
          Map<String, dynamic> json, String currentUserId) =>
      ConversationEntity.fromMap(json, currentUserId);

  /// Getter para participantIds (alias de participants)
  List<String> get participantIds => participants;

  /// Getter para patientId (compatibilidade com datasources)
  String get patientId => participants.first;

  /// Getter para professionalId (compatibilidade com datasources)
  String get professionalId => participants.last;

  /// Copia conversa com campos alterados
  ConversationEntity copyWith({
    String? id,
    List<String>? participants,
    String? otherUserId,
    String? otherUserName,
    String? otherUserSpecialty,
    MessageEntity? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserSpecialty: otherUserSpecialty ?? this.otherUserSpecialty,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se a conversa contém um usuário
  bool hasParticipant(String userId) {
    return participants.contains(userId);
  }
}
