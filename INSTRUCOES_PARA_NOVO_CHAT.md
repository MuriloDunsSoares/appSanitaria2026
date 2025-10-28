# 📝 Instruções para o Novo Chat - Backend Implementation

## Como Começar o Novo Chat (COPIE E COLE ISTO)

Quando você abrir um novo chat, copie e cole o seguinte:

---

### **MENSAGEM PARA COLAR NO NOVO CHAT:**

```
Vou implementar o backend para um projeto Flutter/Firestore existente.

CONTEXTO:
- Projeto: App Sanitária (plataforma de serviços de limpeza)
- Frontend: 100% production-ready com validações em UseCases
- Firestore Rules: Já implementadas com 8 validações de segurança
- Próxima fase: Backend para 2 serviços críticos

NECESSÁRIO:
1. Backend em Dart (shelf ou dart_server)
2. 2 Controllers com 4 endpoints HTTP
3. 2 Services com ACID transactions no Firestore
4. JWT validation
5. Audit logging

ARQUIVOS PARA ANEXAR:
1. BACKEND_IMPLEMENTATION_FOR_NEW_CHAT.md (especificação completa)
2. PR_1_2_BACKEND_SPEC.md (spec detalhada - Reviews)
3. PR_1_3_BACKEND_SPEC.md (spec detalhada - Contracts)

QUER QUE EU ANNEXE ESSES 3 ARQUIVOS AGORA PARA VOCÊ COMEÇAR?
```

---

## Por que dividir em 2 chats?

### Problema do Contexto Longo:
- Chat anterior tinha 12+ horas de work
- Muita informação acumulada
- Pode confundir o AI ao implementar backend
- Melhor: Fresh start com contexto limpo

### Benefício do Novo Chat:
- ✅ Contexto fresco apenas com backend
- ✅ Melhor foco em implementação
- ✅ Menos chance de confusão
- ✅ Mais eficiente

---

## O Que Você Deve Dizer no Novo Chat

### **1º Mensagem: Apresentar o Contexto**

```
Vou implementar backend em Dart para um projeto existente.

CONTEXTO RESUMIDO:
• Frontend: Flutter (production-ready)
• Database: Firestore (já com validações)
• Fase 1: 100% completa (frontend + rules)
• Fase 2: Backend (o que vamos fazer agora)

ESCOPO DO BACKEND:
1. ReviewsService - calcular média de avaliações com ACID
2. ContractsService - validar transições de status com ACID
3. ReviewsController - 1 endpoint HTTP
4. ContractsController - 2 endpoints HTTP
5. AuthService - validar JWT
6. AuditService - registrar auditoria

ENTREGO 3 ARQUIVOS COM ESPECIFICAÇÃO COMPLETA:
1. Guia geral (BACKEND_IMPLEMENTATION_FOR_NEW_CHAT.md)
2. Reviews spec com código (PR_1_2_BACKEND_SPEC.md)
3. Contracts spec com código (PR_1_3_BACKEND_SPEC.md)

PRONTO PARA COMEÇAR?
```

---

### **2º Mensagem: Entregar os Arquivos**

Cole os 3 arquivos (em ordem):

1. Primeiro: Conteúdo de `BACKEND_IMPLEMENTATION_FOR_NEW_CHAT.md`
2. Depois: Conteúdo de `PR_1_2_BACKEND_SPEC.md`
3. Depois: Conteúdo de `PR_1_3_BACKEND_SPEC.md`

Termine com:

```
AGORA TEMOS TUDO MAPEADO!

PRIORIDADE:
1. Phase 1 (Setup) - Estrutura básica
2. Phase 2-3 (Auth + Audit) - Serviços de suporte
3. Phase 4-5 (Reviews) - Primeiro serviço completo
4. Phase 6-7 (Contracts) - Segundo serviço completo
5. Phase 8 (Tests) - Testes e deploy

VAMOS COMEÇAR PELA PHASE 1? FALE "SIM" E VOU IMPLEMENTAR A ESTRUTURA INICIAL
```

