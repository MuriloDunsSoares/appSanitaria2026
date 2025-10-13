# 💾 FIREBASE - BACKUP & DISASTER RECOVERY

**Parte da:** [Consultoria Firebase](FIREBASE_ARCHITECTURE_GUIDE.md)  
**Foco:** Backup, recuperação e continuidade de negócios

---

## 📋 ÍNDICE

1. [Estratégia de Backup](#estratégia-de-backup)
2. [Firestore Backup](#firestore-backup)
3. [Cloud Storage Backup](#cloud-storage-backup)
4. [Disaster Recovery Plan](#disaster-recovery-plan)
5. [Versionamento de Dados](#versionamento-de-dados)
6. [Arquivamento de Dados Históricos](#arquivamento-de-dados-históricos)
7. [Data Retention Policies](#data-retention-policies)
8. [Testing Recovery](#testing-recovery)
9. [Compliance LGPD](#compliance-lgpd)
10. [Checklist](#checklist)

---

## 1. ESTRATÉGIA DE BACKUP

### **RPO vs RTO**

```
RPO (Recovery Point Objective):
  Quanto de dados podemos PERDER?
  
  Exemplo: RPO = 1 hora
  → Backup a cada 1 hora
  → No máximo 1 hora de dados perdidos

RTO (Recovery Time Objective):
  Quanto tempo para RESTAURAR?
  
  Exemplo: RTO = 4 horas
  → Sistema deve voltar em até 4 horas
```

### **Níveis de Criticidade**

| Dados | RPO | RTO | Estratégia |
|-------|-----|-----|-----------|
| **Users, Contracts** | 1 hora | 2 horas | Backup diário + export |
| **Messages** | 24 horas | 4 horas | Backup diário |
| **Reviews** | 24 horas | 8 horas | Backup diário |
| **Logs** | 7 dias | 24 horas | Archive mensalmente |
| **Fotos** | 24 horas | 8 horas | Replicação multi-region |

---

### **3-2-1 Rule**

```
3 cópias dos dados:
  - 1 primária (Firestore)
  - 2 backups

2 tipos de mídia diferentes:
  - Firestore (NoSQL)
  - Cloud Storage (arquivos)
  - BigQuery (analytics)

1 cópia off-site (outra região):
  - us-central1 (primário)
  - southamerica-east1 (backup)
```

---

## 2. FIRESTORE BACKUP

### **Opção 1: Managed Backups (RECOMENDADO)**

**Setup via gcloud:**
```bash
# Habilitar backups gerenciados
gcloud alpha firestore backups schedules create \
  --database='(default)' \
  --recurrence=daily \
  --retention=7d

# Listar backups
gcloud alpha firestore backups list

# Restaurar backup
gcloud alpha firestore backups restore \
  --backup=BACKUP_ID \
  --destination-database=DATABASE_ID
```

**Características:**
- ✅ Automático (diário)
- ✅ Incremental (rápido)
- ✅ Point-in-time recovery
- ❌ Custo: ~$0.03/GB/mês

---

### **Opção 2: Export Manual (Budget-friendly)**

#### **Cloud Function: Daily Export**

```javascript
// functions/src/backups.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const firestore = admin.firestore();
const client = new admin.firestore.v1.FirestoreAdminClient();

exports.scheduledFirestoreExport = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
    const databaseName = client.databasePath(projectId, '(default)');
    
    // Bucket para backups
    const bucket = `gs://${projectId}-firestore-backups`;
    
    // Export com timestamp
    const timestamp = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
    const outputUriPrefix = `${bucket}/${timestamp}`;
    
    try {
      const [operation] = await client.exportDocuments({
        name: databaseName,
        outputUriPrefix,
        // Coleções específicas (opcional)
        collectionIds: [
          'organizations',
          'userProfiles',
          'auditLogs',
        ],
      });
      
      console.log(`Backup started: ${operation.name}`);
      
      // Wait for completion (opcional)
      await operation.promise();
      
      console.log(`Backup completed: ${outputUriPrefix}`);
      
      // Limpar backups antigos (>30 dias)
      await cleanOldBackups(bucket, 30);
      
      return { success: true, path: outputUriPrefix };
    } catch (error) {
      console.error('Backup failed:', error);
      
      // Alertar equipe
      await sendAlertToSlack('🚨 Firestore backup failed!', error.message);
      
      throw error;
    }
  });

async function cleanOldBackups(bucketName: string, daysToKeep: number) {
  const bucket = admin.storage().bucket(bucketName.replace('gs://', ''));
  const [files] = await bucket.getFiles({ prefix: 'firestore-export' });
  
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);
  
  for (const file of files) {
    const [metadata] = await file.getMetadata();
    const fileDate = new Date(metadata.timeCreated);
    
    if (fileDate < cutoffDate) {
      await file.delete();
      console.log(`Deleted old backup: ${file.name}`);
    }
  }
}
```

**Deploy:**
```bash
firebase deploy --only functions:scheduledFirestoreExport
```

**Custo:**
```
Export:
  - Leituras: 1M docs × $0.06/100k = $0.60/dia
  - Storage: 5GB × $0.026/GB = $0.13/mês
  - Total: ~$18.13/mês

Managed Backups:
  - Storage: 5GB × $0.03/GB = $0.15/mês
  - Total: ~$0.15/mês

RECOMENDAÇÃO: Managed Backups (20x mais barato!)
```

---

### **Import/Restore**

```bash
# Importar backup para Firestore
gcloud firestore import gs://PROJECT_ID-firestore-backups/2025-10-13 \
  --database='(default)'

# Ou para database separado (teste)
gcloud firestore import gs://PROJECT_ID-firestore-backups/2025-10-13 \
  --database='test-restore'
```

---

## 3. CLOUD STORAGE BACKUP

### **Multi-region Replication**

```javascript
// Configurar bucket multi-region
const { Storage } = require('@google-cloud/storage');
const storage = new Storage();

async function createMultiRegionBucket() {
  const bucketName = 'app-sanitaria-storage';
  
  await storage.createBucket(bucketName, {
    location: 'us',              // Multi-region (us, eu, asia)
    storageClass: 'STANDARD',
    versioning: { enabled: true }, // Versionamento
  });
  
  console.log(`Bucket ${bucketName} created with multi-region replication.`);
}
```

**Características:**
- ✅ Replicação automática entre regiões
- ✅ Versionamento de arquivos
- ✅ Alta disponibilidade (99.95%)
- ❌ Custo: +20% vs single-region

---

### **Lifecycle Management**

```javascript
// Mover arquivos antigos para storage barato
exports.setupStorageLifecycle = async () => {
  const bucket = storage.bucket('app-sanitaria-storage');
  
  await bucket.setLifecycle({
    rule: [
      {
        action: { type: 'SetStorageClass', storageClass: 'NEARLINE' },
        condition: { age: 90 }, // 90 dias → Nearline ($0.01/GB)
      },
      {
        action: { type: 'SetStorageClass', storageClass: 'COLDLINE' },
        condition: { age: 365 }, // 1 ano → Coldline ($0.004/GB)
      },
      {
        action: { type: 'Delete' },
        condition: { age: 1825 }, // 5 anos → Deletar (LGPD)
      },
    ],
  });
  
  console.log('Lifecycle policy set.');
};
```

**Economia:**
```
Sem lifecycle:
  - 1TB de fotos antigas × $0.026/GB = $26/mês

Com lifecycle (após 90 dias):
  - 100GB recentes × $0.026/GB = $2.60
  - 900GB antigas × $0.01/GB = $9.00
  - Total: $11.60/mês

ECONOMIA: -55% ($14.40/mês)
```

---

### **Versioning (Proteção contra Delete)**

```javascript
// Habilitar versionamento
const bucket = storage.bucket('app-sanitaria-storage');
await bucket.setVersioning({ enabled: true });

// Se arquivo for deletado, versão anterior fica disponível
const file = bucket.file('profiles/user123.jpg');
await file.delete(); // Soft delete

// Restaurar versão anterior
const [versions] = await file.getMetadata();
const previousVersion = versions[versions.length - 2];
await file.copy(`profiles/user123.jpg#${previousVersion.generation}`);
```

---

## 4. DISASTER RECOVERY PLAN

### **Cenários de Desastre**

#### **1. Perda de Dados (Acidental Delete)**

**Cenário:**
```
Desenvolvedor executa:
  DELETE FROM contracts WHERE patient_id = 'user123'
  
MAS esqueceu o WHERE e deletou TODOS os contratos! 😱
```

**Recovery:**
```bash
# Opção A: Restore último backup (RPO = 24h)
gcloud firestore import gs://backups/2025-10-12 \
  --collection-ids=contracts

# Opção B: Point-in-time recovery (se Managed Backups)
gcloud alpha firestore backups restore \
  --backup=backup-id \
  --destination-database=restored-db
```

**Tempo de Recovery:** 1-4 horas (RTO)  
**Dados Perdidos:** Últimas 24 horas (RPO)

---

#### **2. Falha Regional (us-central1 down)**

**Cenário:**
```
Google Cloud us-central1 está OFFLINE (raro, mas acontece)
App não consegue acessar Firestore
```

**Recovery:**
```
1. PREPARAÇÃO (antes do desastre):
   - Multi-region Firestore (nam5, southamerica-east1)
   - Load balancer com failover automático
   
2. DURANTE o desastre:
   - Traffic roteado automaticamente para região secundária
   - Latência pode aumentar (+50-100ms)
   
3. APÓS restauração:
   - Traffic retorna para região primária
   - Sync pendente executado automaticamente
```

**Tempo de Recovery:** <5 minutos (RTO)  
**Dados Perdidos:** 0 (RPO = 0)

---

#### **3. Security Breach (Hacker apaga tudo)**

**Cenário:**
```
Atacante ganha acesso a conta admin e DELETA tudo:
  - Firestore collections
  - Cloud Storage files
  - Cloud Functions
```

**Recovery:**
```bash
# 1. IMEDIATAMENTE: Bloquear acesso
gcloud projects remove-iam-policy-binding PROJECT_ID \
  --member=user:hacker@evil.com \
  --role=roles/owner

# 2. Restaurar Firestore (último backup)
gcloud firestore import gs://backups/2025-10-12

# 3. Restaurar Cloud Storage (versionamento)
gsutil -m cp -r gs://backups-storage/* gs://app-sanitaria-storage/

# 4. Redeployar Cloud Functions (Git)
git checkout main
firebase deploy --only functions

# 5. Auditar logs para entender extensão do ataque
gcloud logging read "protoPayload.methodName=~\"delete\"" \
  --limit=1000 \
  --format=json > attack-logs.json
```

**Tempo de Recovery:** 4-8 horas (RTO)  
**Dados Perdidos:** Últimas 24 horas (RPO)

---

### **Disaster Recovery Playbook**

```markdown
# DISASTER RECOVERY PLAYBOOK

## FASE 1: DETECÇÃO (0-15 min)
- [ ] Alert recebido (PagerDuty)
- [ ] Verificar dashboards (Firestore, Storage)
- [ ] Confirmar extensão do problema
- [ ] Notificar stakeholders (#incidents)

## FASE 2: CONTENÇÃO (15-30 min)
- [ ] Bloquear acesso suspeito
- [ ] Parar writes no Firestore (se necessário)
- [ ] Habilitar maintenance mode no app
- [ ] Preservar logs e evidências

## FASE 3: RECOVERY (30 min - 4 horas)
- [ ] Identificar último backup bom
- [ ] Restaurar Firestore
- [ ] Restaurar Cloud Storage
- [ ] Validar integridade dos dados
- [ ] Testar funcionalidades críticas

## FASE 4: RETORNO (4-8 horas)
- [ ] Desabilitar maintenance mode
- [ ] Monitorar errors/crashes
- [ ] Comunicar usuários (status page)
- [ ] Documentar incidente

## FASE 5: POST-MORTEM (24-48 horas)
- [ ] Root cause analysis
- [ ] Lessons learned
- [ ] Action items (prevent recurrence)
- [ ] Update playbook
```

---

## 5. VERSIONAMENTO DE DADOS

### **Audit Trail (Change Log)**

```javascript
// Cloud Function: Log todas as mudanças
exports.auditChanges = functions.firestore
  .document('{collection}/{docId}')
  .onWrite(async (change, context) => {
    const collection = context.params.collection;
    const docId = context.params.docId;
    
    // Dados antes e depois
    const before = change.before.data();
    const after = change.after.data();
    
    // Calcular diff
    const changes = {};
    if (before && after) {
      for (const key in after) {
        if (before[key] !== after[key]) {
          changes[key] = { before: before[key], after: after[key] };
        }
      }
    }
    
    // Salvar log
    await admin.firestore().collection('auditLogs').add({
      collection,
      docId,
      action: !before ? 'CREATE' : !after ? 'DELETE' : 'UPDATE',
      changes,
      userId: context.auth?.uid || 'SYSTEM',
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
```

**Uso:**
```dart
// Flutter: Ver histórico de mudanças
final logs = await db
  .collection('auditLogs')
  .where('collection', isEqualTo: 'contracts')
  .where('docId', isEqualTo: contractId)
  .orderBy('timestamp', descending: true)
  .limit(50)
  .get();

// Exibir timeline
for (final log in logs.docs) {
  print('${log['timestamp']}: ${log['action']} by ${log['userId']}');
  print('Changes: ${log['changes']}');
}
```

---

### **Soft Delete**

```dart
// Nunca deletar permanentemente
class ContractsRepository {
  Future<void> deleteContract(String contractId) async {
    // ❌ Não fazer:
    // await db.doc('contracts/$contractId').delete();
    
    // ✅ Soft delete:
    await db.doc('contracts/$contractId').update({
      'status': 'deleted',
      'deletedAt': FieldValue.serverTimestamp(),
      'deletedBy': currentUserId,
    });
  }
  
  Future<void> restoreContract(String contractId) async {
    await db.doc('contracts/$contractId').update({
      'status': 'active',
      'deletedAt': FieldValue.delete(), // Remove campo
      'restoredAt': FieldValue.serverTimestamp(),
    });
  }
}

// Queries ignoram deletados
final contracts = await db
  .collection('contracts')
  .where('status', isNotEqualTo: 'deleted')
  .get();
```

---

## 6. ARQUIVAMENTO DE DADOS HISTÓRICOS

### **Mover para BigQuery (Cold Storage)**

```javascript
// Cloud Function: Arquivar dados antigos (mensalmente)
exports.archiveOldData = functions.pubsub
  .schedule('0 0 1 * *') // 1º dia do mês
  .onRun(async () => {
    const bigquery = new BigQuery();
    const datasetId = 'archived_data';
    const tableId = 'messages';
    
    // Data de corte: 6 meses atrás
    const cutoffDate = new Date();
    cutoffDate.setMonth(cutoffDate.getMonth() - 6);
    
    // Buscar mensagens antigas
    const oldMessages = await admin.firestore()
      .collection('messages')
      .where('timestamp', '<', cutoffDate)
      .get();
    
    if (oldMessages.empty) {
      console.log('No messages to archive.');
      return;
    }
    
    // Inserir no BigQuery
    const rows = oldMessages.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      archivedAt: new Date().toISOString(),
    }));
    
    await bigquery
      .dataset(datasetId)
      .table(tableId)
      .insert(rows);
    
    console.log(`Archived ${rows.length} messages to BigQuery.`);
    
    // Deletar do Firestore (economia de storage)
    const batch = admin.firestore().batch();
    oldMessages.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    await batch.commit();
    
    console.log(`Deleted ${oldMessages.size} messages from Firestore.`);
  });
```

**Economia:**
```
Firestore (6 meses de mensagens antigas):
  - Storage: 10GB × $0.18/GB = $1.80/mês
  - Reads ocasionais: 100k × $0.06/100k = $0.06/mês
  - Total: $1.86/mês

BigQuery (cold storage):
  - Storage: 10GB × $0.02/GB = $0.20/mês
  - Queries raras: 1GB × $5/TB = $0.005/mês
  - Total: $0.205/mês

ECONOMIA: -89% ($1.65/mês)
```

---

### **Consultar Dados Arquivados**

```sql
-- BigQuery: Query mensagens arquivadas
SELECT 
  id,
  senderId,
  receiverId,
  text,
  timestamp
FROM 
  `PROJECT_ID.archived_data.messages`
WHERE 
  senderId = 'user123'
  AND timestamp BETWEEN '2024-01-01' AND '2024-06-30'
ORDER BY 
  timestamp DESC
LIMIT 100;
```

---

## 7. DATA RETENTION POLICIES

### **Política LGPD/GDPR**

```
CATEGORIA              | RETENÇÃO     | APÓS RETENÇÃO
-----------------------|--------------|------------------
Dados de usuário       | Até delete   | Anonimizar
Contratos              | 5 anos       | Arquivar
Mensagens              | 2 anos       | Deletar
Reviews                | Permanente   | -
Logs de acesso         | 6 meses      | Deletar
Audit logs (legal)     | 5 anos       | Arquivar
Fotos de perfil        | Até delete   | Deletar
Documentos (contratos) | 7 anos       | Arquivar
```

### **Implementação**

```javascript
// Cloud Function: Cleanup automático (semanal)
exports.cleanupOldData = functions.pubsub
  .schedule('0 2 * * 0') // Domingo 2am
  .onRun(async () => {
    const now = new Date();
    
    // 1. Deletar mensagens >2 anos
    const twoYearsAgo = new Date(now);
    twoYearsAgo.setFullYear(now.getFullYear() - 2);
    
    const oldMessages = await admin.firestore()
      .collection('messages')
      .where('timestamp', '<', twoYearsAgo)
      .limit(500) // Batch de 500
      .get();
    
    const batch = admin.firestore().batch();
    oldMessages.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
    
    console.log(`Deleted ${oldMessages.size} old messages.`);
    
    // 2. Anonimizar usuários deletados >30 dias
    const thirtyDaysAgo = new Date(now);
    thirtyDaysAgo.setDate(now.getDate() - 30);
    
    const deletedUsers = await admin.firestore()
      .collection('users')
      .where('status', '==', 'deleted')
      .where('deletedAt', '<', thirtyDaysAgo)
      .get();
    
    for (const user of deletedUsers.docs) {
      await user.ref.update({
        email: `anonymized_${user.id}@deleted.com`,
        name: 'Usuário Anonimizado',
        phone: null,
        cpf: null,
        address: null,
      });
    }
    
    console.log(`Anonymized ${deletedUsers.size} deleted users.`);
    
    // 3. Deletar logs de acesso >6 meses
    const sixMonthsAgo = new Date(now);
    sixMonthsAgo.setMonth(now.getMonth() - 6);
    
    const oldLogs = await admin.firestore()
      .collection('accessLogs')
      .where('timestamp', '<', sixMonthsAgo)
      .limit(1000)
      .get();
    
    const logsBatch = admin.firestore().batch();
    oldLogs.docs.forEach(doc => logsBatch.delete(doc.ref));
    await logsBatch.commit();
    
    console.log(`Deleted ${oldLogs.size} old access logs.`);
  });
```

---

## 8. TESTING RECOVERY

### **Disaster Recovery Drills**

```markdown
# DISASTER RECOVERY DRILL (Trimestral)

## OBJETIVO
Validar que conseguimos restaurar sistemas em <4 horas.

## CENÁRIO
Simular perda completa do Firestore database.

## PASSOS
1. [ ] Criar database de teste (firestore-test)
2. [ ] Deletar todos os dados do database de teste
3. [ ] Iniciar cronômetro
4. [ ] Executar restore do último backup
5. [ ] Validar integridade de dados
6. [ ] Testar funcionalidades críticas:
   - [ ] Login
   - [ ] Listar profissionais
   - [ ] Criar contrato
   - [ ] Enviar mensagem
7. [ ] Parar cronômetro
8. [ ] Documentar tempo de recovery
9. [ ] Identificar gargalos
10. [ ] Atualizar playbook

## SUCESSO
- Recovery time < 4 horas (RTO)
- 0 erros de integridade
- Todas as funcionalidades operacionais

## FALHA
- Recovery time > 4 horas → Revisar processo
- Erros de integridade → Revisar backup strategy
```

---

### **Restore Test Script**

```bash
#!/bin/bash
# restore-test.sh

set -e

PROJECT_ID="app-sanitaria"
TEST_DATABASE="firestore-test"
BACKUP_DATE=$(date -d "yesterday" +%Y-%m-%d)

echo "🚀 Starting restore test..."
echo "Project: $PROJECT_ID"
echo "Test DB: $TEST_DATABASE"
echo "Backup: $BACKUP_DATE"

# 1. Criar database de teste
echo "1. Creating test database..."
gcloud firestore databases create \
  --database=$TEST_DATABASE \
  --location=us-central1 \
  --type=firestore-native

# 2. Restaurar backup
echo "2. Restoring backup..."
START_TIME=$(date +%s)

gcloud firestore import gs://$PROJECT_ID-firestore-backups/$BACKUP_DATE \
  --database=$TEST_DATABASE

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "✅ Restore completed in ${DURATION}s"

# 3. Validar dados
echo "3. Validating data..."

# Contar documentos
USERS_COUNT=$(gcloud firestore documents list \
  --database=$TEST_DATABASE \
  --collection=users \
  --format=json | jq '. | length')

CONTRACTS_COUNT=$(gcloud firestore documents list \
  --database=$TEST_DATABASE \
  --collection=contracts \
  --format=json | jq '. | length')

echo "Users: $USERS_COUNT"
echo "Contracts: $CONTRACTS_COUNT"

# 4. Limpar
echo "4. Cleaning up..."
gcloud firestore databases delete $TEST_DATABASE --quiet

echo "✅ Test completed successfully!"
echo "Recovery Time: ${DURATION}s (RTO target: 14400s / 4 hours)"

if [ $DURATION -lt 14400 ]; then
  echo "✅ PASSED: Recovery time within target"
  exit 0
else
  echo "❌ FAILED: Recovery time exceeded target"
  exit 1
fi
```

---

## 9. COMPLIANCE LGPD

### **Direito ao Esquecimento**

```dart
// Cloud Function: Deletar TODOS os dados de um usuário
exports.deleteUserData = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated');
  }
  
  const userId = context.auth.uid;
  const firestore = admin.firestore();
  
  console.log(`Starting data deletion for user: ${userId}`);
  
  // 1. Anonimizar mensagens (manter por compliance)
  const messagesSnapshot = await firestore
    .collection('messages')
    .where('senderId', '==', userId)
    .get();
  
  const batch1 = firestore.batch();
  messagesSnapshot.docs.forEach(doc => {
    batch1.update(doc.ref, {
      senderId: 'DELETED_USER',
      senderName: 'Usuário Deletado',
      text: '[Mensagem deletada a pedido do usuário]',
    });
  });
  await batch1.commit();
  
  // 2. Deletar reviews
  const reviewsSnapshot = await firestore
    .collection('reviews')
    .where('patientId', '==', userId)
    .get();
  
  const batch2 = firestore.batch();
  reviewsSnapshot.docs.forEach(doc => batch2.delete(doc.ref));
  await batch2.commit();
  
  // 3. Anonimizar contratos (manter por 5 anos - legal)
  const contractsSnapshot = await firestore
    .collection('contracts')
    .where('patientId', '==', userId)
    .get();
  
  const batch3 = firestore.batch();
  contractsSnapshot.docs.forEach(doc => {
    batch3.update(doc.ref, {
      patientId: 'DELETED_USER',
      patientName: 'Usuário Deletado',
    });
  });
  await batch3.commit();
  
  // 4. Deletar fotos
  const bucket = admin.storage().bucket();
  await bucket.deleteFiles({ prefix: `profiles/${userId}/` });
  
  // 5. Soft delete user
  await firestore.doc(`users/${userId}`).update({
    status: 'deleted',
    email: `deleted_${userId}@anonymized.com`,
    name: 'Usuário Deletado',
    phone: null,
    cpf: null,
    address: null,
    deletedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  
  // 6. Desabilitar autenticação
  await admin.auth().updateUser(userId, { disabled: true });
  
  // 7. Log de auditoria
  await firestore.collection('auditLogs').add({
    action: 'USER_DATA_DELETION',
    userId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    collections: ['messages', 'reviews', 'contracts', 'storage'],
  });
  
  console.log(`Data deletion completed for user: ${userId}`);
  
  return { success: true, message: 'Dados deletados com sucesso.' };
});
```

---

## 10. CHECKLIST

### **Backup**
- [ ] Managed Backups habilitados (diário)
- [ ] Retention policy: 7 dias (mínimo)
- [ ] Export manual mensal (disaster recovery)
- [ ] Storage backups multi-region
- [ ] Versionamento habilitado (Storage)
- [ ] Lifecycle policies configuradas

### **Recovery**
- [ ] Disaster Recovery Playbook documentado
- [ ] RPO/RTO definidos por tipo de dado
- [ ] Restore test trimestral
- [ ] On-call rotation definida
- [ ] Alertas de backup failure

### **Compliance**
- [ ] Data retention policies implementadas
- [ ] Cleanup automático (semanal)
- [ ] Audit logs (5 anos)
- [ ] Direito ao esquecimento (LGPD)
- [ ] Export de dados do usuário
- [ ] Soft delete em produção
- [ ] Versionamento de dados críticos

### **Arquivamento**
- [ ] BigQuery para dados históricos (>6 meses)
- [ ] Storage classes otimizadas (Nearline, Coldline)
- [ ] Política de arquivamento documentada

### **Testing**
- [ ] Restore test passou (<4 horas)
- [ ] Integridade de dados validada
- [ ] Funcionalidades críticas testadas
- [ ] Post-mortem de incidentes documentado

---

**Fim da Consultoria Firebase**

**Documentação Completa:**
- [← Voltar ao Índice](FIREBASE_ARCHITECTURE_GUIDE.md)
- [Estrutura de Dados](FIREBASE_DATABASE_STRUCTURE.md)
- [Security Rules](FIREBASE_SECURITY_RULES.md)
- [Performance & Custos](FIREBASE_PERFORMANCE_OPTIMIZATION.md)
- [Monitoramento](FIREBASE_MONITORING_OBSERVABILITY.md)
- **Backup & Recovery** ← Você está aqui

