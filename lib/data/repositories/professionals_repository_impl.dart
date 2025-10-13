/// Implementação do repositório de profissionais usando Firebase 100%.
library;

import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/professional_entity.dart';
import '../../domain/entities/speciality.dart';
import '../../domain/repositories/professionals_repository.dart';
import '../datasources/firebase_professionals_datasource.dart';

/// Implementação do repositório de profissionais usando Firebase 100%.
///
/// **Características:**
/// - Usa apenas `FirebaseProfessionalsDataSource` (Cloud Firestore)
/// - Dados sincronizam automaticamente
/// - Busca e filtros executados no servidor (quando possível)
class ProfessionalsRepositoryImpl implements ProfessionalsRepository {
  ProfessionalsRepositoryImpl({
    required this.firebaseProfessionalsDataSource,
  });
  final FirebaseProfessionalsDataSource firebaseProfessionalsDataSource;

  @override
  Future<Either<Failure, List<ProfessionalEntity>>>
      getAllProfessionals() async {
    try {
      final professionals =
          await firebaseProfessionalsDataSource.getAllProfessionals();
      return Right(professionals);
    } on StorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProfessionalEntity>>> searchProfessionals({
    String? searchQuery,
    Speciality? speciality,
    String? city,
    double? minRating,
    double? maxPrice,
    double? minPrice,
    int? minExperience,
    bool? availableNow,
  }) async {
    try {
      // Buscar todos os profissionais do Firestore
      var professionals =
          await firebaseProfessionalsDataSource.getAllProfessionals();

      // Filtrar por query de busca (nome ou especialidade)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        professionals = professionals.where((prof) {
          return prof.name.toLowerCase().contains(query) ||
              prof.speciality.name.toLowerCase().contains(query);
        }).toList();
      }

      // Filtrar por especialidade
      if (speciality != null) {
        professionals = professionals
            .where((prof) => prof.speciality == speciality)
            .toList();
      }

      // Filtrar por cidade
      if (city != null) {
        professionals =
            professionals.where((prof) => prof.city == city).toList();
      }

      // Filtrar por rating mínimo
      if (minRating != null) {
        professionals = professionals
            .where((prof) => (prof.averageRating ?? 0) >= minRating)
            .toList();
      }

      // Filtrar por preço máximo
      if (maxPrice != null) {
        professionals =
            professionals.where((prof) => prof.hourlyRate <= maxPrice).toList();
      }

      // Filtrar por preço mínimo
      if (minPrice != null) {
        professionals =
            professionals.where((prof) => prof.hourlyRate >= minPrice).toList();
      }

      // Filtrar por experiência mínima
      if (minExperience != null) {
        professionals = professionals
            .where((prof) => prof.experiencia >= minExperience)
            .toList();
      }

      // Ordenar por rating (maiores primeiro)
      professionals.sort(
          (a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));

      return Right(professionals);
    } on StorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfessionalEntity>> getProfessionalById(
      String id) async {
    try {
      final professional =
          await firebaseProfessionalsDataSource.getProfessionalById(id);

      if (professional == null) {
        return const Left(NotFoundFailure('Profissional não encontrado'));
      }

      return Right(professional);
    } on StorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProfessionalEntity>>>
      getProfessionalsBySpeciality(
    Speciality speciality,
  ) async {
    try {
      final professionals =
          await firebaseProfessionalsDataSource.getAllProfessionals();
      final filtered =
          professionals.where((prof) => prof.speciality == speciality).toList();
      return Right(filtered);
    } on StorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProfessionalEntity>>> getProfessionalsByCity(
    String city,
  ) async {
    try {
      final professionals =
          await firebaseProfessionalsDataSource.getAllProfessionals();
      final filtered =
          professionals.where((prof) => prof.city == city).toList();
      return Right(filtered);
    } on StorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProfessionalEntity>>> getProfessionalsByIds(
    List<String> ids,
  ) async {
    try {
      final professionals =
          await firebaseProfessionalsDataSource.getProfessionalsByIds(ids);
      return Right(professionals);
    } on StorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProfessional(
    ProfessionalEntity professional,
  ) async {
    try {
      await firebaseProfessionalsDataSource.updateProfessional(professional);
      return const Right(unit);
    } on StorageException catch (_) {
      return const Left(StorageFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
