# 💾 ARMAZENAMENTO DE DADOS - APP SANITÁRIA

**Data:** 7 de Outubro, 2025  
**Tecnologia:** SharedPreferences (Android) / UserDefaults (iOS)

---

## 📍 ONDE OS DADOS SÃO ARMAZENADOS?

### **No Android (Emulador Atual):**
```
/data/data/com.example.app_sanitaria/shared_prefs/FlutterSharedPreferences.xml
```

### **No iOS:**
```
Library/Preferences/FlutterSharedPreferences.plist
```

---

## 🗂️ ESTRUTURA DE ARMAZENAMENTO

### **1. CONTAS DE USUÁRIOS** 👥

#### **Pacientes:**
- **Chave:** `app_patients`
- **Formato:** JSON Array
- **Conteúdo:**
```json
[
  {
    "id": "unique_id_123",
    "email": "paciente@test.com",
    "password": "senha_hash",
    "nome": "Nome do Paciente",
    "type": "paciente",
    "cidade": "São Paulo",
    "estado": "SP",
    "telefone": "(11) 91234-5678",
    "cpf": "123.456.789-01",
    "sexo": "M",
    "idade": 45,
    "dataNascimento": "1979-07-12T00:00:00.000Z",
    "dataCadastro": "2025-10-07T20:42:00.000Z"
  }
]
```

#### **Profissionais:**
- **Chave:** `app_professionals`
- **Formato:** JSON Array
- **Conteúdo:**
```json
[
  {
    "id": "unique_id_456",
    "email": "profissional@test.com",
    "password": "senha_hash",
    "nome": "Nome do Profissional",
    "type": "profissional",
    "especialidade": "cuidadores",
    "cidade": "Rio de Janeiro",
    "estado": "RJ",
    "telefone": "(21) 98765-4321",
    "cpf": "234.567.890-12",
    "sexo": "F",
    "dataNascimento": "1985-05-15T00:00:00.000Z",
    "bio": "Descrição profissional",
    "precoHora": 50.0,
    "dataCadastro": "2025-10-07T20:42:00.000Z"
  }
]
```

---

### **2. USUÁRIO LOGADO** 🔐

#### **Dados do usuário atual:**
- **Chave:** `userData`
- **Formato:** JSON Object
- **Conteúdo:** Objeto completo do usuário autenticado

#### **ID do usuário atual:**
- **Chave:** `userId`
- **Formato:** String
- **Conteúdo:** ID único do usuário logado

#### **Preferência "Manter logado":**
- **Chave:** `keepLoggedIn`
- **Formato:** Boolean
- **Conteúdo:** `true` ou `false`

---

### **3. OUTROS DADOS** 📊

#### **Favoritos:**
- **Chave:** `favorites`
- **Formato:** JSON Array de IDs
- **Exemplo:** `["prof_id_1", "prof_id_2"]`

#### **Mensagens de Chat:**
- **Chave:** `messages_[conversationId]`
- **Formato:** JSON Array de mensagens

#### **Contratos:**
- **Chave:** `contracts`
- **Formato:** JSON Array de contratos

#### **Avaliações:**
- **Chave:** `reviews`
- **Formato:** JSON Array de reviews

#### **Fotos de Perfil:**
- **Chave:** `profile_images_[userId]`
- **Formato:** String (caminho do arquivo)

---

## 🔧 DATASOURCES RESPONSÁVEIS

| DataSource | Responsabilidade | Chaves Gerenciadas |
|------------|------------------|-------------------|
| `AuthStorageDataSource` | Login/Logout | `userData`, `userId`, `keepLoggedIn` |
| `UsersStorageDataSource` | CRUD de usuários | `app_patients`, `app_professionals` |
| `FavoritesStorageDataSource` | Favoritos | `favorites` |
| `ChatStorageDataSource` | Mensagens | `messages_*`, `conversations` |
| `ContractsStorageDataSource` | Contratos | `contracts` |
| `ReviewsStorageDataSource` | Avaliações | `reviews` |
| `ProfileStorageDataSource` | Fotos | `profile_images_*` |

