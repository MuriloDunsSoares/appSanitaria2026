# ⚡ FIREBASE - PERFORMANCE & OTIMIZAÇÃO DE CUSTOS

**Parte da:** [Consultoria Firebase](FIREBASE_ARCHITECTURE_GUIDE.md)  
**Foco:** Performance, custos e escalabilidade

---

## 📋 ÍNDICE

1. [Modelo de Precificação Firestore](#modelo-de-precificação-firestore)
2. [Otimização de Reads/Writes](#otimização-de-readswrites)
3. [Estratégias de Caching](#estratégias-de-caching)
4. [Indexação Eficiente](#indexação-eficiente)
5. [Cloud Functions vs Client Logic](#cloud-functions-vs-client-logic)
6. [Paginação e Lazy Loading](#paginação-e-lazy-loading)
7. [Compressão e Storage](#compressão-e-storage)
8. [Monitoramento de Custos](#monitoramento-de-custos)
9. [Casos de Uso Reais](#casos-de-uso-reais)
10. [Checklist de Otimização](#checklist-de-otimização)

---

## 1. MODELO DE PRECIFICAÇÃO FIRESTORE

### **Custos Principais**

| Operação | Preço (US$) | Limite Gratuito |
|----------|-------------|-----------------|
| **Document Reads** | $0.06 / 100k | 50k/dia |
| **Document Writes** | $0.18 / 100k | 20k/dia |
| **Document Deletes** | $0.02 / 100k | 20k/dia |
| **Storage** | $0.18 / GB/mês | 1 GB |
| **Network Egress** | $0.12 / GB | 10 GB/mês |

### **Cloud Functions**

| Recurso | Preço (US$) | Limite Gratuito |
|---------|-------------|-----------------|
| **Invocações** | $0.40 / milhão | 2M/mês |
| **Compute Time** | $0.0000025 / GB-second | 400k GB-s/mês |
| **Network** | $0.12 / GB | 5 GB/mês |

### **Cloud Storage (Imagens/Arquivos)**

| Operação | Preço (US$) | Limite Gratuito |
|----------|-------------|-----------------|
| **Storage** | $0.026 / GB/mês | 5 GB |
| **Downloads** | $0.12 / GB | 1 GB/dia |
| **Uploads** | Grátis | Ilimitado |

---

### **Exemplo de Cálculo: App com 100k Usuários Ativos**

```
CENÁRIO:
- 100,000 usuários ativos mensalmente
- 10 sessões/usuário/mês = 1M sessões
- 50 reads/sessão = 50M reads
- 5 writes/sessão = 5M writes
- 500 MB de storage
- 1000 fotos/dia de 500KB = 15 GB/mês

CUSTOS:
Firestore:
  - Reads:  50M × $0.06/100k = $30
  - Writes: 5M  × $0.18/100k = $9
  - Storage: 500MB × $0.18/GB = $0.09
  Total Firestore: ~$39/mês

Cloud Functions (triggers):
  - 5M invocações × $0.40/M = $2
  - Compute: ~$5
  Total Functions: ~$7/mês

Cloud Storage:
  - Storage: 15GB × $0.026/GB = $0.39
  - Downloads: 5GB × $0.12/GB = $0.60
  Total Storage: ~$1/mês

TOTAL MENSAL: ~$47 (≈ R$ 235)
CUSTO POR USUÁRIO: $0.00047 (≈ R$ 0,0024)
```

---

## 2. OTIMIZAÇÃO DE READS/WRITES

### **Reads são 3x mais caros que Writes**

**❌ RUIM:**
```dart
// 100 reads individuais = 100 × $0.06/100k = $0.06
for (final id in professionalIds) {
  final prof = await db.doc('professionals/$id').get();
  professionals.add(prof);
}
```

**✅ BOM:**
```dart
// 1 query = 100 docs retornados = 100 reads ($0.06)
// MAS apenas 1 round-trip (latência menor)
final profs = await db
  .collection('professionals')
  .where(FieldPath.documentId, whereIn: professionalIds) // máx 10 IDs
  .get();
```

**✅ MELHOR (Batch):**
```dart
// Para >10 IDs: usar batches de 10
Future<List<Professional>> getProfessionalsByIds(List<String> ids) async {
  final batches = <List<String>>[];
  for (var i = 0; i < ids.length; i += 10) {
    batches.add(ids.sublist(i, min(i + 10, ids.length)));
  }
  
  final results = await Future.wait(
    batches.map((batch) => 
      db.collection('professionals')
        .where(FieldPath.documentId, whereIn: batch)
        .get()
    )
  );
  
  return results
    .expand((snapshot) => snapshot.docs)
    .map((doc) => Professional.fromMap(doc.data()))
    .toList();
}
```

---

### **Evitar Writes Desnecessários**

**❌ RUIM: Write em CADA mensagem**
```dart
// Atualiza conversa a CADA mensagem = muitos writes
await db.doc('conversations/$convId').update({
  'lastMessage': message.text,
  'updatedAt': FieldValue.serverTimestamp(),
});

// 100 mensagens = 100 writes = $0.18
```

**✅ BOM: Batch writes**
```dart
// Atualiza conversa + cria mensagem em 1 batch = 2 writes
final batch = db.batch();

batch.set(
  db.doc('messages/${message.id}'),
  message.toMap(),
);

batch.update(
  db.doc('conversations/$convId'),
  {
    'lastMessage': message.text,
    'updatedAt': FieldValue.serverTimestamp(),
  },
);

await batch.commit(); // 1 round-trip, 2 writes
```

---

### **Denormalização: Trade-off Performance vs Consistência**

**❌ NORMALIZADO (3 reads):**
```dart
// Buscar contrato + paciente + profissional = 3 reads
final contract = await getContract(contractId);        // 1 read
final patient = await getPatient(contract.patientId);  // 1 read
final prof = await getProf(contract.profId);           // 1 read

// 1000 contratos carregados = 3000 reads = $0.18
```

**✅ DENORMALIZADO (1 read):**
```dart
// Buscar contrato (já tem nomes embedded) = 1 read
final contract = await getContract(contractId);
print(contract.patientName); // já está aqui
print(contract.profName);    // já está aqui

// 1000 contratos carregados = 1000 reads = $0.06 (3x mais barato!)
```

**Custo da Denormalização:**
- ✅ **-66% reads** ($0.18 → $0.06)
- ❌ **+1 write quando nome muda** (ocasional)
- ❌ **+storage** (nomes duplicados ~50 bytes/doc)

**Quando denormalizar:**
- ✅ Dados **lidos com frequência** (ex: nomes em listas)
- ✅ Dados que **mudam raramente** (ex: nomes, especialidades)
- ✅ Performance **crítica** (ex: feeds, dashboards)

**Quando NÃO denormalizar:**
- ❌ Dados que **mudam frequentemente** (ex: status online)
- ❌ Dados **sensíveis** (ex: CPF, senhas)
- ❌ Dados **grandes** (ex: bio de 5KB)

---

## 3. ESTRATÉGIAS DE CACHING

### **1. Cache Offline (Firestore SDK)**

**Configuração:**
```dart
// main.dart
await Firebase.initializeApp();

FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,               // Cache offline
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Sem limite
);
```

**Como funciona:**
```dart
// Primeira query: busca do servidor (1 read cobrado)
final profs = await db.collection('professionals').get();

// Queries subsequentes: busca do CACHE (0 reads)
final profs2 = await db.collection('professionals')
  .get(const GetOptions(source: Source.cache));
```

**Invalidação de Cache:**
```dart
// Forçar busca do servidor (ignora cache)
final profs = await db.collection('professionals')
  .get(const GetOptions(source: Source.server));

// Limpar cache (logout, por exemplo)
await FirebaseFirestore.instance.clearPersistence();
```

---

### **2. Cache em Memória (Provider/Riverpod)**

```dart
// lib/presentation/providers/professionals_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfessionalsNotifier extends StateNotifier<AsyncValue<List<Professional>>> {
  final ProfessionalsRepository _repository;
  DateTime? _lastFetch;
  final _cacheDuration = const Duration(minutes: 5);
  
  ProfessionalsNotifier(this._repository) : super(const AsyncValue.loading());
  
  Future<void> fetchProfessionals({bool forceRefresh = false}) async {
    // Se cache válido, não busca
    if (!forceRefresh && 
        _lastFetch != null && 
        DateTime.now().difference(_lastFetch!) < _cacheDuration &&
        state.hasValue) {
      print('📦 Usando cache em memória');
      return; // Cache válido
    }
    
    print('🌐 Buscando do servidor...');
    state = const AsyncValue.loading();
    
    final result = await _repository.getProfessionals();
    
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (professionals) {
        state = AsyncValue.data(professionals);
        _lastFetch = DateTime.now();
      },
    );
  }
  
  void invalidateCache() {
    _lastFetch = null;
  }
}

final professionalsProvider = StateNotifierProvider<
  ProfessionalsNotifier, AsyncValue<List<Professional>>
>((ref) {
  return ProfessionalsNotifier(ref.watch(professionalsRepositoryProvider));
});

// Usage
class ProfessionalsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final professionalsAsync = ref.watch(professionalsProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(professionalsProvider.notifier).invalidateCache();
        await ref.read(professionalsProvider.notifier).fetchProfessionals(
          forceRefresh: true
        );
      },
      child: professionalsAsync.when(
        data: (profs) => ListView.builder(
          itemCount: profs.length,
          itemBuilder: (context, index) => ProfessionalCard(profs[index]),
        ),
        loading: () => CircularProgressIndicator(),
        error: (error, stack) => Text('Erro: $error'),
      ),
    );
  }
}
```

**Economia:**
```
Sem cache:
  - 100 usuários abrindo tela de profissionais 10x/dia = 1000 queries
  - 1000 × 50 docs = 50k reads = $0.03/dia × 30 = $0.90/mês

Com cache (5 min):
  - 100 usuários, média 3 queries/dia (cache reduz 70%)
  - 300 × 50 docs = 15k reads = $0.009/dia × 30 = $0.27/mês

ECONOMIA: -70% ($0.63/mês)
```

---

### **3. Timestamps e Cache Condicional**

```dart
class ProfessionalsRepository {
  DateTime? _lastUpdate;
  
  Future<List<Professional>> getProfessionals() async {
    // Buscar apenas documentos atualizados desde última fetch
    Query query = db.collection('professionals');
    
    if (_lastUpdate != null) {
      query = query.where('updatedAt', isGreaterThan: _lastUpdate);
    }
    
    final snapshot = await query.get();
    
    if (snapshot.docs.isNotEmpty) {
      _lastUpdate = DateTime.now();
      // Merge com cache local
      return _mergeWithCache(snapshot.docs);
    }
    
    // Nenhum update, retornar cache
    return _getCachedData();
  }
}
```

---

## 4. INDEXAÇÃO EFICIENTE

### **Índices Custam Storage**

```
Cada índice criado = cópia dos campos indexados

Exemplo:
- 100k profissionais
- Índice composto: (city, specialty, rating)
- 3 campos × 50 bytes = 150 bytes/doc
- 100k × 150 bytes = 15 MB

Custo: 15MB × $0.18/GB = $0.0027/mês (negligível)
```

**⚠️ Problema: Índices MÚLTIPLOS**
```dart
// Se criar 20 índices diferentes:
20 × 15 MB = 300 MB = $0.054/mês

// Para milhões de docs:
1M docs × 20 índices × 150 bytes = 3 GB = $0.54/mês
```

---

### **Estratégias de Indexação**

#### **1. Índices Seletivos**

**❌ RUIM: Índice para tudo**
```javascript
// 20 índices diferentes para cobrir todos os casos
(city, specialty, rating)
(city, specialty, createdAt)
(city, rating)
(specialty, rating)
... // 16 mais
```

**✅ BOM: Índices para queries comuns**
```javascript
// 3 índices estratégicos (80% dos casos)
1. (city, specialty, rating)        // Busca principal
2. (organizationId, createdAt)       // Listar recentes
3. (userId)                          // Perfil de usuário

// Casos raros: filter no client-side
```

#### **2. Client-side Filtering**

```dart
// Query com 2 filtros (usa índice)
final snapshot = await db
  .collection('professionals')
  .where('city', isEqualTo: 'São Paulo')
  .where('specialty', isEqualTo: 'cuidadores')
  .get();

// 3º filtro no client (evita criar índice)
final filtered = snapshot.docs
  .where((doc) => doc['rating'] > 4.5 && doc['experience'] > 5)
  .toList();
```

**Trade-off:**
- ✅ **-storage** (sem índice extra)
- ✅ **-complexidade** (menos índices)
- ❌ **+reads** (traz docs que serão descartados)
- ❌ **+latência** (processamento no client)

**Quando usar:**
- ✅ Queries **raras** (<5% do tráfego)
- ✅ Datasets **pequenos** (<100 docs)
- ❌ Queries **frequentes** (criar índice)
- ❌ Datasets **grandes** (>1000 docs)

---

## 5. CLOUD FUNCTIONS VS CLIENT LOGIC

### **Quando usar Cloud Functions**

#### ✅ **USE Cloud Functions para:**

**1. Validação Crítica de Negócio**
```javascript
// Garantir que paciente não avalie mesmo profissional 2x
exports.onReviewCreate = functions.firestore
  .document('reviews/{reviewId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    
    // Verificar se já existe review
    const existing = await admin.firestore()
      .collection('reviews')
      .where('patientId', '==', data.patientId)
      .where('professionalId', '==', data.professionalId)
      .limit(1)
      .get();
    
    if (existing.size > 1) {
      await snap.ref.delete(); // Deletar review duplicado
      throw new Error('Patient already reviewed this professional');
    }
  });
```

**2. Agregações e Cálculos**
```javascript
// Atualizar rating médio quando novo review é criado
exports.updateProfessionalRating = functions.firestore
  .document('reviews/{reviewId}')
  .onWrite(async (change, context) => {
    const profId = change.after.data().professionalId;
    
    // Calcular nova média
    const reviews = await admin.firestore()
      .collection('reviews')
      .where('professionalId', '==', profId)
      .get();
    
    const total = reviews.size;
    const sum = reviews.docs.reduce((acc, doc) => acc + doc.data().rating, 0);
    const average = sum / total;
    
    // Atualizar professional
    await admin.firestore()
      .doc(`professionals/${profId}`)
      .update({
        rating: average,
        reviewCount: total,
      });
  });
```

**3. Operações em Background**
```javascript
// Enviar notificações push
exports.sendMessageNotification = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    
    // Buscar FCM token do destinatário
    const receiver = await admin.firestore()
      .doc(`users/${message.receiverId}`)
      .get();
    
    const fcmToken = receiver.data().fcmToken;
    
    // Enviar notificação
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: message.senderName,
        body: message.text,
      },
    });
  });
```

**4. Integrações Externas**
```javascript
// Integrar com gateway de pagamento
exports.processPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new Error('Unauthenticated');
  
  // Integrar com Stripe
  const payment = await stripe.charges.create({
    amount: data.amount,
    currency: 'brl',
    customer: data.customerId,
  });
  
  // Salvar no Firestore
  await admin.firestore().collection('payments').add({
    userId: context.auth.uid,
    amount: data.amount,
    status: payment.status,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  return { success: true, paymentId: payment.id };
});
```

---

#### ❌ **NÃO USE Cloud Functions para:**

**1. Lógica Simples que pode ser no Client**
```javascript
// ❌ RUIM: Function para formatar data
exports.formatDate = functions.https.onCall((data) => {
  return new Date(data.timestamp).toLocaleDateString('pt-BR');
});

// ✅ BOM: Fazer no client
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}
```

**2. Validações que Security Rules cobrem**
```javascript
// ❌ RUIM: Function para validar email
exports.validateEmail = functions.https.onCall((data) => {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(data.email);
});

// ✅ BOM: Security Rules
allow create: if request.resource.data.email.matches('^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$');
```

---

### **Custos: Client vs Functions**

**Exemplo: Calcular total de um carrinho**

#### **Opção A: Client-side**
```dart
// GRÁTIS (roda no dispositivo do usuário)
double calculateTotal(List<CartItem> items) {
  return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
}

// Custo: $0
```

#### **Opção B: Cloud Function**
```javascript
exports.calculateTotal = functions.https.onCall((data) => {
  const items = data.items;
  return items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
});

// Custo:
// 1M usuários × 10 cálculos/mês = 10M invocações
// 10M × $0.40/M = $4/mês
// Compute: ~$5/mês
// Total: ~$9/mês
```

**Conclusão:** Use client-side quando possível!

---

## 6. PAGINAÇÃO E LAZY LOADING

### **Paginação Cursor-based**

```dart
class ProfessionalsRepository {
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  
  Future<List<Professional>> getNextPage({int limit = 20}) async {
    if (!_hasMore) return []; // Sem mais dados
    
    Query query = db
      .collection('professionals')
      .orderBy('rating', descending: true)
      .limit(limit);
    
    // Continuar de onde parou
    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }
    
    final snapshot = await query.get();
    
    if (snapshot.docs.isEmpty) {
      _hasMore = false;
      return [];
    }
    
    _lastDoc = snapshot.docs.last;
    
    return snapshot.docs.map((doc) => 
      Professional.fromMap(doc.data())
    ).toList();
  }
  
  void reset() {
    _lastDoc = null;
    _hasMore = true;
  }
}
```

**Vantagens:**
- ✅ Performance **constante** (não importa a página)
- ✅ **Consistente** (novos inserts não desalinham)
- ✅ Funciona com **queries complexas**

**Comparação com Offset-based:**
```dart
// ❌ RUIM: Offset (limit/offset)
// Página 1000: busca 20,000 docs e descarta 19,980! 😱
.limit(20)
.offset(19980)

// ✅ BOM: Cursor
// Busca apenas 20 docs, não importa a página ✅
.startAfterDocument(lastDoc)
.limit(20)
```

---

### **Lazy Loading de Imagens**

```dart
class ProfessionalCard extends StatelessWidget {
  final Professional professional;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          // Lazy load da imagem
          CachedNetworkImage(
            imageUrl: professional.photoUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.person),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            // Cache por 7 dias
            cacheManager: CacheManager(
              Config(
                'professionalPhotos',
                stalePeriod: const Duration(days: 7),
              ),
            ),
          ),
          // Dados textuais (já carregados)
          Expanded(
            child: Column(
              children: [
                Text(professional.name),
                Text(professional.specialty),
                Text('★ ${professional.rating.toStringAsFixed(1)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Economia:**
```
Sem lazy loading:
  - 100 profissionais na lista
  - 100 imagens de 100KB = 10MB download
  - 10MB × $0.12/GB × 30 dias × 10k usuários = $360/mês 😱

Com lazy loading:
  - Usuário vê apenas 10 profissionais (scroll parcial)
  - 10 imagens = 1MB download
  - 1MB × $0.12/GB × 30 dias × 10k usuários = $36/mês ✅

ECONOMIA: -90% ($324/mês)
```

---

## 7. COMPRESSÃO E STORAGE

### **Compressão de Imagens**

```dart
// lib/core/utils/image_compressor.dart
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  static Future<File> compressImage(File image) async {
    final filePath = image.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_compressed.jpg";
    
    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 70,              // 70% qualidade (visual OK, tamanho -60%)
      minWidth: 800,            // Max width 800px
      minHeight: 800,           // Max height 800px
      format: CompressFormat.jpeg,
    );
    
    return result!;
  }
  
  static Future<String> uploadCompressed(File image, String path) async {
    final compressed = await compressImage(image);
    
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putFile(compressed);
    
    return await ref.getDownloadURL();
  }
}

// Usage
final photoUrl = await ImageCompressor.uploadCompressed(
  imageFile,
  'professionals/${userId}/profile.jpg'
);
```

**Economia:**
```
Sem compressão:
  - 10k profissionais × 2MB/foto = 20GB storage
  - 20GB × $0.026/GB = $0.52/mês
  - Downloads: 20GB × 1000 views = 20TB × $0.12/GB = $2,400/mês 😱

Com compressão (70% qualidade):
  - 10k × 800KB/foto = 8GB storage
  - 8GB × $0.026/GB = $0.21/mês
  - Downloads: 8GB × 1000 views = 8TB × $0.12/GB = $960/mês

ECONOMIA: -60% storage, -60% bandwidth ($1,440/mês)
```

---

### **Thumbnails e Versões Múltiplas**

```javascript
// Cloud Function: gerar thumbnails ao fazer upload
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sharp = require('sharp');
const path = require('path');
const os = require('os');
const fs = require('fs');

exports.generateThumbnails = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name;
  const contentType = object.contentType;
  
  // Apenas imagens
  if (!contentType.startsWith('image/')) return;
  
  const fileName = path.basename(filePath);
  const bucket = admin.storage().bucket(object.bucket);
  const tempFilePath = path.join(os.tmpdir(), fileName);
  
  // Download
  await bucket.file(filePath).download({ destination: tempFilePath });
  
  // Gerar múltiplos tamanhos
  const sizes = [
    { name: 'thumb', width: 150, height: 150 },
    { name: 'medium', width: 800, height: 800 },
  ];
  
  await Promise.all(sizes.map(async (size) => {
    const resizedPath = path.join(
      os.tmpdir(), 
      `${size.name}_${fileName}`
    );
    
    await sharp(tempFilePath)
      .resize(size.width, size.height, { fit: 'cover' })
      .jpeg({ quality: 70 })
      .toFile(resizedPath);
    
    const dir = path.dirname(filePath);
    await bucket.upload(resizedPath, {
      destination: path.join(dir, `${size.name}_${fileName}`),
      metadata: { contentType: 'image/jpeg' },
    });
  }));
  
  // Limpar temp files
  fs.unlinkSync(tempFilePath);
});
```

**Uso no Flutter:**
```dart
class ProfessionalAvatar extends StatelessWidget {
  final String photoUrl;
  final double size;
  
  @override
  Widget build(BuildContext context) {
    // Escolher tamanho baseado no widget
    String imageUrl;
    if (size <= 150) {
      imageUrl = photoUrl.replaceFirst('/', '/thumb_'); // 150px
    } else if (size <= 800) {
      imageUrl = photoUrl.replaceFirst('/', '/medium_'); // 800px
    } else {
      imageUrl = photoUrl; // Original
    }
    
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
    );
  }
}
```

---

## 8. MONITORAMENTO DE CUSTOS

### **Firebase Console: Usage Dashboard**

1. **Firestore Usage:**
   - Reads/Writes/Deletes por dia
   - Storage usado
   - Queries por collection

2. **Cloud Functions:**
   - Invocações por função
   - Compute time
   - Errors

3. **Cloud Storage:**
   - Storage total
   - Bandwidth (downloads/uploads)

---

### **Alertas de Custo**

**Google Cloud Console → Billing → Budgets & Alerts:**

```
Budget 1: Firestore Reads
  - Limite: 50M reads/mês
  - Alert: 50%, 80%, 100%
  - Action: Email + Webhook

Budget 2: Cloud Functions
  - Limite: $50/mês
  - Alert: 80%, 100%
  - Action: Email admin

Budget 3: Total Firebase
  - Limite: $500/mês
  - Alert: 90%, 100%
  - Action: Email + DISABLE PROJECT (emergência)
```

---

### **Logs e Analytics**

```dart
// lib/core/services/usage_logger.dart
class UsageLogger {
  static Future<void> logQuery(String collection, int docsRead) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'firestore_read',
      parameters: {
        'collection': collection,
        'docs_count': docsRead,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  static Future<void> logExpensiveQuery(String collection, int docsRead) async {
    if (docsRead > 100) {
      print('⚠️ EXPENSIVE QUERY: $collection ($docsRead docs)');
      
      // Log para BigQuery (análise posterior)
      await FirebaseAnalytics.instance.logEvent(
        name: 'expensive_query',
        parameters: {
          'collection': collection,
          'docs_count': docsRead,
        },
      );
    }
  }
}

// Interceptor para todas as queries
class FirestoreInterceptor {
  static Future<QuerySnapshot> query(Query query) async {
    final stopwatch = Stopwatch()..start();
    final snapshot = await query.get();
    stopwatch.stop();
    
    // Log
    await UsageLogger.logQuery(
      query.parameters['from'],
      snapshot.docs.length,
    );
    
    // Alert se query lenta
    if (stopwatch.elapsedMilliseconds > 1000) {
      print('🐢 SLOW QUERY: ${stopwatch.elapsedMilliseconds}ms');
    }
    
    // Alert se muitos docs
    if (snapshot.docs.length > 100) {
      await UsageLogger.logExpensiveQuery(
        query.parameters['from'],
        snapshot.docs.length,
      );
    }
    
    return snapshot;
  }
}
```

---

## 9. CASOS DE USO REAIS

### **Caso 1: Feed de Profissionais**

**Problema:**
- 10k profissionais no banco
- Usuário abre tela → busca TODOS → 10k reads!
- 1000 usuários/dia = 10M reads/dia = $6/dia = $180/mês 😱

**Solução:**
```dart
// 1. Paginação (20 por página)
// 2. Cache (5 minutos)
// 3. Filtros serverside (city, specialty)

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
    
    // Carregar primeira página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(professionalsProvider.notifier).loadNextPage();
    });
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Chegou a 90% do scroll → carregar mais
      ref.read(professionalsProvider.notifier).loadNextPage();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final professionalsAsync = ref.watch(professionalsProvider);
    
    return professionalsAsync.when(
      data: (professionals) => ListView.builder(
        controller: _scrollController,
        itemCount: professionals.length + 1,
        itemBuilder: (context, index) {
          if (index == professionals.length) {
            // Loader no final
            return CircularProgressIndicator();
          }
          return ProfessionalCard(professionals[index]);
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Erro: $error'),
    );
  }
}

// Provider
class ProfessionalsNotifier extends StateNotifier<AsyncValue<List<Professional>>> {
  final ProfessionalsRepository _repository;
  List<Professional> _allProfessionals = [];
  
  Future<void> loadNextPage() async {
    if (state.isLoading) return; // Já carregando
    
    final newProfessionals = await _repository.getNextPage(limit: 20);
    
    if (newProfessionals.isEmpty) return; // Sem mais dados
    
    _allProfessionals.addAll(newProfessionals);
    state = AsyncValue.data(_allProfessionals);
  }
}

// Resultado:
// - Usuário vê média 3 páginas = 60 reads
// - 1000 usuários/dia = 60k reads/dia = $0.036/dia = $1.08/mês ✅
// ECONOMIA: -94% ($178.92/mês)
```

---

### **Caso 2: Chat em Tempo Real**

**Problema:**
- Listener em tempo real = 1 read por mensagem recebida
- 1M mensagens/dia = $60/mês 😱

**Solução:**
```dart
// 1. Listeners apenas quando tela aberta
// 2. Detach listener quando sai da tela
// 3. Polling a cada 30s (fora da tela) ao invés de real-time

class IndividualChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  
  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends ConsumerState<IndividualChatScreen>
    with WidgetsBindingObserver {
  StreamSubscription<List<Message>>? _messagesSubscription;
  Timer? _pollingTimer;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startListening();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App em background → parar listener em tempo real
      _stopListening();
      _startPolling();
    } else if (state == AppLifecycleState.resumed) {
      // App voltou → restaurar listener
      _stopPolling();
      _startListening();
    }
  }
  
  void _startListening() {
    // Listener em tempo real (apenas quando tela aberta)
    _messagesSubscription = ref
      .read(chatRepositoryProvider)
      .watchMessages(widget.conversationId)
      .listen((messages) {
        // Atualizar UI
        setState(() {});
      });
  }
  
  void _stopListening() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }
  
  void _startPolling() {
    // Polling a cada 30s (economiza reads)
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      ref.read(chatRepositoryProvider).fetchNewMessages(widget.conversationId);
    });
  }
  
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  @override
  void dispose() {
    _stopListening();
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.conversationId));
    
    return Scaffold(
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) => MessageBubble(messages[index]),
      ),
    );
  }
}

