# 📋 ESPECIFICAÇÕES DAS ENTIDADES - GUIA PARA TESTES

## ⚠️ IMPORTANTE: Este documento define as REGRAS DE NEGÓCIO para criação de testes corretos

---

## 1️⃣ **UserEntity** (Abstrata - Base para Patient e Professional)

### Campos OBRIGATÓRIOS:
- `id`: String (UUID gerado pelo sistema)
- `nome`: String (nome completo, mín. 3 caracteres)
- `email`: String (formato válido: user@domain.com)
- `password`: String (mín. 6 caracteres)
- `telefone`: String (formato: (XX) XXXXX-XXXX)
- `dataNascimento`: DateTime (pessoa deve ter 18+ anos)
- `endereco`: String (endereço completo)
- `cidade`: String (nome da cidade)
- `estado`: String (sigla UF: SP, RJ, etc)
- `sexo`: String ('Masculino', 'Feminino', 'Outro')
- `tipo`: UserType enum (profissional ou paciente)
- `dataCadastro`: DateTime (data de registro no sistema)

### Campos CALCULADOS (getters):
- `idade`: int - calculado a partir de `dataNascimento`
- `type`: UserType - alias para `tipo`

### Regras de Negócio:
1. Email deve ser único no sistema
2. Idade mínima: 18 anos
3. `idade` NÃO deve ser passado no construtor (é getter)

---

## 2️⃣ **PatientEntity** (extends UserEntity)

### Campos ADICIONAIS:
- `condicoesMedicas`: String (default: '', opcional)

### Exemplo REALISTA para testes:
```dart
PatientEntity(
  id: 'patient123',
  nome: 'Maria Silva',
  email: 'maria.silva@email.com',
  password: 'senha123',
  telefone: '(11) 98765-4321',
  dataNascimento: DateTime(1990, 5, 15), // 34 anos
  endereco: 'Rua das Flores, 123',
  cidade: 'São Paulo',
  estado: 'SP',
  sexo: 'Feminino',
  dataCadastro: DateTime(2025, 1, 1),
  condicoesMedicas: 'Hipertensão controlada',
)
```

---

## 3️⃣ **ProfessionalEntity** (extends UserEntity)

### Campos ADICIONAIS OBRIGATÓRIOS:
- `especialidade`: Speciality enum (cuidadores, tecnicosEnfermagem, etc)
- `formacao`: String (ex: "Técnico em Enfermagem - SENAC")
- `certificados`: String (ex: "COREN 123456-SP")
- `experiencia`: int (anos de experiência, ex: 5)
- `avaliacao`: double (0.0 a 5.0)

### Campos OPCIONAIS:
- `biografia`: String (default: '')
- `hourlyRate`: double (default: 0.0)
- `averageRating`: double? (null se sem avaliações)

### Exemplo REALISTA para testes:
```dart
ProfessionalEntity(
  id: 'prof123',
  nome: 'João Santos',
  email: 'joao.santos@email.com',
  password: 'senha123',
  telefone: '(11) 91234-5678',
  dataNascimento: DateTime(1985, 3, 20), // 39 anos
  endereco: 'Av. Paulista, 1000',
  cidade: 'São Paulo',
  estado: 'SP',
  sexo: 'Masculino',
  dataCadastro: DateTime(2024, 6, 1),
  especialidade: Speciality.tecnicosEnfermagem,
  formacao: 'Técnico em Enfermagem - SENAC 2010',
  certificados: 'COREN 123456-SP',
  experiencia: 10,
  biografia: 'Técnico em enfermagem com 10 anos de experiência...',
  avaliacao: 4.8,
  hourlyRate: 75.0,
  averageRating: 4.8,
)
```

---

## 4️⃣ **MessageEntity**

### Campos OBRIGATÓRIOS:
- `id`: String
- `senderId`: String
- `receiverId`: String
- `timestamp`: DateTime

### Campos OPCIONAIS (com defaults):
- `conversationId`: String (default: '')
- `senderName`: String (default: '')
- `text`: String (default: '' ou usar `content`)
- `content`: String (alias de `text`)
- `isRead`: bool (default: false)

### Regras:
- `text` e `content` são aliases (pode passar qualquer um)
- Sempre passar pelo menos um deles

### Exemplo REALISTA:
```dart
MessageEntity(
  id: 'msg123',
  conversationId: 'conv456',
  senderId: 'user1',
  senderName: 'Maria Silva',
  receiverId: 'user2',
  content: 'Olá, gostaria de contratar seus serviços!',
  timestamp: DateTime(2025, 10, 9, 14, 30),
  isRead: false,
)
```

