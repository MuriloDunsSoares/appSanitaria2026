# 🏗️ Arquitetura - "Meus Contratos" na Bottom Navigation

## 📋 Resumo das Mudanças

A aba "Meus Contratos" foi adicionada à navegação inferior do paciente com **5 opções** de navegação:
- 0️⃣ **Buscar** → `/professionals`
- 1️⃣ **Conversas** → `/conversations`
- 2️⃣ **Meus Contratos** → `/contracts` (NOVO)
- 3️⃣ **Favoritos** → `/favorites`
- 4️⃣ **Perfil** → `/profile`

---

## 🎯 Camada Frontend (Flutter)

### 1. **Patient Bottom Navigation** (`patient_bottom_nav.dart`)
- ✅ Adicionado ícone `Icons.description_outlined` para Contratos
- ✅ Atualizado switch statement: casos 0-4 (anteriormente 0-3)
- ✅ Rota `/contracts` para índice 2
- ✅ Documentação atualizada para 5 botões

**Aparece em:**
- HomePatientScreen (índice 0)
- ProfessionalsListScreen (índice 0)
- ConversationsScreen (índice 1)
- **ContractsScreen (índice 2) - NOVO**
- FavoritesScreen (índice 3)

### 2. **Contracts Screen** (`contracts_screen.dart`)
- ✅ Adicionado import: `patient_bottom_nav.dart`
- ✅ Removido `PopScope` (usuários navegam pela bottom nav)
- ✅ Adicionado `bottomNavigationBar: const PatientBottomNav(currentIndex: 2)`
- ✅ Mantém filtros de status (Todos, Aguardando, Confirmado, etc)
- ✅ Mantém lista de contratos com refresh

### 3. **Favorites Screen** (`favorites_screen.dart`)
- ✅ Atualizado índice de 2 para 3 em `PatientBottomNav(currentIndex: 3)`
- ✅ Documentação atualizada

### 4. **Outras Telas** - Sem mudanças
- `home_patient_screen.dart` - currentIndex: 0 ✅
- `professionals_list_screen.dart` - currentIndex: 0 ✅
- `conversations_screen.dart` - currentIndex: 1 ✅
- `profile_screen.dart` - Sem bottom nav (fullscreen) ✅

---

## 🗄️ Camada Data (Providers & Repositories)

### **Contracts Provider V2** (`contracts_provider_v2.dart`)
- ✅ Já implementado com Clean Architecture
- ✅ Responsáveis pelas operações:
  - `loadContracts()` - Carrega contratos do usuário
  - `createContract()` - Cria novo contrato
  - `updateContractStatus()` - Atualiza status
  - `getContractsByPatient()` - Use case específico
  - `getContractsByProfessional()` - Use case específico

**Estado gerenciado:**
```dart
ContractsState {
  List<ContractEntity> contracts,
  bool isLoading,
  String? errorMessage,
}
```

---

## 🛠️ Camada Backend (Dart - backend_dart/)

### **Endpoints de Contratos**
Os endpoints devem estar em `backend_dart/lib/src/routes/contracts_routes.dart`:

```dart
// Listar contratos do usuário
GET  /contracts/user/:userId

// Criar novo contrato
POST /contracts

// Atualizar status
PUT  /contracts/:contractId/status

// Obter detalhes
GET  /contracts/:contractId
```

**Responsabilidades do Backend:**
- ✅ Validar permissões (paciente/profissional)
- ✅ Filtrar contratos por status
- ✅ Persistir mudanças de status
- ✅ Registrar atividades (logging)

---

## 🔥 Camada Firebase (Firestore & Rules)

### **Estrutura Firestore**

```
users/
  └─ {userId}/
      ├─ contracts/ (collection)
      │   ├─ {contractId}/
      │   │   ├─ patientId: string
      │   │   ├─ professionalId: string
      │   │   ├─ status: string (pending|confirmed|active|completed|cancelled)
      │   │   ├─ serviceType: string
      │   │   ├─ startDate: timestamp
      │   │   ├─ endDate: timestamp
      │   │   ├─ value: number
      │   │   ├─ createdAt: timestamp
      │   │   └─ updatedAt: timestamp
```

### **Firestore Rules** (`firestore.rules`)

```rules
// Leitura: Usuário pode ler seus próprios contratos
match /users/{userId}/contracts/{contractId} {
  allow read: if request.auth.uid == userId;
  
  // Escrita: Apenas o criador ou profissional pode atualizar
  allow write: if request.auth.uid == userId 
    || request.auth.uid == resource.data.professionalId;
    
  // Validações de status
  allow update: if request.resource.data.status in ['pending', 'confirmed', 'active', 'completed', 'cancelled'];
}
```

---

## 📊 Fluxo de Dados

```
ContractsScreen (UI)
    ↓
ref.watch(contractsProviderV2)
    ↓
ContractsNotifierV2.loadContracts()
    ↓
GetContractsByPatient/GetContractsByProfessional (Use Case)
    ↓
ContractsRepository (Data)
    ↓
FirebaseContractsDataSource / HttpContractsDataSource
    ↓
Firebase Firestore / Backend API
    ↓
Retorna: Either<Failure, List<ContractEntity>>
    ↓
UI atualiza com dados
```

---

## ✅ Checklist de Implementação

### Frontend ✅
- [x] PatientBottomNav com 5 itens
- [x] ContractsScreen com bottom nav
- [x] FavoritesScreen com índice atualizado
- [x] Todos os imports corretos
- [x] Zero linter errors

### Backend 🔄
- [ ] Validar endpoints `/contracts/user/:userId`
- [ ] Implementar filtros de status
- [ ] Adicionar logging

### Firebase 🔄
- [ ] Validar regras de acesso
- [ ] Testar permissões (read/write)
- [ ] Validar estrutura de dados

---

## 🚀 Como Testar

### 1. **Navegação Bottom Nav**
```
HomePatientScreen → Tap index 2 → ContractsScreen ✅
```

### 2. **Filtros de Status**
```
ContractsScreen → Select "Confirmado" → Filter aplicado ✅
```

### 3. **Visualização de Detalhes**
```
ContractsScreen → Tap card → ContractDetailScreen ✅
```

### 4. **Voltar Pela Bottom Nav**
```
ContractsScreen → Tap index 0 (Buscar) → ProfessionalsListScreen ✅
```

---

## 📝 Notas Importantes

- ⚠️ **Perfil Screen**: Continua fullscreen (sem bottom nav)
- ⚠️ **Chat Individual**: Continua fullscreen (sem bottom nav)
- ⚠️ **Professional Detail**: Continua fullscreen (sem bottom nav)
- ✅ **Conversas**: Agora com bottom nav (índice 1)
- ✅ **Contratos**: Novo (índice 2)

---

## 🔗 Referências

- `lib/presentation/widgets/patient_bottom_nav.dart` - Bottom navigation
- `lib/presentation/screens/contracts_screen.dart` - Tela de contratos
- `lib/core/routes/app_router.dart` - Rotas (rota `/contracts` já existe)
- `lib/presentation/providers/contracts_provider_v2.dart` - Estado dos contratos

