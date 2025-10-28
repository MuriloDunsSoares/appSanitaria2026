# 📝 Template Otimizado - Novo Chat (COPIE E COLE)

## 🎯 PRIMEIRA MENSAGEM - Contexto Completo

Copie e cole EXATAMENTE isto:

---

```
PROJETO: App Sanitária (Flutter + Firebase + Backend Dart)
STATUS: Fase 1-3 completas ✅ | Fase 4 com 228 erros compilação ❌

PROBLEMA:
- 228 erros de compilação reportados
- MAS: causados por apenas 4 erros raiz com cascata
- Objetivo: Resolver estruturadamente em 4 fases

OS 4 ERROS RAIZ:

1. ERRO: Método removido ainda na interface
   - Arquivo: lib/domain/repositories/reviews_repository.dart
   - Problema: getAverageRating() removido de impl, mas interface pede
   - Solução: Remover da interface
   - Tempo: 1 minuto

2. ERRO: Enum faltando valores
   - Arquivo: lib/domain/entities/contract_status.dart
   - Problema: Código usa ContractStatus.accepted/rejected mas não existem
   - Solução: Adicionar accepted e rejected ao enum
   - Tempo: 5 minutos

3. ERRO: UseCase com parâmetros novos
   - Arquivo: lib/domain/usecases/contracts/update_contract_status.dart
   - Problema: Agora requer userId e userRole (adicionados em Sprint 3)
   - Solução: Todos UpdateContractStatusParams precisam passar esses parâmetros
   - Tempo: 30 minutos (buscar todos os usos)

4. ERRO: Provider não passa parâmetros
   - Arquivo: lib/presentation/providers/contracts_provider_v2.dart
   - Problema: Linha 112 cria UpdateContractStatusParams sem userId/userRole
   - Solução: Obter userId e userRole de auth context + passar
   - Tempo: 10 minutos

PLANO: 4 FASES ESTRUTURADAS (1 hora total)

FASE 1 (5 min):
  └─ Adicionar enum values
  └─ Arquivo: lib/domain/entities/contract_status.dart
  └─ Depois: flutter analyze (muitos erros desaparecem)

FASE 2 (30 min):
  └─ Passar userId + userRole
  └─ Arquivo: lib/presentation/providers/contracts_provider_v2.dart
  └─ IMPORTANTE: grep -r "UpdateContractStatusParams(" lib/ (encontrar TODOS)
  └─ Depois: flutter analyze (erros de parâmetros desaparecem)

FASE 3 (10 min):
  └─ Remover getAverageRating() da interface
  └─ Arquivo: lib/domain/repositories/reviews_repository.dart
  └─ Depois: flutter analyze (interface error desaparece)

FASE 4 (10 min):
  └─ Validação final
  └─ flutter clean && flutter pub get && flutter analyze
  └─ Esperado: 0 errors

TENHO 2 DOCUMENTOS ANEXADOS:
1. ERRO_DIAGNOSTICO_FRONTEND.md - Análise completa de cada erro
2. INSTRUCOES_NOVO_CHAT_FIXES.md - Instruções fase a fase

VAMOS COMEÇAR PELA FASE 1? 
Peço que você me guie passo a passo conforme estruturado.
```

---

## 🎯 SEGUNDA MENSAGEM - Anexar Documentos

Após a primeira mensagem, envie:

```
Aqui estão os 2 documentos com análise completa:

[COLE CONTEÚDO DE ERRO_DIAGNOSTICO_FRONTEND.md AQUI]

[COLE CONTEÚDO DE INSTRUCOES_NOVO_CHAT_FIXES.md AQUI]

Pronto! Vamos começar?
```

---

## 🎯 TERCEIRA MENSAGEM - Começar Fase 1

```
FASE 1: Enum Fix

REQUERIMENTO:
- Arquivo: lib/domain/entities/contract_status.dart
- Encontrar: enum ContractStatus { ... }
- Adicionar: accepted e rejected se não existem

ME PEDE:
1. Leia o arquivo EXATAMENTE como está agora
2. Mostre a struct do enum atual
3. Crie a versão corrigida
4. Diga qual é a mudança (linhas antes/depois)

PRONTO? Cole o arquivo e a versão corrigida.
```

---

## 🎯 QUARTA MENSAGEM - Após Cada Fix

```
FIZ FASE 1. RESULTADO:
[Cole saída do flutter analyze aqui]

PRÓXIMA: FASE 2 - Provider Fix
```

---

## 💡 PADRÕES DE COMUNICAÇÃO (Melhor Resultado)

### ✅ BOM EXEMPLO:

```
ARQUIVO: lib/domain/entities/contract_status.dart

ENCONTREI:
enum ContractStatus {
  pending,
  completed,
  cancelled,
}

PRECISO:
Adicionar accepted e rejected

ESPERADO DEPOIS:
enum ContractStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
}

CERTO?
```

### ❌ RUIM EXEMPLO:

```
Arruma o enum
```

---

## 📋 ESTRUTURA MELHOR PARA CADA FASE

### FASE 1 - Enum Fix:

