# 🎯 PROMPT PERFEITO PARA RESOLVER TUDO

**Copie e cole INTEIRO no próximo chat:**

---

# 📋 CONTEXTO DO PROJETO

## Status Atual (27 de Outubro de 2025)
```
✅ 0 ERROS DE COMPILAÇÃO
✅ 59 issues (apenas lint warnings/infos)
✅ Pronto para Deploy
```

## Histórico
1. **Sessão Anterior (Manhã):** Corrigimos 111 erros → 0 erros ✅
2. **Chats Intermediários:** Quebraram o código com mudanças inconsistentes
3. **Restauração:** Git reset --hard 1416fcb (voltamos ao estado limpo)
4. **Agora:** 0 erros, alguns warnings de estilo

---

## 🎯 OBJETIVO DESTA SESSÃO

**LIMPAR OS 59 WARNINGS/INFOS RESTANTES → DEIXAR 0 WARNINGS**

Meta: Production-ready 100% clean

---

## 📊 DETALHES DOS 59 ISSUES

### Breakdown
- ✅ **0 ERRORS** (compilação OK)
- ⚠️ **9 WARNINGS** (apenas style)
- ℹ️ **50 INFOS** (lint warnings)

### Categorias Principais

#### 1. TODOs com Formato Errado (10+ infos)
```dart
// ❌ ERRADO
// TODO: fazer algo
// todo: fazer algo

// ✅ CERTO
// TODO(usuario): fazer algo
// ignore: flutter_style_todos
```

**Arquivos:** contract_detail_screen.dart, conversations_screen.dart, etc.

#### 2. Print em Código de Produção (4+ infos)
```dart
// ❌ REMOVER TODOS OS:
print('[AuthProvider] algo...');

// ✅ SUBSTITUIR POR:
AppLogger.debug('[AuthProvider] algo...');
```

**Arquivo:** auth_provider_v2.dart

#### 3. Outros Warnings Pequeninhos
- `avoid_print` (4 instances)
- `flutter_style_todos` (10+ instances)
- `unawaited_futures` (2 instances)
- `unrelated_type_equality_checks` (1 instance)
- `use_build_context_synchronously` (1 instance)
- `prefer_null_aware_method_calls` (1 instance)

---

## ✅ INSTRUÇÕES PARA RESOLVER

### PASSO 1: Remover TODOs com Formato Errado

Buscar por: `// TODO:` ou `// todo:` ou `// TODO `

Substituir por:
- Ou adicionar `(usuario):` após TODO
- Ou remover se não é mais relevante
- Ou adicionar `// ignore: flutter_style_todos` antes

### PASSO 2: Remover print() de Produção

Buscar por: `print('`

Cada print precisa ser:
- Removido, OU
- Substituído por `AppLogger.debug()`

Arquivo principal: `lib/presentation/providers/auth_provider_v2.dart`

### PASSO 3: Corrigir Outros Warnings

Execute: `flutter analyze lib/` e corrija os warnings restantes

### PASSO 4: Verificar Status

```bash
flutter analyze lib/
```

Meta: **0 WARNINGS** (ou apenas 1-2 infos triviais)

---

## 🔒 REGRAS CRÍTICAS

### ✅ FAÇA
- ✅ Corrija warnings um por um
- ✅ Teste após cada mudança
- ✅ Verifique com `flutter analyze lib/`
- ✅ Crie commit após terminar

### ❌ NÃO FAÇA
- ❌ Não adicione features novas
- ❌ Não mude lógica de negócio
- ❌ Não remova métodos sem substituir
- ❌ Não faça mudanças em múltiplos arquivos sem coordenar

### 🔄 SE QUEBRAR
```bash
git reset --hard 1416fcb
```

---

## 📝 PLANO DE EXECUÇÃO

```
FASE 1: TODOs (5 min)
├─ Buscar // TODO com formato errado
├─ Adicionar (usuario): ou remover
└─ Verificar

FASE 2: Print Statements (5 min)
├─ Remover ou substituir por AppLogger
└─ Verificar em auth_provider_v2.dart

FASE 3: Outros Warnings (5-10 min)
├─ unawaited_futures → adicionar await
├─ unrelated_type_equality_checks → corrigir tipo
├─ use_build_context_synchronously → refatorar
└─ prefer_null_aware_method_calls → substituir

FASE 4: Verificação Final (2 min)
├─ flutter analyze lib/
├─ Conferir 0 warnings
└─ Commit

Total: ~20-30 minutos
```

---

## 📊 ARQUIVOS IMPORTANTES

- `SESSAO_CORRECOES_27_10_2025.md` - Histórico detalhado (111 erros → 0)
- `ESTADO_LIMPO_GIT_REFERENCE.md` - Como fazer reset se quebrar
- `PROXIMA_SESSAO_WARNINGS.md` - Análise detalhada dos warnings

---

## 🚀 APÓS TERMINAR

1. Commit com mensagem: `refactor: limpar últimos 59 warnings de lint`
2. Teste com `flutter analyze lib/`
3. Pronto para BUILD e DEPLOY

---

## ⚠️ IMPORTANTE

**Este é o ESTADO ESTÁVEL.**

Se algo quebrar, IMEDIATAMENTE faça:
```bash
git reset --hard 1416fcb
```

Não tente consertar - volta e recomeça.

---

**Data:** 27 de Outubro de 2025  
**Status:** ✅ Pronto para Limpeza Final  
**Tempo Estimado:** 20-30 minutos  
**Dificuldade:** Fácil/Automática
