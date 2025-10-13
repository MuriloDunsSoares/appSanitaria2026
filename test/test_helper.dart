/// Test Helper
///
/// Arquivo central para configuração de mocks usando Mockito.
/// Todos os testes devem importar os mocks gerados deste arquivo.
library;

import 'package:app_sanitaria/domain/repositories/auth_repository.dart';
import 'package:app_sanitaria/domain/repositories/chat_repository.dart';
import 'package:app_sanitaria/domain/repositories/contracts_repository.dart';
import 'package:app_sanitaria/domain/repositories/favorites_repository.dart';
import 'package:app_sanitaria/domain/repositories/professionals_repository.dart';
import 'package:app_sanitaria/domain/repositories/profile_repository.dart';
import 'package:app_sanitaria/domain/repositories/reviews_repository.dart';
import 'package:mockito/annotations.dart';

// Gerar mocks com: dart run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  AuthRepository,
  ChatRepository,
  ContractsRepository,
  FavoritesRepository,
  ProfessionalsRepository,
  ProfileRepository,
  ReviewsRepository,
])
void main() {}
