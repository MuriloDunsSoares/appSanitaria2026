# 🗄️ FIREBASE - ESTRUTURA DE BANCO DE DADOS

**Parte da:** [Consultoria Firebase](FIREBASE_ARCHITECTURE_GUIDE.md)  
**Foco:** Modelagem de dados para grande escala

---

## 📋 ÍNDICE

1. [Firestore vs Realtime Database](#firestore-vs-realtime-database)
2. [Estrutura Multi-Tenant](#estrutura-multi-tenant)
3. [Modelagem de Coleções](#modelagem-de-coleções)
4. [Estratégias de Denormalização](#estratégias-de-denormalização)
5. [Relacionamentos e Referências](#relacionamentos-e-referências)
6. [Sharding e Particionamento](#sharding-e-particionamento)
7. [Indexação](#indexação)
8. [Exemplos Práticos Flutter](#exemplos-práticos-flutter)

---

## 1. FIRESTORE VS REALTIME DATABASE

### **Comparação Detalhada**

| Aspecto | **Firestore ✅** | Realtime Database |
|---------|-----------------|-------------------|
| **Modelo de dados** | Coleções/Documentos | JSON Tree |
| **Escalabilidade** | Automática, ilimitada | Manual, até 200k conexões |
| **Queries** | Compostas, indexadas | Limitadas, deep queries |
| **Offline** | Sincronização automática | Manual sync |
| **Preço** | $0.06/100k reads | $1/GB downloaded |
| **Latência** | ~50-100ms | ~20-50ms |
| **Multi-region** | Sim (replicação global) | Limitado |
| **Transações** | Até 500 docs | Ilimitado (mesmo nó) |
| **Ordenação** | Múltiplos campos | Um campo apenas |
| **Limites** | 1MB por doc | 32MB por nó |

### **DECISÃO: Firestore**

**Justificativas:**

#### ✅ **Escalabilidade**
```
Realtime DB: 200,000 conexões simultâneas (teto fixo)
Firestore:   ILIMITADO (sharding automático)

Para milhões de usuários → Firestore é OBRIGATÓRIO
```

#### ✅ **Queries Complexas**
```dart
// Firestore: Query composta (POSSÍVEL)
db.collection('professionals')
  .where('organizationId', isEqualTo: orgId)
  .where('specialty', isEqualTo: 'cuidadores')
  .where('rating', isGreaterThan: 4.5)
  .orderBy('rating', descending: true)
  .limit(20);

// Realtime DB: Requer múltiplas queries e merge no client (LENTO)
```

#### ✅ **Custos Previsíveis**
```
Realtime DB: Cobra por BANDWIDTH (GB transferido)
  - 1M usuários baixando 50KB = 50TB = $5,000/mês 😱

Firestore: Cobra por OPERAÇÃO (reads/writes)
  - 10M reads/dia = $180/mês ✅
```

#### ⚠️ **Trade-off: Latência**
```
Realtime DB: ~20ms (mais rápido)
Firestore:   ~50ms (aceitável para maioria)

Para chat em tempo real: Considerar híbrido
  - Firestore: dados principais
  - Realtime DB: mensagens ao vivo (opcional)
```

---

## 2. ESTRUTURA MULTI-TENANT

### **Opções de Arquitetura**

#### **Opção A: Banco por Tenant (NÃO RECOMENDADO)**
```
firestore-org1/
firestore-org2/
firestore-org3/
```

**Problemas:**
- ❌ Limite de 10 databases por projeto Firebase
- ❌ Complexidade de gerenciamento
- ❌ Custos de infraestrutura
- ❌ Difícil fazer queries cross-tenant (analytics)

---

#### **Opção B: Collection por Tenant (NÃO RECOMENDADO)**
```
users-org1/
users-org2/
contracts-org1/
contracts-org2/
```

**Problemas:**
- ❌ Explosão de coleções (1000 orgs = 5000 collections)
- ❌ Security Rules ficam gigantescas
- ❌ Difícil adicionar novas entidades

---

#### **Opção C: Documento Root por Tenant ✅ RECOMENDADO**

```
organizations/{orgId}/
  └─ subcollections...
```

**Vantagens:**
- ✅ Isolamento completo (RLS simples)
- ✅ Escalável (ilimitadas orgs)
- ✅ Security Rules elegantes
- ✅ Backups por org
- ✅ Compliance LGPD (dados segregados)
- ✅ Queries rápidas (index por org)

---

### **Estrutura Completa Multi-Tenant**

```
firestore/
│
├─ organizations/               # Root collection
│   ├─ {orgId}/                # Document (dados da organização)
│   │   ├─ name: "Hospital XYZ"
│   │   ├─ plan: "enterprise"
│   │   ├─ maxUsers: 1000
│   │   ├─ createdAt: timestamp
│   │   ├─ settings: {...}
│   │   │
│   │   ├─ users/              # Subcollection
│   │   │   └─ {userId}
│   │   │       ├─ email: string
│   │   │       ├─ name: string
│   │   │       ├─ role: "admin" | "tech" | "supervisor"
│   │   │       ├─ organizationId: string (redundante para queries)
│   │   │       ├─ status: "active" | "suspended"
│   │   │       ├─ createdAt: timestamp
│   │   │       └─ updatedAt: timestamp
│   │   │
│   │   ├─ patients/           # Subcollection
│   │   │   └─ {patientId}
│   │   │       ├─ userId: string (ref)
│   │   │       ├─ nome: string
│   │   │       ├─ telefone: string
│   │   │       ├─ dataNascimento: timestamp
│   │   │       ├─ endereco: {...}
│   │   │       ├─ cidade: string
│   │   │       ├─ estado: string
│   │   │       ├─ sexo: "M" | "F"
│   │   │       └─ createdAt: timestamp
│   │   │
│   │   ├─ professionals/      # Subcollection
│   │   │   └─ {profId}
│   │   │       ├─ userId: string (ref)
│   │   │       ├─ nome: string
│   │   │       ├─ especialidade: string
│   │   │       ├─ formacao: string
│   │   │       ├─ certificados: string[]
│   │   │       ├─ experiencia: string
│   │   │       ├─ bio: string
│   │   │       ├─ avaliacao: float (DENORMALIZADO)
│   │   │       ├─ numeroAvaliacoes: int (DENORMALIZADO)
│   │   │       ├─ availability: {...}
│   │   │       └─ pricing: {...}
│   │   │
│   │   ├─ contracts/          # Subcollection
│   │   │   └─ {contractId}
│   │   │       ├─ patientId: string (ref)
│   │   │       ├─ professionalId: string (ref)
│   │   │       ├─ patientName: string (DENORM)
│   │   │       ├─ profName: string (DENORM)
│   │   │       ├─ serviceType: string
│   │   │       ├─ periodType: "hours" | "days" | "weeks"
│   │   │       ├─ periodValue: int
│   │   │       ├─ startDate: timestamp
│   │   │       ├─ startTime: string
│   │   │       ├─ endDate: timestamp?
│   │   │       ├─ address: string
│   │   │       ├─ observations: string?
│   │   │       ├─ totalValue: float
│   │   │       ├─ status: "pending" | "active" | "completed" | "cancelled"
│   │   │       ├─ createdAt: timestamp
│   │   │       └─ updatedAt: timestamp
│   │   │
│   │   ├─ conversations/      # Subcollection
│   │   │   └─ {conversationId}
│   │   │       ├─ participants: [userId1, userId2]
│   │   │       ├─ participantsMap: {userId1: true, userId2: true}
│   │   │       ├─ lastMessage: {...} (DENORM)
│   │   │       ├─ lastMessageText: string (DENORM)
│   │   │       ├─ lastMessageTime: timestamp (DENORM)
│   │   │       ├─ unreadCount: {userId1: 0, userId2: 3}
│   │   │       └─ updatedAt: timestamp
│   │   │
│   │   ├─ messages/           # Subcollection
│   │   │   └─ {messageId}
│   │   │       ├─ conversationId: string (ref)
│   │   │       ├─ senderId: string
│   │   │       ├─ receiverId: string
│   │   │       ├─ text: string
│   │   │       ├─ timestamp: timestamp
│   │   │       ├─ isRead: bool
│   │   │       └─ attachments?: {...}
│   │   │
│   │   ├─ reviews/            # Subcollection
│   │   │   └─ {reviewId}
│   │   │       ├─ professionalId: string (ref)
│   │   │       ├─ patientId: string (ref)
│   │   │       ├─ patientName: string (DENORM)
│   │   │       ├─ rating: float (1.0-5.0)
│   │   │       ├─ comment: string?
│   │   │       └─ createdAt: timestamp
│   │   │
│   │   └─ activityLogs/       # Subcollection (compliance)
│   │       └─ {logId}
│   │           ├─ userId: string
│   │           ├─ action: string
│   │           ├─ resource: string
│   │           ├─ timestamp: timestamp
│   │           └─ metadata: {...}
│
├─ userProfiles/               # Global collection (auth lookup)
│   └─ {userId}
│       ├─ email: string (INDEXED)
│       ├─ organizationId: string (link to tenant)
│       ├─ role: string
│       ├─ status: string
│       └─ lastLogin: timestamp
│
└─ auditLogs/                  # Global collection (compliance)
    └─ {logId}
        ├─ organizationId: string
        ├─ userId: string
        ├─ action: string ("login", "export_data", "delete_user")
        ├─ ipAddress: string
        ├─ userAgent: string
        ├─ timestamp: timestamp
        └─ success: bool
```

---

## 3. ESTRATÉGIAS DE DENORMALIZAÇÃO

### **Por que Denormalizar?**

**NoSQL não é SQL:**
```sql
-- SQL: JOIN é barato
SELECT c.*, p.nome, prof.nome
FROM contracts c
JOIN patients p ON c.patientId = p.id
JOIN professionals prof ON c.professionalId = prof.id;

-- Firestore: JOIN não existe!
-- Opção 1: 3 queries separadas (LENTO)
-- Opção 2: Denormalizar nomes (RÁPIDO)
```

### **Regra de Ouro:**

> **"Denormalize dados que são lidos juntos com frequência"**

---

### **Exemplo 1: Contratos**

#### ❌ **Normalizado (LENTO)**
```dart
// 3 queries Firestore = 3 × latência
final contract = await getContract(contractId);       // 50ms
final patient = await getPatient(contract.patientId); // 50ms
final prof = await getProf(contract.profId);          // 50ms
// Total: 150ms + custo de 3 reads
```

#### ✅ **Denormalizado (RÁPIDO)**
```dart
// 1 query Firestore
final contract = await getContract(contractId); // 50ms
print(contract.patientName); // já está aqui!
print(contract.profName);    // já está aqui!
// Total: 50ms + custo de 1 read
```

**Estrutura:**
```dart
{
  "id": "contract_123",
  "patientId": "patient_456",      // Referência
  "professionalId": "prof_789",    // Referência
  "patientName": "João Silva",     // DENORMALIZADO
  "profName": "Maria Santos",      // DENORMALIZADO
  "serviceType": "Cuidador",
  "status": "active",
  "totalValue": 2500.00
}
```

---

### **Exemplo 2: Conversas**

#### ✅ **lastMessage Denormalizado**
```dart
{
  "id": "conv_123",
  "participants": ["user1", "user2"],
  "lastMessage": {                    // DENORMALIZADO
    "text": "Oi, tudo bem?",
    "senderId": "user1",
    "timestamp": "2025-10-13T10:30:00Z"
  },
  "unreadCount": {"user1": 0, "user2": 1},
  "updatedAt": "2025-10-13T10:30:00Z"
}
```

**Benefício:** Lista de conversas em 1 query (sem carregar todas as mensagens)

---

### **Exemplo 3: Profissionais**

#### ✅ **Rating Agregado**
```dart
{
  "id": "prof_123",
  "nome": "Maria Santos",
  "especialidade": "Cuidador",
  "avaliacao": 4.7,              // DENORMALIZADO (calculado)
  "numeroAvaliacoes": 43,        // DENORMALIZADO (contagem)
  // ...
}
```

**Atualização (Cloud Function):**
```javascript
exports.updateProfessionalRating = functions.firestore
  .document('organizations/{orgId}/reviews/{reviewId}')
  .onWrite(async (change, context) => {
    const profId = change.after.data().professionalId;
    
    // Calcula nova média
    const reviewsSnapshot = await admin.firestore()
      .collection(`organizations/${context.params.orgId}/reviews`)
      .where('professionalId', '==', profId)
      .get();
    
    const total = reviewsSnapshot.size;
    const sum = reviewsSnapshot.docs.reduce((acc, doc) => 
      acc + doc.data().rating, 0);
    const average = sum / total;
    
    // Atualiza professional
    await admin.firestore()
      .doc(`organizations/${context.params.orgId}/professionals/${profId}`)
      .update({
        avaliacao: average,
        numeroAvaliacoes: total
      });
  });
```

---

### **Quando NÃO Denormalizar**

❌ **Dados que mudam frequentemente**
```dart
// ❌ NÃO denormalizar status de usuário (muda muito)
{
  "contract": {
    "patientStatus": "online"  // VAI FICAR DESATUALIZADO!
  }
}

// ✅ Fazer query quando necessário
final patient = await getPatient(contract.patientId);
final isOnline = patient.status == 'online';
```

❌ **Dados sensíveis**
```dart
// ❌ NÃO denormalizar dados sensíveis
{
  "contract": {
    "patientCPF": "123.456.789-01"  // VAZAMENTO DE DADOS!
  }
}
```

---

## 4. RELACIONAMENTOS E REFERÊNCIAS

### **Tipos de Relacionamentos**

#### **1. One-to-One (1:1)**

**Exemplo: User ↔ Professional**

```dart
// Opção A: Dados na mesma collection (RECOMENDADO para small data)
users/{userId}
  ├─ email, name, role
  ├─ professionalData: {        // Embedded
  │    especialidade,
  │    formacao,
  │    bio
  │  }

// Opção B: Collections separadas (RECOMENDADO para large data)
users/{userId}
  └─ email, name, role

professionals/{profId}
  └─ userId (reference), especialidade, bio, ...
```

---

#### **2. One-to-Many (1:N)**

**Exemplo: Professional → Reviews (1:N)**

```dart
// ✅ Subcollection (RECOMENDADO)
organizations/{orgId}/professionals/{profId}
organizations/{orgId}/reviews/{reviewId}
  └─ professionalId: string (reference)

// Query todas as reviews de um profissional
db.collection('organizations/$orgId/reviews')
  .where('professionalId', isEqualTo: profId)
  .get();
```

**❌ NÃO usar array de IDs:**
```dart
// ❌ RUIM: Limite de 1MB por document
professionals/{profId}
  └─ reviewIds: ["review1", "review2", ..., "review9999"] // EXPLODE!
```

---

#### **3. Many-to-Many (N:M)**

**Exemplo: Patients ↔ Professionals (via Contracts)**

```dart
// ✅ Collection intermediária (RECOMENDADO)
contracts/{contractId}
  ├─ patientId: string
  ├─ professionalId: string
  └─ ...

// Query contratos de um paciente
db.collection('organizations/$orgId/contracts')
  .where('patientId', isEqualTo: patientId)
  .get();

// Query contratos de um profissional
db.collection('organizations/$orgId/contracts')
  .where('professionalId', isEqualTo: profId)
  .get();
```

---

## 5. SHARDING E PARTICIONAMENTO

### **Por que Shardar?**

**Limite do Firestore:**
- **1 documento = 1 MB máximo**
- **500 writes/segundo por documento**

Para alta concorrência (ex: contador global), shardar é essencial.

---

### **Exemplo: Contador de Usuários Online**

#### ❌ **Sem Sharding (GARGALO)**
```dart
// 1 documento = limite de 500 writes/s
onlineUsers/counter
  └─ count: 1234567

// Se 1000 usuários fazem login/s → ERRO!
```

#### ✅ **Com Sharding (ESCALÁVEL)**
```dart
// 10 shards = 10 × 500 = 5000 writes/s
onlineUsers/shard_0  → count: 123456
onlineUsers/shard_1  → count: 123457
...
onlineUsers/shard_9  → count: 123450

// Total = sum(shard_0 a shard_9)
```

**Implementação:**
```dart
Future<void> incrementOnlineCount() async {
  final shardId = Random().nextInt(10); // 0-9
  await db.doc('onlineUsers/shard_$shardId').update({
    'count': FieldValue.increment(1)
  });
}

Future<int> getTotalOnline() async {
  final shards = await db.collection('onlineUsers').get();
  return shards.docs.fold(0, (sum, doc) => sum + doc.data()['count']);
}
```

---

### **Quando Shardar?**

✅ **Shardar quando:**
- Hotspot de writes (>100 writes/s no mesmo doc)
- Contadores globais
- Leaderboards

❌ **NÃO shardar quando:**
- Writes distribuídos (diferentes docs)
- Reads dominam (sharding complica queries)

---

## 6. INDEXAÇÃO

### **Índices Automáticos (Firestore)**

Firestore cria índices automaticamente para:
- **Single-field queries**
- **Equality (==)**
- **Range (<, >, <=, >=)**
- **OrderBy**

```dart
// ✅ Índice automático
.where('status', isEqualTo: 'active')
.where('createdAt', isGreaterThan: yesterday)
.orderBy('createdAt', descending: true)
```

---

### **Índices Compostos (Manual)**

**Quando necessário:**
- Queries com múltiplos campos
- OrderBy + Where em campos diferentes
- Array-contains + outro filtro

#### **Exemplo: Busca de Profissionais**

```dart
// Query complexa
db.collection('organizations/$orgId/professionals')
  .where('specialty', isEqualTo: 'cuidadores')  // Campo 1
  .where('rating', isGreaterThan: 4.0)          // Campo 2
  .orderBy('rating', descending: true)           // Campo 2
  .orderBy('createdAt', descending: true)        // Campo 3
  .limit(20);

// ❌ Erro sem índice composto:
// "The query requires an index. Create it here: [LINK]"
```

**Criar índice (Firebase Console):**
```
Collection: organizations/{orgId}/professionals
Fields:
  - specialty (Ascending)
  - rating (Descending)
  - createdAt (Descending)
```

---

### **Índices de Array**

```dart
// Query com array
.where('tags', arrayContains: 'cuidador')

// Índice automático criado
```

**⚠️ Limitação:**
```dart
// ❌ NÃO FUNCIONA: Múltiplos array-contains
.where('tags', arrayContains: 'cuidador')
.where('certifications', arrayContains: 'COREN')

// ✅ WORKAROUND: Usar map
.where('tagsMap.cuidador', isEqualTo: true)
.where('certsMap.COREN', isEqualTo: true)
```

---

### **Estratégias de Otimização**

#### **1. Minimize Queries Compostas**
```dart
// ❌ RUIM: 3 filtros = índice complexo
.where('city', isEqualTo: 'SP')
.where('specialty', isEqualTo: 'cuidador')
.where('rating', isGreaterThan: 4.5)

// ✅ MELHOR: 2 filtros + client-side filter
final docs = await db
  .where('city', isEqualTo: 'SP')
  .where('specialty', isEqualTo: 'cuidador')
  .get();

final filtered = docs.where((doc) => doc['rating'] > 4.5);
```

#### **2. Use Cache Agressivamente**
```dart
// Cache por 10 minutos
final snapshot = await db
  .collection('professionals')
  .where('city', isEqualTo: 'SP')
  .get(GetOptions(source: Source.cache));
```

---

## 7. PAGINAÇÃO EFICIENTE

### **Cursor-based Pagination (RECOMENDADO)**

```dart
class ProfessionalsRepository {
  DocumentSnapshot? _lastDoc;
  
  Future<List<Professional>> getNextPage({int limit = 20}) async {
    Query query = db
      .collection('organizations/$orgId/professionals')
      .where('specialty', isEqualTo: 'cuidadores')
      .orderBy('rating', descending: true)
      .limit(limit);
    
    // Se tem cursor, continua de onde parou
    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }
    
    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last; // Salva cursor
    }
    
    return snapshot.docs.map((doc) => 
      Professional.fromMap(doc.data())
    ).toList();
  }
  
  void reset() {
    _lastDoc = null; // Reseta paginação
  }
}
```

**Vantagens:**
- ✅ Performance constante (não importa a página)
- ✅ Dados consistentes (mesmo com novos inserts)
- ✅ Funciona com queries complexas

---

### **Infinite Scroll (Flutter)**

```dart
class ProfessionalsScreen extends ConsumerStatefulWidget {
  @override
  _ProfessionalsScreenState createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends ConsumerState<ProfessionalsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Carrega primeira página
    ref.read(professionalsProvider.notifier).loadNextPage();
  }
  
  void _onScroll() {
    // Detecta chegada ao fim da lista
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(professionalsProvider.notifier).loadNextPage();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final professionals = ref.watch(professionalsProvider);
    
    return ListView.builder(
      controller: _scrollController,
      itemCount: professionals.length + 1, // +1 para loader
      itemBuilder: (context, index) {
        if (index == professionals.length) {
          return CircularProgressIndicator(); // Loading
        }
        return ProfessionalCard(professional: professionals[index]);
      },
    );
  }
}
```

---

## 8. EXEMPLOS PRÁTICOS FLUTTER

### **Setup Firestore**

```dart
// lib/core/config/firebase_config.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Enable offline persistence
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // Development: Use emulator
    if (kDebugMode) {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    }
  }
  
  static FirebaseFirestore get instance => FirebaseFirestore.instance;
  
  // Helper para multi-tenant
  static CollectionReference orgCollection(String orgId, String collection) {
    return instance
      .collection('organizations')
      .doc(orgId)
      .collection(collection);
  }
}
```

---

### **DataSource Example**

```dart
// lib/data/datasources/contracts_firestore_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractsFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final String _organizationId;
  
  ContractsFirestoreDataSource(this._firestore, this._organizationId);
  
  CollectionReference get _collection =>
    _firestore
      .collection('organizations')
      .doc(_organizationId)
      .collection('contracts');
  
  // CREATE
  Future<String> createContract(Map<String, dynamic> data) async {
    final docRef = await _collection.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
  
  // READ
  Future<Map<String, dynamic>?> getContract(String contractId) async {
    final doc = await _collection.doc(contractId).get();
    if (!doc.exists) return null;
    
    return {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    };
  }
  
  // READ MANY (com paginação)
  Future<List<Map<String, dynamic>>> getContractsByPatient(
    String patientId, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _collection
      .where('patientId', isEqualTo: patientId)
      .orderBy('createdAt', descending: true)
      .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    }).toList();
  }
  
  // UPDATE
  Future<void> updateContract(String contractId, Map<String, dynamic> data) async {
    await _collection.doc(contractId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // DELETE (soft delete recomendado)
  Future<void> deleteContract(String contractId) async {
    await _collection.doc(contractId).update({
      'status': 'deleted',
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // STREAM (real-time)
  Stream<List<Map<String, dynamic>>> watchContractsByPatient(String patientId) {
    return _collection
      .where('patientId', isEqualTo: patientId)
      .where('status', isNotEqualTo: 'deleted')
      .orderBy('status')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList());
  }
}
```

---

### **Repository Implementation**

```dart
// lib/data/repositories/contracts_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/repositories/contracts_repository.dart';
import '../datasources/contracts_firestore_datasource.dart';

class ContractsRepositoryImpl implements ContractsRepository {
  final ContractsFirestoreDataSource _dataSource;
  
  ContractsRepositoryImpl(this._dataSource);
  
  @override
  Future<Either<Failure, String>> createContract(ContractEntity contract) async {
    try {
      final id = await _dataSource.createContract({
        'patientId': contract.patientId,
        'professionalId': contract.professionalId,
        'patientName': contract.patientName,  // DENORMALIZADO
        'profName': contract.profName,        // DENORMALIZADO
        'serviceType': contract.serviceType,
        'periodType': contract.periodType,
        'periodValue': contract.periodValue,
        'startDate': Timestamp.fromDate(contract.startDate),
        'startTime': contract.startTime,
        'address': contract.address,
        'totalValue': contract.totalValue,
        'status': 'pending',
      });
      return Right(id);
    } catch (e) {
      return Left(ServerFailure('Erro ao criar contrato: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<ContractEntity>>> getContractsByPatient(
    String patientId
  ) async {
    try {
      final data = await _dataSource.getContractsByPatient(patientId);
      final contracts = data.map((map) => ContractEntity.fromMap(map)).toList();
      return Right(contracts);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar contratos: $e'));
    }
  }
  
  @override
  Stream<List<ContractEntity>> watchContractsByPatient(String patientId) {
    return _dataSource.watchContractsByPatient(patientId).map(
      (data) => data.map((map) => ContractEntity.fromMap(map)).toList()
    );
  }
}
```

---

### **Provider (Riverpod)**

```dart
// lib/presentation/providers/contracts_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contractsProvider = StreamProvider.autoDispose.family<
  List<ContractEntity>, String
>((ref, patientId) {
  final repository = ref.watch(contractsRepositoryProvider);
  return repository.watchContractsByPatient(patientId);
});

// Usage na UI
class ContractsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).user!.id;
    final contractsAsync = ref.watch(contractsProvider(userId));
    
    return contractsAsync.when(
      data: (contracts) => ListView.builder(
        itemCount: contracts.length,
        itemBuilder: (context, index) => 
          ContractCard(contract: contracts[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erro: $error'),
    );
  }
}
```

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Criar projeto Firebase
- [ ] Configurar Firestore (multi-region)
- [ ] Definir estrutura de coleções
- [ ] Implementar multi-tenancy
- [ ] Criar Security Rules (ver [FIREBASE_SECURITY_RULES.md](FIREBASE_SECURITY_RULES.md))
- [ ] Configurar índices compostos
- [ ] Implementar datasources
- [ ] Implementar repositories
- [ ] Adicionar offline persistence
- [ ] Testar paginação
- [ ] Implementar caching
- [ ] Configurar backups
- [ ] Documentar decisões

---

**Próximo:** [Security Rules →](FIREBASE_SECURITY_RULES.md)

