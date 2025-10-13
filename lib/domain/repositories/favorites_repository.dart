/// Interface do repositório de favoritos.
///
/// **Responsabilidades:**
/// - Adicionar/remover profissionais dos favoritos
/// - Listar favoritos de um paciente
/// - Verificar se um profissional está nos favoritos
library;

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

/// Contrato do repositório de favoritos.
abstract class FavoritesRepository {
  /// Retorna IDs dos profissionais favoritos de um paciente.
  ///
  /// Retorna:
  /// - [Right(List<String>)]: lista de IDs (pode ser vazia)
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<String>>> getFavorites(String patientId);

  /// Adiciona um profissional aos favoritos.
  ///
  /// Retorna:
  /// - [Right(Unit)]: favorito adicionado com sucesso
  /// - [Left(StorageFailure)]: erro ao salvar
  Future<Either<Failure, Unit>> addFavorite(
    String patientId,
    String professionalId,
  );

  /// Remove um profissional dos favoritos.
  ///
  /// Retorna:
  /// - [Right(Unit)]: favorito removido com sucesso
  /// - [Left(StorageFailure)]: erro ao salvar
  Future<Either<Failure, Unit>> removeFavorite(
    String patientId,
    String professionalId,
  );

  /// Verifica se um profissional está nos favoritos.
  ///
  /// Retorna:
  /// - [Right(bool)]: true se está nos favoritos
  /// - [Left(StorageFailure)]: erro ao verificar
  Future<Either<Failure, bool>> isFavorite(
    String patientId,
    String professionalId,
  );

  /// Alterna o estado de favorito (adiciona se não existe, remove se existe).
  ///
  /// Retorna:
  /// - [Right(bool)]: novo estado (true = adicionado, false = removido)
  /// - [Left(StorageFailure)]: erro ao alternar
  Future<Either<Failure, bool>> toggleFavorite(
    String patientId,
    String professionalId,
  );
}
