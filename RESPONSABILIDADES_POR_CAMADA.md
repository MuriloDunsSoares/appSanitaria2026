# 🏗️ Responsabilidades por Camada - "Meus Contratos"

## 📋 Overview

Este documento detalha as responsabilidades de cada camada da arquitetura para a aba "Meus Contratos".

---

## 🎨 CAMADA FRONTEND (Flutter/Dart)

### Responsabilidades
- Exibir bottom navigation com 5 itens
- Navegar entre telas
- Exibir lista de contratos
- Filtrar por status
- Mostrar estados (loading, error, empty, success)

### Componentes Principais

#### 1. **PatientBottomNav Widget** (`patient_bottom_nav.dart`)
```dart
// RESPONSABILIDADES:
• Renderizar 5 botões: Buscar, Conversas, Contratos, Favoritos, Perfil
• Destacar botão ativo
• Implementar lógica de navegação onTap()
• Usar Icons.description_outlined para Contratos

// O QUE NÃO FAZ:
✗ Não gerencia estado
✗ Não carrega dados
✗ Não trata erros
```

#### 2. **ContractsScreen** (`contracts_screen.dart`)
```dart
// RESPONSABILIDADES:
• Construir UI da tela
• Observar contractsProviderV2 para dados
• Exibir filtros (chips de status)
• Mostrar lista com RefreshIndicator
• Navegar para detalhe ao clicar card
• Incluir PatientBottomNav na bottom

// O QUE NÃO FAZ:
✗ Não busca dados diretamente do Firebase
✗ Não valida dados
✗ Não persiste mudanças
```

#### 3. **FavoritesScreen** (`favorites_screen.dart`)
```dart
// RESPONSABILIDADES:
• Atualizou índice de 2 → 3 no PatientBottomNav
• Mantém funcionamento anterior

// IMPACTO:
✅ Cascata de índices atualizado corretamente
```

### Fluxo de Dados Frontend
```
ContractsScreen (UI)
    ↓
    └─→ ref.watch(contractsProviderV2)
            ↓
            └─→ Observa mudanças em estado
                ↓
                └─→ rebuild automático com novos dados
                    ↓
                    └─→ renderiza filtros e lista
```

### Telas Afetadas
| Tela | Índice | Status |
|------|--------|--------|
| HomePatientScreen | 0 | ✅ Sem mudanças |
| ProfessionalsListScreen | 0 | ✅ Sem mudanças |
| ConversationsScreen | 1 | ✅ Sem mudanças |
| **ContractsScreen** | **2** | **✅ NOVO** |
| FavoritesScreen | 3 | ✅ Atualizado |
| ProfileScreen | - | ✅ Sem bottom nav |

---

## 🗄️ CAMADA DATA (State Management & Repositories)

### Responsabilidades
- Gerenciar estado dos contratos
- Comunicar com repositories
- Tratar sucessos e falhas
- Fornecer dados para UI

### Componentes Principais

#### **ContractsProviderV2** (`contracts_provider_v2.dart`)
```dart
// RESPONSABILIDADES:
• Criar ContractsState com: contracts[], isLoading, errorMessage
• Expor ContractsNotifierV2 que gerencia estado
• Implementar métodos:
  - loadContracts() → Carrega de acordo com tipo (paciente/profissional)
  - createContract() → Cria novo contrato
  - updateContractStatus() → Atualiza status

// PADRÃO:
• Clean Architecture com Use Cases
• State Pattern (StateNotifier)
• Either<Failure, Success> para tratamento de erros

// FLOW:
  ContractsNotifierV2.loadContracts()
    ↓
    ├─→ isProfessional?
    │   ├─ SIM: getContractsByProfessional.call(userId)
    │   └─ NÃO: getContractsByPatient.call(userId)
    ↓
    result.fold(
      (failure) → state = isLoading=false, errorMessage="...",
      (contracts) → state = contracts=[...], isLoading=false
    )
```

#### **Use Cases** (`domain/usecases/contracts/`)
```dart
// CreateContract
  • Valida dados
  • Chama repository.create()
  • Retorna Either<Failure, ContractEntity>

// GetContractsByPatient
  • Chama repository.getByPatient(userId)
  • Retorna Either<Failure, List<ContractEntity>>

// GetContractsByProfessional
  • Chama repository.getByProfessional(userId)
  • Retorna Either<Failure, List<ContractEntity>>

// UpdateContractStatus
  • Valida novo status
  • Chama repository.updateStatus()
  • Retorna Either<Failure, ContractEntity>
```