```
PASSO 1: Ler arquivo
"Leia lib/domain/entities/contract_status.dart completo"

PASSO 2: Mostrar estrutura
"Mostre como está agora"

PASSO 3: Versão corrigida
"Crie versão com accepted e rejected adicionados"

PASSO 4: Confirmar
"Isto está certo?"

PASSO 5: Aplicar
"Aplique a mudança"

PASSO 6: Testar
"flutter analyze - mostra quantos erros?"
```

### FASE 2 - Provider Fix:

```
PASSO 1: Encontrar todos os usos
"Qual é a saída de: grep -r 'UpdateContractStatusParams(' lib/"

PASSO 2: Para cada uso
"Mostre: [uso 1], [uso 2], ... [uso N]"

PASSO 3: Versão corrigida de cada
"Corrija cada um passando userId e userRole"

PASSO 4: Confirmar
"Fiz correto? Todos têm userId e userRole?"

PASSO 5: Aplicar
"Aplique as mudanças"

PASSO 6: Testar
"flutter analyze - quantos erros restam?"
```

---

## 🎯 DICAS PARA MÁXIMA EFICIÊNCIA

### 1. SER ESPECÍFICO
```
❌ "Arruma isso"
✅ "Adicione accepted e rejected ao enum ContractStatus em lib/domain/entities/contract_status.dart"
```

### 2. FORNECER CONTEXTO
```
❌ "Erro no arquivo"
✅ "ERRO: Required named parameter 'userId' must be provided.
     ARQUIVO: lib/presentation/providers/contracts_provider_v2.dart:112
     CAUSA: UpdateContractStatusParams agora requer userId e userRole"
```

### 3. PEDIR CONFIRMAÇÃO
```
❌ "Faça e pronto"
✅ "Isto está certo? [mostre resultado]
     Continuo para fase 2?"
```

### 4. TESTAR APÓS CADA PASSO
```
❌ "Tudo pronto"
✅ "Fiz fase 1. Rodei flutter analyze.
     Resultado: [cole saída]
     Próxima fase?"
```

### 5. REFERENCIAR DOCUMENTAÇÃO
```
❌ "Como faz?"
✅ "Conforme ERRO_DIAGNOSTICO_FRONTEND.md linha 150, preciso..."
```

---

## 📞 SE FICAR PRESO

### Bom Jeito:

```
PRESO EM: [qual parte]
ERRO: [cola erro exato]
ARQUIVO: [arquivo problemático]
O QUE FIZ: [o que tentou]
RESULTADO: [o que aconteceu]

PRÓXIMO: [o que gostaria de fazer]
```

### Ruim Jeito:

```
Não funcionou
```

---

## ✨ FINAL DA SESSÃO

```
COMPLETEI TODAS 4 FASES!

RESULTADO FINAL:
[Cola saída de flutter analyze]

ANTES: 228 erros, 113 warnings
DEPOIS: [N] erros, [N] warnings

SUCESSO? SIM ✅ / NÃO ❌

PRÓXIMO: [o que vem depois]
```

---

## 🎬 SEQUÊNCIA COMPLETA (Do Início ao Fim)

```
1. MENSAGEM 1: Contexto + 4 erros + plano
   └─ Espera resposta

2. MENSAGEM 2: Anexar 2 documentos
   └─ Espera reconhecimento

3. MENSAGEM 3: FASE 1 - Enum
   └─ Fazer mudança
   └─ Testar

4. MENSAGEM 4: FASE 2 - Provider
   └─ Fazer mudança
   └─ Testar

5. MENSAGEM 5: FASE 3 - Interface
   └─ Fazer mudança
   └─ Testar

6. MENSAGEM 6: FASE 4 - Validação
   └─ Flutter analyze final
   └─ Confirmar 0 erros

7. MENSAGEM 7: Próximas ações
   └─ Backend? Deploy?
```

---

## 💡 REGRA DE OURO

**Depois de CADA mudança:**

```
"flutter analyze"
Cole a saída
"Quantos erros restam?"
```

Isto prova que:
- ✅ Mudança foi aplicada
- ✅ Erros diminuem
- ✅ Progresso está acontecendo

---

## 📊 Esperado em Cada Fase

```
FASE 1: 228 erros → ~150 erros (enum fix)
FASE 2: 150 erros → ~10 erros (provider fix)
FASE 3: 10 erros → ~2 erros (interface fix)
FASE 4: 2 erros → 0 erros ✅
```

Se não diminuir, algo está errado. Peça help!

---

## 🎯 IMPORTANTE - Não Faça Assim

```
❌ "Arruma tudo"
❌ "Corrija os erros"
❌ "Faça a compilação passar"
❌ "Não sei qual é o problema"
```

**FAÇA ASSIM:**

```
✅ "FASE 1: Adicione accepted e rejected ao enum ContractStatus"
✅ "Antes [mostra código]. Depois [mostra código]. Certo?"
✅ "Aplique. Resultado: [flutter analyze output]"
✅ "Próxima fase 2?"
```

---

**RESUMO: Seja específico, forneça contexto, teste, confirme, siga adiante.**

