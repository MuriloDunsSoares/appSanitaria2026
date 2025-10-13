# 📋 DOCUMENTAÇÃO TÉCNICA - ENTITIES (Domain Layer)

**Camada:** Domain (Clean Architecture)  
**Propósito:** Modelos de dados imutáveis e type-safe  
**Total:** 7 entities  
**Padrão:** Data Transfer Objects (DTOs) com serialização JSON

---

## 🎯 VISÃO GERAL

Entities representam os modelos de dados core da aplicação.
Seguem princípios de Clean Architecture: **independentes de frameworks**.

**Características:**
- Imutáveis (final fields)
- Serialização bidirecional (toMap/fromMap)
- Métodos copyWith() para updates imutáveis
- Type-safe (compilador detecta erros)
- Null-safe (Dart 3.0)

---

## 📁 ENTITIES

### 1. `user_entity.dart` (~40 linhas)

**Propósito:** Define enum UserType (paciente vs profissional)

**Enum UserType:**
```dart
enum UserType {
  paciente,      // Busca profissionais, contrata, avalia
  profissional   // Recebe contratos, responde chats
}
```

**Onde é usado:**
- AuthProvider: Determina home screen após login
- AppRouter: Redirect baseado em userType
- Bottom navigation: Pacientes têm nav bar, profissionais têm FABs

**Não é uma entity completa, apenas um enum helper**

---

### 2. `patient_entity.dart` (~25 linhas)

**Propósito:** Representa dados de um paciente

**Campos principais:**
- id: String (userId único)
- nome: String
- email: String
- telefone: String
- dataNascimento: String (ISO 8601)
- endereco: String
- cidade: String
- estado: String
- sexo: String ('Masculino'/'Feminino')

**Métodos:**
- `fromMap()`: Deserializa JSON do SharedPreferences
- `toMap()`: Serializa para JSON
- `copyWith()`: Update imutável de campos

**Uso típico:**
```dart
final patient = PatientEntity.fromMap(userData);
final updated = patient.copyWith(telefone: '(11) 99999-9999');
```

**Onde é usado:**
- PatientRegistrationScreen: Criar novo paciente
- ProfileScreen: Exibir/editar dados
- LocalStorageDataSource: Persistência

---

### 3. `professional_entity.dart` (~60 linhas)

**Propósito:** Representa dados de um profissional de saúde

**Campos principais:**
- id, nome, email, telefone (mesmos de Patient)
- **especialidade**: String ('Cuidadores', 'Técnicos de enfermagem', etc)
- **formacao**: String (ex: 'Técnico em Enfermagem')
- **certificados**: String (ex: 'COREN ativo')
- **experiencia**: String (ex: '10 anos em home care')
- **avaliacao**: double (média de reviews, 0.0-5.0)
- **numeroAvaliacoes**: int (total de reviews)

**Métodos:**
- fromMap, toMap, copyWith (igual PatientEntity)

**Uso típico:**
```dart
final prof = ProfessionalEntity.fromMap(profData);
final displayRating = prof.avaliacao.toStringAsFixed(1); // "4.8"
```

**Onde é usado:**
- ProfessionalRegistrationScreen: Criar profissional
- ProfessionalCard: Exibir em lista
- ProfessionalProfileDetailScreen: Perfil completo
- ProfessionalsProvider: Filtros e busca

**Diferença de PatientEntity:**
- Tem campos de qualificação profissional
- Tem avaliação (pacientes não têm)

---

### 4. `contract_entity.dart` (~130 linhas)

**Propósito:** Representa contrato entre paciente e profissional

**Campos principais:**
- id: String (contract_timestamp)
- patientId: String
- professionalId: String
- serviceType: String ('Cuidador', 'Técnico enfermagem', etc)
- periodType: String ('hours', 'days', 'weeks')
- periodValue: int (quantidade de horas/dias/semanas)
- startDate: DateTime
- startTime: String ('HH:mm')
- endDate: DateTime?
- address: String (local do serviço)
- observations: String?
- totalValue: double (valor total R$)
- status: String ('pending', 'active', 'completed', 'cancelled')
- createdAt: DateTime
- updatedAt: DateTime

**Métodos especiais:**
- `getContractStatusLabel()`: Traduz status para português
  - 'pending' → 'Pendente'
  - 'active' → 'Ativo'
  - 'completed' → 'Concluído'
  - 'cancelled' → 'Cancelado'

