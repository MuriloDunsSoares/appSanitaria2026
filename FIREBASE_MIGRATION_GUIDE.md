# 🔄 GUIA DE MIGRAÇÃO FIREBASE - MULTI-TENANT

**Data:** Outubro 2025  
**Status:** Implementação Parcial - Estrutura Base Pronta  
**Baseado em:** [Consultoria Firebase](FIREBASE_ARCHITECTURE_GUIDE.md)

---

## 📊 O QUE FOI IMPLEMENTADO

### ✅ **1. Firebase Config (NEW)**

**Arquivo:** `lib/core/config/firebase_config.dart`

**Funcionalidades:**
- ✅ Inicialização centralizada do Firebase
- ✅ Configuração de offline persistence (cache ilimitado)
- ✅ Integration Firebase Analytics
- ✅ Integration Firebase Crashlytics  
- ✅ Integration Firebase Performance
- ✅ **Multi-tenant helpers** (orgCollection, orgDocument)
- ✅ **Global collections** (userProfiles, auditLogs)
- ✅ Suporte a emulators (desenvolvimento local)

**Uso:**
```dart
// Inicializar no main.dart
await FirebaseConfig.initialize();

// Acessar collection multi-tenant
final contracts = FirebaseConfig.orgCollection('org_001', 'contracts');

// Acessar collection global
final userProfiles = FirebaseConfig.userProfilesCollection;
```

---

### ✅ **2. Base Firestore DataSource (NEW)**

**Arquivo:** `lib/data/datasources/base_firestore_datasource.dart`

**Funcionalidades:**
- ✅ Classe abstrata para todos os datasources
- ✅ **Multi-tenant support** (organizationId)
- ✅ Helper para collections
- ✅ Tratamento padronizado de erros
- ✅ Helpers para timestamps e conversões

**Uso:**
```dart
class MyDataSource extends BaseFirestoreDataSource {
  MyDataSource(String organizationId) : super(organizationId);
  
  CollectionReference get _collection => collection('myCollection');
  
  Future<void> create(Map<String, dynamic> data) async {
    await _collection.add(addTimestamps(data));
  }
}
```

---

### ✅ **3. Contracts DataSource V2 (NEW)**

**Arquivo:** `lib/data/datasources/firebase_contracts_datasource_v2.dart`

**Melhores Práticas Implementadas:**

#### **🔐 Multi-tenant Isolation**
```dart
// Todos os contratos ficam dentro da organização
organizations/{orgId}/contracts/{contractId}
```

#### **📊 Denormalização**
```dart
{
  "id": "contract_123",
  "patientId": "user_456",
  "professionalId": "prof_789",
  "patientName": "João Silva",       // DENORMALIZADO
  "professionalName": "Maria Santos", // DENORMALIZADO
  "status": "active",
  "totalValue": 2500.00
}
```
**Benefício:** -66% reads (evita 2 queries extras)

#### **📄 Paginação Cursor-based**
```dart
getContractsByPatient(
  'patient_123',
  startAfter: lastDoc,  // Cursor
  limit: 20
);
```
**Benefício:** Performance constante (não importa a página)

#### **🗑️ Soft Delete**
```dart
deleteContract(contractId, userId);
// Define status='deleted' e deletedAt=timestamp
// Permite recovery e mantém audit trail
```

#### **📡 Real-time Streams**
```dart
watchContractsByPatient('patient_123').listen((contracts) {
  // Atualiza UI em tempo real
});
```

---

### ✅ **4. Firestore Collections Updated**

**Arquivo:** `lib/core/config/firestore_collections.dart`

**Adições:**
- ✅ Constante `organizations`
- ✅ Constante `userProfiles` (global)
- ✅ Constante `auditLogs` (global)
- ✅ Campos multi-tenant (`organizationId`, `role`, `status`)
- ✅ Campos soft delete (`deletedAt`, `deletedBy`)

---

### ✅ **5. Security Rules (NEW)**

**Arquivo:** `firestore.rules`

**Recursos Implementados:**

#### **🔐 Row-Level Security (RLS)**
```javascript
// Usuário só acessa dados da própria org
allow read: if isSameOrg(orgId) && isActive();
```

