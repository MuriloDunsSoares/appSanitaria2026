# 🚀 FIREBASE - QUICK START GUIDE

**Comece em 30 minutos!**

---

## ⏱️ TIMELINE

```
[ 0-10 min ] Setup Firebase Project
[10-20 min ] Configure Flutter App
[20-25 min ] First Firestore Write
[25-30 min ] Security Rules Básicas
```

---

## 📦 PRÉ-REQUISITOS

```bash
# Verificar instalações
flutter --version  # >=3.0.0
dart --version     # >=3.0.0
firebase --version # >=12.0.0

# Se firebase CLI não instalado:
npm install -g firebase-tools

# Login Firebase
firebase login
```

---

## STEP 1: CRIAR PROJETO FIREBASE (5 min)

### **1.1 Console Firebase**

```
1. Acesse: https://console.firebase.google.com/
2. Clique: "Adicionar projeto"
3. Nome: "app-sanitaria"
4. Desabilitar Google Analytics (por enquanto)
5. Criar projeto
```

### **1.2 Adicionar App Flutter**

```
1. No dashboard, clique: iOS / Android
2. iOS:
   - Bundle ID: com.example.appSanitaria
   - Baixar GoogleService-Info.plist
   - Mover para: ios/Runner/
3. Android:
   - Package: com.example.app_sanitaria
   - Baixar google-services.json
   - Mover para: android/app/
```

### **1.3 Habilitar Serviços**

```
Console Firebase → Build:

✓ Authentication
  - Email/Password: HABILITAR
  
✓ Firestore Database
  - Criar database
  - Modo: Test mode (por enquanto)
  - Região: southamerica-east1 (São Paulo)
  
✓ Storage
  - Criar storage
  - Região: southamerica-east1
```

---

## STEP 2: CONFIGURAR FLUTTER (10 min)

### **2.1 Instalar FlutterFire CLI**

```bash
dart pub global activate flutterfire_cli

# Configurar projeto
flutterfire configure
# Selecione: app-sanitaria
# Plataformas: iOS, Android
```

Isso gera automaticamente: `lib/firebase_options.dart`

### **2.2 Adicionar Dependências**

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase Core
  firebase_core: ^2.24.0
  
  # Firebase Services
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Utils
  dartz: ^0.10.1
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

```bash
flutter pub get
```