---

### **3º Mensagem em Diante: Ir Implementando**

Uma vez que começar, siga o padrão:

```
PHASE 2: Implementar AuthService

REQUISITOS:
- Validar JWT tokens
- Decodificar e verificar assinatura
- Checar expiração
- Retornar userId

ARQUIVO: backend/lib/features/auth/domain/services/auth_service.dart

COMECE:
```

---

## 🎯 Estratégia de Implementação

### **Ordem Recomendada:**

```
1. SETUP (1h)
   └─ Criar estrutura, configurar Firebase

2. AUTH SERVICE (1h)
   └─ Validar JWT

3. AUDIT SERVICE (1h)
   └─ Registrar ações

4. REVIEWS (3h)
   ├─ ReviewsService
   ├─ ReviewsController
   └─ Testes

5. CONTRACTS (3h)
   ├─ ContractsService
   ├─ ContractsController
   └─ Testes

6. DEPLOY (1h)
   └─ Staging + validação
```

---

## 📋 Checklist Durante Implementação

Em cada phase, peça ao AI:

```
CHECKLIST PARA PHASE X:
- [ ] Arquivo criado com estrutura
- [ ] Métodos principais implementados
- [ ] ACID transaction (se aplicável)
- [ ] Error handling completo
- [ ] Unit tests
- [ ] Comentários inline

PRÓXIMA: PHASE X+1
```

---

## 🔄 Se Algo Der Errado

Se ficar preso no novo chat:

1. **Volte para esse chat** e diga:
   "Tive um problema com [X]. Preciso rever algo do contexto anterior."

2. **Ou crie um novo chat** com:
   - Descrição do erro
   - O que estava fazendo
   - Arquivo que gera erro
   - Mensagem de erro completa

3. **Cole os arquivos relevantes** do novo chat

---

## 💡 Dicas para Melhor Resultado

### No Novo Chat:

1. **Seja específico**: "Implementar Phase 2" é melhor que "começar"
2. **Referencie o spec**: "Ver BACKEND_IMPLEMENTATION_FOR_NEW_CHAT.md linha X"
3. **Cole blocos pequenos**: Pedir tudo de uma vez é difícil
4. **Valide depois**: Pedir testes após cada file
5. **Peça review**: "Revisa esse código?" para qualidade

### Exemplo Boa Mensagem:

```
PHASE 4: Implementar ReviewsService

REQUISITOS (do spec):
- Calcular média de ratings
- ACID transaction (update professional + audit log)
- Error handling
- Retornar Map com: { professionalId, average, count }

COMEÇAR COM O MÉTODO calculateAverageRating()
INCLUIR COMENTÁRIOS EXPLICANDO CADA PASSO
```

### Exemplo Mensagem Ruim:

```
fazer o backend
```

---

## 📞 Quando Voltar Para Este Chat

Volte aqui apenas para:
- [ ] Dúvidas sobre frontend (não backend)
- [ ] Dúvidas sobre arquitetura geral
- [ ] Confirmar algo do contexto anterior
- [ ] Quando terminar: para fazer deploy

---

## ✅ Depois de Pronto

Quando terminar o backend no novo chat:

1. Crie um novo commit com todo o código
2. Volte para este chat e faça deploy final
3. Testaremos frontend + backend + firestore juntos

---

## 🎉 Resumo Executivo

**O que fazer:**
1. ✅ Abra novo chat
2. ✅ Cole a mensagem de contexto
3. ✅ Anexe os 3 arquivos
4. ✅ Siga o plano passo a passo
5. ✅ Quando pronto, volte aqui

**Tempo estimado**: 8-10 horas

**Resultado**: Backend 100% production-ready

**Próximo**: Deploy final (frontend + backend + firestore = 3 camadas segurança)

---

**Created**: 27 October 2025  
**Purpose**: Backend implementation guide  
**Status**: Ready to use