**Uso típico:**
```dart
final contract = ContractEntity.fromJson(contractData);
final statusLabel = getContractStatusLabel(contract.status); // "Ativo"
final isPending = contract.status == 'pending';
```

**Onde é usado:**
- HiringScreen: Criar novo contrato
- ContractsScreen: Listar contratos do usuário
- ContractDetailScreen: Exibir detalhes + ações
- ContractsProvider: CRUD operations

**Lifecycle de um contrato:**
```
pending → active → completed
                ↓ cancelled
```

---

### 5. `message_entity.dart` (~60 linhas)

**Propósito:** Representa uma mensagem de chat individual

**Campos principais:**
- id: String (msg_timestamp)
- conversationId: String (referência à conversa)
- senderId: String (userId de quem enviou)
- receiverId: String (userId de quem recebe)
- text: String (conteúdo da mensagem)
- timestamp: DateTime
- isRead: bool (false até ser visualizada)
- isSentByMe: bool (calculado, não persistido)

**Métodos:**
- fromMap, toMap, copyWith
- `isSentByMe` não é campo, é helper getter

**Uso típico:**
```dart
final message = MessageEntity(
  id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
  conversationId: conversationId,
  senderId: currentUserId,
  receiverId: otherUserId,
  text: textController.text,
  timestamp: DateTime.now(),
  isRead: false,
);

await chatProvider.sendMessage(message);
```

**Onde é usado:**
- IndividualChatScreen: Enviar/receber mensagens
- MessageBubble: Renderizar balão de chat
- ConversationCard: Exibir última mensagem
- ChatProvider: Persistir e carregar mensagens

**Design:**
- Simples e flat (sem nested objects)
- Timestamp para ordenação cronológica
- isRead para notificações não lidas

---

### 6. `conversation_entity.dart` (~95 linhas)

**Propósito:** Representa uma conversa de chat (thread)

**Campos principais:**
- id: String (conversation_userId1_userId2)
- participants: List<String> (2 userIds)
- otherUserId: String (o outro usuário na conversa)
- otherUserName: String (nome para exibição)
- otherUserSpecialty: String? (se profissional)
- lastMessage: MessageEntity? (última msg trocada)
- unreadCount: int (mensagens não lidas)
- updatedAt: DateTime (última atividade)

**Métodos especiais:**
- `hasParticipant(userId)`: Verifica se userId está na conversa
- `fromMap()`: Recebe currentUserId para calcular otherUserId

**Uso típico:**
```dart
final conversation = ConversationEntity.fromMap(data, currentUserId);
final hasUnread = conversation.unreadCount > 0;
final preview = conversation.lastMessage?.text ?? 'Sem mensagens';
```

**Onde é usado:**
- ConversationsScreen: Listar conversas do usuário
- ConversationCard: Renderizar item da lista
- ChatProvider: Criar/atualizar conversas
- IndividualChatScreen: Exibir nome do outro usuário

**Design:**
- participants sempre tem 2 userIds (chat 1-on-1)
- otherUserId calculado para facilitar UI
- lastMessage embedded para preview
- unreadCount para badge de notificação

**ID format:**
```dart
// Sempre ordena IDs alfabeticamente para consistência
final sortedIds = [userId1, userId2]..sort();
final conversationId = 'conversation_${sortedIds[0]}_${sortedIds[1]}';
// Garante que mesma conversa sempre tem mesmo ID
```

---

### 7. `review_entity.dart` (~55 linhas)

**Propósito:** Representa avaliação de um profissional por paciente

**Campos principais:**
- id: String (review_timestamp)
- professionalId: String (quem foi avaliado)
- patientId: String (quem avaliou)
- patientName: String (nome para exibir)
- rating: double (1.0-5.0 estrelas)
- comment: String? (texto opcional)
- createdAt: DateTime

**Métodos:**
- fromMap, toMap, copyWith

**Uso típico:**
```dart
final review = ReviewEntity(
  id: 'review_${DateTime.now().millisecondsSinceEpoch}',
  professionalId: professionalId,
  patientId: currentUserId,
  patientName: currentUserName,
  rating: selectedStars.toDouble(), // 1.0-5.0
  comment: commentController.text,
  createdAt: DateTime.now(),
);

await reviewsProvider.addReview(review);
```

