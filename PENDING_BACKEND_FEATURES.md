# ⏳ FEATURES PENDENTES NO BACKEND

**Data**: 27 de Outubro de 2025  
**Status**: Lista priorizada para implementação  
**Total**: 8 features críticas

---

## 🎯 PRIORIDADE 1️⃣ - CRÍTICAS (Sprint atual)

### Feature 1.1: Reviews Aggregation Service

**Status**: 🔴 **BLOQUEADO** - Lógica ainda no frontend

**Descrição**:  
Calcular e atualizar média de avaliações de forma segura no backend, com auditoria.

**Dados Envolvidos**:
```
Input:
  - professionalId: string
  - newRating: int (1-5)
  - reviewCount: int

Output:
  - averageRating: double
  - totalReviews: int
  - updatedAt: timestamp
```

**APIs Externas**: Nenhuma

**Requisitos de Segurança**:
- ✅ Validar JWT token
- ✅ Verificar se usuário é o author da avaliação
- ✅ Transação ACID (Review + Professional update)
- ✅ Auditoria de cálculo
- ✅ Timeout 30s

**Requisitos de Autorização**:
- ✅ Apenas usuário autenticado
- ✅ Apenas para suas próprias avaliações
- ✅ Admin pode forçar recalcular

**Localização no Frontend**:
- `lib/data/datasources/firebase_reviews_datasource.dart:39` (_updateProfessionalAverageRating)
- `lib/data/datasources/firebase_reviews_datasource.dart:78` (getAverageRating)

**Ação Recomendada**:
```
Backend: POST /api/v1/reviews/{professionalId}/aggregate
- Recalcula média de todas as reviews do profissional
- Atualiza professional.averageRating
- Registra auditoria
```

---

### Feature 1.2: Contract Status Transitions

**Status**: 🔴 **BLOQUEADO** - Validação apenas em UseCase

**Descrição**:  
Validar transições de status de contrato no backend (pending → accepted → completed).

**Dados Envolvidos**:
```
Input:
  - contractId: string
  - newStatus: 'accepted' | 'rejected' | 'completed' | 'cancelled'
  - userId: string (current user)
  - userType: 'paciente' | 'profissional'

Output:
  - contract: ContractEntity
  - success: bool
  - reason?: string (se rejeitado)
```

**APIs Externas**: Nenhuma

**Requisitos de Segurança**:
- ✅ Validar JWT token
- ✅ Verificar autorização (paciente/profissional envolvido)
- ✅ Transação ACID
- ✅ Validar transição válida (não pode ir de completed → pending)
- ✅ Auditoria

**Requisitos de Autorização**:
- ✅ Apenas participante do contrato pode atualizar
- ✅ Paciente pode: cancelar, aceitar
- ✅ Profissional pode: aceitar, rejeitar
- ✅ Admin pode: qualquer transição

**Transições Válidas**:
```
pending → accepted (profissional)
pending → rejected (profissional)
pending → cancelled (paciente)
accepted → completed (qualquer um)
accepted → cancelled (qualquer um)
* → * : NUNCA (documentar transições proibidas)
```

**Localização no Frontend**:
- `lib/domain/usecases/contracts/update_contract_status.dart`
- `lib/domain/usecases/contracts/cancel_contract.dart`
- `lib/domain/usecases/contracts/update_contract.dart`

**Ação Recomendada**:
```
Backend:
  PATCH /api/v1/contracts/{contractId}/status
  - Valida transição
  - Atualiza status
  - Emite eventos (para notificações)

Backend:
  PATCH /api/v1/contracts/{contractId}/cancel
  - Valida se pode cancelar
  - Marca como cancelado
  - Registra motivo
```

---

### Feature 1.3: Firestore Rules Enforcement

**Status**: 🟡 **PARCIAL** - Rules existem mas são fracas

**Descrição**:  
Fortalecer regras de segurança do Firestore para bloquear ações inválidas.

**Dados Envolvidos**:
```
Validações necessárias:
- Contract status transitions
- Review rating bounds (1-5)
- Message rate limiting
- User profile ownership
```

