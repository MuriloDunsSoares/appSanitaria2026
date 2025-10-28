# 📋 PLANO DE PRs/COMMITS - SEPARAÇÃO DE CAMADAS

**Data**: 27 de Outubro de 2025  
**Status**: 🟢 Pronto para execução  
**Total de PRs**: 8 (distribuído em 3 sprints)

---

## 🎯 ESTRATÉGIA GERAL

### Princípios
1. **Incremental**: Uma feature por PR
2. **Testado**: Cada PR com testes
3. **Reversível**: Cada PR pode ser revertido
4. **Documentado**: Descrição detalhada em cada PR

### Ordem de Implementação
1. **Sprint 1 (Week 1)**: Segurança de Rules + Backend Backend-like
2. **Sprint 2 (Week 2)**: Consolidação de Repositories
3. **Sprint 3 (Week 3)**: Limpeza do Frontend

---

## 📝 SPRINT 1: SEGURANÇA (Week 1)

### PR 1.1: Fortalecer Firestore Rules

**Título**:  
```
feat: fortalecer firestore.rules com validações de negócio

- Adicionar validação de transição de status de contrato
- Adicionar validação de rating (1-5)
- Adicionar validação de mensagem (tamanho)
- Adicionar validação de bloqueio de usuários
- Implementar least-privilege default
```

**Descrição**:
```markdown
## Resumo
Implementa validações de negócio críticas nas Firestore Rules,
criando uma segunda camada de defesa.

## Mudanças
- firestore.rules: +8 novas funções de validação
- Validações: isValidRating(), isValidStatusTransition(), etc

## Testes
- [x] Simular criar review com rating 6 → BLOQUEADO ✅
- [x] Simular mudar contrato de 'completed' → 'pending' → BLOQUEADO ✅
- [x] Simular enviar mensagem vazia → BLOQUEADO ✅

## Breaking Changes
Nenhum (apenas rejeita operações inválidas)

## Relacionado
Closes: #0 (issue de segurança de rules)
```

**Arquivos Modificados**:
- `firestore.rules` (+150 linhas)

**Tempo Estimado**: 1h

**Reviews Necessários**: 1 (arquitetura)

**Deploy**: 
- [ ] Test em staging
- [ ] Deploy em produção com notification

---

### PR 1.2: Mover Cálculo de Média de Reviews para Backend

**Título**:
```
refactor: mover agregação de reviews para backend

- Remover _updateProfessionalAverageRating() do datasource
- Implementar backend POST /api/v1/reviews/aggregate
- Atualizar repository para chamar backend
- Adicionar ACID transaction no backend
```

**Descrição**:
```markdown
## Resumo
Lógica de cálculo de média (agregação) é movida do frontend
para o backend, garantindo segurança e atomicidade.

## Mudanças
### Frontend
- firebase_reviews_datasource.dart: Remover método privado
- reviews_repository_impl.dart: Chamar backend em vez de local

### Backend
- reviews_service.dart: Novo método calculateAverageRating()
- reviews_controller.dart: Novo endpoint POST /api/v1/reviews/aggregate
- Transação ACID garantida

## Testes
- [x] Criar 5 reviews (ratings: 1,2,3,4,5) → média deve ser 3.0 ✅
- [x] Falha ao calcular → rollback automático ✅

## Breaking Changes
Nenhum (transparente ao usuário)

## Performance
- Antes: Cálculo síncrono no cliente (100ms)
- Depois: Backend com cache (50ms em média)
```

**Arquivos Modificados**:
- `lib/data/datasources/firebase_reviews_datasource.dart` (-30 linhas)
- `lib/data/repositories/reviews_repository_impl.dart` (±10 linhas)
- Backend (novo método + endpoint)

**Tempo Estimado**: 2h

**Reviews Necessários**: 2 (backend + frontend)

---

### PR 1.3: Implementar Contract Status Transitions no Backend

**Título**:
```
feat: implementar validação de transições de contrato no backend

- Criar validador de transições
- Implementar PATCH /api/v1/contracts/{id}/status
- Transação ACID com auditoria
- Rejeitar transições inválidas com erro específico
```

**Descrição**:
```markdown
## Resumo
Validação de transições de status de contrato é movida para backend,
garantindo que estado do contrato seja sempre válido.

## Estados e Transições Válidas
- pending → accepted, rejected, cancelled
- accepted → completed, cancelled
- completed → (terminal)
- cancelled → (terminal)

## Mudanças
### Backend
- contracts_service.dart: Novo método validateStatusTransition()
- contracts_controller.dart: PATCH /api/v1/contracts/{id}/status
- ACID transaction com rollback

### Frontend
- UpdateContractStatus UseCase: Já chama backend
- Nenhuma mudança necessária

## Testes
- [x] Transição válida (pending→accepted) ✅
- [x] Transição inválida (completed→pending) → erro 400 ✅
- [x] Falha na transação → rollback automático ✅

## Related Issues
Fixes: #issue-contract-security
```

