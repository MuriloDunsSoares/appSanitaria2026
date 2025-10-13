/// Use Case: Buscar profissionais com filtros.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/professional_entity.dart';
import '../../entities/speciality.dart';
import '../../repositories/professionals_repository.dart';

/// Use Case para buscar profissionais com filtros.
class SearchProfessionals
    extends UseCase<List<ProfessionalEntity>, SearchProfessionalsParams> {
  final ProfessionalsRepository repository;

  SearchProfessionals(this.repository);

  @override
  Future<Either<Failure, List<ProfessionalEntity>>> call(
    SearchProfessionalsParams params,
  ) async {
    return await repository.searchProfessionals(
      searchQuery: params.searchQuery,
      speciality: params.speciality,
      city: params.city,
      minRating: params.minRating,
      maxPrice: params.maxPrice,
      minPrice: params.minPrice,
      minExperience: params.minExperience,
      availableNow: params.availableNow,
    );
  }
}

/// Parâmetros para busca de profissionais.
class SearchProfessionalsParams extends Equatable {
  final String? searchQuery;
  final Speciality? speciality;
  final String? city;
  final double? minRating;
  final double? maxPrice;
  final double? minPrice;
  final int? minExperience; // Anos mínimos de experiência
  final bool? availableNow; // Disponível agora

  const SearchProfessionalsParams({
    this.searchQuery,
    this.speciality,
    this.city,
    this.minRating,
    this.maxPrice,
    this.minPrice,
    this.minExperience,
    this.availableNow,
  });

  @override
  List<Object?> get props => [
        searchQuery,
        speciality,
        city,
        minRating,
        maxPrice,
        minPrice,
        minExperience,
        availableNow,
      ];
}