**Onde é usado:**
- AddReviewScreen: Criar nova avaliação
- ProfessionalProfileDetailScreen: Exibir reviews
- ReviewCard: Renderizar review individual
- ReviewsProvider: Calcular média e gerenciar reviews
- RatingsCacheProvider: Cache de ratings por profissional

**Validação:**
- rating deve estar entre 1.0 e 5.0
- patientId não pode avaliar mesmo profissional 2x (lógica no provider)
- comment é opcional (pode ser vazio)

**Cálculo de média:**
```dart
// ReviewsProvider.getAverageRating()
final reviews = await getReviewsForProfessional(professionalId);
if (reviews.isEmpty) return 0.0;
final sum = reviews.fold(0.0, (acc, r) => acc + r.rating);
return sum / reviews.length;
```

---

## 🎯 PADRÕES COMUNS

### 1. Serialização JSON

Todas entities seguem mesmo padrão:

```dart
// Salvar (toMap/toJson)
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'nome': nome,
    'timestamp': timestamp.toIso8601String(),
    // ...
  };
}

// Carregar (fromMap/fromJson)
factory Entity.fromMap(Map<String, dynamic> map) {
  return Entity(
    id: map['id'],
    nome: map['nome'],
    timestamp: DateTime.parse(map['timestamp']),
    // ...
  );
}
```

### 2. Imutabilidade + copyWith

```dart
// Todos os campos são final
final String id;
final String nome;

// Update via copyWith (retorna nova instância)
Entity copyWith({String? id, String? nome}) {
  return Entity(
    id: id ?? this.id,
    nome: nome ?? this.nome,
  );
}
```

### 3. ID Generation

Pattern consistente para IDs únicos:

```dart
// Timestamp-based (garante unicidade)
final id = 'prefix_${DateTime.now().millisecondsSinceEpoch}';

// Exemplos:
// user_1728345678901
// contract_1728345678902
// message_1728345678903
```

---

## 📊 ESTATÍSTICAS

**Total de linhas:** ~400  
**Média por entity:** ~57 linhas  
**Maior:** ContractEntity (130 linhas)  
**Menor:** PatientEntity (25 linhas)

**Distribuição:**
- User: 40 linhas (enum helper)
- Patient: 25 linhas (dados básicos)
- Professional: 60 linhas (+ qualificações)
- Contract: 130 linhas (mais complexo)
- Message: 60 linhas (chat)
- Conversation: 95 linhas (thread)
- Review: 55 linhas (avaliação)

---

## 🔄 INTERAÇÕES ENTRE ENTITIES

```
User (enum)
  └─ usado por Patient e Professional

Patient
  ├─ cria Contract
  ├─ envia Message
  └─ escreve Review

Professional
  ├─ recebe Contract
  ├─ responde Message
  └─ recebe Review

Contract
  ├─ referencia Patient (patientId)
  └─ referencia Professional (professionalId)

Conversation
  ├─ contém múltiplos Message
  └─ entre Patient e Professional

Message
  └─ pertence a Conversation

Review
  ├─ referencia Professional (professionalId)
  └─ referencia Patient (patientId)
```

---

## ✅ BOAS PRÁTICAS SEGUIDAS

1. ✅ **Imutabilidade:** Todos os campos são `final`
2. ✅ **Serialização:** toMap/fromMap consistentes
3. ✅ **Null Safety:** Uso correto de `?` e `!`
4. ✅ **Type Safety:** Enums ao invés de strings magic
5. ✅ **Clean Architecture:** Sem dependência de Flutter/packages
6. ✅ **Naming:** Nomes claros e descritivos (PascalCase)
7. ✅ **DateTime:** ISO 8601 para timestamps
8. ✅ **IDs:** Formato consistente prefix_timestamp

---

## 🚀 MELHORIAS FUTURAS

- [ ] Usar Freezed package (gera copyWith/toJson automaticamente)
- [ ] Adicionar validação inline (ex: rating entre 1-5)
- [ ] Usar DateTime ao invés de String para dates
- [ ] Adicionar métodos de negócio (ex: Contract.isExpired())
- [ ] Criar abstract base Entity com id/createdAt/updatedAt
- [ ] Adicionar equals/hashCode para comparação
