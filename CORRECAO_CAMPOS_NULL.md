# ✅ Correção: Campos NULL no Firestore

## 🐛 Problema Identificado

Durante o teste de autenticação (criar conta → logout → login), o processo falhou com o erro:

```
Error: type 'Null' is not a subtype of type 'String' in type cast
```

**Causa Raiz:**
1. O campo `tipo` não estava sendo salvo explicitamente no Firestore durante o registro
2. As entidades (`PatientEntity` e `ProfessionalEntity`) faziam cast direto sem verificar NULL

---

## ✅ Correções Implementadas

### 1. FirebaseAuthDataSource - Garantir campo `tipo`

**Arquivo:** `lib/data/datasources/firebase_auth_datasource.dart`

#### Correção no Registro de Pacientes:
```dart
// ANTES:
final patientData = patient.toJson();
patientData[FirestoreCollections.id] = uid;
patientData[FirestoreCollections.createdAt] = FieldValue.serverTimestamp();

// DEPOIS:
final patientData = patient.toJson();
patientData[FirestoreCollections.id] = uid;
patientData[FirestoreCollections.tipo] = 'paciente'; // ✅ GARANTIR que tipo seja salvo
patientData[FirestoreCollections.createdAt] = FieldValue.serverTimestamp();
AppLogger.info('📝 [FirebaseAuth] Salvando dados no Firestore: ${patientData.keys.toList()}');
```

#### Correção no Registro de Profissionais:
```dart
// ANTES:
final professionalData = professional.toJson();
professionalData[FirestoreCollections.id] = uid;
professionalData[FirestoreCollections.createdAt] = FieldValue.serverTimestamp();

// DEPOIS:
final professionalData = professional.toJson();
professionalData[FirestoreCollections.id] = uid;
professionalData[FirestoreCollections.tipo] = 'profissional'; // ✅ GARANTIR que tipo seja salvo
professionalData[FirestoreCollections.createdAt] = FieldValue.serverTimestamp();
AppLogger.info('📝 [FirebaseAuth] Salvando dados no Firestore: ${professionalData.keys.toList()}');
```

**Benefícios:**
- ✅ Campo `tipo` sempre salvo explicitamente
- ✅ Log detalhado dos campos sendo salvos

---

### 2. PatientEntity - Tratamento de NULL

**Arquivo:** `lib/domain/entities/patient_entity.dart`

```dart
// ANTES (sem proteção NULL):
factory PatientEntity.fromJson(Map<String, dynamic> json) {
  return PatientEntity(
    id: json['id'] as String,  // ❌ Falha se NULL
    nome: json['nome'] as String,
    // ...
  );
}

// DEPOIS (com proteção NULL):
factory PatientEntity.fromJson(Map<String, dynamic> json) {
  return PatientEntity(
    id: (json['id'] as String?) ?? '',  // ✅ Valor default se NULL
    nome: (json['nome'] as String?) ?? '',
    email: (json['email'] as String?) ?? '',
    password: (json['password'] as String?) ?? '',
    telefone: (json['telefone'] as String?) ?? '',
    dataNascimento: json['dataNascimento'] != null 
        ? DateTime.parse(json['dataNascimento'] as String)
        : DateTime.now(),
    endereco: (json['endereco'] as String?) ?? '',
    cidade: (json['cidade'] as String?) ?? '',
    estado: (json['estado'] as String?) ?? '',
    sexo: (json['sexo'] as String?) ?? '',
    dataCadastro: json['dataCadastro'] != null
        ? DateTime.parse(json['dataCadastro'] as String)
        : DateTime.now(),
    condicoesMedicas: (json['condicoesMedicas'] as String?) ?? '',
  );
}
```

---

### 3. ProfessionalEntity - Tratamento de NULL

**Arquivo:** `lib/domain/entities/professional_entity.dart`

