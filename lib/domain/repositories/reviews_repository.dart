/// Interface do repositório de avaliações.
///
/// **Responsabilidades:**
/// - Adicionar avaliações de profissionais
/// - Listar avaliações por profissional
/// - Calcular rating médio
/// - Deletar avaliações
library;

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/review_entity.dart';

/// Contrato do repositório de avaliações.
abstract class ReviewsRepository {
  /// Retorna TODAS as avaliações de um profissional.
  ///
  /// Retorna:
  /// - [Right(List<ReviewEntity>)]: lista de avaliações (pode ser vazia)
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ReviewEntity>>> getReviewsByProfessional(
    String professionalId,
  );

  /// Adiciona uma nova avaliação.
  ///
  /// Retorna:
  /// - [Right(ReviewEntity)]: avaliação criada com sucesso
  /// - [Left(ValidationFailure)]: dados inválidos
  /// - [Left(StorageFailure)]: erro ao salvar
  Future<Either<Failure, ReviewEntity>> addReview(ReviewEntity review);

  /// Deleta uma avaliação.
  ///
  /// Retorna:
  /// - [Right(Unit)]: avaliação deletada com sucesso
  /// - [Left(NotFoundFailure)]: avaliação não existe
  /// - [Left(StorageFailure)]: erro ao deletar
  Future<Either<Failure, Unit>> deleteReview(String reviewId);

  /// Calcula o rating médio de um profissional.
  ///
  /// Retorna:
  /// - [Right(double)]: rating médio (0.0 se não houver avaliações)
  /// - [Left(StorageFailure)]: erro ao calcular
  Future<Either<Failure, double>> getAverageRating(String professionalId);

  /// Conta o número de avaliações de um profissional.
  ///
  /// Retorna:
  /// - [Right(int)]: número de avaliações
  /// - [Left(StorageFailure)]: erro ao contar
  Future<Either<Failure, int>> getReviewsCount(String professionalId);
}