**APIs Externas**: Nenhuma

**Requisitos de Segurança**:
- ✅ Deny by default
- ✅ Least privilege
- ✅ Field-level validation
- ✅ Type checking

**Requisitos de Autorização**:
- ✅ Usuário só pode ler/escrever seus próprios dados
- ✅ Admin tem acesso total
- ✅ Público só leitura para dados públicos

**Ações Proibidas**:
- ❌ Alterar status de contrato para estado inválido
- ❌ Salvar review com rating > 5 ou < 1
- ❌ Deletar contratos (soft delete apenas)
- ❌ Modificar createdAt/updatedAt

**Localização no Repositório**:
- `firestore.rules` - todo o arquivo

**Ação Recomendada**:
```
Fortalecer rules com:
- validateContractStatusTransition()
- validateReviewRating()
- validateMessageContent()
- Fazer código backend validar também
```

---

## 🎯 PRIORIDADE 2️⃣ - ALTAS (Próximas 2 semanas)

### Feature 2.1: Contract Validations

**Status**: 🟡 **PARCIAL** - Alguns validações em UseCase

**Descrição**:  
Consolidar validações de contrato no backend antes de salvar.

**Validações Necessárias**:
- Data não pode ser no passado
- Endereço obrigatório
- Tipo de serviço válido (enum)
- Valor do serviço > 0
- Duração válida
- Profissional existe e está ativo
- Paciente tem conta ativa

**Localização no Frontend**:
- `lib/domain/usecases/contracts/create_contract.dart`
- `lib/domain/usecases/contracts/update_contract.dart`

**Ação Recomendada**:
```
Backend: POST /api/v1/contracts (já parcialmente existe)
- Executar TODAS as validações
- Retornar erros específicos
- Auditoria

Backend: PATCH /api/v1/contracts/{contractId}
- Validar modificações
- Proibir alterações de campos críticos (paciente, profissional)
```

---

### Feature 2.2: Review Validations

**Status**: 🟡 **PARCIAL** - Rating validado em 2 lugares

**Descrição**:  
Consolidar validações de review no backend.

**Validações Necessárias**:
- Rating entre 1 e 5
- Comment não vazio (min 10 caracteres)
- Comment não muito longo (max 500)
- Usuário não pode avaliar a si mesmo
- Profissional existe
- Contrato existe e foi completado
- Usuário só pode avaliar 1x por profissional por contrato

**Localização no Frontend**:
- `lib/domain/usecases/reviews/add_review.dart:40`
- `lib/data/datasources/http_reviews_datasource.dart`

**Ação Recomendada**:
```
Backend: POST /api/v1/reviews/{professionalId}/reviews
- Já existe parcialmente
- Adicionar validações faltantes
- Retornar erros específicos
```

---

### Feature 2.3: Message Validations & Rate Limiting

**Status**: 🟢 **OK** - Já implementado

**Descrição**:  
Rate limiting e validação de mensagens.

**Status Atual**: ✅ Implementado em backend
- Comprimento validado (1-5000 caracteres)
- Rate limiting (5 msgs/minuto)
- Spam detection
- Bloqueio de usuários

**Localização**:
- `lib/data/datasources/http_messages_datasource.dart` (cliente)
- Backend já implementado

---

## 🎯 PRIORIDADE 3️⃣ - MÉDIAS (Next sprint)

### Feature 3.1: Professional Search Aggregations

**Status**: 🟢 **OK** - Backend implementado

**Descrição**:  
Busca avançada com agregações.

**Status Atual**: ✅ Implementado
- Filtros: especialidade, cidade, rating, preço, experiência
- Score de relevância
- Paginação
- Cache

---

### Feature 3.2: User Profile Consolidation

**Status**: 🟡 **PARCIAL** - HTTP + Firebase misturado

**Descrição**:  
Consolidar CRUD de perfil de usuário.

**Dados Envolvidos**:
- Perfil básico (name, phone, address)
- Dados profissionais (especialidade, experiência)
- Preferências (cidade, horários)
- Foto de perfil