```dart
// DEPOIS (com proteção NULL):
factory ProfessionalEntity.fromJson(Map<String, dynamic> json) {
  return ProfessionalEntity(
    id: (json['id'] as String?) ?? '',
    nome: (json['nome'] as String?) ?? '',
    email: (json['email'] as String?) ?? '',
    password: (json['password'] as String?) ?? '',
    // ... todos os campos com proteção NULL
    especialidade: json['especialidade'] != null
        ? Speciality.values.firstWhere(
            (e) => e.name == json['especialidade'],
            orElse: () => Speciality.cuidadores,
          )
        : Speciality.cuidadores,
    formacao: (json['formacao'] as String?) ?? '',
    // ...
  );
}
```

---

## 🧪 Como Testar

### Teste 1: Nova Conta (Deve Funcionar Agora!)

1. **Reinicie o app:**
   ```bash
   flutter run -d emulator-5554
   ```

2. **Crie uma nova conta:**
   - Clique em "Cadastre-se"
   - Preencha todos os dados
   - Clique em "Cadastrar"

3. **Verifique nos logs:**
   ```
   📝 [FirebaseAuth] Salvando dados no Firestore: [id, nome, email, tipo, ...]
   ✅ Paciente registrado com sucesso: [UID]
   ```

4. **Faça logout:**
   - Vá no perfil/menu
   - Clique em "Sair"

5. **Tente fazer login:**
   - Use o MESMO email e senha
   - Clique em "Entrar"

**Resultado Esperado:**
```
🔐 [FirebaseAuth] Iniciando login para: seuemail@gmail.com
✅ [FirebaseAuth] Conexão verificada com sucesso
🔑 [FirebaseAuth] Autenticando no Firebase Auth...
👤 [FirebaseAuth] UID obtido: [UID]
📄 [FirebaseAuth] Buscando dados do usuário no Firestore...
✅ [FirebaseAuth] Dados do usuário carregados. Tipo: paciente
✅ [FirebaseAuth] Login bem-sucedido como PACIENTE
```

---

### Teste 2: Contas Antigas (com tipo=null)

As contas antigas que têm `tipo=null` agora também devem funcionar porque:
- ✅ O `fromJson` agora aceita NULL
- ✅ Usa valor default se campo estiver NULL

**Para verificar:**
1. Tente fazer login com uma conta antiga (gbtc@gmail.com, ivan@gmail.com, etc.)
2. Deve funcionar sem erros!

---

## 📊 Impacto das Mudanças

### ✅ Benefícios

1. **Registro mais robusto:**
   - Campo `tipo` sempre garantido
   - Logs detalhados para debug

2. **Deserialização segura:**
   - Não falha mais com campos NULL
   - Valores default apropriados

3. **Compatibilidade:**
   - Funciona com dados antigos (NULL)
   - Funciona com dados novos (completos)

### ⚠️ Notas Importantes

- **Contas novas:** Terão todos os campos preenchidos corretamente
- **Contas antigas:** Funcionarão com valores default para campos NULL
- **Segurança:** Ainda recomendado remover senha do Firestore no futuro

---

## 🎯 Próximos Passos

Após confirmar que funciona:

1. **Testar ambos os fluxos:**
   - Registro de Paciente
   - Registro de Profissional

2. **Testar cenários:**
   - Login após registro
   - Logout e login novamente
   - Login com contas antigas

3. **Verificar Firebase Console:**
   - Ir em Firestore → users
   - Verificar que novos usuários têm campo `tipo` definido

---

## ✅ Checklist de Testes

- [ ] Criar conta de paciente
- [ ] Fazer logout
- [ ] Fazer login novamente → **Deve funcionar!**
- [ ] Criar conta de profissional
- [ ] Fazer logout
- [ ] Fazer login novamente → **Deve funcionar!**
- [ ] Tentar login com conta antiga → **Deve funcionar!**

---

**Status:** ✅ Correções implementadas e prontas para teste!

