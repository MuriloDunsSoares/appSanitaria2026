# 🔥 GUIA DE CONFIGURAÇÃO FIREBASE - App Sanitária

## ✅ ETAPA 1: CRIAR PROJETO FIREBASE (5 min)

1. Acesse: https://console.firebase.google.com
2. Clique em **"Adicionar projeto"** (Add project)
3. Nome: `app-sanitaria`
4. Clique **"Continuar"**
5. **DESABILITE** Google Analytics
6. Clique **"Criar projeto"**
7. Aguarde (~30 seg)
8. Clique **"Continuar"**

---

## 📱 ETAPA 2: CONFIGURAR ANDROID (10 min)

### 2.1 Adicionar App Android

1. No Firebase Console, clique no ícone **Android** (robô verde)
2. **Nome do pacote Android:** `com.example.app_sanitaria`
   - ⚠️ IMPORTANTE: Use exatamente esse nome!
3. **Apelido do app:** `App Sanitária Android`
4. Clique **"Registrar app"**

### 2.2 Baixar google-services.json

1. Clique em **"Fazer o download de google-services.json"**
2. Salve o arquivo
3. **MOVA** o arquivo para: `android/app/google-services.json`
   - Caminho completo: `/Users/dcpduns/Desktop/appSanitaria/android/app/google-services.json`

### 2.3 Copiar Configurações

Você verá algo assim na tela do Firebase:

```json
{
  "project_info": {
    "project_id": "app-sanitaria-xxxxx",
    "project_number": "123456789012",
    ...
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abcdef123456",
        ...
      },
      "api_key": [
        {
          "current_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        }
      ]
    }
  ]
}
```

**ANOTE ESSES VALORES:**
- ✅ `project_id`: `app-sanitaria-xxxxx`
- ✅ `project_number` (messaging_sender_id): `123456789012`
- ✅ `mobilesdk_app_id`: `1:123456789012:android:abcdef123456`
- ✅ `current_key` (API Key): `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

---

## 📋 ETAPA 3: ENVIAR OS VALORES PARA MIM

**Copie e cole isso preenchido:**

```
PROJECT_ID=app-sanitaria-xxxxx
SENDER_ID=123456789012
ANDROID_APP_ID=1:123456789012:android:abcdef123456
ANDROID_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

---

## 🔐 ETAPA 4: ATIVAR AUTHENTICATION

1. No Firebase Console (menu esquerdo), clique em **"Authentication"** (Build → Authentication)
2. Clique em **"Começar"** (Get started)
3. Na aba **"Sign-in method"**, clique em **"E-mail/senha"**
4. **ATIVE** o primeiro toggle (E-mail/senha)
5. Clique **"Salvar"**

---

## 💾 ETAPA 5: ATIVAR FIRESTORE DATABASE

1. No Firebase Console (menu esquerdo), clique em **"Firestore Database"** (Build → Firestore Database)
2. Clique em **"Criar banco de dados"** (Create database)
3. Selecione **"Começar no modo de teste"** (Start in test mode)
4. Selecione a localização: **`us-east1`** (ou a mais próxima do Brasil: `southamerica-east1`)
5. Clique **"Ativar"**

---

## 📲 ETAPA 6: ATIVAR CLOUD MESSAGING (FCM)

1. No Firebase Console (menu esquerdo), clique em **"Cloud Messaging"** (Build → Cloud Messaging)
2. Clique em **"Começar"**
3. **Pronto!** FCM já está ativo.

---

## 🎯 DEPOIS DE FAZER TUDO ISSO:

**Me envie os 4 valores da ETAPA 3:**

```
PROJECT_ID=???
SENDER_ID=???
ANDROID_APP_ID=???
ANDROID_API_KEY=???
```

**E confirme que você:**
- ✅ Moveu o `google-services.json` para `android/app/`
- ✅ Ativou Authentication (E-mail/senha)
- ✅ Criou Firestore Database (modo teste)
- ✅ Ativou Cloud Messaging

**Aí eu continuo a implementação automaticamente!** 🚀

