// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script para migração de dados para arquitetura multi-tenant
/// 
/// ATENÇÃO: Execute este script com CUIDADO!
/// 
/// Passos:
/// 1. Fazer BACKUP completo do Firestore
/// 2. Testar em ambiente de STAGING primeiro
/// 3. Executar em horário de baixo tráfego
/// 4. Monitorar logs durante execução
/// 
/// Uso:
/// ```bash
/// dart run scripts/migrate_to_multitenant.dart
/// ```

const String DEFAULT_ORG_ID = 'default_org';
const bool DRY_RUN = true; // ⚠️ Mudar para false para executar de verdade

void main() async {
  print('🚀 Iniciando migração para Multi-Tenant...\n');
  
  if (DRY_RUN) {
    print('⚠️  DRY RUN MODE - Nenhuma mudança será feita');
    print('   Mude DRY_RUN = false para executar de verdade\n');
  }
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;
  
  try {
    // Passo 1: Criar organização default
    await createDefaultOrganization(firestore);
    
    // Passo 2: Migrar usuários
    await migrateUsers(firestore);
    
    // Passo 3: Migrar contratos
    await migrateContracts(firestore);
    
    // Passo 4: Migrar conversas
    await migrateConversations(firestore);
    
    // Passo 5: Migrar mensagens
    await migrateMessages(firestore);
    
    // Passo 6: Migrar reviews
    await migrateReviews(firestore);
    
    // Passo 7: Migrar favoritos
    await migrateFavorites(firestore);
    
    // Passo 8: Criar userProfiles
    await createUserProfiles(firestore);
    
    print('\n✅ Migração concluída com sucesso!');
    
    if (DRY_RUN) {
      print('\n⚠️  Isto foi um DRY RUN - nenhuma mudança foi feita');
      print('   Revise os logs e mude DRY_RUN = false para executar');
    }
  } catch (e, stackTrace) {
    print('\n❌ Erro durante migração: $e');
    print('Stack trace: $stackTrace');
  }
}