### **2.3 Configurar Firebase no App**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Sanitária',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Quick Start'),
      ),
      body: Center(
        child: Text(
          '🔥 Firebase Configurado!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
```

### **2.4 Testar**

```bash
flutter run
```

**✅ Se o app abrir sem erros, Firebase está configurado!**

---

## STEP 3: PRIMEIRA ESCRITA FIRESTORE (5 min)

### **3.1 Criar Botão de Teste**

```dart
// lib/main.dart (atualizar HomeScreen)
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  Future<void> _testFirestore() async {
    final firestore = FirebaseFirestore.instance;
    
    try {
      // Escrever documento de teste
      final docRef = await firestore.collection('test').add({
        'message': 'Hello Firebase!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('✅ Documento criado: ${docRef.id}');
    } catch (e) {
      print('❌ Erro: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Quick Start'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🔥 Firebase Configurado!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _testFirestore,
              child: const Text('Testar Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### **3.2 Testar Escrita**

```bash
flutter run
```

1. Clique no botão "Testar Firestore"
2. Verifique console: "✅ Documento criado: ..."
3. Acesse Firebase Console → Firestore Database
4. Você verá a collection `test` com 1 documento

**✅ Primeira escrita funcionou!**

---

## STEP 4: SECURITY RULES BÁSICAS (5 min)

### **4.1 Atualizar Rules (Firebase Console)**

```
Firebase Console → Firestore Database → Rules
```

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ❌ REMOVER: allow read, write: if true;
    
    // ✅ ADICIONAR:
    
    // Test collection (apenas desenvolvimento)
    match /test/{docId} {
      allow read, write: if request.auth != null;
    }
    
    // Organizations (multi-tenant)
    match /organizations/{orgId}/{document=**} {
      allow read, write: if request.auth != null &&
                             request.auth.uid != null;
      // TODO: Adicionar RLS (Row-Level Security)
    }
    
    // User Profiles (global)
    match /userProfiles/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if false; // Managed by Cloud Functions
    }
  }
}
```

**Publicar Rules**

### **4.2 Testar Autenticação**

```dart
// lib/main.dart (adicionar autenticação)
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  User? _user;
  
  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }
  
  Future<void> _signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      print('✅ Autenticado: ${_user?.uid}');
    } catch (e) {
      print('❌ Erro: $e');
    }
  }
  
  Future<void> _signOut() async {
    await _auth.signOut();
  }
  
  Future<void> _testFirestore() async {
    if (_user == null) {
      print('❌ Não autenticado!');
      return;
    }
    
    final firestore = FirebaseFirestore.instance;
    
    try {
      final docRef = await firestore.collection('test').add({
        'userId': _user!.uid,
        'message': 'Hello from authenticated user!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('✅ Documento criado: ${docRef.id}');
    } catch (e) {
      print('❌ Erro: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Quick Start'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🔥 Firebase Configurado!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            
            // Status de autenticação
            Text(
              _user == null 
                ? '❌ Não autenticado' 
                : '✅ Autenticado: ${_user!.uid.substring(0, 8)}...',
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 32),
            
            // Botões
            if (_user == null)
              ElevatedButton(
                onPressed: _signInAnonymously,
                child: const Text('Login Anônimo'),
              )
            else ...[
              ElevatedButton(
                onPressed: _testFirestore,
                child: const Text('Testar Firestore'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _signOut,
                child: const Text('Logout'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### **4.3 Habilitar Anonymous Auth**

```
Firebase Console → Authentication → Sign-in method
→ Anonymous: HABILITAR
```

### **4.4 Testar Fluxo Completo**

```bash
flutter run
```

1. Clique "Login Anônimo"
2. Aguarde "✅ Autenticado"
3. Clique "Testar Firestore"
4. Verifique Firebase Console → documento criado com `userId`

**✅ Autenticação + Security Rules funcionando!**

---

## ✅ CHECKPOINT - 30 MINUTOS

Você agora tem:

- ✅ Projeto Firebase configurado
- ✅ Flutter App conectado
- ✅ Firestore escrevendo dados
- ✅ Autenticação funcionando
- ✅ Security Rules básicas

---

## 🎯 PRÓXIMOS PASSOS (Opcional)

### **Implementar Multi-Tenant**

```dart
// lib/core/config/firebase_config.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  static CollectionReference orgCollection(
    String organizationId,
    String collectionName,
  ) {
    return firestore
        .collection('organizations')
        .doc(organizationId)
        .collection(collectionName);
  }
}

// Uso:
final contracts = await FirebaseConfig
  .orgCollection('org_001', 'contracts')
  .get();
```

### **Criar Primeira Entity**

```dart
// lib/domain/entities/professional_entity.dart
class ProfessionalEntity {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  
  const ProfessionalEntity({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
  });
  
  factory ProfessionalEntity.fromMap(Map<String, dynamic> map) {
    return ProfessionalEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
```

### **Implementar DataSource**

```dart
// lib/data/datasources/professionals_firestore_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_config.dart';

class ProfessionalsFirestoreDataSource {
  final String organizationId;
  
  ProfessionalsFirestoreDataSource(this.organizationId);
  
  CollectionReference get _collection =>
      FirebaseConfig.orgCollection(organizationId, 'professionals');
  
  Future<List<Map<String, dynamic>>> getProfessionals() async {
    final snapshot = await _collection
        .orderBy('rating', descending: true)
        .limit(20)
        .get();
    
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    }).toList();
  }
  
  Future<String> createProfessional(Map<String, dynamic> data) async {
    final docRef = await _collection.add({
      ...data,
      'organizationId': organizationId,
      'rating': 0.0,
      'reviewCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }
}
```

---

## 📚 RECURSOS

### **Documentação Completa**

- [Estrutura de Dados](FIREBASE_DATABASE_STRUCTURE.md)
- [Security Rules](FIREBASE_SECURITY_RULES.md)
- [Performance](FIREBASE_PERFORMANCE_OPTIMIZATION.md)
- [Monitoramento](FIREBASE_MONITORING_OBSERVABILITY.md)
- [Backup](FIREBASE_BACKUP_DISASTER_RECOVERY.md)
- [Exemplos de Código](FIREBASE_CODE_EXAMPLES.md)
- [Diagramas](FIREBASE_ARCHITECTURE_DIAGRAMS.md)

### **Firebase Docs**

- [FlutterFire](https://firebase.flutter.dev/)
- [Firestore Docs](https://firebase.google.com/docs/firestore)
- [Security Rules](https://firebase.google.com/docs/rules)

---

## 🐛 TROUBLESHOOTING

### **Erro: "Firebase not initialized"**

```dart
// Certifique-se de ter:
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### **Erro: "PERMISSION_DENIED"**

```
1. Verifique Security Rules
2. Certifique-se de estar autenticado
3. Verifique se userId/orgId estão corretos
```

### **Erro: "Network error"**

```
1. Verifique internet
2. iOS: Adicione App Transport Security no Info.plist
3. Android: Adicione INTERNET permission no AndroidManifest.xml
```

### **Erro: "GoogleService-Info.plist not found"**

```
1. Baixe arquivo no Firebase Console
2. Coloque em: ios/Runner/
3. Adicione ao Xcode project (drag & drop)
```

---

## ✅ CHECKLIST

- [ ] Projeto Firebase criado
- [ ] iOS configurado (GoogleService-Info.plist)
- [ ] Android configurado (google-services.json)
- [ ] Firestore habilitado
- [ ] Authentication habilitada
- [ ] FlutterFire CLI configurado
- [ ] Dependências instaladas
- [ ] App roda sem erros
- [ ] Primeira escrita Firestore funcionou
- [ ] Autenticação funcionando
- [ ] Security Rules configuradas

---

**Parabéns! 🎉 Seu app Firebase está funcionando!**

**Próximo passo:** Implementar sua primeira feature completa seguindo [FIREBASE_CODE_EXAMPLES.md](FIREBASE_CODE_EXAMPLES.md)

---

**Última atualização:** Outubro 2025  
**Tempo estimado:** 30 minutos  
**Dificuldade:** Iniciante