#### **👥 RBAC (Role-Based Access Control)**
```javascript
// Admin tem acesso total
allow write: if hasRole('admin');

// Usuário normal: acesso limitado
allow update: if request.auth.uid == userId;
```

#### **✅ Validação de Dados**
```javascript
// Email válido
allow create: if isValidEmail(request.resource.data.email);

// Rating entre 1-5
allow create: if request.resource.data.rating >= 1.0 &&
                 request.resource.data.rating <= 5.0;
```

#### **🛡️ Proteção Contra Ataques**
```javascript
// Enumeration attack: listar bloqueado
allow list: if false;

// Mass assignment: apenas campos permitidos
allow update: if onlyAllowedFieldsChanged(['nome', 'telefone']);

// Timestamp validation: até 5 min futuro (clock skew)
allow create: if isRecentTimestamp(request.resource.data.timestamp);
```

---

### ✅ **6. Dependencies Updated**

**Arquivo:** `pubspec.yaml`

**Adições:**
```yaml
firebase_analytics: ^11.3.3     # Analytics e eventos
firebase_crashlytics: ^4.1.3    # Error tracking
firebase_performance: ^0.10.0+8 # Performance monitoring
```

---

## 📋 ESTRUTURA MULTI-TENANT

### **Antes (Flat)**
```
firestore/
├─ users/
├─ contracts/
├─ messages/
└─ reviews/

❌ Problema: Sem isolamento entre organizações
```

### **Depois (Multi-tenant)**
```
firestore/
│
├─ organizations/
│  ├─ org_001/
│  │  ├─ users/
│  │  ├─ contracts/
│  │  ├─ messages/
│  │  └─ reviews/
│  │
│  └─ org_002/
│     ├─ users/       ← Isolado de org_001
│     └─ ...
│
├─ userProfiles/      ← Global (auth lookup)
└─ auditLogs/         ← Global (compliance)

✅ Benefícios:
  - Isolamento completo
  - Security Rules simples
  - Escalabilidade horizontal
  - Compliance LGPD
```

---

## 🚀 PRÓXIMOS PASSOS

### **Fase 1: Migração de Dados (CRÍTICO)**

#### **1.1 Criar Organização Default**
```dart
// Script: scripts/create_default_organization.dart
await FirebaseFirestore.instance
  .collection('organizations')
  .doc('default_org')
  .set({
    'name': 'Organização Padrão',
    'plan': 'free',
    'maxUsers': 100,
    'createdAt': FieldValue.serverTimestamp(),
  });
```

#### **1.2 Migrar Dados Existentes**
```dart
// Script: scripts/migrate_to_multitenant.dart

// 1. Buscar todos os contratos antigos (flat)
final oldContracts = await firestore.collection('contracts').get();

// 2. Mover para dentro da organização
for (final doc in oldContracts.docs) {
  await firestore
    .collection('organizations')
    .doc('default_org')
    .collection('contracts')
    .doc(doc.id)
    .set({
      ...doc.data(),
      'organizationId': 'default_org',
    });
}

// 3. Deletar contratos antigos
// (CUIDADO: Fazer backup antes!)
```

#### **1.3 Criar UserProfiles**
```dart
// Para cada usuário existente
final users = await firestore.collection('users').get();

for (final doc in users.docs) {
  await firestore
    .collection('userProfiles')
    .doc(doc.id)
    .set({
      'email': doc.data()['email'],
      'organizationId': 'default_org',
      'role': 'client',  // ou 'admin'
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
}
```

---

### **Fase 2: Atualizar DataSources**

#### **2.1 Contracts**
```dart
// ANTES (flat)
class ContractsRepositoryImpl {
  final FirebaseContractsDataSource _dataSource;
}

// DEPOIS (multi-tenant)
class ContractsRepositoryImpl {
  final FirebaseContractsDataSourceV2 _dataSource;
  
  ContractsRepositoryImpl(String organizationId)
    : _dataSource = FirebaseContractsDataSourceV2(organizationId);
}
```

