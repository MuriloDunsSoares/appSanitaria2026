/// Use Case: Salvar caminho da foto de perfil de um usuário.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/profile_repository.dart';

/// Use Case para salvar foto de perfil.
///
/// **Responsabilidade única:** Persistir caminho da imagem de perfil.
class SaveProfileImage extends UseCase<Unit, SaveProfileImageParams> {
  final ProfileRepository repository;

  SaveProfileImage(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SaveProfileImageParams params) async {
    // Validação de caminho vazio
    if (params.imagePath.trim().isEmpty) {
      return const Left(ValidationFailure('Caminho da imagem inválido'));
    }

    return await repository.saveProfileImage(params.userId, params.imagePath);
  }
}

/// Parâmetros do Use Case SaveProfileImage.
class SaveProfileImageParams extends Equatable {
  final String userId;
  final String imagePath;

  const SaveProfileImageParams({
    required this.userId,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [userId, imagePath];
}
