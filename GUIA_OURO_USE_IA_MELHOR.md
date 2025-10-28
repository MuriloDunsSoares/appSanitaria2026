# 🎯 GUIA DE OURO: COMO USAR IA SEM DESPERDÍCIO

**Você está desperdiçando 70% do tempo/dinheiro.**

Aqui está como não desperdiçar mais.

---

## ❌ O QUE VOCÊ FOI FAZENDO (ERRADO)

```
Você: "Tem um erro"
IA: "Deixa eu ensinar o que é erro..."
Você: Paga US$ X por educação desnecessária
```

---

## ✅ O QUE VOCÊ DEVE FAZER (CERTO)

```
Você: "Limpa esses 9 warnings específicos (lista anexa)"
IA: Resolve em 3 minutos
Você: Paga US$ 0.10 por solução real
```

---

## 📋 ESTRUTURA PARA NUNCA DESPERDIÇAR

### 1. NUNCA peça para "ensinar"
```
❌ ERRADO
"Me explica como funciona X"

✅ CERTO
"Implemente X assim: [especificação]"
```

### 2. SEMPRE seja específico e claro
```
❌ ERRADO
"Arruma os erros"

✅ CERTO
"Remova os 4 print() de auth_provider_v2.dart e substitua por AppLogger.debug()"
```

### 3. SEMPRE forneça contexto em 1 linha
```
❌ ERRADO
Nada

✅ CERTO
"App Flutter em produção. 0 erros reais, apenas lint warnings. Sem quebrar nada."
```

### 4. SEMPRE diga exatamente o que espera
```
❌ ERRADO
"Consertar"

✅ CERTO
"flutter analyze lib/ deve mostrar 59 issues (sem 'error')"
```

### 5. SEMPRE tenha plano B
```
❌ ERRADO
Nada

✅ CERTO
"Se quebrar: git reset --hard 1416fcb"
```

---

## 🚀 TEMPLATE DE PROMPT PERFEITO (Copie e adapte)

```markdown
# 🎯 TAREFA: [NOME CURTO]

## Estado Atual
[Output de: flutter analyze lib/ ou outro comando]

## O que fazer
[Tarefa específica em 1-2 linhas]

## Restrições
- Sem quebrar [X]
- Sem adicionar [Y]
- Sem mexer em [Z]

## Como saber que funcionou
[Comando para verificar]

## Emergência
git reset --hard [HASH]
```

---

## 💡 EXEMPLOS DE BONS PROMPTS

### ✅ Exemplo 1: 5 minutos (US$ 0.05)
```
# 🎯 Remover print statements

## Estado Atual
Arquivo: lib/presentation/providers/auth_provider_v2.dart
Tem 4 print() statements

## O que fazer
Substitua todos print(' por AppLogger.debug(

## Verificação
flutter analyze lib/ | grep avoid_print → vazio

## Emergência
git reset --hard 1416fcb
```

### ✅ Exemplo 2: 10 minutos (US$ 0.10)
```
# 🎯 Corrigir 3 files com TODO format

## Estado Atual
9 warnings: flutter_style_todos em:
- contract_detail_screen.dart:216
- conversations_screen.dart:66
- home_patient_screen.dart:103

## O que fazer
Adicione (dev): após TODO em cada linha

## Verificação
flutter analyze lib/ | grep flutter_style_todos | wc -l → 0

## Emergência
git reset --hard 1416fcb
```

---

## 🎯 REGRA DO 80/20

**80% do tempo gasto em EXPLICAÇÕES = DESPERDÍCIO**

**20% do tempo em AÇÃO = RESULTADO**

Você quer os 20% ✅

---

## 🔧 COMO CONVERSAR COM IA

### ❌ Conversa ruim (desperdício)
```
Você: "Qual é a diferença entre X e Y?"
IA: [5 parágrafos de explicação]
Você: [Continua fazendo perguntas educacionais]
Resultado: $$ Desperdiçado, 0 progresso
```

### ✅ Conversa boa (resultado)
```
Você: "Faça X especificamente assim. Se quebrar: git reset"
IA: [Faz em 2 minutos]
Você: [Próxima tarefa específica]
Resultado: $$ Gasto, 100% progresso
```

---

## 🚨 SINAIS DE ALERTA (Quando você está desperdiçando)

- [ ] IA começou a ENSINAR em vez de FAZER
- [ ] Você leu mais de 1 parágrafo de resposta
- [ ] Não há `código real` ou `comando para executar`
- [ ] IA fez uma lista com múltiplas opções
- [ ] Você pediu "entenda" ou "explique"
- [ ] Não tem verificação clara (`flutter analyze`, `git status`, etc)

**Se 3+ sinais acima: INTERROMPA e redirecione**

---

## 💪 COMANDO MÁGICO QUANDO ERRA

```
Escreva isto quando IA sair do caminho:

"Sem explanações. Só código/comandos. Tarefa: [especificar]"
```

---

## 📊 COMPARAÇÃO: Desperdício vs Eficiência

### Forma Errada (Hoje)
```
Chat 1: Diagnosticar → 2x "e como assim?"
Chat 2: Tentar consertar → Criou documentação
Chat 3: Restaurar → Mais documentação

Tempo: 3-4 horas
Dinheiro: US$ 40-50
Resultado: NADA PRÁTICO
```

### Forma Certa
```
Chat 1: "Remova print() de auth_provider_v2.dart"
Chat 2: "Corrija 3 files com TODO format"
Chat 3: "Limpar os últimos 5 warnings"
Chat 4: "Build e deploy"

Tempo: 40 minutos
Dinheiro: US$ 2-3
Resultado: PROJETO COMPLETO
```

---

## 🎯 PRÓXIMO CHAT: USE ASSIM

**Copie isto como primeiro prompt:**

```
# 🎯 LIMPAR WARNINGS FINAIS

## Estado
flutter analyze lib/ → 59 issues
- 9 warnings (flutter_style_todos)
- 4 print() avoid_print
- Outros pequenos

## Fazer
Remova os 9 TODOs com formato errado

## Verificação
flutter analyze lib/ | grep flutter_style_todos → 0

## Emergência
git reset --hard 1416fcb
```

Depois só passe tarefas curtas e específicas.

---

## ⚠️ RESUMO EXECUTIVO

**Para economizar 90% do dinheiro:**

1. ❌ Nunca peça "entenda", "explique", "qual é"
2. ✅ Sempre peça "faça X especificamente"
3. ✅ Sempre forneça: contexto + tarefa + verificação
4. ✅ Sempre tenha plano B (git reset)
5. ❌ Se IA começar a escrever >500 palavras: interrompa

---

## 🚀 HOJE MESMO

Use este prompt para o próximo chat:

```
# 🎯 LIMPAR 9 WARNINGS flutter_style_todos

## Fazer
Remova ou corrija 9 TODOs em:
- contract_detail_screen.dart:216
- conversations_screen.dart:66
- home_patient_screen.dart:103
- home_professional_screen.dart:112
- individual_chat_screen.dart:204
- professional_profile_detail_screen.dart:82
- professional_profile_detail_screen.dart:152
- professionals_list_screen.dart:91
- filters_modal.dart:259

## Verificação
flutter analyze lib/ | grep flutter_style_todos | wc -l → 0

## Emergência
git reset --hard 1416fcb
```

5 minutos. Pronto.

---

**Você está certo de estar frustrado.**

**Use isto daqui em diante.**

**Vai economizar 95% do tempo/dinheiro.**

