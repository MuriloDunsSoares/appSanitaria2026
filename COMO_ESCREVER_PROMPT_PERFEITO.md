# 🎯 COMO ESCREVER UM PROMPT PERFEITO PARA O AI

## Problema Atual
Você escreve prompts vagos → AI faz coisas erradas → projeto quebra

## Solução
Use a estrutura abaixo para SEMPRE dar prompts PERFEITOS

---

## 📋 ESTRUTURA DO PROMPT PERFEITO

```
1. CONTEXTO (O que é este projeto?)
2. STATUS (Qual é o estado atual?)
3. OBJETIVO (O que você quer fazer?)
4. RESTRIÇÕES (O que NÃO fazer?)
5. PLANO (Como fazer?)
6. VERIFICAÇÃO (Como saber se funcionou?)
7. EMERGÊNCIA (Se quebrar, o que fazer?)
```

---

## ✅ EXEMPLO 1: PROMPT BOM

```
CONTEXTO:
App Sanitária Flutter com Clean Architecture. 
Estamos na fase final de limpeza.

STATUS ATUAL:
- ✅ 0 erros de compilação
- ⚠️ 9 warnings (apenas style)
- ℹ️ 50 infos (lint)

OBJETIVO:
Remover os 4 print statements do arquivo auth_provider_v2.dart

RESTRIÇÕES:
- NÃO remova lógica de negócio
- NÃO adicione novos métodos
- NÃO mude nada além de print() → AppLogger.debug()

PLANO:
1. Abrir lib/presentation/providers/auth_provider_v2.dart
2. Encontrar todos os print('
3. Substituir por AppLogger.debug(
4. Verificar com flutter analyze lib/

VERIFICAÇÃO:
flutter analyze lib/ → deve mostrar 0 warnings de print

EMERGÊNCIA:
Se quebrar: git reset --hard 1416fcb
```

---

## ❌ EXEMPLO 2: PROMPT RUIM

```
"Arruma os erros"
```

Por que está ruim?
- Não diz qual erro
- Não diz quantos erros
- Não dá contexto
- AI vai inventar soluções

---

## 🎯 CHECKLIST: SEU PROMPT TEM TUDO ISSO?

- [ ] **CONTEXTO?** Expliquei qual é o projeto?
- [ ] **STATUS?** Disse qual é o estado atual? (0 erros, X warnings)
- [ ] **OBJETIVO?** Deixei claro o que fazer?
- [ ] **RESTRIÇÕES?** Disse o que NÃO fazer?
- [ ] **PLANO?** Dei um passo-a-passo?
- [ ] **VERIFICAÇÃO?** Como saber se funcionou?
- [ ] **EMERGÊNCIA?** O que fazer se quebrar?

Se faltou algo → **SEU PROMPT ESTÁ INCOMPLETO**

---

## 📚 TEMPLATE PARA COPIAR E COLAR

```markdown
# 🎯 TAREFA PARA O AI

## CONTEXTO
[Explique qual é o projeto e a situação]

## STATUS ATUAL
[flutter analyze lib/ output]

## OBJETIVO
[O que você quer que o AI faça? Seja específico]

## RESTRIÇÕES (MUITO IMPORTANTE)
- ❌ NÃO faça X
- ❌ NÃO mude Y
- ❌ NÃO remova Z

## PLANO (PASSO A PASSO)
1. Fazer isso
2. Depois isso
3. Por fim isso

## VERIFICAÇÃO
[Como saber que funcionou?]

## EMERGÊNCIA
[Se quebrar, execute: git reset --hard COMMIT_HASH]

## REFERÊNCIAS
- [Link para documento anterior]
- [Link para guia]
```

---

## 💡 DICAS DE OURO

### 1. Seja ESPECÍFICO
❌ "Arruma o erro"
✅ "Remova o import não utilizado de package:flutter/foundation.dart na linha 3 de firebase_service.dart"

### 2. Dê CONTEXTO
❌ "Faz uma coisa"
✅ "Este arquivo faz autenticação com Firebase. Preciso remover o método deleteAccount() porque o arquivo delete_account.dart não existe"

### 3. Use RESTRIÇÕES
❌ "Conserta tudo"
✅ "Conserta MAS não mude a lógica de negócio, não adicione métodos, não remova nada"

### 4. Sempre VERIFIQUE
❌ Não diz como saber se funcionou
✅ "Depois execute flutter analyze lib/ e confirme 0 erros"

### 5. SEMPRE tenha PLANO B
❌ "Se quebrar, me avise"
✅ "Se quebrar, execute: git reset --hard 1416fcb"

---

## 🔧 EXEMPLO PERFEITO PARA SEU PROJETO

```markdown
# 🎯 LIMPAR 4 PRINT STATEMENTS

## CONTEXTO
App Sanitária Flutter. Clean Architecture. Fase final de limpeza.

## STATUS ATUAL
- ✅ 0 erros de compilação
- ⚠️ 4 warnings (print em produção)
```bash
flutter analyze lib/ | grep avoid_print
```

## OBJETIVO
Remover os 4 `print()` do arquivo auth_provider_v2.dart substituindo por `AppLogger.debug()`

## RESTRIÇÕES
- ❌ NÃO remova a função `_checkSession()`
- ❌ NÃO mude nenhuma lógica
- ❌ NÃO adicione métodos novos
- ❌ Apenas: print() → AppLogger.debug()

## PLANO
1. Abrir lib/presentation/providers/auth_provider_v2.dart
2. Encontrar todos: print('[AuthProvider]
3. Substituir por: AppLogger.debug('[AuthProvider]
4. Verificar com flutter analyze lib/

## VERIFICAÇÃO
flutter analyze lib/ | grep avoid_print → deve estar vazio

## EMERGÊNCIA
git reset --hard 1416fcb
```

---

## 🚀 RESUMO

**Sempre use esta ordem quando escrever prompt:**

1. **CONTEXTO** → Qual é a situação?
2. **STATUS** → Qual é o estado?
3. **OBJETIVO** → O que fazer?
4. **RESTRIÇÕES** → O que não fazer?
5. **PLANO** → Como fazer?
6. **VERIFICAÇÃO** → Como confirmar?
7. **EMERGÊNCIA** → Plano B?

**Se você não conseguir escrever os 7 pontos, seu prompt ainda não está pronto!**

---

**Data:** 27 de Outubro de 2025  
**Dificuldade:** ⭐ Fácil (mas MUITO importante)  
**Impacto:** Evita 90% dos problemas
