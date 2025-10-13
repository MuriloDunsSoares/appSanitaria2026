/// Interface do repositório de profissionais.
///
/// **Responsabilidades:**
/// - Buscar profissionais (com filtros, especialidades, localização)
/// - Obter detalhes de um profissional específico
/// - Gerenciar dados de profissionais
library;

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/professional_entity.dart';
import '../entities/speciality.dart';

/// Contrato do repositório de profissionais.
abstract class ProfessionalsRepository {
  /// Retorna TODOS os profissionais cadastrados.
  ///
  /// Retorna:
  /// - [Right(List<ProfessionalEntity>)]: lista de profissionais (pode ser vazia)
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ProfessionalEntity>>> getAllProfessionals();

  /// Busca profissionais com filtros opcionais.
  ///
  /// **Parâmetros:**
  /// - [searchQuery]: busca por nome/especialidade (case-insensitive)
  /// - [speciality]: filtro por especialidade específica
  /// - [city]: filtro por cidade
  /// - [minRating]: rating mínimo (0.0 - 5.0)
  /// - [maxPrice]: preço máximo por hora
  /// - [minPrice]: preço mínimo por hora
  /// - [minExperience]: anos mínimos de experiência
  /// - [availableNow]: disponível agora
  ///
  /// Retorna:
  /// - [Right(List<ProfessionalEntity>)]: profissionais que atendem aos filtros
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ProfessionalEntity>>> searchProfessionals({
    String? searchQuery,
    Speciality? speciality,
    String? city,
    double? minRating,
    double? maxPrice,
    double? minPrice,
    int? minExperience,
    bool? availableNow,
  });

  /// Retorna um profissional por ID.
  ///
  /// Retorna:
  /// - [Right(ProfessionalEntity)]: profissional encontrado
  /// - [Left(NotFoundFailure)]: profissional não existe
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, ProfessionalEntity>> getProfessionalById(String id);

  /// Retorna profissionais de uma especialidade específica.
  ///
  /// Retorna:
  /// - [Right(List<ProfessionalEntity>)]: profissionais da especialidade
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ProfessionalEntity>>>
      getProfessionalsBySpeciality(Speciality speciality);

  /// Retorna profissionais de uma cidade específica.
  ///
  /// Retorna:
  /// - [Right(List<ProfessionalEntity>)]: profissionais da cidade
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ProfessionalEntity>>> getProfessionalsByCity(
      String city);

  /// Retorna múltiplos profissionais por lista de IDs.
  ///
  /// Útil para buscar profissionais favoritos.
  ///
  /// Retorna:
  /// - [Right(List<ProfessionalEntity>)]: profissionais encontrados (pode ser lista vazia)
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, List<ProfessionalEntity>>> getProfessionalsByIds(
      List<String> ids);

  /// Atualiza dados de um profissional.
  ///
  /// Retorna:
  /// - [Right(Unit)]: profissional atualizado com sucesso
  /// - [Left(StorageFailure)]: erro ao acessar armazenamento
  Future<Either<Failure, Unit>> updateProfessional(
      ProfessionalEntity professional);
}

