/// Use Case: Deletar foto de perfil de um usuário.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/profile_repository.dart';

/// Use Case para deletar foto de perfil.
///
/// **Responsabilidade única:** Remover imagem de perfil.
class DeleteProfileImage extends UseCase<Unit, String> {
  final ProfileRepository repository;

  DeleteProfileImage(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String userId) async {
    return await repository.deleteProfileImage(userId);
  }
}

/// Parâmetros do Use Case DeleteProfileImage.
class DeleteProfileImageParams extends Equatable {
  final String userId;

  const DeleteProfileImageParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