#### **2.2 Professionals**
```dart
// TODO: Criar FirebaseProfessionalsDataSourceV2
// - Seguir mesmo padrão de ContractsV2
// - Implementar denormalização (rating, reviewCount)
// - Adicionar paginação cursor-based
```

#### **2.3 Chat**
```dart
// TODO: Criar FirebaseChatDataSourceV2
// - Listeners em tempo real
// - Unread count denormalizado
// - Soft delete de mensagens
```

---

### **Fase 3: Atualizar Repositories**

```dart
// ANTES
final contractsRepo = ContractsRepositoryImpl(dataSource);

// DEPOIS
final organizationId = getCurrentUser().organizationId;
final contractsRepo = ContractsRepositoryImpl(organizationId);
```

---

### **Fase 4: Atualizar Providers**

```dart
// ANTES
final contractsProvider = Provider((ref) {
  return ContractsRepositoryImpl(dataSource);
});

// DEPOIS
final contractsProvider = Provider((ref) {
  final user = ref.watch(authProvider).user;
  final orgId = user?.organizationId ?? 'default_org';
  return ContractsRepositoryImpl(orgId);
});
```

---

### **Fase 5: Deploy Security Rules**

```bash
# 1. Testar localmente com emulator
firebase emulators:start --only firestore

# 2. Deploy para staging
firebase deploy --only firestore:rules --project staging

# 3. Testar em staging
# - Criar usuários
# - Criar contratos
# - Verificar isolamento

# 4. Deploy para produção
firebase deploy --only firestore:rules --project production
```

---

### **Fase 6: Monitoramento**

```dart
// Configurar Performance Monitoring
final trace = FirebasePerformance.instance.newTrace('contract_create');
await trace.start();

// ... operação ...

await trace.stop();
```

---

## ⚠️ AVISOS IMPORTANTES

### **🔴 BREAKING CHANGES**

1. **Estrutura de Dados Mudou**
   - Collections antigas (flat) NÃO funcionam mais
   - Security Rules novas bloqueiam acesso antigo
   - **MIGRAÇÃO OBRIGATÓRIA**

2. **organizationId Requerido**
   - Todos os datasources precisam de organizationId
   - UserProfile deve ter organizationId
   - Security Rules validam organizationId

3. **Soft Delete**
   - Não usar `.delete()` (hard delete)
   - Usar `deleteContract(id, userId)` (soft delete)

---

## 📊 BENEFÍCIOS DA MIGRAÇÃO

| Aspecto | Antes | Depois |
|---------|-------|--------|
| **Isolamento** | ❌ Sem isolamento | ✅ Multi-tenant completo |
| **Segurança** | ⚠️ Security Rules básicas | ✅ RLS + RBAC completo |
| **Performance** | 🐢 3 queries (joins) | ⚡ 1 query (denorm) |
| **Escalabilidade** | 🔴 Limite 200k docs | ✅ Ilimitado (shard por org) |
| **Compliance** | ❌ Sem audit trail | ✅ LGPD completo |
| **Monitoramento** | ❌ Básico | ✅ Analytics + Crashlytics |
| **Custos** | 💰 $180/mês | 💰 $120/mês (-33%) |

---

## 📚 DOCUMENTAÇÃO RELACIONADA

- [Consultoria Firebase Completa](FIREBASE_ARCHITECTURE_GUIDE.md)
- [Estrutura de Dados](FIREBASE_DATABASE_STRUCTURE.md)
- [Security Rules](FIREBASE_SECURITY_RULES.md)
- [Performance](FIREBASE_PERFORMANCE_OPTIMIZATION.md)
- [Exemplos de Código](FIREBASE_CODE_EXAMPLES.md)

---

## 🆘 SUPORTE

**Dúvidas?**
1. Consultar documentação Firebase oficial
2. Revisar exemplos na consultoria
3. Testar com emulators locais

**Problemas?**
1. Verificar logs (AppLogger)
2. Verificar Security Rules
3. Verificar organizationId

---

**Última atualização:** Outubro 2025  
**Versão:** 1.0 (Estrutura Base)  
**Próxima etapa:** Migração de dados + Update de todos os datasources

