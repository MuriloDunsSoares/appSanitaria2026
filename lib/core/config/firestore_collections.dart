/// Constantes para nomes das coleções e campos do Firestore
/// 
/// Essa classe centraliza todos os nomes de coleções e campos
/// para evitar typos e facilitar manutenção.
/// 
/// CONSULTORIA: Arquitetura multi-tenant
/// - organizations/{orgId}/ - Root collection (isolation)
/// - userProfiles/ - Global collection (auth lookup)
/// - auditLogs/ - Global collection (compliance LGPD)
class FirestoreCollections {
  // ==================== COLEÇÕES MULTI-TENANT ====================
  
  /// Coleção root de organizações (multi-tenant)
  static const String organizations = 'organizations';
  
  /// Coleção de usuários (dentro de organizations)
  /// Path: organizations/{orgId}/users
  static const String users = 'users';
  
  /// Coleção de profissionais (dentro de organizations)
  /// Path: organizations/{orgId}/professionals
  static const String professionals = 'professionals';
  
  /// Coleção de conversas de chat
  static const String conversations = 'conversations';
  
  /// Coleção de mensagens (subcoleção de conversations)
  static const String messages = 'messages';
  
  /// Coleção de contratos
  static const String contracts = 'contracts';
  
  /// Coleção de avaliações
  static const String reviews = 'reviews';
  
  /// Coleção de favoritos
  static const String favorites = 'favorites';
  
  // ==================== CAMPOS COMUNS ====================
  
  /// Campo: ID do documento
  static const String id = 'id';
  
  /// Campo: Timestamp de criação
  static const String createdAt = 'createdAt';
  
  /// Campo: Timestamp de atualização
  static const String updatedAt = 'updatedAt';
  
  // ==================== CAMPOS DE USERS ====================
  
  /// Campo: Email do usuário
  static const String email = 'email';
  
  /// Campo: Nome do usuário
  static const String nome = 'nome';
  
  /// Campo: Tipo do usuário (paciente/profissional)
  static const String tipo = 'tipo';
  
  /// Campo: Telefone
  static const String telefone = 'telefone';
  
  /// Campo: CPF
  static const String cpf = 'cpf';
  
  /// Campo: Data de nascimento
  static const String dataNascimento = 'dataNascimento';
  
  /// Campo: Cidade
  static const String cidade = 'cidade';
  
  /// Campo: Estado
  static const String estado = 'estado';
  
  /// Campo: Especialidade (profissional)
  static const String especialidade = 'especialidade';
  
  /// Campo: Certificados (profissional)
  static const String certificados = 'certificados';
  
  /// Campo: Formação (profissional)
  static const String formacao = 'formacao';
  
  /// Campo: Avaliação média (profissional)
  static const String avaliacao = 'avaliacao';
  
  /// Campo: URL da foto de perfil
  static const String photoUrl = 'photoUrl';
  
  /// Campo: Token FCM para notificações push
  static const String fcmToken = 'fcmToken';
  
  // ==================== CAMPOS DE CONVERSATIONS ====================
  
  /// Campo: IDs dos participantes
  static const String participants = 'participants';
  
  /// Campo: Última mensagem
  static const String lastMessage = 'lastMessage';
  
  /// Campo: Mensagens não lidas por usuário
  static const String unreadCount = 'unreadCount';
  
  // ==================== CAMPOS DE MESSAGES ====================
  
  /// Campo: ID da conversa
  static const String conversationId = 'conversationId';
  
  /// Campo: ID do remetente
  static const String senderId = 'senderId';
  
  /// Campo: Nome do remetente
  static const String senderName = 'senderName';
  
  /// Campo: ID do destinatário
  static const String receiverId = 'receiverId';
  
  /// Campo: Texto da mensagem
  static const String text = 'text';
  
  /// Campo: Timestamp da mensagem
  static const String timestamp = 'timestamp';
  
  /// Campo: Se a mensagem foi lida
  static const String isRead = 'isRead';
  
  // ==================== CAMPOS DE CONTRACTS ====================
  
  /// Campo: ID do paciente
  static const String patientId = 'patientId';
  
  /// Campo: Nome do paciente
  static const String patientName = 'patientName';
  
  /// Campo: ID do profissional
  static const String professionalId = 'professionalId';
  
  /// Campo: Nome do profissional
  static const String professionalName = 'professionalName';
  
  /// Campo: Serviço contratado
  static const String service = 'service';
  
  /// Campo: Data de início
  static const String startDate = 'startDate';
  
  /// Campo: Data de fim
  static const String endDate = 'endDate';
  
  /// Campo: Horário
  static const String time = 'time';
  
  /// Campo: Endereço
  static const String address = 'address';
  
  /// Campo: Observações
  static const String observations = 'observations';
  
  /// Campo: Valor total
  static const String totalValue = 'totalValue';
  
  /// Campo: Status do contrato
  static const String status = 'status';
  
  // ==================== CAMPOS DE REVIEWS ====================
  
  /// Campo: ID do autor da avaliação
  static const String authorId = 'authorId';
  
  /// Campo: Nome do autor da avaliação
  static const String authorName = 'authorName';
  
  /// Campo: Nota (1-5)
  static const String rating = 'rating';
  
  /// Campo: Comentário
  static const String comment = 'comment';
  
  // ==================== CAMPOS DE FAVORITES ====================
  
  /// Campo: ID do usuário
  static const String userId = 'userId';
  
  /// Campo: Lista de IDs de profissionais favoritos
  static const String professionalIds = 'professionalIds';
  
  // ==================== COLEÇÕES GLOBAIS ====================
  
  /// Coleção global de perfis de usuário (auth lookup)
  /// Path: userProfiles/{userId}
  /// 
  /// CONSULTORIA: Usado para lookup rápido após autenticação
  /// - email (indexed)
  /// - organizationId (link para tenant)
  /// - role, status
  static const String userProfiles = 'userProfiles';
  
  /// Coleção global de audit logs (compliance LGPD)
  /// Path: auditLogs/{logId}
  /// 
  /// CONSULTORIA: Trilha de auditoria completa
  /// - action, userId, organizationId
  /// - timestamp, ipAddress
  /// - Retenção: 5 anos
  static const String auditLogs = 'auditLogs';
  
  // ==================== CAMPOS MULTI-TENANT ====================
  
  /// Campo: ID da organização (presente em todos os docs multi-tenant)
  static const String organizationId = 'organizationId';
  
  /// Campo: Role do usuário (admin, supervisor, tech, client)
  static const String role = 'role';
  
  /// Campo: Status do registro (active, suspended, deleted)
  static const String statusField = 'status';
  
  /// Campo: Timestamp de deleção (soft delete)
  static const String deletedAt = 'deletedAt';
  
  /// Campo: Quem deletou (soft delete)
  static const String deletedBy = 'deletedBy';
}

