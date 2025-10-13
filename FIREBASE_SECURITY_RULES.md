# 🔐 FIREBASE - SECURITY RULES

**Parte da:** [Consultoria Firebase](FIREBASE_ARCHITECTURE_GUIDE.md)  
**Foco:** Segurança, autenticação e autorização em escala

---

## 📋 ÍNDICE

1. [Fundamentos de Security Rules](#fundamentos-de-security-rules)
2. [Row-Level Security (RLS)](#row-level-security-rls)
3. [RBAC vs ABAC](#rbac-vs-abac)
4. [Rules Completas - Multi-tenant](#rules-completas---multi-tenant)
5. [Validação de Dados](#validação-de-dados)
6. [Proteção Contra Ataques](#proteção-contra-ataques)
7. [Compliance LGPD/GDPR](#compliance-lgpdgdpr)
8. [Rate Limiting](#rate-limiting)
9. [Testing Security Rules](#testing-security-rules)
10. [Best Practices](#best-practices)

---

## 1. FUNDAMENTOS DE SECURITY RULES

### **Princípio Básico**

> **"Deny by default, allow explicitly"**

```javascript
// ❌ NUNCA faça isso em produção!
allow read, write: if true;

// ✅ Sempre valide autenticação e autorização
allow read: if isAuthenticated() && isSameOrg();
allow write: if isAuthenticated() && hasRole('admin');
```

---

### **Conceitos Fundamentais**

#### **1. request vs resource**

```javascript
// request = dados NOVOS sendo enviados
request.resource.data.email    // Email no novo documento
request.auth.uid               // ID do usuário autenticado
request.time                   // Timestamp da request

// resource = dados EXISTENTES no banco
resource.data.email            // Email do documento atual
resource.id                    // ID do documento
```

#### **2. Tipos de Operação**

```javascript
// Granular
allow read: if ...     // get + list
allow write: if ...    // create + update + delete

// Específico (RECOMENDADO)
allow get: if ...      // Ler 1 documento
allow list: if ...     // Listar múltiplos
allow create: if ...   // Criar novo
allow update: if ...   // Atualizar existente
allow delete: if ...   // Deletar
```

---

### **3. Match Paths**

```javascript
// Match exato
match /users/{userId} {
  // Aplica para: /users/abc123
}

// Match recursivo
match /organizations/{orgId}/{document=**} {
  // Aplica para TODAS as subcollections
  // /organizations/org1/users/user1
  // /organizations/org1/contracts/contract1
  // /organizations/org1/messages/msg1/attachments/att1
}

// Match com condição
match /users/{userId} {
  allow read: if userId == request.auth.uid; // Apenas próprio usuário
}
```

---

## 2. ROW-LEVEL SECURITY (RLS)

### **O que é RLS?**

**Filtrar dados no nível de LINHA (documento), não apenas collection.**

#### ❌ **Sem RLS (INSEGURO)**
```javascript
match /contracts/{contractId} {
  // Qualquer usuário autenticado pode ler TODOS os contratos
  allow read: if request.auth != null;
}

// Usuário A pode ver contratos do Usuário B! 😱
```

#### ✅ **Com RLS (SEGURO)**
```javascript
match /contracts/{contractId} {
  // Usuário só vê contratos onde ele está envolvido
  allow read: if request.auth.uid == resource.data.patientId ||
                 request.auth.uid == resource.data.professionalId;
}

// Usuário A NUNCA vê contratos do Usuário B ✅
```

---

### **RLS Multi-tenant**

```javascript
function getUserOrg() {
  return get(/databases/$(database)/documents/userProfiles/$(request.auth.uid)).data.organizationId;
}

function isSameOrg(orgId) {
  return getUserOrg() == orgId;
}

match /organizations/{orgId}/contracts/{contractId} {
  // Apenas usuários da MESMA organização
  allow read: if isSameOrg(orgId);
  
  // E que estejam ENVOLVIDOS no contrato
  allow read: if isSameOrg(orgId) && 
                 (resource.data.patientId == request.auth.uid ||
                  resource.data.professionalId == request.auth.uid);
}
```

---

## 3. RBAC vs ABAC

### **RBAC (Role-Based Access Control)**

**Acesso baseado em ROLE do usuário.**

```javascript
function getUserData() {
  return get(/databases/$(database)/documents/userProfiles/$(request.auth.uid)).data;
}

function hasRole(role) {
  return getUserData().role == role;
}

match /organizations/{orgId}/users/{userId} {
  // Admin pode tudo
  allow read, write: if hasRole('admin');
  
  // Supervisor pode ler
  allow read: if hasRole('supervisor');
  
  // User pode ler apenas próprio perfil
  allow read: if request.auth.uid == userId;
}
```

**Roles comuns:**
- `admin` - Full access
- `supervisor` - Read all, write limited
- `tech` - Read/write próprios recursos
- `client` - Read only

---

### **ABAC (Attribute-Based Access Control)**

**Acesso baseado em ATRIBUTOS dinâmicos.**

```javascript
function canAccessContract(contractData) {
  let user = getUserData();
  
  // Atributos combinados
  return user.organizationId == contractData.organizationId &&  // Mesma org
         user.department == contractData.department &&          // Mesmo dept
         (user.role == 'admin' ||                               // Admin OU
          user.id == contractData.assignedTo);                  // Assignado
}

match /organizations/{orgId}/contracts/{contractId} {
  allow read: if canAccessContract(resource.data);
}
```

**Quando usar cada um:**
- **RBAC:** Regras simples, hierarquia clara
- **ABAC:** Regras complexas, multi-fator, dinâmicas

---

## 4. RULES COMPLETAS - MULTI-TENANT

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ==========================================
    // HELPER FUNCTIONS
    // ==========================================
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function getUserProfile() {
      return get(/databases/$(database)/documents/userProfiles/$(request.auth.uid)).data;
    }
    
    function getOrgId() {
      return getUserProfile().organizationId;
    }
    
    function getUserRole() {
      return getUserProfile().role;
    }
    
    function hasRole(role) {
      return isAuthenticated() && getUserRole() == role;
    }
    
    function isSameOrg(orgId) {
      return isAuthenticated() && getOrgId() == orgId;
    }
    
    function isActive() {
      return getUserProfile().status == 'active';
    }
    
    // Validação de email
    function isValidEmail(email) {
      return email is string && 
             email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
    }
    
    // Validação de timestamp
    function isRecentTimestamp(timestamp) {
      // Aceita timestamps até 5 minutos no futuro (clock skew)
      return timestamp is timestamp && 
             timestamp <= request.time + duration.value(5, 'm');
    }
    
    // ==========================================
    // ORGANIZATIONS (Root collection)
    // ==========================================
    
    match /organizations/{orgId} {
      // Ler organização: apenas membros
      allow get: if isSameOrg(orgId) && isActive();
      
      // Listar organizações: NEGADO (enumeration attack)
      allow list: if false;
      
      // Criar organização: NEGADO (usar Cloud Function)
      allow create: if false;
      
      // Atualizar organização: apenas admin
      allow update: if isSameOrg(orgId) && hasRole('admin');
      
      // Deletar: NEGADO (usar Cloud Function para soft delete)
      allow delete: if false;
      
      // ==========================================
      // USERS (Subcollection)
      // ==========================================
      
      match /users/{userId} {
        // Ler: mesma org
        allow get: if isSameOrg(orgId) && isActive();
        
        // Listar: mesma org (com limite)
        allow list: if isSameOrg(orgId) && 
                       isActive() &&
                       request.query.limit <= 100;
        
        // Criar: apenas admin
        allow create: if isSameOrg(orgId) && 
                         hasRole('admin') &&
                         isValidEmail(request.resource.data.email) &&
                         request.resource.data.organizationId == orgId;
        
        // Atualizar: admin OU próprio usuário (campos limitados)
        allow update: if isSameOrg(orgId) && 
                         (hasRole('admin') || 
                          (request.auth.uid == userId && 
                           onlyAllowedFieldsChanged(['name', 'phone', 'avatar'])));
        
        // Deletar: apenas admin (soft delete recomendado)
        allow delete: if isSameOrg(orgId) && hasRole('admin');
      }
      
      // ==========================================
      // PATIENTS (Subcollection)
      // ==========================================
      
      match /patients/{patientId} {
        // Ler: mesma org
        allow get: if isSameOrg(orgId) && isActive();
        
        // Listar: mesma org + profissionais podem listar
        allow list: if isSameOrg(orgId) && 
                       isActive() &&
                       (hasRole('admin') || hasRole('professional'));
        
        // Criar: admin ou próprio usuário
        allow create: if isSameOrg(orgId) && 
                         (hasRole('admin') || 
                          request.resource.data.userId == request.auth.uid);
        
        // Atualizar: admin ou próprio paciente
        allow update: if isSameOrg(orgId) && 
                         (hasRole('admin') || 
                          resource.data.userId == request.auth.uid);
        
        // Deletar: apenas admin
        allow delete: if isSameOrg(orgId) && hasRole('admin');
      }
      
      // ==========================================
      // PROFESSIONALS (Subcollection)
      // ==========================================
      
      match /professionals/{profId} {
        // Ler: mesma org (profissionais são públicos dentro da org)
        allow get: if isSameOrg(orgId) && isActive();
        
        // Listar: mesma org (pacientes buscam profissionais)
        allow list: if isSameOrg(orgId) && 
                       isActive() &&
                       request.query.limit <= 50;
        
        // Criar: admin ou próprio usuário
        allow create: if isSameOrg(orgId) && 
                         (hasRole('admin') || 
                          request.resource.data.userId == request.auth.uid) &&
                         validateProfessionalData(request.resource.data);
        
        // Atualizar: admin ou próprio profissional
        allow update: if isSameOrg(orgId) && 
                         (hasRole('admin') || 
                          resource.data.userId == request.auth.uid);
        
        // Deletar: apenas admin
        allow delete: if isSameOrg(orgId) && hasRole('admin');
      }
      
      // ==========================================
      // CONTRACTS (Subcollection)
      // ==========================================
      
      match /contracts/{contractId} {
        // Ler: envolvido no contrato OU admin
        allow get: if isSameOrg(orgId) && 
                      isActive() &&
                      (resource.data.patientId == request.auth.uid ||
                       resource.data.professionalId == request.auth.uid ||
                       hasRole('admin'));
        
        // Listar: apenas próprios contratos
        allow list: if isSameOrg(orgId) && 
                       isActive() &&
                       (request.query.filters.patientId == request.auth.uid ||
                        request.query.filters.professionalId == request.auth.uid ||
                        hasRole('admin'));
        
        // Criar: apenas paciente (para si mesmo)
        allow create: if isSameOrg(orgId) && 
                         isActive() &&
                         request.resource.data.patientId == request.auth.uid &&
                         request.resource.data.status == 'pending' &&
                         validateContractData(request.resource.data);
        
        // Atualizar: validar transição de status
        allow update: if isSameOrg(orgId) && 
                         isActive() &&
                         (resource.data.patientId == request.auth.uid ||
                          resource.data.professionalId == request.auth.uid ||
                          hasRole('admin')) &&
                         validateStatusTransition(resource.data.status, 
                                                  request.resource.data.status);
        
        // Deletar: NEGADO (usar soft delete via update)
        allow delete: if false;
      }
      
      // ==========================================
      // CONVERSATIONS (Subcollection)
      // ==========================================
      
      match /conversations/{conversationId} {
        // Ler: participante da conversa
        allow get: if isSameOrg(orgId) && 
                      isActive() &&
                      request.auth.uid in resource.data.participants;
        
        // Listar: apenas próprias conversas
        allow list: if isSameOrg(orgId) && 
                       isActive() &&
                       request.auth.uid in resource.data.participants;
        
        // Criar: participantes válidos
        allow create: if isSameOrg(orgId) && 
                         isActive() &&
                         request.auth.uid in request.resource.data.participants &&
                         request.resource.data.participants.size() == 2;
        
        // Atualizar: participante (apenas lastMessage, unreadCount)
        allow update: if isSameOrg(orgId) && 
                         isActive() &&
                         request.auth.uid in resource.data.participants &&
                         onlyAllowedFieldsChanged(['lastMessage', 'unreadCount', 'updatedAt']);
        
        // Deletar: NEGADO
        allow delete: if false;
      }
      
      // ==========================================
      // MESSAGES (Subcollection)
      // ==========================================
      
      match /messages/{messageId} {
        // Ler: remetente ou destinatário
        allow get: if isSameOrg(orgId) && 
                      isActive() &&
                      (resource.data.senderId == request.auth.uid ||
                       resource.data.receiverId == request.auth.uid);
        
        // Listar: mensagens de uma conversa onde é participante
        allow list: if isSameOrg(orgId) && 
                       isActive() &&
                       conversationHasParticipant(request.query.filters.conversationId, 
                                                  request.auth.uid);
        
        // Criar: apenas o sender
        allow create: if isSameOrg(orgId) && 
                         isActive() &&
                         request.resource.data.senderId == request.auth.uid &&
                         isRecentTimestamp(request.resource.data.timestamp) &&
                         validateMessageData(request.resource.data);
        
        // Atualizar: apenas marcar como lido (destinatário)
        allow update: if isSameOrg(orgId) && 
                         isActive() &&
                         resource.data.receiverId == request.auth.uid &&
                         onlyAllowedFieldsChanged(['isRead']);
        
        // Deletar: NEGADO (mensagens são imutáveis)
        allow delete: if false;
      }
      
      // ==========================================
      // REVIEWS (Subcollection)
      // ==========================================
      
      match /reviews/{reviewId} {
        // Ler: qualquer um da org (reviews são públicas)
        allow get: if isSameOrg(orgId) && isActive();
        
        // Listar: reviews de um profissional (público)
        allow list: if isSameOrg(orgId) && 
                       isActive() &&
                       request.query.limit <= 50;
        
        // Criar: apenas paciente (para profissionais que contratou)
        allow create: if isSameOrg(orgId) && 
                         isActive() &&
                         request.resource.data.patientId == request.auth.uid &&
                         hasActiveContract(request.resource.data.patientId, 
                                          request.resource.data.professionalId) &&
                         validateReviewData(request.resource.data);
        
        // Atualizar: próprio autor (dentro de 24h)
        allow update: if isSameOrg(orgId) && 
                         isActive() &&
                         resource.data.patientId == request.auth.uid &&
                         resource.data.createdAt > request.time - duration.value(24, 'h');
        
        // Deletar: admin ou autor
        allow delete: if isSameOrg(orgId) && 
                         (hasRole('admin') || 
                          resource.data.patientId == request.auth.uid);
      }
      
      // ==========================================
      // ACTIVITY LOGS (Subcollection)
      // ==========================================
      
      match /activityLogs/{logId} {
        // Ler: apenas admin
        allow read: if isSameOrg(orgId) && hasRole('admin');
        
        // Criar: qualquer usuário autenticado (auto-logging)
        allow create: if isSameOrg(orgId) && 
                         isActive() &&
                         request.resource.data.userId == request.auth.uid;
        
        // Atualizar/Deletar: NEGADO (logs são imutáveis)
        allow update, delete: if false;
      }
    }
    
    // ==========================================
    // USER PROFILES (Global collection)
    // ==========================================
    
    match /userProfiles/{userId} {
      // Ler: apenas próprio perfil
      allow get: if isAuthenticated() && request.auth.uid == userId;
      
      // Listar: NEGADO (enumeration attack)
      allow list: if false;
      
      // Criar: Cloud Function após signup
      allow create: if false;
      
      // Atualizar: próprio usuário (campos limitados)
      allow update: if isAuthenticated() && 
                       request.auth.uid == userId &&
                       onlyAllowedFieldsChanged(['lastLogin', 'fcmToken']);
      
      // Deletar: NEGADO (usar Cloud Function)
      allow delete: if false;
    }
    
    // ==========================================
    // AUDIT LOGS (Global collection)
    // ==========================================
    
    match /auditLogs/{logId} {
      // Ler: apenas admin da org
      allow read: if isAuthenticated() && 
                     hasRole('admin') &&
                     resource.data.organizationId == getOrgId();
      
      // Criar: Cloud Functions apenas
      allow create: if false;
      
      // Atualizar/Deletar: NEGADO (logs são imutáveis)
      allow update, delete: if false;
    }
    
    // ==========================================
    // VALIDATION FUNCTIONS
    // ==========================================
    
    function onlyAllowedFieldsChanged(allowedFields) {
      return request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(allowedFields);
    }
    
    function validateProfessionalData(data) {
      return data.keys().hasAll(['userId', 'especialidade', 'bio']) &&
             data.especialidade is string &&
             data.especialidade.size() > 0 &&
             data.bio.size() <= 500;
    }
    
    function validateContractData(data) {
      return data.keys().hasAll(['patientId', 'professionalId', 'totalValue']) &&
             data.totalValue is number &&
             data.totalValue > 0 &&
             data.status in ['pending', 'active', 'completed', 'cancelled'];
    }
    
    function validateStatusTransition(oldStatus, newStatus) {
      // pending → active, cancelled
      // active → completed, cancelled
      return (oldStatus == 'pending' && newStatus in ['active', 'cancelled']) ||
             (oldStatus == 'active' && newStatus in ['completed', 'cancelled']);
    }
    
    function validateMessageData(data) {
      return data.keys().hasAll(['senderId', 'receiverId', 'text']) &&
             data.text is string &&
             data.text.size() > 0 &&
             data.text.size() <= 5000;
    }
    
    function validateReviewData(data) {
      return data.keys().hasAll(['professionalId', 'patientId', 'rating']) &&
             data.rating is number &&
             data.rating >= 1.0 &&
             data.rating <= 5.0 &&
             (data.comment == null || data.comment.size() <= 1000);
    }
    
    function conversationHasParticipant(conversationId, userId) {
      return exists(/databases/$(database)/documents/conversations/$(conversationId)) &&
             userId in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
    }
    
    function hasActiveContract(patientId, professionalId) {
      // Verifica se existe contrato ativo/completed entre patient e prof
      // (Implementar via Cloud Function para performance)
      return true; // Placeholder
    }
  }
}
```

---

## 5. VALIDAÇÃO DE DADOS

### **Tipos de Validação**

#### **1. Tipo de Dados**
```javascript
data.email is string
data.age is int
data.rating is number
data.active is bool
data.createdAt is timestamp
data.tags is list
data.metadata is map
```

#### **2. Tamanho/Range**
```javascript
data.email.size() > 5
data.email.size() <= 100
data.age >= 18
data.age <= 120
data.rating >= 1.0 && data.rating <= 5.0
data.tags.size() <= 10
```

#### **3. Formato (Regex)**
```javascript
// Email
data.email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$')

// Telefone brasileiro
data.phone.matches('^\\(\\d{2}\\)\\s\\d{4,5}-\\d{4}$')

// CPF (apenas dígitos)
data.cpf.matches('^\\d{11}$')

// Slugs
data.slug.matches('^[a-z0-9-]+$')
```

#### **4. Campos Obrigatórios**
```javascript
// Tem TODOS os campos
data.keys().hasAll(['email', 'name', 'role'])

// Tem APENAS esses campos
data.keys().hasOnly(['email', 'name', 'role'])

// Tem ALGUM desses campos
data.keys().hasAny(['email', 'phone'])
```

#### **5. Valores Permitidos (Enum)**
```javascript
data.status in ['pending', 'active', 'completed', 'cancelled']
data.role in ['admin', 'supervisor', 'tech', 'client']
```

---

### **Validação Completa - Exemplo**

```javascript
function validateUserData(data) {
  return data.keys().hasAll(['email', 'name', 'role', 'organizationId']) &&
         
         // Email válido
         data.email is string &&
         data.email.size() >= 5 &&
         data.email.size() <= 100 &&
         data.email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$') &&
         
         // Nome válido
         data.name is string &&
         data.name.size() >= 2 &&
         data.name.size() <= 100 &&
         
         // Role válido
         data.role in ['admin', 'supervisor', 'tech', 'client'] &&
         
         // OrganizationId válido
         data.organizationId is string &&
         data.organizationId.size() > 0 &&
         
         // Telefone opcional, mas se existir deve ser válido
         (!data.keys().hasAny(['phone']) || 
          (data.phone is string && data.phone.matches('^\\(\\d{2}\\)\\s\\d{4,5}-\\d{4}$')));
}
```

---

## 6. PROTEÇÃO CONTRA ATAQUES

### **1. Enumeration Attack**

❌ **Vulnerável:**
```javascript
// Permite listar TODAS as organizações
match /organizations/{orgId} {
  allow list: if isAuthenticated();
}

// Atacante pode enumerar todas as orgs do sistema! 😱
```

✅ **Protegido:**
```javascript
// Permite apenas GET (1 documento específico)
match /organizations/{orgId} {
  allow get: if isSameOrg(orgId);
  allow list: if false; // NUNCA permitir list global
}
```

---

### **2. Mass Assignment**

❌ **Vulnerável:**
```javascript
// Permite atualizar QUALQUER campo
allow update: if request.auth.uid == userId;

// Atacante pode mudar role: admin! 😱
await db.doc('users/user123').update({
  name: 'Novo Nome',
  role: 'admin'  // INJEÇÃO!
});
```

✅ **Protegido:**
```javascript
// Permite apenas campos específicos
allow update: if request.auth.uid == userId &&
                 onlyAllowedFieldsChanged(['name', 'phone', 'avatar']);

function onlyAllowedFieldsChanged(allowedFields) {
  return request.resource.data.diff(resource.data).affectedKeys()
         .hasOnly(allowedFields);
}
```

---

### **3. Time-based Attack**

❌ **Vulnerável:**
```javascript
// Aceita qualquer timestamp
allow create: if request.resource.data.timestamp is timestamp;

// Atacante pode inserir timestamps do passado/futuro! 😱
```

✅ **Protegido:**
```javascript
// Força uso de serverTimestamp ou valida range
allow create: if request.resource.data.timestamp == request.time ||
                 (request.resource.data.timestamp > request.time - duration.value(1, 'm') &&
                  request.resource.data.timestamp <= request.time + duration.value(5, 'm'));
```

---

### **4. Document Size Attack**

❌ **Vulnerável:**
```javascript
// Aceita qualquer tamanho de texto
allow create: if request.resource.data.comment is string;

// Atacante envia 900KB de texto, estoura limite do documento! 😱
```

✅ **Protegido:**
```javascript
// Limita tamanho de campos
allow create: if request.resource.data.comment is string &&
                 request.resource.data.comment.size() <= 5000;
```

---

### **5. Privilege Escalation**

❌ **Vulnerável:**
```javascript
// Usuário pode criar conta com qualquer role
allow create: if isAuthenticated();

// Atacante cria conta admin! 😱
```

✅ **Protegido:**
```javascript
// Apenas admin pode criar contas
allow create: if hasRole('admin') &&
                 // E role do novo usuário não pode ser admin (exceto super-admin)
                 (request.resource.data.role != 'admin' || 
                  hasRole('super-admin'));
```

---

## 7. COMPLIANCE LGPD/GDPR

### **Requisitos Legais**

#### **1. Right to Access (Direito de Acesso)**

```javascript
// Usuário pode ler TODOS os seus dados
match /organizations/{orgId}/users/{userId} {
  allow get: if request.auth.uid == userId;
}

// Exportar dados (Cloud Function)
exports.exportUserData = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated');
  
  const userId = context.auth.uid;
  const orgId = context.auth.token.organizationId;
  
  // Buscar TODOS os dados do usuário
  const userData = await admin.firestore()
    .doc(`organizations/${orgId}/users/${userId}`).get();
  
  const contracts = await admin.firestore()
    .collection(`organizations/${orgId}/contracts`)
    .where('patientId', '==', userId)
    .get();
  
  const messages = await admin.firestore()
    .collection(`organizations/${orgId}/messages`)
    .where('senderId', '==', userId)
    .get();
  
  // Retornar JSON completo
  return {
    user: userData.data(),
    contracts: contracts.docs.map(d => d.data()),
    messages: messages.docs.map(d => d.data()),
  };
});
```

---

#### **2. Right to Deletion (Direito ao Esquecimento)**

```javascript
// Cloud Function para deletar TODOS os dados do usuário
exports.deleteUserAccount = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated');
  
  const userId = context.auth.uid;
  const orgId = context.auth.token.organizationId;
  
  const batch = admin.firestore().batch();
  
  // 1. Anonimizar mensagens (LGPD: manter por 5 anos para fins legais)
  const messages = await admin.firestore()
    .collection(`organizations/${orgId}/messages`)
    .where('senderId', '==', userId)
    .get();
  
  messages.forEach(doc => {
    batch.update(doc.ref, {
      senderId: 'DELETED_USER',
      text: '[Mensagem deletada por solicitação do usuário]',
      deletedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
  
  // 2. Soft delete user
  batch.update(admin.firestore().doc(`organizations/${orgId}/users/${userId}`), {
    status: 'deleted',
    email: `deleted_${userId}@anonymized.com`,
    name: 'Usuário Deletado',
    phone: null,
    deletedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  // 3. Desativar autenticação
  await admin.auth().updateUser(userId, {
    disabled: true,
  });
  
  await batch.commit();
  
  // 4. Log de auditoria
  await admin.firestore().collection('auditLogs').add({
    action: 'USER_DELETION',
    userId,
    organizationId: orgId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
});
```

---

#### **3. Audit Trail (Trilha de Auditoria)**

```javascript
// Log TODAS as ações sensíveis
match /auditLogs/{logId} {
  allow create: if isAuthenticated() &&
                   request.resource.data.userId == request.auth.uid &&
                   request.resource.data.action in [
                     'LOGIN', 'LOGOUT', 
                     'EXPORT_DATA', 'DELETE_ACCOUNT',
                     'UPDATE_SENSITIVE_DATA',
                     'ACCESS_PATIENT_RECORD'
                   ];
}
```

---

## 8. RATE LIMITING

### **Limitação no Security Rules (Básico)**

```javascript
// Limitar queries por tamanho
allow list: if request.query.limit <= 100;

// Limitar writes por timestamp (anti-spam básico)
allow create: if request.resource.data.createdAt > 
                 resource.data.lastCreateAt + duration.value(1, 's');
```

**⚠️ Limitação:** Security Rules não têm estado global (não consegue contar writes/segundo).

---

### **Rate Limiting com Cloud Functions (Avançado)**

```javascript
// functions/src/rateLimiter.ts
import * as admin from 'firebase-admin';

const RATE_LIMITS = {
  messages: { max: 100, window: 60 }, // 100 msgs/minuto
  contracts: { max: 10, window: 60 }, // 10 contratos/minuto
};

export async function checkRateLimit(
  userId: string, 
  action: string
): Promise<boolean> {
  const limit = RATE_LIMITS[action];
  if (!limit) return true;
  
  const now = Date.now();
  const windowStart = now - (limit.window * 1000);
  
  // Contar ações na janela de tempo
  const count = await admin.firestore()
    .collection('rateLimits')
    .doc(userId)
    .collection(action)
    .where('timestamp', '>', windowStart)
    .count()
    .get();
  
  return count.data().count < limit.max;
}

// Usar no onCreate trigger
exports.onMessageCreate = functions.firestore
  .document('organizations/{orgId}/messages/{msgId}')
  .onCreate(async (snap, context) => {
    const senderId = snap.data().senderId;
    
    // Verificar rate limit
    const allowed = await checkRateLimit(senderId, 'messages');
    
    if (!allowed) {
      // Deletar mensagem e bloquear usuário temporariamente
      await snap.ref.delete();
      await admin.firestore()
        .doc(`organizations/${context.params.orgId}/users/${senderId}`)
        .update({ 
          blocked: true, 
          blockedReason: 'Rate limit exceeded',
          blockedUntil: Date.now() + (5 * 60 * 1000), // 5 min
        });
      
      throw new Error('Rate limit exceeded');
    }
    
    // Registrar ação para contagem
    await admin.firestore()
      .collection('rateLimits')
      .doc(senderId)
      .collection('messages')
      .add({ timestamp: Date.now() });
  });
```

---

## 9. TESTING SECURITY RULES

### **Firebase Emulator (Local)**

```bash
# Instalar emulators
firebase init emulators

# Iniciar emulator
firebase emulators:start --only firestore
```

**Testes:**
```typescript
// test/security-rules.test.ts
import * as firebase from '@firebase/rules-unit-testing';

const PROJECT_ID = 'test-project';

describe('Security Rules', () => {
  let testEnv: firebase.RulesTestEnvironment;
  
  beforeAll(async () => {
    testEnv = await firebase.initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: await fs.readFile('firestore.rules', 'utf8'),
      },
    });
  });
  
  afterAll(async () => {
    await testEnv.cleanup();
  });
  
  test('User can read own profile', async () => {
    const context = testEnv.authenticatedContext('user123', {
      organizationId: 'org1',
    });
    
    const docRef = context.firestore().doc('organizations/org1/users/user123');
    await firebase.assertSucceeds(docRef.get());
  });
  
  test('User cannot read other user profile', async () => {
    const context = testEnv.authenticatedContext('user123', {
      organizationId: 'org1',
    });
    
    const docRef = context.firestore().doc('organizations/org1/users/user456');
    await firebase.assertFails(docRef.get());
  });
  
  test('Only admin can create users', async () => {
    const adminContext = testEnv.authenticatedContext('admin1', {
      organizationId: 'org1',
      role: 'admin',
    });
    
    const userContext = testEnv.authenticatedContext('user123', {
      organizationId: 'org1',
      role: 'user',
    });
    
    const docRef = adminContext.firestore().doc('organizations/org1/users/newuser');
    
    await firebase.assertSucceeds(
      docRef.set({ email: 'test@test.com', name: 'Test', role: 'user' })
    );
    
    await firebase.assertFails(
      userContext.firestore().doc('organizations/org1/users/newuser2')
        .set({ email: 'test2@test.com', name: 'Test2', role: 'user' })
    );
  });
});
```

---

## 10. BEST PRACTICES

### ✅ **DO**

1. **Deny by default, allow explicitly**
2. **Validate TUDO no servidor (Security Rules)**
3. **Use funções helper para reutilização**
4. **Limite queries (`.limit <= 100`)**
5. **Bloqueie `list` em coleções sensíveis**
6. **Use `get()` para verificar permissões em outros docs**
7. **Valide tipos, tamanhos e formatos**
8. **Implemente audit logs**
9. **Teste exaustivamente no emulator**
10. **Documente decisões de segurança**

### ❌ **DON'T**

1. **❌ NUNCA `allow read, write: if true`**
2. **❌ NUNCA confie apenas em validação client-side**
3. **❌ NUNCA permita updates sem validação de campos**
4. **❌ NUNCA exponha dados de outras organizações**
5. **❌ NUNCA permita listar TODAS as collections**
6. **❌ NUNCA permita timestamps arbitrários**
7. **❌ NUNCA ignore rate limiting**
8. **❌ NUNCA deixe enumeration attacks abertos**
9. **❌ NUNCA hardcode secrets nas rules**
10. **❌ NUNCA ignore compliance LGPD/GDPR**

---

## 📋 CHECKLIST DE SEGURANÇA

- [ ] Security Rules implementadas para TODAS as collections
- [ ] RLS (Row-Level Security) configurado
- [ ] Multi-tenancy isolado por `organizationId`
- [ ] RBAC/ABAC implementado
- [ ] Validação de tipos, tamanhos e formatos
- [ ] Proteção contra enumeration attacks
- [ ] Proteção contra mass assignment
- [ ] Rate limiting configurado
- [ ] Audit logs implementados
- [ ] LGPD/GDPR compliance (export, delete, logs)
- [ ] Testes de security rules (>=80% cobertura)
- [ ] Documentação de decisões de segurança

---

**Próximo:** [Performance & Custos →](FIREBASE_PERFORMANCE_OPTIMIZATION.md)

