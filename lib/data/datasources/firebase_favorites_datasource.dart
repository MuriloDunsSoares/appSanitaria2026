import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firestore_collections.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/app_logger.dart';

/// DataSource para favoritos usando Firestore
/// 
/// Responsável por:
/// - Adicionar/remover favoritos
/// - Buscar favoritos de um usuário
/// - Verificar se profissional está favoritado
class FirebaseFavoritesDataSource {
  final FirebaseFirestore _firestore;

  FirebaseFavoritesDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtém os IDs dos profissionais favoritos de um usuário
  Future<List<String>> getFavorites(String userId) async {
    try {
      AppLogger.info('Buscando favoritos: $userId');

      final doc = await _firestore
          .collection(FirestoreCollections.favorites)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return [];
      }

      final data = doc.data()!;
      final favorites = List<String>.from(
        (data[FirestoreCollections.professionalIds] ?? []) as List,
      );

      AppLogger.info('✅ ${favorites.length} favoritos encontrados');

      return favorites;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar favoritos', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao buscar favoritos: $e');
    }
  }

  /// Adiciona um profissional aos favoritos
  Future<void> addFavorite(String userId, String professionalId) async {
    try {
      AppLogger.info('Adicionando favorito: $userId -> $professionalId');

      await _firestore
          .collection(FirestoreCollections.favorites)
          .doc(userId)
          .set({
        FirestoreCollections.userId: userId,
        FirestoreCollections.professionalIds: FieldValue.arrayUnion([professionalId]),
        FirestoreCollections.updatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      AppLogger.info('✅ Favorito adicionado');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao adicionar favorito', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao adicionar favorito: $e');
    }
  }

  /// Remove um profissional dos favoritos
  Future<void> removeFavorite(String userId, String professionalId) async {
    try {
      AppLogger.info('Removendo favorito: $userId -> $professionalId');

      await _firestore
          .collection(FirestoreCollections.favorites)
          .doc(userId)
          .update({
        FirestoreCollections.professionalIds: FieldValue.arrayRemove([professionalId]),
        FirestoreCollections.updatedAt: FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Favorito removido');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao remover favorito', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao remover favorito: $e');
    }
  }

  /// Verifica se um profissional está nos favoritos
  Future<bool> isFavorite(String userId, String professionalId) async {
    try {
      final favorites = await getFavorites(userId);
      return favorites.contains(professionalId);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar favorito', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Remove todos os favoritos de um usuário
  Future<void> clearAllFavorites(String userId) async {
    try {
      AppLogger.info('Limpando favoritos: $userId');

      await _firestore
          .collection(FirestoreCollections.favorites)
          .doc(userId)
          .delete();

      AppLogger.info('✅ Favoritos limpos');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao limpar favoritos', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao limpar favoritos: $e');
    }
  }
}

