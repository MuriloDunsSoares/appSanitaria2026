# 🎨 FIREBASE - DIAGRAMAS DE ARQUITETURA

**Parte da:** [Consultoria Firebase](FIREBASE_ARCHITECTURE_GUIDE.md)  
**Foco:** Visualização da arquitetura proposta

---

## 📋 ÍNDICE

1. [Arquitetura Geral](#arquitetura-geral)
2. [Estrutura Firestore Multi-Tenant](#estrutura-firestore-multi-tenant)
3. [Fluxo de Autenticação](#fluxo-de-autenticação)
4. [Fluxo de Criação de Contrato](#fluxo-de-criação-de-contrato)
5. [Fluxo de Chat em Tempo Real](#fluxo-de-chat-em-tempo-real)
6. [Backup e Recovery](#backup-e-recovery)
7. [Segurança - Camadas](#segurança---camadas)

---

## 1. ARQUITETURA GERAL

```
┌──────────────────────────────────────────────────────────────────────┐
│                          CLIENTE (Flutter App)                       │
│                                                                      │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐       │
│  │  Presentation  │  │   Domain       │  │     Data       │       │
│  │   (Screens)    │  │  (Entities)    │  │ (Datasources)  │       │
│  │                │  │                │  │                │       │
│  │ • Widgets      │  │ • ContractEnt  │  │ • Firestore    │       │
│  │ • Providers    │  │ • ProfEnt      │  │ • Storage      │       │
│  │ • State Mgmt   │  │ • MessageEnt   │  │ • Auth         │       │
│  └────────┬───────┘  └────────┬───────┘  └────────┬───────┘       │
│           │                   │                   │                │
│           └───────────────────┼───────────────────┘                │
│                               │                                    │
└───────────────────────────────┼────────────────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │    INTERNET (HTTPS)    │
                    └───────────┬───────────┘
                                │
┌───────────────────────────────┼────────────────────────────────────┐
│                          FIREBASE BACKEND                          │
│                               │                                    │
│  ┌────────────────────────────┴───────────────────────────┐       │
│  │                   FIREBASE AUTH                         │       │
│  │  • Email/Password                                       │       │
│  │  • Google Sign-In                                       │       │
│  │  • JWT Tokens                                           │       │
│  └────────────────────┬────────────────────────────────────┘       │
│                       │                                            │
│  ┌────────────────────┴────────────────────────────────────┐       │
│  │              FIRESTORE (NoSQL Database)                 │       │
│  │                                                          │       │
│  │  organizations/{orgId}/                                 │       │
│  │    ├─ users/        ← Subcollection                    │       │
│  │    ├─ professionals/                                    │       │
│  │    ├─ contracts/                                        │       │
│  │    ├─ messages/                                         │       │
│  │    └─ reviews/                                          │       │
│  │                                                          │       │
│  │  • Multi-tenant Isolation                               │       │
│  │  • Row-Level Security                                   │       │
│  │  • Real-time Sync                                       │       │
│  │  • Offline Support                                      │       │
│  └────────────────────┬────────────────────────────────────┘       │
│                       │                                            │
│  ┌────────────────────┴────────────────────────────────────┐       │
│  │              CLOUD STORAGE (Files)                      │       │
│  │                                                          │       │
│  │  profiles/{userId}/photo.jpg                            │       │
│  │  documents/{contractId}/contract.pdf                    │       │
│  │                                                          │       │
│  │  • Multi-region Replication                             │       │
│  │  • CDN (Fast Downloads)                                 │       │
│  │  • Automatic Thumbnails                                 │       │
│  └────────────────────┬────────────────────────────────────┘       │
│                       │                                            │
│  ┌────────────────────┴────────────────────────────────────┐       │
│  │            CLOUD FUNCTIONS (Serverless)                 │       │
│  │                                                          │       │
│  │  • onContractCreate  → Send notifications               │       │
│  │  • onReviewCreate    → Update ratings                   │       │
│  │  • scheduledBackup   → Daily backups                    │       │
│  │  • deleteUserData    → LGPD compliance                  │       │
│  └────────────────────┬────────────────────────────────────┘       │
│                       │                                            │
│  ┌────────────────────┴────────────────────────────────────┐       │
│  │          MONITORING & OBSERVABILITY                     │       │
│  │                                                          │       │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │       │
│  │  │ Performance │ │ Crashlytics │ │  Analytics  │      │       │
│  │  │  (Traces)   │ │   (Errors)  │ │  (Events)   │      │       │
│  │  └─────────────┘ └─────────────┘ └─────────────┘      │       │
│  │                                                          │       │
│  │  ┌─────────────┐ ┌─────────────┐                       │       │
│  │  │   Logging   │ │   Alerts    │                       │       │
│  │  │(Stackdriver)│ │ (PagerDuty) │                       │       │
│  │  └─────────────┘ └─────────────┘                       │       │
│  └────────────────────────────────────────────────────────┘       │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## 2. ESTRUTURA FIRESTORE MULTI-TENANT

```
firestore/
│
├─ organizations/                           ← ROOT COLLECTION
│  │
│  ├─ {org_001}/                           ← ORGANIZATION DOCUMENT
│  │  │
│  │  │── name: "Hospital ABC"
│  │  │── plan: "enterprise"
│  │  │── maxUsers: 1000
│  │  │── createdAt: 2025-01-01
│  │  │
│  │  ├─ users/                            ← SUBCOLLECTION (Isolated)
│  │  │  ├─ {user_001}
│  │  │  │  ├─ email: "joao@hospital.com"
│  │  │  │  ├─ name: "João Silva"
│  │  │  │  ├─ role: "admin"
│  │  │  │  └─ organizationId: "org_001"   ← Redundant for queries
│  │  │  │
│  │  │  ├─ {user_002}
│  │  │  │  ├─ email: "maria@hospital.com"
│  │  │  │  ├─ name: "Maria Santos"
│  │  │  │  ├─ role: "professional"
│  │  │  │  └─ organizationId: "org_001"
│  │  │  │
│  │  │  └─ ...
│  │  │
│  │  ├─ professionals/                    ← SUBCOLLECTION
│  │  │  ├─ {prof_001}
│  │  │  │  ├─ userId: "user_002"         ← Link to users/
│  │  │  │  ├─ name: "Maria Santos"       ← DENORMALIZED
│  │  │  │  ├─ specialty: "Cuidador"
│  │  │  │  ├─ rating: 4.8                ← DENORMALIZED (aggregated)
│  │  │  │  ├─ reviewCount: 23            ← DENORMALIZED
│  │  │  │  └─ organizationId: "org_001"
│  │  │  │
│  │  │  └─ ...
│  │  │
│  │  ├─ contracts/                        ← SUBCOLLECTION
│  │  │  ├─ {contract_001}
│  │  │  │  ├─ patientId: "user_003"
│  │  │  │  ├─ professionalId: "prof_001"
│  │  │  │  ├─ patientName: "José Costa"  ← DENORMALIZED
│  │  │  │  ├─ profName: "Maria Santos"   ← DENORMALIZED
│  │  │  │  ├─ status: "active"
│  │  │  │  ├─ totalValue: 2500.00
│  │  │  │  ├─ createdAt: 2025-10-01
│  │  │  │  └─ organizationId: "org_001"
│  │  │  │
│  │  │  └─ ...
│  │  │
│  │  ├─ messages/                         ← SUBCOLLECTION (Flat)
│  │  │  ├─ {msg_001}
│  │  │  │  ├─ conversationId: "conv_user_003_user_002"
│  │  │  │  ├─ senderId: "user_003"
│  │  │  │  ├─ receiverId: "user_002"
│  │  │  │  ├─ text: "Oi, tudo bem?"
│  │  │  │  ├─ timestamp: 2025-10-13 10:30
│  │  │  │  ├─ isRead: false
│  │  │  │  └─ organizationId: "org_001"
│  │  │  │
│  │  │  └─ ...
│  │  │
│  │  ├─ conversations/                    ← SUBCOLLECTION (Aggregates)
│  │  │  ├─ {conv_user_003_user_002}
│  │  │  │  ├─ participants: ["user_003", "user_002"]
│  │  │  │  ├─ lastMessage: {            ← DENORMALIZED
│  │  │  │  │    text: "Oi, tudo bem?",
│  │  │  │  │    senderId: "user_003",
│  │  │  │  │    timestamp: 2025-10-13 10:30
│  │  │  │  │  }
│  │  │  │  ├─ unreadCount: {
│  │  │  │  │    "user_003": 0,
│  │  │  │  │    "user_002": 1
│  │  │  │  │  }
│  │  │  │  └─ updatedAt: 2025-10-13 10:30
│  │  │  │
│  │  │  └─ ...
│  │  │
│  │  └─ reviews/                          ← SUBCOLLECTION
│  │     ├─ {review_001}
│  │     │  ├─ professionalId: "prof_001"
│  │     │  ├─ patientId: "user_003"
│  │     │  ├─ patientName: "José Costa"  ← DENORMALIZED
│  │     │  ├─ rating: 5.0
│  │     │  ├─ comment: "Excelente!"
│  │     │  └─ createdAt: 2025-10-05
│  │     │
│  │     └─ ...
│  │
│  ├─ {org_002}/                           ← ANOTHER ORGANIZATION (Isolated)
│  │  │
│  │  │── name: "Clínica XYZ"
│  │  │
│  │  ├─ users/                            ← Completely ISOLATED from org_001
│  │  │  └─ ...
│  │  │
│  │  ├─ professionals/
│  │  │  └─ ...
│  │  │
│  │  └─ ...
│  │
│  └─ ...
│
├─ userProfiles/                            ← GLOBAL COLLECTION (Auth lookup)
│  ├─ {user_001}
│  │  ├─ email: "joao@hospital.com"
│  │  ├─ organizationId: "org_001"         ← Link to tenant
│  │  ├─ role: "admin"
│  │  ├─ status: "active"
│  │  └─ lastLogin: 2025-10-13 09:00
│  │
│  ├─ {user_002}
│  │  ├─ email: "maria@hospital.com"
│  │  ├─ organizationId: "org_001"
│  │  ├─ role: "professional"
│  │  └─ status: "active"
│  │
│  └─ ...
│
└─ auditLogs/                               ← GLOBAL COLLECTION (Compliance)
   ├─ {log_001}
   │  ├─ organizationId: "org_001"
   │  ├─ userId: "user_001"
   │  ├─ action: "contract_created"
   │  ├─ resource: "contract_001"
   │  ├─ timestamp: 2025-10-13 10:00
   │  └─ ipAddress: "192.168.1.100"
   │
   └─ ...


SECURITY BENEFITS:
✅ Organizations COMPLETELY isolated
✅ Query within org only: /organizations/{orgId}/users
✅ Security Rules: if isSameOrg(orgId)
✅ Backup per organization possible
✅ LGPD compliant (data segregation)
```

---

## 3. FLUXO DE AUTENTICAÇÃO

```
┌─────────────┐
│  FLUTTER    │
│    APP      │
└──────┬──────┘
       │
       │ 1. User enters email/password
       │
       ▼
┌──────────────────────────────────────────┐
│  FirebaseAuth.signInWithEmailAndPassword │
└──────┬───────────────────────────────────┘
       │
       │ 2. HTTPS POST → Firebase Auth
       │
       ▼
┌──────────────────────┐
│   FIREBASE AUTH      │
│                      │
│  ✓ Validate password │
│  ✓ Generate JWT      │
│  ✓ Return token      │
└──────┬───────────────┘
       │
       │ 3. JWT Token (uid, email)
       │
       ▼
┌──────────────────────────────────────────┐
│  APP: Get user data from Firestore       │
└──────┬───────────────────────────────────┘
       │
       │ 4. Query: userProfiles/{uid}
       │
       ▼
┌──────────────────────┐
│   FIRESTORE          │
│                      │
│  userProfiles/       │
│    └─ {uid}          │
│       ├─ orgId       │
│       ├─ role        │
│       └─ status      │
└──────┬───────────────┘
       │
       │ 5. User data (organizationId, role)
       │
       ▼
┌──────────────────────────────────────────┐
│  APP: Cache user + redirect to home      │
│                                           │
│  • Save to Provider                       │
│  • Navigate based on role                 │
│  • Setup FCM token                        │
└───────────────────────────────────────────┘


SECURITY LAYERS:
┌────────────────────────────────────────────┐
│ 1. Firebase Auth (JWT validation)         │
├────────────────────────────────────────────┤
│ 2. Security Rules (RLS check)             │
├────────────────────────────────────────────┤
│ 3. userProfiles (organizationId lookup)   │
├────────────────────────────────────────────┤
│ 4. App Logic (role-based UI)              │
└────────────────────────────────────────────┘
```

---

## 4. FLUXO DE CRIAÇÃO DE CONTRATO

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                                  │
└────────┬────────────────────────────────────────────────────────────┘
         │
         │ 1. User fills contract form
         │    (professional, date, value)
         │
         ▼
┌────────────────────────────────────────────────────────────────────┐
│  ContractsProvider.createContract()                                │
└────────┬───────────────────────────────────────────────────────────┘
         │
         │ 2. ContractEntity → Repository
         │
         ▼
┌────────────────────────────────────────────────────────────────────┐
│  ContractsRepositoryImpl.createContract()                          │
└────────┬───────────────────────────────────────────────────────────┘
         │
         │ 3. Entity → Map → DataSource
         │
         ▼
┌────────────────────────────────────────────────────────────────────┐
│  ContractsFirestoreDataSource.createContract()                     │
└────────┬───────────────────────────────────────────────────────────┘
         │
         │ 4. Firestore.collection().add()
         │    {
         │      patientId: "user_003",
         │      professionalId: "prof_001",
         │      patientName: "José Costa",      ← DENORMALIZED
         │      profName: "Maria Santos",       ← DENORMALIZED
         │      status: "pending",
         │      totalValue: 2500.00,
         │      createdAt: serverTimestamp()
         │    }
         │
         ▼
┌────────────────────────────────────────────────────────────────────┐
│                         FIRESTORE                                  │
│                                                                    │
│  organizations/{orgId}/contracts/{contractId}                     │
│                                                                    │
│  ✓ Security Rules validate:                                       │
│    - User is authenticated                                         │
│    - User belongs to organization                                  │
│    - patientId matches request.auth.uid                           │
│    - status == "pending"                                           │
│                                                                    │
│  ✓ Document created                                               │
└────────┬───────────────────────────────────────────────────────────┘
         │
         │ 5. onCreate Trigger fired
         │
         ▼
┌────────────────────────────────────────────────────────────────────┐
│                    CLOUD FUNCTION                                  │
│                                                                    │
│  functions.firestore                                               │
│    .document('organizations/{orgId}/contracts/{contractId}')      │
│    .onCreate(async (snap, context) => {                           │
│                                                                    │
│      const contract = snap.data();                                │
│                                                                    │
│      // A) Send notification to professional                      │
│      await sendNotification(                                       │
│        contract.professionalId,                                    │
│        "Novo Contrato!",                                           │
│        `${contract.patientName} te contratou.`                    │
│      );                                                            │
│                                                                    │
│      // B) Create conversation                                    │
│      await createConversation(                                     │
│        orgId,                                                      │
│        contract.patientId,                                         │
│        contract.professionalId                                     │
│      );                                                            │
│                                                                    │
│      // C) Log audit trail                                        │
│      await logAction('contract_created', contract);               │
│                                                                    │
│    });                                                             │
└────────┬───────────────────────────────────────────────────────────┘
         │
         │ 6. Notification sent via FCM
         │
         ▼
┌────────────────────────────────────────────────────────────────────┐
│              PROFESSIONAL'S DEVICE (Push Notification)             │
│                                                                    │
│  🔔 Novo Contrato!                                                 │
│     José Costa te contratou.                                       │
└────────────────────────────────────────────────────────────────────┘


TIMELINE:
├─ t=0ms:    User submits form
├─ t=50ms:   Flutter validates locally
├─ t=100ms:  Firestore write request sent
├─ t=150ms:  Security Rules validation
├─ t=200ms:  Document created ✅
├─ t=250ms:  onCreate trigger fired
├─ t=500ms:  Cloud Function executed
├─ t=700ms:  Notification sent ✅
└─ t=750ms:  User sees success message ✅

TOTAL: ~750ms (P99 <1s)
```

---

## 5. FLUXO DE CHAT EM TEMPO REAL

```
┌─────────────────┐                         ┌─────────────────┐
│  USER A (App)   │                         │  USER B (App)   │
│  (Sender)       │                         │  (Receiver)     │
└────────┬────────┘                         └────────┬────────┘
         │                                           │
         │ 1. Types message                          │
         │    "Olá, tudo bem?"                       │
         │                                           │
         ▼                                           │
┌─────────────────────────────┐                     │
│  MessagesProvider           │                     │
│  .sendMessage()             │                     │
└────────┬────────────────────┘                     │
         │                                           │
         │ 2. Create MessageEntity                   │
         │                                           │
         ▼                                           │
┌─────────────────────────────┐                     │
│  Firestore.collection()     │                     │
│  .add(message)              │                     │
└────────┬────────────────────┘                     │
         │                                           │
         │ 3. Write to Firestore                     │
         │                                           │
         ▼                                           │
┌────────────────────────────────────────────────────────┐
│                    FIRESTORE                           │
│                                                        │
│  organizations/{orgId}/messages/{msgId}               │
│  {                                                     │
│    conversationId: "conv_userA_userB",                │
│    senderId: "userA",                                 │
│    receiverId: "userB",                               │
│    text: "Olá, tudo bem?",                            │
│    timestamp: 2025-10-13 10:30:00,                    │
│    isRead: false                                      │
│  }                                                     │
│                                                        │
│  ✓ Security Rules validate                            │
│  ✓ Document created                                   │
└────────┬───────────────────────┬───────────────────────┘
         │                       │
         │ 4. Real-time          │ 5. Real-time
         │    snapshot to        │    snapshot to
         │    sender (confirm)   │    receiver (new msg)
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│  USER A         │     │  USER B         │
│                 │     │                 │
│  Message sent ✅│     │  🔔 New message │
│                 │     │  "Olá, tudo     │
│                 │     │   bem?"         │
└─────────────────┘     └────────┬────────┘
                                 │
                                 │ 6. User B opens chat
                                 │
                                 ▼
                        ┌─────────────────────────┐
                        │  Mark as read           │
                        │  .update(isRead: true)  │
                        └────────┬────────────────┘
                                 │
                                 ▼
                        ┌─────────────────────────┐
                        │     FIRESTORE           │
                        │  messages/{msgId}       │
                        │  { isRead: true }       │
                        └────────┬────────────────┘
                                 │
                                 │ 7. Real-time update
                                 │
                                 ▼
                        ┌─────────────────────────┐
                        │  USER A                 │
                        │  Message read ✓✓        │
                        └─────────────────────────┘


LATENCY:
├─ Send message:    50-100ms  (write)
├─ Receive message: 50-150ms  (snapshot)
└─ Mark as read:    50-100ms  (update)

TOTAL: ~200-350ms (real-time feel)


LISTENER LIFECYCLE:
┌──────────────────────────────────────────────────┐
│  ChatScreen (StatefulWidget)                     │
│                                                  │
│  initState() {                                   │
│    // Start listener                             │
│    _subscription = firestore                     │
│      .collection('messages')                     │
│      .where('conversationId', '==', convId)      │
│      .snapshots()                                │
│      .listen((snapshot) {                        │
│        setState(() { messages = ... });          │
│      });                                         │
│  }                                               │
│                                                  │
│  dispose() {                                     │
│    // Stop listener (important!)                 │
│    _subscription.cancel();                       │
│  }                                               │
└──────────────────────────────────────────────────┘

⚠️  IMPORTANT: Always cancel listeners in dispose()
    to avoid memory leaks and unnecessary reads!
```

---

## 6. BACKUP E RECOVERY

```
┌──────────────────────────────────────────────────────────────────────┐
│                          PRODUCTION FIRESTORE                        │
│                                                                      │
│  organizations/                                                      │
│    ├─ org_001/                                                       │
│    ├─ org_002/                                                       │
│    └─ ...                                                            │
│                                                                      │
│  userProfiles/                                                       │
│  auditLogs/                                                          │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │ Daily Backup (Automated)
                             │ via Cloud Function
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────────┐
│                   CLOUD SCHEDULER (Daily at 2 AM)                    │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │ Trigger
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────────┐
│                      CLOUD FUNCTION                                  │
│                                                                      │
│  exports.scheduledFirestoreExport = functions.pubsub                │
│    .schedule('every 24 hours')                                       │
│    .onRun(async (context) => {                                       │
│                                                                      │
│      const timestamp = new Date().toISOString().split('T')[0];      │
│      const bucket = `gs://PROJECT-firestore-backups/${timestamp}`;  │
│                                                                      │
│      await client.exportDocuments({                                  │
│        name: databaseName,                                           │
│        outputUriPrefix: bucket,                                      │
│        collectionIds: ['organizations', 'userProfiles', ...]        │
│      });                                                             │
│                                                                      │
│    });                                                               │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │ Export
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────────┐
│                      CLOUD STORAGE (Backups)                         │
│                                                                      │
│  PROJECT-firestore-backups/                                         │
│    ├─ 2025-10-01/                                                    │
│    │  ├─ all_namespaces/                                             │
│    │  │  └─ kind_organizations/                                      │
│    │  │     └─ output-0                                              │
│    │  └─ metadata                                                    │
│    │                                                                 │
│    ├─ 2025-10-02/                                                    │
│    ├─ 2025-10-03/                                                    │
│    └─ ...                                                            │
│                                                                      │
│  ✓ Retention: 30 days (auto-delete old backups)                    │
│  ✓ Lifecycle: Move to Coldline after 7 days                        │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │ In case of disaster...
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    DISASTER SCENARIO                                 │
│                                                                      │
│  ⚠️  Firestore database corrupted/deleted                           │
│  ⚠️  User: "Help! All data is gone!"                                │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │ Recovery Process
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    RECOVERY STEPS                                    │
│                                                                      │
│  1. Identify last good backup (e.g., 2025-10-12)                   │
│                                                                      │
│  2. Run import command:                                              │
│                                                                      │
│     gcloud firestore import \                                        │
│       gs://PROJECT-firestore-backups/2025-10-12 \                   │
│       --database='(default)'                                         │
│                                                                      │
│  3. Wait for import to complete (~1-4 hours for GB of data)        │
│                                                                      │
│  4. Validate data integrity:                                         │
│     - Check document counts                                          │
│     - Test critical queries                                          │
│     - Verify user logins                                             │
│                                                                      │
│  5. Enable app (disable maintenance mode)                            │
│                                                                      │
│  6. Monitor for errors                                               │
│                                                                      │
│  7. Post-mortem: Document incident                                   │
└──────────────────────────────────────────────────────────────────────┘


BACKUP STRATEGY (3-2-1 Rule):
┌────────────────────────────────────────┐
│  3 Copies:                             │
│    1. Production Firestore (primary)   │
│    2. Daily backup (Cloud Storage)     │
│    3. Weekly backup (different region) │
├────────────────────────────────────────┤
│  2 Different Media:                    │
│    1. Firestore (NoSQL)                │
│    2. Cloud Storage (files)            │
├────────────────────────────────────────┤
│  1 Off-site:                           │
│    • Multi-region replication          │
│    • southamerica-east1 (backup)       │
└────────────────────────────────────────┘


RETENTION TIMELINE:
┌─────────────────────────────────────────────────────┐
│ Day 0-7:   Daily backups (STANDARD storage)         │
│ Day 7-30:  Daily backups (NEARLINE storage)         │
│ Day 30+:   Weekly backups (COLDLINE storage)        │
│ Year 5+:   Delete (LGPD compliance)                 │
└─────────────────────────────────────────────────────┘
```

---

## 7. SEGURANÇA - CAMADAS

```
┌──────────────────────────────────────────────────────────────────────┐
│                         CLIENT (Flutter App)                         │
│                                                                      │
│  Layer 1: CLIENT-SIDE VALIDATION                                    │
│  ├─ Form validation (email, required fields)                        │
│  ├─ Business logic (can user create contract?)                      │
│  └─ UI permissions (hide admin buttons)                             │
│                                                                      │
│  ⚠️  UNTRUSTED - Can be bypassed by attacker                        │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │ HTTPS Request
                             │ (JWT Token in header)
                             │
                             ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         FIREBASE BACKEND                             │
│                                                                      │
│  Layer 2: AUTHENTICATION                                            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Firebase Auth                                             │    │
│  │  ├─ Validate JWT signature                                 │    │
│  │  ├─ Check token expiration                                 │    │
│  │  ├─ Extract uid, email                                     │    │
│  │  └─ Result: request.auth.uid = "user_123"                 │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ✅ TRUSTED - Server-side validation                                │
│                                                                      │
│  ↓                                                                   │
│                                                                      │
│  Layer 3: AUTHORIZATION (Security Rules)                            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Firestore Security Rules                                  │    │
│  │                                                             │    │
│  │  match /organizations/{orgId}/contracts/{contractId} {     │    │
│  │                                                             │    │
│  │    // Check 1: User is authenticated                       │    │
│  │    allow read: if request.auth != null                     │    │
│  │                                                             │    │
│  │    // Check 2: User belongs to organization                │    │
│  │    && isSameOrg(orgId)                                     │    │
│  │                                                             │    │
│  │    // Check 3: User is involved in contract                │    │
│  │    && (resource.data.patientId == request.auth.uid ||      │    │
│  │        resource.data.professionalId == request.auth.uid || │    │
│  │        hasRole('admin'));                                  │    │
│  │                                                             │    │
│  │  }                                                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ✅ TRUSTED - Row-Level Security (RLS)                              │
│                                                                      │
│  ↓                                                                   │
│                                                                      │
│  Layer 4: DATA VALIDATION (Security Rules)                          │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Firestore Security Rules (Validation)                     │    │
│  │                                                             │    │
│  │  allow create: if                                           │    │
│  │    // Required fields                                       │    │
│  │    request.resource.data.keys().hasAll([                   │    │
│  │      'patientId', 'professionalId', 'totalValue'           │    │
│  │    ])                                                       │    │
│  │    // Type validation                                       │    │
│  │    && request.resource.data.totalValue is number           │    │
│  │    // Range validation                                      │    │
│  │    && request.resource.data.totalValue > 0                 │    │
│  │    // Status validation                                     │    │
│  │    && request.resource.data.status == 'pending';           │    │
│  │                                                             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ✅ TRUSTED - Server-side validation                                │
│                                                                      │
│  ↓                                                                   │
│                                                                      │
│  Layer 5: BUSINESS LOGIC (Cloud Functions)                          │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Cloud Functions (onCreate/onUpdate triggers)              │    │
│  │                                                             │    │
│  │  • Complex validations (e.g., can't review same prof 2x)  │    │
│  │  • Rate limiting (max 100 msgs/min)                        │    │
│  │  • Audit logging (track all changes)                       │    │
│  │  • Aggregations (update ratings)                           │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ✅ TRUSTED - Server-side business logic                            │
│                                                                      │
│  ↓                                                                   │
│                                                                      │
│  Layer 6: AUDIT & MONITORING                                        │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  • Cloud Logging (all requests logged)                     │    │
│  │  • Crashlytics (errors tracked)                            │    │
│  │  • Performance Monitoring (latency tracked)                │    │
│  │  • Alerting (anomalies detected)                           │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ✅ TRUSTED - Observability                                         │
└──────────────────────────────────────────────────────────────────────┘


DEFENSE IN DEPTH (Multiple Layers):
┌─────────────────────────────────────────────────────┐
│ If Layer 1 is bypassed (client hacked)              │
│   → Layer 2 (Auth) blocks unauthenticated requests  │
│                                                     │
│ If Layer 2 is bypassed (stolen token)               │
│   → Layer 3 (RLS) blocks unauthorized access        │
│                                                     │
│ If Layer 3 is bypassed (somehow)                    │
│   → Layer 4 (Validation) rejects invalid data       │
│                                                     │
│ If Layer 4 is bypassed (valid but malicious data)   │
│   → Layer 5 (Functions) catches business logic      │
│                                                     │
│ All layers logged in Layer 6 (Audit)                │
│   → Post-mortem analysis possible                   │
└─────────────────────────────────────────────────────┘
```

---

## 📚 CONCLUSÃO

Estes diagramas ilustram:

✅ **Arquitetura multi-tenant** isolada  
✅ **Fluxos end-to-end** (auth, CRUD, real-time)  
✅ **Segurança em camadas** (defense in depth)  
✅ **Backup e disaster recovery** (3-2-1 rule)  
✅ **Performance** (denormalização, caching)  
✅ **Observabilidade** (monitoring, logging)

**Use estes diagramas como referência durante a implementação.**

---

**Última atualização:** Outubro 2025  
**Versão:** 1.0

