/// Entidade de Mensagem
///
/// Representa uma mensagem individual em uma conversa
class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String text;
  final String content; // Alias para text (compatibilidade)
  final DateTime timestamp;
  final bool isRead;

  MessageEntity({
    required this.id,
    String? conversationId,
    required this.senderId,
    String? senderName,
    required this.receiverId,
    String? text,
    String? content,
    required this.timestamp,
    this.isRead = false,
  })  : conversationId = conversationId ?? '',
        senderName = senderName ?? '',
        text = text ?? content ?? '',
        content = content ?? text ?? '';

  /// Cria mensagem a partir de Map
  factory MessageEntity.fromMap(Map<String, dynamic> map) {
    return MessageEntity(
      id: (map['id'] ?? '') as String,
      conversationId: (map['conversationId'] ?? '') as String,
      senderId: (map['senderId'] ?? '') as String,
      senderName: (map['senderName'] ?? '') as String,
      receiverId: (map['receiverId'] ?? '') as String,
      text: (map['text'] ?? '') as String,
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      isRead: (map['isRead'] ?? false) as bool,
    );
  }

  /// Converte mensagem para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  /// Copia mensagem com campos alterados
  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
