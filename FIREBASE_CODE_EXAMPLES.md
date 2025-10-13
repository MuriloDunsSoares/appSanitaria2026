# 💻 FIREBASE - EXEMPLOS DE CÓDIGO PRÁTICOS

**Parte da:** [Consultoria Firebase](FIREBASE_ARCHITECTURE_GUIDE.md)  
**Foco:** Código pronto para implementação

---

## 📋 ÍNDICE

1. [Setup Inicial](#setup-inicial)
2. [Datasources](#datasources)
3. [Repositories](#repositories)
4. [Providers](#providers)
5. [Security Rules](#security-rules)
6. [Cloud Functions](#cloud-functions)
7. [Widgets Flutter](#widgets-flutter)

---

## 1. SETUP INICIAL

### **Firebase Config**

```dart
// lib/core/config/firebase_config.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static late FirebaseFirestore _firestore;
  static late FirebaseAuth _auth;
  static late FirebaseStorage _storage;
  static late FirebaseAnalytics _analytics;
  
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;
    _analytics = FirebaseAnalytics.instance;
    
    // Configurar Firestore
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    // Configurar Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    
    // Habilitar Performance Monitoring
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    
    // Development: Usar emulators
    if (kDebugMode) {
      _useEmulators();
    }
    
    print('✅ Firebase initialized successfully');
  }
  
  static void _useEmulators() {
    try {
      _firestore.useFirestoreEmulator('localhost', 8080);
      _auth.useAuthEmulator('localhost', 9099);
      _storage.useStorageEmulator('localhost', 9199);
      print('🔧 Using Firebase Emulators');
    } catch (e) {
      print('⚠️ Emulators not available: $e');
    }
  }
  
  // Getters
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseAuth get auth => _auth;
  static FirebaseStorage get storage => _storage;
  static FirebaseAnalytics get analytics => _analytics;
  
  // Helper: Collection reference com organizationId
  static CollectionReference collection(
    String organizationId,
    String collectionName,
  ) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection(collectionName);
  }
}
```

### **Main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseConfig.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
```

---

## 2. DATASOURCES

### **Base Datasource**

```dart
// lib/data/datasources/base_firestore_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_config.dart';
import '../../core/error/exceptions.dart';

abstract class BaseFirestoreDataSource {
  final String organizationId;
  
  BaseFirestoreDataSource(this.organizationId);
  
  FirebaseFirestore get firestore => FirebaseConfig.firestore;
  
  CollectionReference collection(String name) {
    return FirebaseConfig.collection(organizationId, name);
  }
  
  // Helper: Converter exception para ServerException
  Never handleFirestoreException(dynamic error, StackTrace stackTrace) {
    if (error is FirebaseException) {
      throw ServerException(
        message: error.message ?? 'Firebase error',
        code: error.code,
      );
    }
    throw ServerException(
      message: error.toString(),
      stackTrace: stackTrace,
    );
  }
}
```

### **Contracts Datasource**

```dart
// lib/data/datasources/contracts_firestore_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_firestore_datasource.dart';

class ContractsFirestoreDataSource extends BaseFirestoreDataSource {
  ContractsFirestoreDataSource(String organizationId) : super(organizationId);
  
  CollectionReference get _collection => collection('contracts');
  
  // CREATE
  Future<String> createContract(Map<String, dynamic> data) async {
    try {
      final docRef = await _collection.add({
        ...data,
        'organizationId': organizationId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // READ ONE
  Future<Map<String, dynamic>?> getContract(String contractId) async {
    try {
      final doc = await _collection.doc(contractId).get();
      
      if (!doc.exists) return null;
      
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // READ MANY (com paginação)
  Future<List<Map<String, dynamic>>> getContractsByPatient(
    String patientId, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query query = _collection
          .where('patientId', isEqualTo: patientId)
          .where('status', isNotEqualTo: 'deleted')
          .orderBy('status')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // UPDATE
  Future<void> updateContract(
    String contractId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _collection.doc(contractId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // DELETE (soft delete)
  Future<void> deleteContract(String contractId, String userId) async {
    try {
      await _collection.doc(contractId).update({
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
      });
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // STREAM (real-time)
  Stream<List<Map<String, dynamic>>> watchContractsByPatient(
    String patientId,
  ) {
    return _collection
        .where('patientId', isEqualTo: patientId)
        .where('status', isNotEqualTo: 'deleted')
        .orderBy('status')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList());
  }
  
  // BATCH OPERATIONS
  Future<void> updateMultipleContracts(
    List<String> contractIds,
    Map<String, dynamic> data,
  ) async {
    try {
      final batch = firestore.batch();
      
      for (final contractId in contractIds) {
        batch.update(
          _collection.doc(contractId),
          {
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }
      
      await batch.commit();
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
}
```

### **Professionals Datasource**

```dart
// lib/data/datasources/professionals_firestore_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_firestore_datasource.dart';

class ProfessionalsFirestoreDataSource extends BaseFirestoreDataSource {
  ProfessionalsFirestoreDataSource(String organizationId) 
      : super(organizationId);
  
  CollectionReference get _collection => collection('professionals');
  
  // CREATE
  Future<String> createProfessional(Map<String, dynamic> data) async {
    try {
      final docRef = await _collection.add({
        ...data,
        'organizationId': organizationId,
        'avaliacao': 0.0,
        'numeroAvaliacoes': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // READ ONE
  Future<Map<String, dynamic>?> getProfessional(String profId) async {
    try {
      final doc = await _collection.doc(profId).get();
      
      if (!doc.exists) return null;
      
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // SEARCH (com filtros)
  Future<List<Map<String, dynamic>>> searchProfessionals({
    String? city,
    String? specialty,
    double? minRating,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query query = _collection;
      
      // Filtros
      if (city != null) {
        query = query.where('cidade', isEqualTo: city);
      }
      
      if (specialty != null) {
        query = query.where('especialidade', isEqualTo: specialty);
      }
      
      if (minRating != null) {
        query = query.where('avaliacao', isGreaterThanOrEqualTo: minRating);
      }
      
      // Ordenação
      query = query
          .orderBy('avaliacao', descending: true)
          .orderBy('numeroAvaliacoes', descending: true)
          .limit(limit);
      
      // Paginação
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
  
  // UPDATE RATING (denormalizado)
  Future<void> updateRating(
    String profId,
    double newRating,
    int newCount,
  ) async {
    try {
      await _collection.doc(profId).update({
        'avaliacao': newRating,
        'numeroAvaliacoes': newCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      handleFirestoreException(e, stackTrace);
    }
  }
}
```

---

## 3. REPOSITORIES

### **Contracts Repository**

```dart
// lib/data/repositories/contracts_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/repositories/contracts_repository.dart';
import '../datasources/contracts_firestore_datasource.dart';

class ContractsRepositoryImpl implements ContractsRepository {
  final ContractsFirestoreDataSource _dataSource;
  
  ContractsRepositoryImpl(this._dataSource);
  
  @override
  Future<Either<Failure, String>> createContract(
    ContractEntity contract,
  ) async {
    try {
      final id = await _dataSource.createContract({
        'patientId': contract.patientId,
        'professionalId': contract.professionalId,
        'patientName': contract.patientName,
        'profName': contract.profName,
        'serviceType': contract.serviceType,
        'periodType': contract.periodType,
        'periodValue': contract.periodValue,
        'startDate': contract.startDate.toIso8601String(),
        'startTime': contract.startTime,
        'address': contract.address,
        'observations': contract.observations,
        'totalValue': contract.totalValue,
        'status': 'pending',
      });
      
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }
  
  @override
  Future<Either<Failure, ContractEntity>> getContract(
    String contractId,
  ) async {
    try {
      final data = await _dataSource.getContract(contractId);
      
      if (data == null) {
        return Left(NotFoundFailure('Contrato não encontrado'));
      }
      
      final contract = ContractEntity.fromMap(data);
      return Right(contract);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<ContractEntity>>> getContractsByPatient(
    String patientId,
  ) async {
    try {
      final data = await _dataSource.getContractsByPatient(patientId);
      final contracts = data
          .map((map) => ContractEntity.fromMap(map))
          .toList();
      
      return Right(contracts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }
  
  @override
  Stream<List<ContractEntity>> watchContractsByPatient(String patientId) {
    return _dataSource
        .watchContractsByPatient(patientId)
        .map((data) => data
            .map((map) => ContractEntity.fromMap(map))
            .toList());
  }
  
  @override
  Future<Either<Failure, void>> updateContractStatus(
    String contractId,
    String newStatus,
  ) async {
    try {
      await _dataSource.updateContract(contractId, {
        'status': newStatus,
      });
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Erro inesperado: $e'));
    }
  }
}
```

---

## 4. PROVIDERS

### **Contracts Provider**

```dart
// lib/presentation/providers/contracts_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/repositories/contracts_repository.dart';

// Repository provider
final contractsRepositoryProvider = Provider<ContractsRepository>((ref) {
  // Inject dependencies
  final organizationId = ref.watch(authProvider).user!.organizationId;
  final dataSource = ContractsFirestoreDataSource(organizationId);
  return ContractsRepositoryImpl(dataSource);
});

// Stream provider (real-time contracts)
final contractsStreamProvider = StreamProvider.autoDispose.family<
  List<ContractEntity>, String
>((ref, patientId) {
  final repository = ref.watch(contractsRepositoryProvider);
  return repository.watchContractsByPatient(patientId);
});

// State notifier (CRUD operations)
class ContractsNotifier extends StateNotifier<AsyncValue<List<ContractEntity>>> {
  final ContractsRepository _repository;
  
  ContractsNotifier(this._repository) : super(const AsyncValue.loading());
  
  // CREATE
  Future<void> createContract(ContractEntity contract) async {
    state = const AsyncValue.loading();
    
    final result = await _repository.createContract(contract);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (contractId) {
        // Reload contracts
        loadContracts(contract.patientId);
      },
    );
  }
  
  // READ
  Future<void> loadContracts(String patientId) async {
    state = const AsyncValue.loading();
    
    final result = await _repository.getContractsByPatient(patientId);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (contracts) => state = AsyncValue.data(contracts),
    );
  }
  
  // UPDATE
  Future<void> updateStatus(String contractId, String newStatus) async {
    final result = await _repository.updateContractStatus(contractId, newStatus);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) {
        // Reload contracts
        if (state.hasValue) {
          final patientId = state.value!.first.patientId;
          loadContracts(patientId);
        }
      },
    );
  }
}

final contractsProvider = StateNotifierProvider.autoDispose<
  ContractsNotifier, AsyncValue<List<ContractEntity>>
>((ref) {
  final repository = ref.watch(contractsRepositoryProvider);
  return ContractsNotifier(repository);
});
```

---

## 5. SECURITY RULES

### **firestore.rules**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ==========================================
    // HELPER FUNCTIONS
    // ==========================================
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function getUserProfile() {
      return get(/databases/$(database)/documents/userProfiles/$(request.auth.uid)).data;
    }
    
    function getOrgId() {
      return getUserProfile().organizationId;
    }
    
    function hasRole(role) {
      return isAuthenticated() && getUserProfile().role == role;
    }
    
    function isSameOrg(orgId) {
      return isAuthenticated() && getOrgId() == orgId;
    }
    
    function isActive() {
      return getUserProfile().status == 'active';
    }
    
    // ==========================================
    // ORGANIZATIONS
    // ==========================================
    
    match /organizations/{orgId} {
      allow read: if isSameOrg(orgId) && isActive();
      allow write: if isSameOrg(orgId) && hasRole('admin');
      
      // CONTRACTS
      match /contracts/{contractId} {
        allow get: if isSameOrg(orgId) && 
                      isActive() &&
                      (resource.data.patientId == request.auth.uid ||
                       resource.data.professionalId == request.auth.uid ||
                       hasRole('admin'));
        
        allow list: if isSameOrg(orgId) && isActive();
        
        allow create: if isSameOrg(orgId) && 
                         isActive() &&
                         request.resource.data.patientId == request.auth.uid &&
                         request.resource.data.status == 'pending';
        
        allow update: if isSameOrg(orgId) && 
                         isActive() &&
                         (resource.data.patientId == request.auth.uid ||
                          resource.data.professionalId == request.auth.uid ||
                          hasRole('admin'));
        
        allow delete: if false; // Use soft delete
      }
      
      // PROFESSIONALS
      match /professionals/{profId} {
        allow read: if isSameOrg(orgId) && isActive();
        
        allow create: if isSameOrg(orgId) && 
                         isActive() &&
                         (hasRole('admin') || 
                          request.resource.data.userId == request.auth.uid);
        
        allow update: if isSameOrg(orgId) && 
                         isActive() &&
                         (hasRole('admin') || 
                          resource.data.userId == request.auth.uid);
        
        allow delete: if isSameOrg(orgId) && hasRole('admin');
      }
    }
    
    // USER PROFILES
    match /userProfiles/{userId} {
      allow read: if isAuthenticated() && request.auth.uid == userId;
      allow write: if false; // Managed by Cloud Functions
    }
  }
}
```

---

## 6. CLOUD FUNCTIONS

### **onContractCreate.ts**

```typescript
// functions/src/contracts.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const onContractCreate = functions.firestore
  .document('organizations/{orgId}/contracts/{contractId}')
  .onCreate(async (snap, context) => {
    const contract = snap.data();
    const { orgId, contractId } = context.params;
    
    console.log(`New contract created: ${contractId}`);
    
    try {
      // 1. Send notification to professional
      await sendNotification(
        contract.professionalId,
        'Novo Contrato!',
        `${contract.patientName} te contratou.`
      );
      
      // 2. Create conversation between patient and professional
      await createConversation(
        orgId,
        contract.patientId,
        contract.professionalId
      );
      
      // 3. Log audit trail
      await admin.firestore()
        .collection('organizations')
        .doc(orgId)
        .collection('activityLogs')
        .add({
          action: 'contract_created',
          contractId,
          patientId: contract.patientId,
          professionalId: contract.professionalId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      
      console.log(`Contract ${contractId} processed successfully`);
    } catch (error) {
      console.error(`Error processing contract ${contractId}:`, error);
      throw error;
    }
  });

async function sendNotification(
  userId: string,
  title: string,
  body: string
) {
  const userDoc = await admin.firestore()
    .doc(`userProfiles/${userId}`)
    .get();
  
  const fcmToken = userDoc.data()?.fcmToken;
  
  if (!fcmToken) {
    console.log(`No FCM token for user ${userId}`);
    return;
  }
  
  await admin.messaging().send({
    token: fcmToken,
    notification: { title, body },
    data: { type: 'contract_created' },
  });
}

async function createConversation(
  orgId: string,
  user1Id: string,
  user2Id: string
) {
  const conversationId = [user1Id, user2Id].sort().join('_');
  
  await admin.firestore()
    .collection('organizations')
    .doc(orgId)
    .collection('conversations')
    .doc(conversationId)
    .set({
      participants: [user1Id, user2Id],
      participantsMap: {
        [user1Id]: true,
        [user2Id]: true,
      },
      unreadCount: {
        [user1Id]: 0,
        [user2Id]: 0,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
```

### **updateProfessionalRating.ts**

```typescript
// functions/src/reviews.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const updateProfessionalRating = functions.firestore
  .document('organizations/{orgId}/reviews/{reviewId}')
  .onWrite(async (change, context) => {
    const { orgId } = context.params;
    
    // Get professionalId from review
    const review = change.after.exists ? change.after.data() : change.before.data();
    const professionalId = review?.professionalId;
    
    if (!professionalId) return;
    
    console.log(`Updating rating for professional: ${professionalId}`);
    
    try {
      // Calculate new rating
      const reviewsSnapshot = await admin.firestore()
        .collection('organizations')
        .doc(orgId)
        .collection('reviews')
        .where('professionalId', '==', professionalId)
        .get();
      
      const totalReviews = reviewsSnapshot.size;
      
      if (totalReviews === 0) {
        // No reviews, reset to 0
        await updateProfessionalRatingDoc(orgId, professionalId, 0, 0);
        return;
      }
      
      const sumRatings = reviewsSnapshot.docs.reduce(
        (sum, doc) => sum + doc.data().rating,
        0
      );
      
      const averageRating = sumRatings / totalReviews;
      
      // Update professional document
      await updateProfessionalRatingDoc(
        orgId,
        professionalId,
        averageRating,
        totalReviews
      );
      
      console.log(
        `Professional ${professionalId} rating updated: ${averageRating.toFixed(2)} (${totalReviews} reviews)`
      );
    } catch (error) {
      console.error('Error updating rating:', error);
      throw error;
    }
  });

async function updateProfessionalRatingDoc(
  orgId: string,
  professionalId: string,
  rating: number,
  count: number
) {
  await admin.firestore()
    .collection('organizations')
    .doc(orgId)
    .collection('professionals')
    .doc(professionalId)
    .update({
      avaliacao: rating,
      numeroAvaliacoes: count,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
}
```

---

## 7. WIDGETS FLUTTER

### **Contracts List Screen**

```dart
// lib/presentation/screens/contracts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contracts_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/contract_card.dart';

class ContractsScreen extends ConsumerWidget {
  const ContractsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).user!.id;
    final contractsAsync = ref.watch(contractsStreamProvider(userId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Contratos'),
      ),
      body: contractsAsync.when(
        data: (contracts) {
          if (contracts.isEmpty) {
            return const Center(
              child: Text('Nenhum contrato encontrado'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(contractsStreamProvider(userId));
            },
            child: ListView.builder(
              itemCount: contracts.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return ContractCard(
                  contract: contracts[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContractDetailScreen(
                          contractId: contracts[index].id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(contractsStreamProvider(userId));
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### **Contract Card Widget**

```dart
// lib/presentation/widgets/contract_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/contract_entity.dart';
import 'package:intl/intl.dart';

class ContractCard extends StatelessWidget {
  final ContractEntity contract;
  final VoidCallback? onTap;
  
  const ContractCard({
    Key? key,
    required this.contract,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      contract.profName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _buildStatusChip(contract.status),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Service Type
              Row(
                children: [
                  const Icon(Icons.medical_services, size: 16),
                  const SizedBox(width: 8),
                  Text(contract.serviceType),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(contract.startDate),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      contract.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ ${contract.totalValue.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pendente';
        break;
      case 'active':
        color = Colors.green;
        label = 'Ativo';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Concluído';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelado';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
```

---

## 🎯 PRÓXIMOS PASSOS

1. **Copiar código base** (config, datasources)
2. **Adaptar para suas entities** (Contract → SuaEntity)
3. **Implementar Security Rules**
4. **Testar localmente** (Firebase Emulators)
5. **Deploy gradual** (dev → staging → prod)

---

**Última atualização:** Outubro 2025  
**Versão:** 1.0