#### **Repositories** (`data/repositories/`)
```dart
// ContractsRepository (interface)
  • Contrato (interface) de métodos

// ContractsRepositoryImpl
  • Recebe datasources (Firebase e HTTP)
  • Escolhe qual usar
  • Trata erros

// ORDEM DE PRIORIDADE:
  1. Firebase (Firestore)
  2. Backend HTTP (fallback)
```

### Fluxo de Dados Data
```
ContractsProviderV2 (State Manager)
    ↓
ContractsNotifierV2 (State Notifier)
    ↓
Use Cases (GetContracts, CreateContract, etc)
    ↓
ContractsRepository (Interface)
    ↓
ContractsRepositoryImpl (Implementação)
    ↓
├─→ FirebaseContractsDataSource (Firestore)
└─→ HttpContractsDataSource (Backend)
```

---

## 🛠️ CAMADA BACKEND (Dart API - backend_dart/)

### Responsabilidades
- Expor endpoints de contratos
- Validar permissões (paciente/profissional)
- Aplicar regras de negócio
- Persistir em banco de dados
- Registrar logs

### Endpoints Esperados

```
GET  /contracts/user/:userId
     • Retorna contratos do usuário
     • Valida se userId == autenticado
     • Filtra por tipo (paciente vs profissional)
     • Response: { contracts: [...], success: true }

POST /contracts
     • Cria novo contrato
     • Valida: patientId, professionalId, serviceType, dates, value
     • Valida permissões (quem pode criar?)
     • Response: { contractId: "...", success: true }

PUT  /contracts/:contractId/status
     • Atualiza status do contrato
     • Valida novo status: pending|confirmed|active|completed|cancelled
     • Valida permissões (apenas paciente/prof do contrato)
     • Response: { contract: {...}, success: true }

GET  /contracts/:contractId
     • Obtém detalhes do contrato
     • Valida permissão de acesso
     • Response: { contract: {...}, success: true }
```

### Validações Backend

```dart
// SEGURANÇA:
✅ Validar autenticação (token JWT)
✅ Validar autorização (owner do contrato)
✅ Validar entrada (tipos corretos)
✅ Sanitizar strings

// REGRAS DE NEGÓCIO:
✅ Apenas paciente pode criar contrato
✅ Apenas paciente/prof pode mudar status
✅ Status deve seguir transições válidas:
   pending → confirmed
   confirmed → active
   active → completed
   any → cancelled

// LOGGING:
✅ Log todas operações com timestamp
✅ Log erros de autenticação
✅ Log mudanças de status
```

### Responsabilidades NÃO inclui
- ✗ Autenticação Firebase (feita no middleware)
- ✗ Conversão de tipos (feita no datasource)
- ✗ Cache de dados (feita no client)

---

## 🔥 CAMADA FIREBASE (Firestore & Rules)

### Responsabilidades
- Armazenar documentos de contratos
- Aplicar regras de segurança
- Indexar para queries eficientes
- Replicar dados em tempo real

### Estrutura Firestore

```
users/
  └─ {userId}/
      ├─ profile (document)
      ├─ contracts/ (collection)
      │   └─ {contractId}/ (document)
      │       ├─ patientId: string
      │       ├─ professionalId: string
      │       ├─ status: string
      │       ├─ serviceType: string
      │       ├─ startDate: timestamp
      │       ├─ endDate: timestamp
      │       ├─ value: number
      │       ├─ observations: string
      │       ├─ createdAt: timestamp
      │       ├─ updatedAt: timestamp
      │       └─ createdBy: string (userId)
```

### Firestore Rules

```rules
// Ler contratos do próprio usuário
match /users/{userId}/contracts/{contractId} {
  allow read: if request.auth.uid == userId;
  
  // Criar contrato (apenas o paciente)
  allow create: if request.auth.uid == userId 
    && request.resource.data.patientId == userId
    && request.auth.uid == request.resource.data.createdBy;
  
  // Atualizar contrato (paciente ou profissional)
  allow update: if request.auth.uid == userId
    || request.auth.uid == resource.data.professionalId;
  
  // Deletar (apenas criador)
  allow delete: if request.auth.uid == resource.data.createdBy;
  
  // Validações de status
  allow update: if request.resource.data.status in 
    ['pending', 'confirmed', 'active', 'completed', 'cancelled'];
}

// Index para queries eficientes
index on status, createdAt desc;
```

