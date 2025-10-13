import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firestore_collections.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/review_entity.dart';

/// DataSource para avaliações usando Firestore
/// 
/// Responsável por:
/// - Adicionar avaliações de profissionais
/// - Buscar avaliações por profissional
/// - Calcular avaliação média
class FirebaseReviewsDataSource {
  final FirebaseFirestore _firestore;

  FirebaseReviewsDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Adiciona uma nova avaliação
  Future<ReviewEntity> addReview(ReviewEntity review) async {
    try {
      AppLogger.info('Adicionando avaliação: ${review.professionalId}');

      final reviewId = _firestore
          .collection(FirestoreCollections.reviews)
          .doc()
          .id;

      final reviewData = review.toJson();
      reviewData[FirestoreCollections.id] = reviewId;
      reviewData[FirestoreCollections.createdAt] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirestoreCollections.reviews)
          .doc(reviewId)
          .set(reviewData);

      // Atualizar avaliação média do profissional
      await _updateProfessionalAverageRating(review.professionalId);

      AppLogger.info('✅ Avaliação adicionada: $reviewId');

      // Retornar entidade com ID atualizado
      return ReviewEntity.fromJson({...review.toJson(), 'id': reviewId});
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao adicionar avaliação', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao adicionar avaliação: $e');
    }
  }

  /// Obtém todas as avaliações de um profissional
  Future<List<ReviewEntity>> getReviewsByProfessional(
    String professionalId,
  ) async {
    try {
      AppLogger.info('Buscando avaliações: $professionalId');

      final snapshot = await _firestore
          .collection(FirestoreCollections.reviews)
          .where(FirestoreCollections.professionalId, isEqualTo: professionalId)
          .orderBy(FirestoreCollections.createdAt, descending: true)
          .get();

      final reviews = snapshot.docs.map((doc) {
        return ReviewEntity.fromJson(doc.data());
      }).toList();

      AppLogger.info('✅ ${reviews.length} avaliações encontradas');

      return reviews;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar avaliações', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao buscar avaliações: $e');
    }
  }

  /// Calcula e obtém a avaliação média de um profissional
  Future<double> getAverageRating(String professionalId) async {
    try {
      final reviews = await getReviewsByProfessional(professionalId);

      if (reviews.isEmpty) {
        return 0.0;
      }

      final sum = reviews.fold<double>(
        0.0,
        (sum, review) => sum + review.rating,
      );

      return sum / reviews.length;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao calcular avaliação média', error: e, stackTrace: stackTrace);
      return 0.0;
    }
  }

  /// Atualiza a avaliação média do profissional no documento de usuário
  Future<void> _updateProfessionalAverageRating(String professionalId) async {
    try {
      final averageRating = await getAverageRating(professionalId);

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(professionalId)
          .update({
        FirestoreCollections.avaliacao: averageRating,
        FirestoreCollections.updatedAt: FieldValue.serverTimestamp(),
      });

      AppLogger.info('✅ Avaliação média atualizada: $professionalId -> $averageRating');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar avaliação média', error: e, stackTrace: stackTrace);
    }
  }

  /// Deleta uma avaliação
  Future<void> deleteReview(String reviewId) async {
    try {
      AppLogger.info('Deletando avaliação: $reviewId');

      // Buscar avaliação para pegar professionalId
      final doc = await _firestore
          .collection(FirestoreCollections.reviews)
          .doc(reviewId)
          .get();

      if (!doc.exists) {
        throw const StorageException('Avaliação não encontrada');
      }

      final professionalId = doc.data()![FirestoreCollections.professionalId] as String;

      // Deletar avaliação
      await _firestore
          .collection(FirestoreCollections.reviews)
          .doc(reviewId)
          .delete();

      // Atualizar avaliação média
      await _updateProfessionalAverageRating(professionalId);

      AppLogger.info('✅ Avaliação deletada: $reviewId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao deletar avaliação', error: e, stackTrace: stackTrace);
      throw StorageException('Erro ao deletar avaliação: $e');
    }
  }
}