---

## 📱 COMO VISUALIZAR OS DADOS NO EMULADOR

### **Método 1: Via Terminal ADB**
```bash
# Conectar ao emulador
adb shell

# Navegar até o diretório
cd /data/data/com.example.app_sanitaria/shared_prefs/

# Ver o arquivo XML
cat FlutterSharedPreferences.xml
```

### **Método 2: Via Android Studio**
1. Abra **Device File Explorer**
2. Navegue: `data/data/com.example.app_sanitaria/shared_prefs/`
3. Baixe o arquivo `FlutterSharedPreferences.xml`

### **Método 3: Programaticamente (Debug)**
```dart
final prefs = await SharedPreferences.getInstance();
print('Todas as chaves: ${prefs.getKeys()}');
print('Pacientes: ${prefs.getString('app_patients')}');
print('Profissionais: ${prefs.getString('app_professionals')}');
```

---

## 🔄 FLUXO DE CADASTRO E ARMAZENAMENTO

### **Quando você cria uma conta:**

1. **Usuário preenche formulário** (tela de registro)
2. **AuthProvider.registerPatient()** ou **registerProfessional()** é chamado
3. **Use Case** (`RegisterPatient` ou `RegisterProfessional`) valida dados
4. **Repository** (`AuthRepositoryImpl`) chama o DataSource
5. **UsersStorageDataSource.savePatient()** ou **saveProfessional()**:
   - Carrega array existente do SharedPreferences
   - Adiciona novo usuário ao array
   - Salva de volta como JSON string
6. **Dados persistidos** no arquivo XML do SharedPreferences

### **Quando você faz login:**

1. **AuthProvider.login()** é chamado
2. **Use Case** (`LoginUser`) busca usuário por email
3. **Repository** chama **UsersStorageDataSource.getUserByEmail()**
4. **DataSource**:
   - Busca em todos os pacientes
   - Se não encontrar, busca em todos os profissionais
   - Compara senha
5. **Se válido:** Salva usuário em `userData` e `userId`
6. **AuthProvider** atualiza estado para `authenticated`

---

## 🗑️ COMO LIMPAR OS DADOS

### **Método 1: Logout no App**
- Clica em "Sair" → Remove `userData`, `userId`, `keepLoggedIn`
- **As contas permanecem** (você pode fazer login novamente)

### **Método 2: Desinstalar o App**
```bash
adb uninstall com.example.app_sanitaria
```
- **Todos os dados são deletados** (incluindo contas criadas)

### **Método 3: Limpar dados do App (Android)**
```bash
adb shell pm clear com.example.app_sanitaria
```
- **Dados deletados, app permanece instalado**

### **Método 4: Programaticamente (Debug)**
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.clear(); // Limpa TUDO
```

---

## ⚠️ IMPORTANTE

### **Persistência:**
- ✅ Dados **persistem** após fechar o app
- ✅ Dados **persistem** após reiniciar o emulador
- ❌ Dados **NÃO persistem** após desinstalar o app
- ❌ Dados **NÃO são sincronizados** entre dispositivos (local apenas)

### **Segurança:**
- ⚠️ SharedPreferences **NÃO é criptografado** por padrão
- ⚠️ Senhas devem ser **hasheadas** antes de salvar
- ⚠️ Para produção, considere usar:
  - `flutter_secure_storage` (dados sensíveis)
  - Backend com banco de dados real
  - Autenticação OAuth/Firebase

---

## 📝 RESUMO

**Onde:** `/data/data/com.example.app_sanitaria/shared_prefs/`  
**Formato:** XML com chaves/valores JSON  
**Tecnologia:** SharedPreferences (nativo Android)  
**Persistência:** Local, não sincroniza  
**Segurança:** Básica (para desenvolvimento)

---

**Para visualizar seus dados agora:**
```bash
adb shell
cd /data/data/com.example.app_sanitaria/shared_prefs/
cat FlutterSharedPreferences.xml
```

✅ **Todos os dados ficam salvos localmente no dispositivo/emulador!**
