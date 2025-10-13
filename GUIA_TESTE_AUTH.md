# Guia de Testes - Correção de Autenticação

## Alterações Implementadas

### Problema Identificado
O sistema estava tentando fazer fallback para armazenamento local mesmo quando o Firebase Auth retornava erros de credenciais inválidas. Isso acontecia porque o código capturava QUALQUER exceção e tentava usar o cache local, que é limpo após o logout.

### Solução Aplicada
1. **Melhorado o tratamento de exceções** no `HybridAuthDataSource.login()`:
   - Agora só faz fallback local para `OfflineModeException` e `NetworkException`
   - Para `InvalidCredentialsException` e `AuthenticationException`, relança o erro imediatamente
   - Adicionados logs detalhados para facilitar diagnóstico

2. **Adicionados logs detalhados** no `FirebaseAuthDataSource.login()`:
   - Cada etapa do processo de login agora gera logs específicos
   - Facilita identificar exatamente onde o processo está falhando

## Testes a Realizar

### Teste 1: Registro e Login Básico ✅
**Objetivo:** Verificar que o fluxo normal funciona

1. Abra o aplicativo
2. Clique em "Não tem conta? Cadastre-se"
3. Preencha todos os campos obrigatórios
4. **NÃO marque** a opção "manter logado"
5. Complete o cadastro
6. Faça logout
7. Tente fazer login com as mesmas credenciais

**Resultado Esperado:** 
- ✅ Login deve funcionar normalmente
- ✅ Deve redirecionar para a home

---

### Teste 2: Registro com "Manter Logado" ✅
**Objetivo:** Verificar persistência de sessão

1. Crie uma nova conta
2. **MARQUE** a opção "manter logado"
3. Complete o cadastro
4. Feche completamente o aplicativo
5. Abra o aplicativo novamente

**Resultado Esperado:**
- ✅ Deve abrir direto na tela home (sem pedir login)

---

### Teste 3: Logout e Login Novamente ⚠️ (TESTE CRÍTICO)
**Objetivo:** Verificar o problema original

1. Com uma conta já criada e logada
2. Faça logout
3. Tente fazer login novamente com as MESMAS credenciais

**Resultado Esperado:**
- ✅ Login deve funcionar (NÃO deve dar erro "email ou senha incorretos")
- ✅ Deve redirecionar para a home

**Se falhar:**
- Verificar os logs no console
- Procurar por linhas começando com `[FirebaseAuth]` ou `[HybridAuth]`
- Anotar qual erro está sendo exibido

---

### Teste 4: Credenciais Inválidas 🔒
**Objetivo:** Verificar que erros reais são tratados corretamente

1. Tente fazer login com email que NÃO existe
2. Tente fazer login com senha errada

**Resultado Esperado:**
- ✅ Deve mostrar mensagem "Email ou senha incorretos"
- ✅ NÃO deve travar ou mostrar outros erros

---

### Teste 5: Modo Offline (Opcional) 📡
**Objetivo:** Verificar comportamento sem internet

1. Crie uma conta e marque "manter logado"
2. Faça login pelo menos uma vez (para cachear os dados)
3. Desligue a internet (WiFi + dados móveis)
4. Feche o aplicativo
5. Abra novamente
6. Se deslogado, tente fazer login

**Resultado Esperado:**
- ✅ Com "manter logado" ativo: Deve conseguir entrar usando cache
- ⚠️ Sem "manter logado": Deve mostrar mensagem pedindo conexão
- ❌ Primeiro login SEMPRE requer internet

---

## Logs para Observar

Durante os testes, observe os seguintes logs no console:

### Logs de Sucesso 
```
✅ [FirebaseAuth] Conexão verificada com sucesso
🔑 [FirebaseAuth] Autenticando no Firebase Auth...
👤 [FirebaseAuth] UID obtido: [algum_id]
📄 [FirebaseAuth] Buscando dados do usuário no Firestore...
✅ [FirebaseAuth] Dados do usuário carregados. Tipo: paciente
✅ [FirebaseAuth] Login bem-sucedido como PACIENTE
```

### Logs de Erro (Credenciais Inválidas)
```
❌ [FirebaseAuth] FirebaseAuthException: wrong-password
🔑 [FirebaseAuth] Senha incorreta fornecida
❌ Credenciais inválidas fornecidas
```

### Logs de Erro (Sem Internet)
```
❌ [FirebaseAuth] Sem conexão com internet detectada
⚠️ Modo offline detectado. Buscando usuário local...
```

---

## Problemas Conhecidos e Soluções

### ❌ "Dados do usuário não encontrados no Firestore"
**Causa:** Usuário existe no Firebase Auth mas não no Firestore
**Solução:** Isso não deveria acontecer no fluxo normal. Se acontecer:
1. Verifique o console do Firebase → Authentication
2. Verifique o console do Firebase → Firestore → coleção "users"
3. Certifique-se que o documento existe com o mesmo UID

### ⚠️ "É necessário conexão com internet para fazer login pela primeira vez"
**Causa:** Tentando fazer login offline sem ter cache local
**Solução:** Normal. Primeiro login sempre requer internet.

### ❌ Erro ao sincronizar usuários
**Causa:** Problema de permissões no Firestore
**Solução:** Verificar regras de segurança do Firestore

---

## Teste de Regressão

Após confirmar que os testes acima passam, teste novamente:

1. ✅ Criação de múltiplas contas (paciente e profissional)
2. ✅ Alternância entre contas
3. ✅ Persistência após reiniciar o dispositivo
4. ✅ Navegação entre telas após login

---

## Reportar Problemas

Se algum teste falhar, forneça:

1. **Qual teste falhou** (número do teste)
2. **Mensagem de erro exibida** na tela
3. **Logs do console** (especialmente linhas com [FirebaseAuth] ou [HybridAuth])
4. **Passos para reproduzir** o problema
5. **Dispositivo/Plataforma** (Android, iOS, Web, Emulador)

---

## Próximos Passos (Se Necessário)

Se o problema persistir, as próximas ações serão:

1. **Adicionar mais logs** específicos na área problemática
2. **Verificar configuração do Firebase** (Rules, Authentication settings)
3. **Implementar mecanismo de retry** para operações de rede
4. **Adicionar telemetria** para monitorar problemas em produção

