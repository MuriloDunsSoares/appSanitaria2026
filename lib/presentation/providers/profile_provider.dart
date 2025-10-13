/// Provider para gerenciamento de perfil.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_sanitaria/core/di/injection_container.dart';
import 'package:app_sanitaria/domain/usecases/profile/delete_profile_image.dart';
import 'package:app_sanitaria/domain/usecases/profile/get_profile_image.dart';
import 'package:app_sanitaria/domain/usecases/profile/save_profile_image.dart';
import 'package:app_sanitaria/domain/usecases/profile/update_patient_profile.dart';
import 'package:app_sanitaria/domain/usecases/profile/update_professional_profile.dart';
import 'package:app_sanitaria/domain/entities/patient_entity.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';

/// Estado do Perfil
enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State do Perfil
class ProfileState {
  final ProfileStatus status;
  final String? profileImagePath;
  final String? errorMessage;

  ProfileState({
    required this.status,
    this.profileImagePath,
    this.errorMessage,
  });

  factory ProfileState.initial() => ProfileState(status: ProfileStatus.initial);
  factory ProfileState.loading() => ProfileState(status: ProfileStatus.loading);
  factory ProfileState.loaded(String? imagePath) {
    return ProfileState(
      status: ProfileStatus.loaded,
      profileImagePath: imagePath,
    );
  }
  factory ProfileState.error(String message) {
    return ProfileState(status: ProfileStatus.error, errorMessage: message);
  }

  bool get isLoading => status == ProfileStatus.loading;
  bool get hasImage => profileImagePath != null && profileImagePath!.isNotEmpty;

  ProfileState copyWith({
    ProfileStatus? status,
    String? profileImagePath,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// ProfileNotifier - Gerencia estado do perfil
class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfileImage _getProfileImage;
  final SaveProfileImage _saveProfileImage;
  final DeleteProfileImage _deleteProfileImage;

  ProfileNotifier({
    required GetProfileImage getProfileImage,
    required SaveProfileImage saveProfileImage,
    required DeleteProfileImage deleteProfileImage,
  })  : _getProfileImage = getProfileImage,
        _saveProfileImage = saveProfileImage,
        _deleteProfileImage = deleteProfileImage,
        super(ProfileState.initial());

  /// Carrega foto de perfil de um usuário
  Future<void> loadProfileImage(String userId) async {
    state = ProfileState.loading();

    final result = await _getProfileImage.call(userId);

    result.fold(
      (failure) {
        state = ProfileState.error('Erro ao carregar foto de perfil');
      },
      (imagePath) {
        state = ProfileState.loaded(imagePath);
      },
    );
  }

  /// Salva nova foto de perfil
  Future<void> saveProfileImage(String userId, String imagePath) async {
    state = ProfileState.loading();

    final result = await _saveProfileImage.call(
      SaveProfileImageParams(userId: userId, imagePath: imagePath),
    );

    result.fold(
      (failure) {
        state = ProfileState.error('Erro ao salvar foto de perfil');
      },
      (_) {
        state = ProfileState.loaded(imagePath);
      },
    );
  }

  /// Deleta foto de perfil
  Future<void> deleteProfileImage(String userId) async {
    state = ProfileState.loading();

    final result = await _deleteProfileImage.call(userId);

    result.fold(
      (failure) {
        state = ProfileState.error('Erro ao deletar foto de perfil');
      },
      (_) {
        state = ProfileState.loaded(null);
      },
    );
  }
}

/// Provider para operações de atualização de perfil
final profileUpdateProvider = FutureProvider.family<bool, UserEntity>((ref, user) async {
  final updatePatientProfile = getIt<UpdatePatientProfile>();
  final updateProfessionalProfile = getIt<UpdateProfessionalProfile>();

  if (user is PatientEntity) {
    final result = await updatePatientProfile.call(user);
    return result.isRight();
  } else if (user is ProfessionalEntity) {
    final result = await updateProfessionalProfile.call(user);
    return result.isRight();
  }

  throw Exception('Tipo de usuário não suportado');
});

/// Provider global para perfil (imagens)
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(
    getProfileImage: getIt<GetProfileImage>(),
    saveProfileImage: getIt<SaveProfileImage>(),
    deleteProfileImage: getIt<DeleteProfileImage>(),
  ),
);