**Requisitos de Segurança**:
- ✅ Usuário só pode editar seu próprio perfil
- ✅ Admin pode editar qualquer perfil
- ✅ Auditoria de mudanças

**Localização no Frontend**:
- `lib/data/repositories/profile_repository_impl.dart` (usa HTTP + Firebase)
- `lib/presentation/screens/edit_profile_screen.dart`

**Ação Recomendada**:
```
Backend: Consolidar endpoints
  PATCH /api/v1/users/{userId}/profile
  PATCH /api/v1/users/{userId}/professional-profile
  PATCH /api/v1/users/{userId}/settings
```

---

### Feature 3.3: Audit Logging

**Status**: 🟡 **PARCIAL** - Estrutura existe, precisa de completude

**Descrição**:  
Auditoria centralized de ações críticas.

**Ações a Auditar**:
- ✅ Contract status changes
- ✅ Review submissions
- ✅ Message sending
- ⏳ Profile updates
- ⏳ Account deletions
- ⏳ Login/logout

**Localização**:
- `firestore.rules:299-310` (auditLogs collection definida)

**Ação Recomendada**:
```
Backend: Centralizar logs
  - Logging em Service Layer (backend)
  - Auditoria completa em Firebase
  - Retenção por 5 anos (LGPD)
```

---

## 🎯 PRIORIDADE 4️⃣ - BAIXAS (Future sprints)

### Feature 4.1: Notification System

**Status**: 🔴 **NÃO INICIADO**

**Descrição**:  
Sistema de notificações em tempo real.

**Eventos a Notificar**:
- Contract status change
- New message
- New review
- Account actions

---

### Feature 4.2: Payment Integration (Stripe/PagSeguro)

**Status**: 🔴 **NÃO INICIADO**

**Descrição**:  
Integração com provedor de pagamento.

**Requisitos**:
- PCI compliance
- Webhook handling
- Reconciliação

---

## 📋 CHECKLIST DE IMPLEMENTAÇÃO

### Para cada feature, o backend deve ter:

- [ ] **Endpoint HTTP** RESTful
- [ ] **Validação** completa de inputs
- [ ] **Autorização** (JWT + regras de negócio)
- [ ] **Transação ACID** (para múltiplos dados)
- [ ] **Error handling** com status codes apropriados
- [ ] **Logging/Auditoria** de ações
- [ ] **Retry logic** para operações falhas
- [ ] **Rate limiting** (se aplicável)
- [ ] **Testes unitários** (min 80% cobertura)
- [ ] **Documentação** (OpenAPI/Swagger)

---

## 🚀 PRÓXIMOS PASSOS

### Week 1: Feature 1.1 + 1.2 + 1.3
- Implementar Reviews Aggregation
- Implementar Contract Status Transitions
- Fortalecer Firestore Rules

### Week 2: Feature 2.1 + 2.2
- Consolidar Contract Validations
- Consolidar Review Validations

### Week 3: Feature 3.1 + 3.2 + 3.3
- Publicar Professional Search
- Profile Consolidation
- Audit Logging

---

## 📊 MATRIZ DE DEPENDÊNCIAS

```
Feature 1.1 (Reviews Agg)
  ├─ Backend implementation ✅
  └─ Firestore Rules 🔄

Feature 1.2 (Contract Status)
  ├─ Backend validation ✅
  └─ Firestore Rules 🔄

Feature 1.3 (Firestore Rules)
  ├─ Independente 🔄
  └─ Backend validations (1.1, 1.2)

Feature 2.1 (Contract Validations)
  ├─ Depende: 1.2 ✅
  └─ Backend ✅

Feature 2.2 (Review Validations)
  ├─ Depende: 1.1 ✅
  └─ Backend ✅

Feature 3.2 (Profile Consolidation)
  ├─ Independente
  └─ Frontend refactor needed
```

---

## 📝 NOTAS

- **Segurança Primeiro**: Nenhuma validação crítica no client-side
- **Backend Duplo**: Validação no UseCase + Backend (defesa em profundidade)
- **Sem Admin SDK**: Client não usa Admin SDK
- **Auditoria**: Todas as ações críticas devem ser auditadas