### Responsabilidades NÃO inclui
- ✗ Validação de tipos (feita no backend)
- ✗ Hashing de senhas (feito no auth)
- ✗ Geração de IDs (feita pelo Firestore)

---

## 🔄 Fluxo End-to-End Completo

```
╔═══════════════════════════════════════════════════════════════╗
║  1. FRONTEND - Usuário abre aba "Contratos"                  ║
╚═══════════════════════════════════════════════════════════════╝
   ContractsScreen.build()
   ↓
   ref.watch(contractsProviderV2)  ← Observable

╔═══════════════════════════════════════════════════════════════╗
║  2. DATA LAYER - Provider reage                              ║
╚═══════════════════════════════════════════════════════════════╝
   ContractsNotifierV2.loadContracts()
   ↓
   state = { isLoading: true }  ← UI mostra spinner
   ↓
   if (isProfessional)
     GetContractsByProfessional.call(userId)
   else
     GetContractsByPatient.call(userId)

╔═══════════════════════════════════════════════════════════════╗
║  3. REPOSITORY - Busca dados                                 ║
╚═══════════════════════════════════════════════════════════════╝
   ContractsRepositoryImpl.getByPatient(userId)
   ↓
   Tenta Firebase primeiro
   └─→ FirebaseContractsDataSource.getContracts(userId)
       ↓
       Query Firestore: users/{userId}/contracts

╔═══════════════════════════════════════════════════════════════╗
║  4. FIREBASE - Busca no banco                                ║
╚═══════════════════════════════════════════════════════════════╝
   Firestore.collection('users').doc(userId)
           .collection('contracts')
           .where('patientId', '==', userId)
           .orderBy('createdAt', 'desc')
           .get()
   ↓
   Retorna: List<DocumentSnapshot>

╔═══════════════════════════════════════════════════════════════╗
║  5. DATA SOURCE - Converte para entidades                    ║
╚═══════════════════════════════════════════════════════════════╝
   DocumentSnapshot → ContractEntity (mapeamento)
   ↓
   Retorna: Either<FirebaseException, List<ContractEntity>>

╔═══════════════════════════════════════════════════════════════╗
║  6. USE CASE - Trata resultado                               ║
╚═══════════════════════════════════════════════════════════════╝
   result.fold(
     (failure) → state = { 
       isLoading: false,
       errorMessage: failure.message 
     },
     (contracts) → state = { 
       contracts: contracts,
       isLoading: false 
     }
   )

╔═══════════════════════════════════════════════════════════════╗
║  7. FRONTEND - UI rerender com dados                         ║
╚═══════════════════════════════════════════════════════════════╝
   ContractsScreen detecta mudança em contractsProviderV2
   ↓
   build() chamado novamente
   ↓
   ListView.builder() renderiza contratos
   ↓
   UI exibe lista com filtros, refresh, etc
```

---

## 📊 Responsabilidades por Camada - Resumo

| Tarefa | Frontend | Data Layer | Backend | Firebase |
|--------|----------|-----------|---------|----------|
| Renderizar UI | ✅ | - | - | - |
| Gerenciar Estado | - | ✅ | - | - |
| Buscar Dados | - | ✅ | ✅ | ✅ |
| Validar Permissões | - | - | ✅ | ✅ |
| Validar Status | - | - | ✅ | ✅ |
| Persistir Dados | - | - | ✅ | ✅ |
| Replicar Realtime | - | - | - | ✅ |
| Logging | - | - | ✅ | - |

---

## ✅ Checklist Final

### Frontend ✅
- [x] PatientBottomNav com 5 itens
- [x] ContractsScreen com bottom nav
- [x] FavoritesScreen com índice atualizado
- [x] Zero erros de compilação
- [x] Zero linter warnings

### Data Layer ✅
- [x] ContractsProviderV2 implementado
- [x] Use Cases implementados
- [x] Repository pattern seguido

### Backend 🔄
- [ ] Validar endpoints
- [ ] Implementar validações
- [ ] Adicionar logging

### Firebase 🔄
- [ ] Validar rules
- [ ] Testar permissões
- [ ] Criar índices se necessário

---

**Status: PRONTO PARA TESTES** ✅

