import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/firestore_collections.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/professional_entity.dart';
import '../../domain/entities/user_entity.dart';

/// DataSource para autenticação usando Firebase Auth
/// 
/// Responsável por:
/// - Login/Logout usando Firebase Auth (apenas modo online)
/// - Registro de pacientes e profissionais
/// - Sincronização de dados de usuário com Firestore
/// - Verificação de conectividade
/// - Exibição de mensagens de erro quando offline
class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== AUTENTICAÇÃO ====================

  /// Faz login com email e senha (apenas modo online)
  /// 
  /// Lança [InvalidCredentialsException] se credenciais inválidas
  /// Lança [NetworkException] se sem conexão
  /// Lança [OfflineModeException] se tentar usar offline
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('🔐 [FirebaseAuth] Iniciando login para: $email');
      AppLogger.info('📡 [FirebaseAuth] Verificando conexão com internet...');
      
      // Verificar conexão com internet primeiro
      try {
        await _firestore.runTransaction((transaction) async {
          // Apenas testa a conexão
          return null;
        });
        AppLogger.info('✅ [FirebaseAuth] Conexão verificada com sucesso');
      } catch (e) {
        AppLogger.warning('❌ [FirebaseAuth] Sem conexão com internet detectada');
        throw const OfflineModeException(
          'Este aplicativo requer conexão com internet para funcionar.\n'
          'Por favor, verifique sua conexão e tente novamente.',
        );
      }

      AppLogger.info('🔑 [FirebaseAuth] Autenticando no Firebase Auth...');

      // Autenticar no Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      AppLogger.info('👤 [FirebaseAuth] UID obtido: $uid');
      
      if (uid == null) {
        AppLogger.error('❌ [FirebaseAuth] UID é null após autenticação');
        throw const InvalidCredentialsException('Usuário não encontrado');
      }

      AppLogger.info('📄 [FirebaseAuth] Buscando dados do usuário no Firestore...');
      
      // Buscar dados do usuário no Firestore
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        AppLogger.warning('⚠️ [FirebaseAuth] Documento do usuário não encontrado no Firestore');
        throw const StorageException('Dados do usuário não encontrados no Firestore');
      }

      final userData = userDoc.data()!;
      
      // Verificar se campo 'tipo' existe e não é null
      final userType = userData[FirestoreCollections.tipo] as String?;
      
      if (userType == null) {
        AppLogger.error('❌ [FirebaseAuth] Campo "tipo" está null no Firestore para UID: $uid');
        throw const StorageException(
          'Dados do usuário incompletos. Campo "tipo" não encontrado.',
        );
      }
      
      AppLogger.info('✅ [FirebaseAuth] Dados do usuário carregados. Tipo: $userType');

      // Retornar entidade apropriada (Patient ou Professional)
      if (userType == 'paciente') {
        AppLogger.info('✅ [FirebaseAuth] Login bem-sucedido como PACIENTE');
        return PatientEntity.fromJson(userData);
      } else {
        AppLogger.info('✅ [FirebaseAuth] Login bem-sucedido como PROFISSIONAL');
        return ProfessionalEntity.fromJson(userData);
      }
    } on OfflineModeException {
      AppLogger.warning('⚠️ [FirebaseAuth] OfflineModeException capturada - relançando');
      rethrow;
    } on StorageException {
      AppLogger.warning('⚠️ [FirebaseAuth] StorageException capturada - relançando');
      rethrow;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ [FirebaseAuth] FirebaseAuthException: ${e.code}', error: e);
      AppLogger.error('Mensagem: ${e.message}');
      
      switch (e.code) {
        case 'user-not-found':
          AppLogger.info('👤 [FirebaseAuth] Usuário não encontrado no Firebase Auth');
          throw const InvalidCredentialsException(
            'Email ou senha incorretos. Verifique e tente novamente.',
          );
        case 'wrong-password':
          AppLogger.info('🔑 [FirebaseAuth] Senha incorreta fornecida');
          throw const InvalidCredentialsException(
            'Email ou senha incorretos. Verifique e tente novamente.',
          );
        case 'invalid-credential':
          AppLogger.info('🔑 [FirebaseAuth] Credenciais inválidas');
          throw const InvalidCredentialsException(
            'Email ou senha incorretos. Verifique e tente novamente.',
          );
        case 'user-disabled':
          AppLogger.info('🚫 [FirebaseAuth] Conta desativada');
          throw const InvalidCredentialsException('Esta conta foi desativada.');
        case 'too-many-requests':
          AppLogger.info('⏰ [FirebaseAuth] Muitas tentativas de login');
          throw const NetworkException(
            'Muitas tentativas de login. Tente novamente mais tarde.',
          );
        case 'network-request-failed':
          AppLogger.info('📡 [FirebaseAuth] Falha na requisição de rede');
          throw const OfflineModeException(
            'Este aplicativo requer conexão com internet para funcionar.\n'
            'Por favor, verifique sua conexão e tente novamente.',
          );
        default:
          AppLogger.error('❓ [FirebaseAuth] Erro desconhecido: ${e.code}');
          throw AuthenticationException('Erro ao fazer login: ${e.message}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('💥 [FirebaseAuth] Erro inesperado durante login', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Registra um novo paciente
  /// 
  /// Lança [EmailAlreadyExistsException] se email já cadastrado
  /// Lança [ValidationException] se dados inválidos
  Future<PatientEntity> registerPatient(PatientEntity patient) async {
    try {
      AppLogger.info('Registrando paciente: ${patient.email}');

      // Criar conta no Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: patient.email,
        password: patient.password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw const AuthenticationException('Falha ao criar conta');
      }

      // Criar documento no Firestore
      final patientData = patient.toJson();
      patientData[FirestoreCollections.id] = uid;
      patientData[FirestoreCollections.tipo] = 'paciente'; // IMPORTANTE: garantir que tipo seja salvo
      patientData[FirestoreCollections.createdAt] = FieldValue.serverTimestamp();
      patientData[FirestoreCollections.updatedAt] = FieldValue.serverTimestamp();

      AppLogger.info('📝 [FirebaseAuth] Salvando dados no Firestore: ${patientData.keys.toList()}');
      
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .set(patientData);

      AppLogger.info('✅ Paciente registrado com sucesso: $uid');

      // Retornar entidade com ID atualizado
      return PatientEntity.fromJson({...patient.toJson(), 'id': uid});
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Erro ao registrar paciente', error: e);

      switch (e.code) {
        case 'email-already-in-use':
          throw const EmailAlreadyExistsException(
            'Este email já está cadastrado. Tente fazer login.',
          );
        case 'invalid-email':
          throw const ValidationException('Email inválido');
        case 'weak-password':
          throw const ValidationException(
            'Senha muito fraca. Use pelo menos 6 caracteres.',
          );
        case 'network-request-failed':
          throw const NetworkException(
            'Sem conexão com a internet. Verifique sua conexão.',
          );
        default:
          throw AuthenticationException('Erro ao registrar: ${e.message}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro inesperado ao registrar paciente', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Registra um novo profissional
  /// 
  /// Lança [EmailAlreadyExistsException] se email já cadastrado
  /// Lança [ValidationException] se dados inválidos
  Future<ProfessionalEntity> registerProfessional(
    ProfessionalEntity professional,
  ) async {
    try {
      AppLogger.info('Registrando profissional: ${professional.email}');

      // Criar conta no Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: professional.email,
        password: professional.password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw const AuthenticationException('Falha ao criar conta');
      }

      // Criar documento no Firestore
      final professionalData = professional.toJson();
      professionalData[FirestoreCollections.id] = uid;
      professionalData[FirestoreCollections.tipo] = 'profissional'; // IMPORTANTE: garantir que tipo seja salvo
      professionalData[FirestoreCollections.createdAt] = FieldValue.serverTimestamp();
      professionalData[FirestoreCollections.updatedAt] = FieldValue.serverTimestamp();
      professionalData[FirestoreCollections.avaliacao] = 0.0; // Avaliação inicial

      AppLogger.info('📝 [FirebaseAuth] Salvando dados no Firestore: ${professionalData.keys.toList()}');
      
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .set(professionalData);

      AppLogger.info('✅ Profissional registrado com sucesso: $uid');

      // Retornar entidade com ID atualizado
      return ProfessionalEntity.fromJson({...professional.toJson(), 'id': uid, 'avaliacao': 0.0});
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Erro ao registrar profissional', error: e);

      switch (e.code) {
        case 'email-already-in-use':
          throw const EmailAlreadyExistsException(
            'Este email já está cadastrado. Tente fazer login.',
          );
        case 'invalid-email':
          throw const ValidationException('Email inválido');
        case 'weak-password':
          throw const ValidationException(
            'Senha muito fraca. Use pelo menos 6 caracteres.',
          );
        case 'network-request-failed':
          throw const NetworkException(
            'Sem conexão com a internet. Verifique sua conexão.',
          );
        default:
          throw AuthenticationException('Erro ao registrar: ${e.message}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro inesperado ao registrar profissional', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Faz logout do usuário
  Future<void> logout() async {
    try {
      AppLogger.info('Fazendo logout');
      await _auth.signOut();
      AppLogger.info('✅ Logout realizado com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao fazer logout', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retorna o usuário atualmente logado (se houver)
  Future<UserEntity?> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final uid = currentUser.uid;
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data()!;
      
      // Verificar se campo 'tipo' existe e não é null
      final userType = userData[FirestoreCollections.tipo] as String?;
      
      if (userType == null) {
        AppLogger.error('❌ [FirebaseAuth] Campo "tipo" está null no getCurrentUser()');
        return null;
      }

      if (userType == 'paciente') {
        return PatientEntity.fromJson(userData);
      } else {
        return ProfessionalEntity.fromJson(userData);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar usuário atual', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Verifica se há um usuário autenticado
  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }
}