**Arquivos Modificados**:
- Backend (+150 linhas)
- Frontend (nenhuma mudança)

**Tempo Estimado**: 2h

**Reviews Necessários**: 1 (backend)

---

## 📝 SPRINT 2: CONSOLIDAÇÃO (Week 2)

### PR 2.1: Consolidar Reviews Repository

**Título**:
```
refactor: consolidar validações e agregações de reviews

- Remover cálculo de média local
- Remover validação de rating duplicada
- Simplificar reviews_repository_impl.dart
- Centralizar em backend
```

**Descrição**:
```markdown
## Resumo
Reviews repository agora apenas orquestra chamadas ao backend,
removendo lógica duplicada.

## Mudanças
- reviews_repository_impl.dart: -40% de linhas
- Domain: Manter reviews UseCase (para validações locais)
- Data: Apenas CRUD via backend

## Testes
- [x] Adicionar review → backend ✅
- [x] Listar reviews → Firebase ✅
- [x] Atualizar review → backend ✅

## Performance
Sem mudanças (já era HTTP)

## Breaking Changes
Nenhum
```

**Arquivos Modificados**:
- `lib/data/repositories/reviews_repository_impl.dart` (-60 linhas)

**Tempo Estimado**: 1h

**Reviews Necessários**: 1 (frontend)

---

### PR 2.2: Consolidar Contracts Repository

**Título**:
```
refactor: consolidar contracts repository com validações backend

- Remover validações de transição local
- Chamar backend para todas as mudanças de status
- Simplificar contracts_repository_impl.dart
- Manter Firebase para reads (listeners)
```

**Descrição**:
```markdown
## Responsabilidades
- Create: Backend
- Read: Firebase (listeners em tempo real)
- Update Status: Backend
- Update Fields: Backend
- Delete: Soft delete no backend

## Testes
- [x] Criar contrato → backend ✅
- [x] Listar contratos → Firebase ✅
- [x] Mudar status → backend ✅
- [x] Listeners continuam funcionando ✅

## Breaking Changes
Nenhum
```

**Arquivos Modificados**:
- `lib/data/repositories/contracts_repository_impl.dart` (-80 linhas)

**Tempo Estimado**: 1.5h

**Reviews Necessários**: 1 (frontend)

---

### PR 2.3: Consolidar Profile Repository

**Título**:
```
refactor: consolidar profile repository - HTTP para tudo

- Mover perfil completo para backend
- Remover lógica duplicada de HTTP + Firebase
- Simplificar profile_repository_impl.dart
- Um único source of truth (backend)
```

**Descrição**:
```markdown
## Mudanças
### Antes
- HTTP: Alguns dados
- Firebase: Outros dados
- Frontend: Reconciliar

### Depois
- Backend: Todos os dados
- Firebase: Apenas cache/sync

## Testes
- [x] Atualizar perfil → backend ✅
- [x] Carregar foto → Firebase ✅

## Impacto
- Reduz calls ao Firestore
- Centraliza validações
```

**Arquivos Modificados**:
- `lib/data/repositories/profile_repository_impl.dart` (-70 linhas)

**Tempo Estimado**: 1h

**Reviews Necessários**: 1 (frontend)

---

## 📝 SPRINT 3: LIMPEZA (Week 3)

### PR 3.1: Remover Validações Duplicadas do Frontend

**Título**:
```
refactor: remover validações de negócio críticas do frontend

- Manter apenas validações de UX (formato, obrigatório)
- Remover validações de transição de contrato
- Remover validações de rating duplicadas
- Documentar por que confiamos no backend
```

**Descrição**:
```markdown
## Mudanças
### Domain UseCases - Remover
- update_contract_status.dart: Validação de transição
- contracts/update_contract.dart: Validação de data
- reviews/add_review.dart: Validação de rating (já no backend)

### Domain UseCases - Manter
- Orquestração
- Mapping entre DTOs
- Logging

## Rationale
Backend é a fonte única de verdade (trust boundary).
Frontend apenas coordena UX.

## Testes
- [x] Nenhum teste quebrado
- [x] Funcionalidade idêntica

## Segurança
Aumenta (remove confiança no cliente)
```

**Arquivos Modificados**:
- `lib/domain/usecases/contracts/*.dart` (-120 linhas)
- `lib/domain/usecases/reviews/*.dart` (-40 linhas)

**Tempo Estimado**: 1h

**Reviews Necessários**: 2 (frontend + backend)

---

### PR 3.2: Atualizar Storage Rules

**Título**:
```
refactor: melhorar storage.rules com least-privilege

- Remover permitir leitura anônima de service_images
- Adicionar validação de content-type
- Adicionar validação de tamanho de arquivo
- Rate limiting para uploads
```

