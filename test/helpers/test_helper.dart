import 'package:mockito/annotations.dart';
import 'package:app_sanitaria/domain/repositories/auth_repository.dart';
import 'package:app_sanitaria/domain/repositories/professionals_repository.dart';
import 'package:app_sanitaria/domain/repositories/contracts_repository.dart';
import 'package:app_sanitaria/domain/repositories/chat_repository.dart';
import 'package:app_sanitaria/domain/repositories/favorites_repository.dart';
import 'package:app_sanitaria/domain/repositories/reviews_repository.dart';
import 'package:app_sanitaria/domain/repositories/profile_repository.dart';

@GenerateMocks([
  AuthRepository,
  ProfessionalsRepository,
  ContractsRepository,
  ChatRepository,
  FavoritesRepository,
  ReviewsRepository,
  ProfileRepository,
])
void main() {}


