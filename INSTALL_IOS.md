# 📱 Instalar App no iPhone

## Opção 1: Via Xcode (Mac)

### Pré-requisitos:
- Mac com Xcode instalado
- iPhone conectado via cabo USB
- Conta Apple (gratuita)

### Passos:

1. **Conecte o iPhone no Mac via cabo**

2. **No terminal, execute:**
```bash
cd /Users/dcpduns/Desktop/appSanitaria
flutter build ios --debug --no-codesign
```

3. **Abra o Xcode:**
```bash
open ios/Runner.xcworkspace
```

4. **No Xcode:**
   - Selecione seu iPhone no topo (ao lado do botão ▶️)
   - Vá em "Signing & Capabilities"
   - Selecione seu Apple ID em "Team"
   - Aguarde o Xcode configurar automaticamente

5. **Clique no botão ▶️ (Play)** no Xcode
   - O app será instalado automaticamente no iPhone
   - Pode levar 2-5 minutos na primeira vez

6. **No iPhone:**
   - Vá em: Ajustes → Geral → VPN e Gerenciamento de Dispositivos
   - Toque no seu Apple ID
   - Toque em "Confiar"
   - Pronto! O app está instalado

---

## Opção 2: Via Flutter Run (Wireless)

### Se o iPhone estiver na mesma rede WiFi:

1. **Conecte o iPhone via cabo uma vez**

2. **Execute:**
```bash
cd /Users/dcpduns/Desktop/appSanitaria
flutter devices
```

3. **Copie o ID do seu iPhone**

4. **Execute:**
```bash
flutter run -d [ID_DO_IPHONE]
```

5. **Desconecte o cabo** (funciona via WiFi agora!)

---

## Opção 3: TestFlight (Para testes prolongados)

### Vantagens:
- ✅ Não precisa cabo
- ✅ Atualiza automaticamente
- ✅ Vários testadores simultâneos
- ✅ Funciona por 90 dias

### Desvantagens:
- ❌ Demora ~1 hora para primeira aprovação
- ❌ Requer conta Apple Developer (grátis ou paga)

### Passos resumidos:
1. Criar app no App Store Connect
2. Fazer upload do build
3. Adicionar testadores (email)
4. Testadores instalam via TestFlight app

---

## Opção 4: Android (ALTERNATIVA RÁPIDA) 🚀

**Se você tem um Android disponível:**

1. **Build APK:**
```bash
cd /Users/dcpduns/Desktop/appSanitaria
flutter build apk --debug
```

2. **O APK estará em:**
```
build/app/outputs/flutter-apk/app-debug.apk
```

3. **Transfira para o Android:**
   - Via AirDrop → Android Nearby Share
   - Via Email/WhatsApp
   - Via cabo USB

4. **No Android:**
   - Instale o APK (permita instalação de fontes desconhecidas)
   - Pronto!

---

## 🧪 TESTAR CHAT ENTRE DISPOSITIVOS

### Cenário 1: iPhone + Android
- Instale no iPhone via Xcode
- Instale no Android via APK
- Login com usuários diferentes
- Teste o chat!

### Cenário 2: iPhone + Emulador
- Instale no iPhone via Xcode
- Mantenha o emulador rodando no Mac
- Login com usuários diferentes
- Teste o chat!

### Cenário 3: 2 iPhones
- Instale no iPhone 1 via Xcode
- Instale no iPhone 2 via Xcode
- Login com usuários diferentes
- Teste o chat!

---

## ⚠️ Problemas Comuns

### "Could not find an option named 'no-codesign'"
Use:
```bash
flutter build ios --debug
```

### "No valid code signing certificates were found"
- Abra Xcode
- Configure o Team em Signing & Capabilities
- Tente novamente

### "iPhone is not paired with this computer"
- Desbloqueie o iPhone
- Toque em "Confiar" quando aparecer a mensagem

### "Firebase not configured for iOS"
- Verifique se existe o arquivo: `ios/Runner/GoogleService-Info.plist`
- Se não existir, baixe do Firebase Console

---

## 📞 Qual opção você prefere?


