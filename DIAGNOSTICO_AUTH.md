# Diagnóstico do Problema de Autenticação

## Problema Reportado

1. ✅ Criar conta e marcar "manter logado" → Funciona
2. ✅ Fechar app e abrir novamente → Continua logado
3. ❌ Fazer logout → Não consegue mais fazer login
4. ❌ Erro: "Email ou senha incorretos"

## Fluxo Atual Identificado

### Registro
```
1. FirebaseAuthDataSource.registerPatient()
   - Cria usuário no Firebase Auth (senha hashada)
   - Salva documento no Firestore (com senha em plain text - PROBLEMA DE SEGURANÇA!)
   - Retorna PatientEntity com senha em plain text

2. HybridAuthDataSource.registerPatient()
   - Recebe PatientEntity do Firebase
   - Salva localmente (com senha em plain text)

3. Firebase Auth mantém usuário logado automaticamente após createUserWithEmailAndPassword
```

### Logout
```
1. HybridAuthDataSource.logout()
   - Faz signOut() no Firebase Auth ✅
   - Limpa storage local ✅
   
2. AuthRepositoryFirebaseImpl.logout()
   - Limpa keepLoggedIn ✅
```

### Tentativa de Login Após Logout
```
1. HybridAuthDataSource.login()
   - Tenta Firebase Auth primeiro
   - Firebase Auth DEVERIA autenticar com email/senha
   - MAS algo está falhando aqui!
   
2. Quando Firebase falha, tenta fallback local
   - Busca usuário em local storage
   - MAS foi limpo no logout!
   - Retorna erro "Email não encontrado"
```

## Hipóteses do Problema

### Hipótese 1: Senha Não Está Sendo Salva no Firebase Auth ❌
**Improvável** - Se fosse isso, não funcionaria nem no primeiro login após registro.

### Hipótese 2: Fallback Local Está Sendo Ativado Incorretamente ✅ PROVÁVEL
**Muito provável** - O catch genérico (linha 59) captura QUALQUER exceção do Firebase e tenta usar local storage que não existe mais após logout.

### Hipótese 3: Firebase Auth Não Está Funcionando Offline ✅ PROVÁVEL
**Provável** - Se estiver sem internet, o Firebase Auth não consegue autenticar e cai no fallback local.

### Hipótese 4: OfflineModeException Não Está Sendo Lançada ✅ PROVÁVEL
O `FirebaseAuthDataSource.login()` verifica conexão (linhas 44-54), mas apenas testa uma transação. Se a conexão for intermitente, pode passar nesse teste mas falhar na autenticação.

## Solução Proposta

### 1. Melhorar o tratamento de exceções no HybridAuthDataSource.login()

**ANTES:**
```dart
} catch (e) {
  AppLogger.info('⚠️ Firebase falhou. Buscando usuário local...');
  // Tenta fallback local para QUALQUER exceção
}
```

**DEPOIS:**
```dart
} on OfflineModeException {
  // Apenas tenta fallback local se estiver offline
  // Para outros erros, relança a exceção
} on InvalidCredentialsException {
  // Senha/email incorretos - não tentar fallback
  rethrow;
}
```

### 2. Remover senha do Firestore (Segurança!)

A senha NÃO deve ser salva no Firestore. O Firebase Auth já gerencia a autenticação.

**Mudanças necessárias:**
- Não salvar campo 'password' no Firestore
- Remover validação de senha no fallback local (só verificar se usuário existe)
- Usar Firebase Auth como única fonte de verdade para senhas

### 3. Implementar Persistência do Firebase Auth

O Firebase Auth tem um mecanismo de persistência que mantém o usuário logado entre sessões:

```dart
await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
```

Isso permitiria que o usuário ficasse logado mesmo após fechar o app, sem depender do SharedPreferences.

## Testes Necessários

Para confirmar qual hipótese está correta, preciso que você teste:

### Teste 1: Verificar Logs Durante Login
1. Criar uma conta nova
2. Fazer logout
3. Tentar fazer login novamente
4. **Verificar nos logs** qual exceção está sendo lançada

### Teste 2: Verificar Se Usuário Existe no Firestore
1. Abrir console do Firebase
2. Ir em Authentication → Users
3. Verificar se o usuário está lá
4. Ir em Firestore → users collection
5. Verificar se o documento do usuário existe

### Teste 3: Verificar Senha no Firestore
1. No documento do usuário no Firestore
2. Verificar se o campo "password" está presente
3. Comparar com a senha que você usou para criar a conta

## Próximos Passos

Baseado nos resultados dos testes acima, vou implementar a solução apropriada.

