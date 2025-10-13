import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firestore_collections.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/professional_entity.dart';
import '../../domain/entities/user_type.dart';

/// DataSource para profissionais usando Firestore
/// 
/// Responsável por:
/// - Buscar profissionais
/// - Filtrar por especialidade/cidade
/// - Atualizar dados de profissionais
class FirebaseProfessionalsDataSource {
  final FirebaseFirestore _firestore;

  FirebaseProfessionalsDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtém todos os profissionais
  Future<List<ProfessionalEntity>> getAllProfessionals() async {
    try {
      AppLogger.info('Buscando todos profissionais');

      final snapshot = await _firestore
          .collection(FirestoreCollections.users)
          .where(FirestoreCollections.tipo, isEqualTo: UserType.professional.name)
          .get();

      final professionals = snapshot.docs.map((doc) {
        return ProfessionalEntity.fromJson(doc.data());
      }).toList();

      AppLogger.info('✅ ${professionals.length} profissionais encontrados');

      return professionals;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar profissionais', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao buscar profissionais: $e');
    }
  }

  /// Busca profissionais por query (nome ou especialidade)
  Future<List<ProfessionalEntity>> searchProfessionals(String query) async {
    try {
      AppLogger.info('Buscando profissionais: $query');

      // Firestore não tem busca full-text nativa, então vamos buscar todos
      // e filtrar no código (para MVP). Em produção, use Algolia ou ElasticSearch.
      final allProfessionals = await getAllProfessionals();

      final queryLower = query.toLowerCase();

      final filtered = allProfessionals.where((prof) {
        final nomeLower = prof.nome.toLowerCase();
        final especialidadeLower = prof.especialidade.toString().toLowerCase();
        return nomeLower.contains(queryLower) ||
            especialidadeLower.contains(queryLower);
      }).toList();

      AppLogger.info('✅ ${filtered.length} profissionais encontrados com "$query"');

      return filtered;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar profissionais', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao buscar profissionais: $e');
    }
  }

  /// Obtém um profissional por ID
  Future<ProfessionalEntity?> getProfessionalById(String id) async {
    try {
      AppLogger.info('Buscando profissional: $id');

      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(id)
          .get();

      if (!doc.exists) {
        AppLogger.info('⚠️ Profissional não encontrado: $id');
        return null;
      }

      final data = doc.data()!;
      final tipo = data[FirestoreCollections.tipo] as String;

      if (tipo != UserType.professional.name) {
        AppLogger.info('⚠️ Usuário $id não é profissional');
        return null;
      }

      return ProfessionalEntity.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar profissional', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Obtém múltiplos profissionais por IDs
  /// Útil para buscar favoritos
  Future<List<ProfessionalEntity>> getProfessionalsByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) {
        return [];
      }

      AppLogger.info('Buscando ${ids.length} profissionais por IDs');

      // Buscar profissionais em lotes (Firestore limita 'whereIn' a 10 itens)
      final List<ProfessionalEntity> professionals = [];
      
      // Dividir em chunks de 10 IDs
      for (var i = 0; i < ids.length; i += 10) {
        final chunkEnd = (i + 10 < ids.length) ? i + 10 : ids.length;
        final chunk = ids.sublist(i, chunkEnd);

        final snapshot = await _firestore
            .collection(FirestoreCollections.users)
            .where(FieldPath.documentId, whereIn: chunk)
            .where(FirestoreCollections.tipo, isEqualTo: UserType.professional.name)
            .get();

        final chunkProfessionals = snapshot.docs.map((doc) {
          return ProfessionalEntity.fromJson(doc.data());
        }).toList();

        professionals.addAll(chunkProfessionals);
      }

      AppLogger.info('✅ ${professionals.length} profissionais encontrados por IDs');

      return professionals;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar profissionais por IDs', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao buscar profissionais por IDs: $e');
    }
  }

  /// Atualiza dados de um profissional
  Future<void> updateProfessional(ProfessionalEntity professional) async {
    try {
      AppLogger.info('Atualizando profissional: ${professional.id}');

      final data = professional.toJson();
      data[FirestoreCollections.updatedAt] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(professional.id)
          .update(data);

      AppLogger.info('✅ Profissional atualizado: ${professional.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar profissional', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao atualizar profissional: $e');
    }
  }

  /// Atualiza a avaliação média de um profissional
  Future<void> updateProfessionalRating(
    String professionalId,
    double newRating,
  ) async {
    try {
      AppLogger.info('Atualizando avaliação: $professionalId -> $newRating');

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(professionalId)
          .update({
        FirestoreCollections.avaliacao: newRating,
        FirestoreCollections.updatedAt: FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Avaliação atualizada: $professionalId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar avaliação', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao atualizar avaliação: $e');
    }
  }

  /// Atualiza a foto de perfil de um profissional
  Future<void> updateProfessionalPhoto(
    String professionalId,
    String photoUrl,
  ) async {
    try {
      AppLogger.info('Atualizando foto: $professionalId');

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(professionalId)
          .update({
        FirestoreCollections.photoUrl: photoUrl,
        FirestoreCollections.updatedAt: FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Foto atualizada: $professionalId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar foto', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao atualizar foto: $e');
    }
  }
}

