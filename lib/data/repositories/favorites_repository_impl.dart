/// Implementação do repositório de favoritos.
library;

import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/firebase_favorites_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FirebaseFavoritesDataSource dataSource;

  FavoritesRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<String>>> getFavorites(String patientId) async {
    try {
      final favorites = await dataSource.getFavorites(patientId);
      return Right(favorites);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addFavorite(
    String patientId,
    String professionalId,
  ) async {
    try {
      await dataSource.addFavorite(patientId, professionalId);
      return const Right(unit);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(
    String patientId,
    String professionalId,
  ) async {
    try {
      await dataSource.removeFavorite(patientId, professionalId);
      return const Right(unit);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(
    String patientId,
    String professionalId,
  ) async {
    try {
      final isFav = await dataSource.isFavorite(patientId, professionalId);
      return Right(isFav);
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(
    String patientId,
    String professionalId,
  ) async {
    try {
      final isFav = await dataSource.isFavorite(patientId, professionalId);
      if (isFav) {
        await dataSource.removeFavorite(patientId, professionalId);
        return const Right(false);
      } else {
        await dataSource.addFavorite(patientId, professionalId);
        return const Right(true);
      }
    } on LocalStorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}