/// Cria organização default
Future<void> createDefaultOrganization(FirebaseFirestore firestore) async {
  print('📋 Passo 1: Criando organização default...');
  
  final orgRef = firestore.collection('organizations').doc(DEFAULT_ORG_ID);
  final orgExists = (await orgRef.get()).exists;
  
  if (orgExists) {
    print('   ℹ️  Organização já existe: $DEFAULT_ORG_ID');
    return;
  }
  
  if (!DRY_RUN) {
    await orgRef.set({
      'name': 'Organização Padrão',
      'plan': 'free',
      'maxUsers': 1000,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  print('   ✅ Organização criada: $DEFAULT_ORG_ID');
}

/// Migra usuários para dentro da organização
Future<void> migrateUsers(FirebaseFirestore firestore) async {
  print('\n📋 Passo 2: Migrando usuários...');
  
  final usersSnapshot = await firestore.collection('users').get();
  print('   Encontrados ${usersSnapshot.docs.length} usuários');
  
  int migrated = 0;
  for (final doc in usersSnapshot.docs) {
    final data = doc.data();
    
    if (!DRY_RUN) {
      // Copiar para dentro da organização
      await firestore
          .collection('organizations')
          .doc(DEFAULT_ORG_ID)
          .collection('users')
          .doc(doc.id)
          .set({
        ...data,
        'organizationId': DEFAULT_ORG_ID,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    migrated++;
    if (migrated % 10 == 0) {
      print('   Progresso: $migrated/${usersSnapshot.docs.length}');
    }
  }
  
  print('   ✅ $migrated usuários migrados');
}

/// Migra contratos para dentro da organização
Future<void> migrateContracts(FirebaseFirestore firestore) async {
  print('\n📋 Passo 3: Migrando contratos...');
  
  final contractsSnapshot = await firestore.collection('contracts').get();
  print('   Encontrados ${contractsSnapshot.docs.length} contratos');
  
  int migrated = 0;
  for (final doc in contractsSnapshot.docs) {
    final data = doc.data();
    
    if (!DRY_RUN) {
      await firestore
          .collection('organizations')
          .doc(DEFAULT_ORG_ID)
          .collection('contracts')
          .doc(doc.id)
          .set({
        ...data,
        'organizationId': DEFAULT_ORG_ID,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    migrated++;
    if (migrated % 10 == 0) {
      print('   Progresso: $migrated/${contractsSnapshot.docs.length}');
    }
  }
  
  print('   ✅ $migrated contratos migrados');
}

/// Migra conversas para dentro da organização
Future<void> migrateConversations(FirebaseFirestore firestore) async {
  print('\n📋 Passo 4: Migrando conversas...');
  
  final conversationsSnapshot = await firestore.collection('conversations').get();
  print('   Encontrados ${conversationsSnapshot.docs.length} conversas');
  
  int migrated = 0;
  for (final doc in conversationsSnapshot.docs) {
    final data = doc.data();
    
    if (!DRY_RUN) {
      await firestore
          .collection('organizations')
          .doc(DEFAULT_ORG_ID)
          .collection('conversations')
          .doc(doc.id)
          .set({
        ...data,
        'organizationId': DEFAULT_ORG_ID,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    migrated++;
  }
  
  print('   ✅ $migrated conversas migradas');
}

/// Migra mensagens para dentro da organização
Future<void> migrateMessages(FirebaseFirestore firestore) async {
  print('\n📋 Passo 5: Migrando mensagens...');
  
  final messagesSnapshot = await firestore.collection('messages').get();
  print('   Encontrados ${messagesSnapshot.docs.length} mensagens');
  
  int migrated = 0;
  for (final doc in messagesSnapshot.docs) {
    final data = doc.data();
    
    if (!DRY_RUN) {
      await firestore
          .collection('organizations')
          .doc(DEFAULT_ORG_ID)
          .collection('messages')
          .doc(doc.id)
          .set({
        ...data,
        'organizationId': DEFAULT_ORG_ID,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    migrated++;
    if (migrated % 50 == 0) {
      print('   Progresso: $migrated/${messagesSnapshot.docs.length}');
    }
  }
  
  print('   ✅ $migrated mensagens migradas');
}

/// Migra reviews para dentro da organização
Future<void> migrateReviews(FirebaseFirestore firestore) async {
  print('\n📋 Passo 6: Migrando reviews...');
  
  final reviewsSnapshot = await firestore.collection('reviews').get();
  print('   Encontrados ${reviewsSnapshot.docs.length} reviews');
  
  int migrated = 0;
  for (final doc in reviewsSnapshot.docs) {
    final data = doc.data();
    
    if (!DRY_RUN) {
      await firestore
          .collection('organizations')
          .doc(DEFAULT_ORG_ID)
          .collection('reviews')
          .doc(doc.id)
          .set({
        ...data,
        'organizationId': DEFAULT_ORG_ID,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    migrated++;
  }
  
  print('   ✅ $migrated reviews migradas');
}

/// Migra favoritos para dentro da organização
Future<void> migrateFavorites(FirebaseFirestore firestore) async {
  print('\n📋 Passo 7: Migrando favoritos...');
  
  final favoritesSnapshot = await firestore.collection('favorites').get();
  print('   Encontrados ${favoritesSnapshot.docs.length} favoritos');
  
  int migrated = 0;
  for (final doc in favoritesSnapshot.docs) {
    final data = doc.data();
    
    if (!DRY_RUN) {
      await firestore
          .collection('organizations')
          .doc(DEFAULT_ORG_ID)
          .collection('favorites')
          .doc(doc.id)
          .set({
        ...data,
        'organizationId': DEFAULT_ORG_ID,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    migrated++;
  }
  
  print('   ✅ $migrated favoritos migrados');
}

/// Cria userProfiles (global collection) para cada usuário
Future<void> createUserProfiles(FirebaseFirestore firestore) async {
  print('\n📋 Passo 8: Criando userProfiles...');
  
  final usersSnapshot = await firestore
      .collection('organizations')
      .doc(DEFAULT_ORG_ID)
      .collection('users')
      .get();
  
  print('   Criando profiles para ${usersSnapshot.docs.length} usuários');
  
  int created = 0;
  for (final doc in usersSnapshot.docs) {
    final data = doc.data();
    
    if (!DRY_RUN) {
      await firestore.collection('userProfiles').doc(doc.id).set({
        'email': data['email'],
        'organizationId': DEFAULT_ORG_ID,
        'role': _getUserRole(data['tipo']),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    
    created++;
  }
  
  print('   ✅ $created userProfiles criados');
}

/// Mapeia tipo de usuário para role
String _getUserRole(String? tipo) {
  if (tipo == 'profissional') return 'professional';
  if (tipo == 'paciente') return 'client';
  return 'client';  // default
}

