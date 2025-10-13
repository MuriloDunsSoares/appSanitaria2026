/// Use Case: Obter caminho da foto de perfil de um usuário.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/profile_repository.dart';

/// Use Case para obter foto de perfil.
///
/// **Responsabilidade única:** Buscar caminho da imagem de perfil.
class GetProfileImage extends UseCase<String?, String> {
  GetProfileImage(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, String?>> call(String userId) async {
    return repository.getProfileImage(userId);
  }
}

/// Parâmetros do Use Case GetProfileImage.
class GetProfileImageParams extends Equatable {
  const GetProfileImageParams({required this.userId});
  final String userId;

  @override
  List<Object?> get props => [userId];
}