// Resultado:
// - 1M mensagens/dia, mas 70% com app em background
// - 700k mensagens → polling (1 read a cada 30s vs 1 por msg)
// - Redução de 95% nos reads de mensagens em background
// ECONOMIA: -57% (~$34/mês)
```

---

## 10. CHECKLIST DE OTIMIZAÇÃO

### **Performance**

- [ ] Paginação implementada (cursor-based)
- [ ] Cache offline habilitado (Firestore SDK)
- [ ] Cache em memória (Provider/Riverpod)
- [ ] Denormalização estratégica (nomes, ratings)
- [ ] Lazy loading de imagens
- [ ] Compressão de imagens (70% qualidade)
- [ ] Thumbnails múltiplos tamanhos
- [ ] Listeners em tempo real apenas quando necessário
- [ ] Detach listeners quando sair da tela
- [ ] Batch writes quando possível

### **Custos**

- [ ] Monitoramento de custos configurado
- [ ] Alertas de budget (50%, 80%, 100%)
- [ ] Logs de queries caras (>100 docs)
- [ ] Índices seletivos (apenas queries comuns)
- [ ] Client-side filtering para queries raras
- [ ] Cloud Functions apenas para lógica crítica
- [ ] Polling em background (ao invés de real-time)
- [ ] Compressão de dados (gzip para JSONs grandes)

### **Queries**

- [ ] Evitar `whereIn` com >10 IDs (usar batches)
- [ ] Evitar `list` sem limite (max 100)
- [ ] Usar `get()` ao invés de `list()` quando possível
- [ ] Evitar queries sem índices
- [ ] Evitar queries com `!=` ou `array-contains-any` (lentas)

### **Storage**

- [ ] Imagens comprimidas (<1MB)
- [ ] Thumbnails gerados automaticamente
- [ ] Delete de arquivos órfãos (cleanup)
- [ ] CDN configurado (Firebase Hosting)

---

**Próximo:** [Monitoramento & Observability →](FIREBASE_MONITORING_OBSERVABILITY.md)

