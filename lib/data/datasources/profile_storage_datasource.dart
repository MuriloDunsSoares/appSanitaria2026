/// DataSource para armazenamento local de perfis de usuário
library;

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/professional_entity.dart';
import 'dart:convert';

/// ProfileStorageDataSource - Responsável pelo armazenamento local de perfis
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas gerenciamento de storage local de perfis
/// - Dependency Injection: Recebe SharedPreferences via construtor
///
/// Responsabilidades:
/// - Salvar/carregar caminhos de fotos de perfil
/// - Salvar/carregar dados de perfil de pacientes
/// - Salvar/carregar dados de perfil de profissionais
class ProfileStorageDataSource {
  final SharedPreferences _prefs;

  static const String _profileImagePrefix = 'profile_image_';
  static const String _patientProfilePrefix = 'patient_profile_';
  static const String _professionalProfilePrefix = 'professional_profile_';

  ProfileStorageDataSource({required SharedPreferences prefs}) : _prefs = prefs;

  /// Obtém o caminho da foto de perfil de um usuário
  Future<String?> getProfileImage(String userId) async {
    try {
      AppLogger.info('Buscando foto de perfil: $userId');
      final key = '$_profileImagePrefix$userId';
      final imagePath = _prefs.getString(key);
      
      if (imagePath != null) {
        AppLogger.info('✅ Foto encontrada: $imagePath');
      } else {
        AppLogger.info('⚠️ Nenhuma foto encontrada');
      }
      
      return imagePath;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao buscar foto de perfil',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocalStorageException('Erro ao buscar foto de perfil: $e');
    }
  }

  /// Salva o caminho da foto de perfil de um usuário
  Future<void> saveProfileImage(String userId, String imagePath) async {
    try {
      AppLogger.info('Salvando foto de perfil: $userId -> $imagePath');
      final key = '$_profileImagePrefix$userId';
      await _prefs.setString(key, imagePath);
      AppLogger.info('✅ Foto salva com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao salvar foto de perfil',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocalStorageException('Erro ao salvar foto de perfil: $e');
    }
  }

  /// Deleta a foto de perfil de um usuário
  Future<void> deleteProfileImage(String userId) async {
    try {
      AppLogger.info('Deletando foto de perfil: $userId');
      final key = '$_profileImagePrefix$userId';
      await _prefs.remove(key);
      AppLogger.info('✅ Foto deletada com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao deletar foto de perfil',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocalStorageException('Erro ao deletar foto de perfil: $e');
    }
  }

  /// Salva perfil de paciente localmente
  Future<void> savePatientProfile(PatientEntity patient) async {
    try {
      AppLogger.info('Salvando perfil de paciente: ${patient.id}');
      final key = '$_patientProfilePrefix${patient.id}';
      final jsonData = json.encode(patient.toJson());
      await _prefs.setString(key, jsonData);
      AppLogger.info('✅ Perfil de paciente salvo');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao salvar perfil de paciente',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocalStorageException('Erro ao salvar perfil de paciente: $e');
    }
  }

  /// Obtém perfil de paciente localmente
  Future<PatientEntity?> getPatientProfile(String patientId) async {
    try {
      AppLogger.info('Buscando perfil de paciente: $patientId');
      final key = '$_patientProfilePrefix$patientId';
      final jsonData = _prefs.getString(key);
      
      if (jsonData != null) {
        final jsonMap = json.decode(jsonData) as Map<String, dynamic>;
        final patient = PatientEntity.fromJson(jsonMap);
        AppLogger.info('✅ Perfil de paciente encontrado');
        return patient;
      }
      
      AppLogger.info('⚠️ Perfil de paciente não encontrado');
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao buscar perfil de paciente',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocalStorageException('Erro ao buscar perfil de paciente: $e');
    }
  }

  /// Salva perfil de profissional localmente
  Future<void> saveProfessionalProfile(ProfessionalEntity professional) async {
    try {
      AppLogger.info('Salvando perfil de profissional: ${professional.id}');
      final key = '$_professionalProfilePrefix${professional.id}';
      final jsonData = json.encode(professional.toJson());
      await _prefs.setString(key, jsonData);
      AppLogger.info('✅ Perfil de profissional salvo');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao salvar perfil de profissional',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocalStorageException('Erro ao salvar perfil de profissional: $e');
    }
  }

  /// Obtém perfil de profissional localmente
  Future<ProfessionalEntity?> getProfessionalProfile(
    String professionalId,
  ) async {
    try {
      AppLogger.info('Buscando perfil de profissional: $professionalId');
      final key = '$_professionalProfilePrefix$professionalId';
      final jsonData = _prefs.getString(key);
      
      if (jsonData != null) {
        final jsonMap = json.decode(jsonData) as Map<String, dynamic>;
        final professional = ProfessionalEntity.fromJson(jsonMap);
        AppLogger.info('✅ Perfil de profissional encontrado');
        return professional;
      }
      
      AppLogger.info('⚠️ Perfil de profissional não encontrado');
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao buscar perfil de profissional',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocalStorageException('Erro ao buscar perfil de profissional: $e');
    }
  }

  /// Limpa dados sensíveis do perfil (usado no logout)
  /// NOTA: NÃO remove fotos de perfil - elas devem persistir entre sessões
  Future<void> clearAllProfiles() async {
    try {
      AppLogger.info('Limpando dados sensíveis dos perfis locais');
      
      // Buscar todas as chaves relacionadas a perfis EXCETO fotos
      final keys = _prefs.getKeys();
      final profileKeys = keys.where((key) =>
          // key.startsWith(_profileImagePrefix) ||  // NÃO remover fotos!
          key.startsWith(_patientProfilePrefix) ||
          key.startsWith(_professionalProfilePrefix));
      
      // Remover apenas dados de perfil (não fotos)
      for (final key in profileKeys) {
        await _prefs.remove(key);
      }
      
      AppLogger.info('✅ Dados sensíveis dos perfis foram limpos (fotos preservadas)');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erro ao limpar perfis',
        error: e,
        stackTrace: stackTrace,
      );
      throw LocalStorageException('Erro ao limpar perfis: $e');
    }
  }
}