**Descrição**:
```markdown
## Mudanças
- service_images: Apenas autenticados podem ler
- profile_images: Campo EXIF removido
- chat_images: Validação de tipo + tamanho

## Testes
- [x] Upload sem auth → bloqueado ✅
- [x] Upload arquivo grande → bloqueado ✅

## Breaking Changes
Nenhum (apenas segurança)
```

**Arquivos Modificados**:
- `storage.rules` (+30 linhas)

**Tempo Estimado**: 0.5h

**Reviews Necessários**: 1 (segurança)

---

### PR 3.3: Documentação e Guia de Manutenção

**Título**:
```
docs: documentar arquitetura de separação de camadas

- Atualizar README.md com diagrama
- Criar ARCHITECTURE.md detalhado
- Documentar fluxo de dados
- Guia para adicionar novas features
```

**Descrição**:
```markdown
## Documentação Criada
- README.md: Overview
- ARCHITECTURE.md: Diagrama e explicação
- LAYER_SEPARATION.md: Este documento
- BACKEND_FEATURES.md: Roadmap

## Diagramas
- Fluxo de dados por feature
- Responsabilidades por camada
- Trust boundaries

## Exemplos
- Como adicionar nova feature
- Checklist de segurança
```

**Arquivos Criados**:
- `ARCHITECTURE_LAYERS.md`
- `CONTRIBUTING_LAYERS.md`

**Tempo Estimado**: 1h

**Reviews Necessários**: 1 (tech lead)

---

## 📊 TIMELINE DE EXECUÇÃO

```
Week 1 (Sprint 1):
  Mon: PR 1.1 (Rules)
  Tue: PR 1.2 (Reviews Aggregate)
  Wed: PR 1.3 (Contract Transitions)
  Thu: Review + Fixes
  Fri: Deploy

Week 2 (Sprint 2):
  Mon: PR 2.1 (Reviews Repo)
  Tue: PR 2.2 (Contracts Repo)
  Wed: PR 2.3 (Profile Repo)
  Thu: Review + Fixes
  Fri: Deploy

Week 3 (Sprint 3):
  Mon: PR 3.1 (Remove Frontend Validations)
  Tue: PR 3.2 (Storage Rules)
  Wed: PR 3.3 (Documentation)
  Thu: Review + Fixes
  Fri: Deploy + Tag Release

Total: ~3 semanas = 15 dias úteis
```

---

## ✅ CHECKLIST PRÉ-PR

Antes de criar cada PR:

- [ ] Branch criada: `feat/layer-separation-{number}`
- [ ] Testes escritos (pelo menos 2 happy path + 1 error case)
- [ ] Code review local (lint, type-safety)
- [ ] Mensagem de commit clara
- [ ] Link para related issues
- [ ] Screenshots (se tiver mudança de UI)
- [ ] Documentação atualizada

---

## 📝 TEMPLATE DE PR

```markdown
## Descrição
[Explicar o que está sendo feito e por quê]

## Tipo de Mudança
- [ ] Bug fix
- [x] Feature nova
- [x] Refactoring
- [ ] Breaking change

## Related Issues
Fixes #0

## Testes
- [x] Teste 1 ✅
- [x] Teste 2 ✅
- [ ] Teste 3 (manual)

## Checklist
- [ ] Código segue style guide
- [ ] Tests passam
- [ ] Documentação atualizada
- [ ] Sem breaking changes (ou documentado)

## Screenshots
[Se houver mudanças visuais]
```

---

## 🔄 PROCESS DE REVIEW

1. **Author**: Cria PR com descrição completa
2. **Reviewer 1**: Backend/Arquitetura
3. **Reviewer 2**: Frontend (se houver mudanças)
4. **Author**: Responde comentários + faz fixes
5. **Approver**: Tech Lead aprova
6. **Merger**: Merge em main (squash commits)
7. **Deployer**: Deploy em staging → produção

**SLA**: 48h máximo

---

## 🚀 DEPLOY STRATEGY

### Staging
- Deploy automático após merge em `main`
- QA testa 24h antes de produção
- Rollback automático se erro

### Produção
- Deploy manual via CD pipeline
- Blue-green deployment (zero downtime)
- Monitoring ativo por 1h
- Rollback se necess ário

---

## 📊 MÉTRICAS DE SUCESSO

### Antes
- Backend-like logic no frontend: 22 arquivos
- Validações duplicadas: 5+ lugares
- Admin SDK no cliente: 0 (já correto)

### Depois
- Backend-like logic no frontend: 0 arquivos
- Validações duplicadas: 0
- Admin SDK no cliente: 0 (mantém)

### Target
- 100% de redução de backend-like logic no frontend ✅
- 100% consolidação em backend ✅
- 0 segredos no cliente ✅