---

## 5️⃣ **ConversationEntity**

### Campos OBRIGATÓRIOS:
- `id`: String

### Campos OPCIONAIS (com defaults):
- `participants`: List<String> (ou `participantIds`)
- `otherUserId`: String (default: '')
- `otherUserName`: String (default: 'Usuário')
- `otherUserSpecialty`: String? (null para pacientes)
- `lastMessage`: MessageEntity? (null se sem mensagens)
- `lastMessageTime`: DateTime? (alias para `updatedAt`)
- `unreadCount`: int (default: 0)
- `updatedAt`: DateTime (default: DateTime.now())

### Exemplo REALISTA:
```dart
ConversationEntity(
  id: 'conv123',
  participants: ['patient1', 'prof2'],
  otherUserId: 'prof2',
  otherUserName: 'João Santos',
  otherUserSpecialty: 'Técnicos de enfermagem',
  lastMessage: MessageEntity(...),
  lastMessageTime: DateTime(2025, 10, 9, 14, 30),
  unreadCount: 3,
)
```

---

## 6️⃣ **ContractEntity**

### Campos OBRIGATÓRIOS:
- `id`: String
- `patientId`: String
- `professionalId`: String
- `period`: String ('Diário', 'Semanal', 'Mensal')
- `duration`: int (horas)
- `date`: DateTime
- `time`: String (formato "HH:mm")
- `address`: String
- `createdAt`: DateTime

### Campos OPCIONAIS (com defaults):
- `patientName`: String (default: '')
- `professionalName`: String (default: '')
- `serviceType`: String (ou `service`, default: '')
- `observations`: String? (null se sem observações)
- `status`: ContractStatus (default: pending)
- `totalValue`: double (ou `price`, default: 0.0)
- `updatedAt`: DateTime? (null se nunca atualizado)

### Exemplo REALISTA:
```dart
ContractEntity(
  id: 'contract123',
  patientId: 'patient1',
  professionalId: 'prof2',
  patientName: 'Maria Silva',
  professionalName: 'João Santos',
  serviceType: 'Cuidados domiciliares',
  period: 'Semanal',
  duration: 40,
  date: DateTime(2025, 10, 15),
  time: '08:00',
  address: 'Rua das Flores, 123 - São Paulo/SP',
  observations: 'Paciente com mobilidade reduzida',
  status: ContractStatus.confirmed,
  totalValue: 3000.0,
  createdAt: DateTime(2025, 10, 9),
)
```

---

## 7️⃣ **ReviewEntity**

### Campos OBRIGATÓRIOS:
- `id`: String
- `professionalId`: String
- `patientId`: String
- `patientName`: String
- `rating`: int (1 a 5)
- `comment`: String
- `createdAt`: DateTime

### Regras:
- `rating` deve ser entre 1 e 5
- `comment` não pode ser vazio

### Exemplo REALISTA:
```dart
ReviewEntity(
  id: 'review123',
  professionalId: 'prof2',
  patientId: 'patient1',
  patientName: 'Maria Silva',
  rating: 5,
  comment: 'Excelente profissional! Muito atencioso e competente.',
  createdAt: DateTime(2025, 10, 9),
)
```

---

## 🎯 **REGRAS PARA TESTES:**

### ✅ FAZER:
1. Usar dados REALISTAS (nomes reais, datas válidas, etc)
2. Passar TODOS os campos obrigatórios
3. Respeitar valores default dos campos opcionais
4. Testar casos de borda com dados VÁLIDOS

### ❌ NÃO FAZER:
1. Omitir campos obrigatórios esperando que "passe mesmo assim"
2. Usar valores genéricos tipo 'test', 'abc', '123'
3. Passar `idade` no construtor de User/Patient/Professional
4. Ignorar regras de negócio (ex: rating fora de 1-5)

---

## 📊 **TIPOS DO EITHER:**

### CORRETO:
```dart
expect(result, isA<Right<Failure, List<MessageEntity>>>());
```

### INCORRETO:
```dart
expect(result, isA<Right<dynamic, List<MessageEntity>>>());
```

**Motivo:** `Either<L, R>` onde L é sempre `Failure`, não `dynamic`!

---

Esse documento deve ser CONSULTADO antes de criar QUALQUER teste!

