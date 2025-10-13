/// Service Locator (Dependency Injection Container).
///
/// **Responsabilidades:**
/// - Registrar todas as dependências da aplicação (datasources, repositories, use cases)
/// - Fornecer instâncias através do GetIt (Service Locator pattern)
/// - Gerenciar lifecycle (Singleton vs Factory)
///
/// **Convenção:**
/// - `sl<T>()` - Service Locator global (acessível em qualquer lugar)
/// - Registrar na ordem: Core → Data → Domain → Presentation
/// - Usar Lazy Singletons para melhor performance
///
/// **Setup:**
/// Chamar `await setupDependencyInjection()` no `main.dart` ANTES de `runApp()`.
///
/// **Firebase 100%:**
/// - Usa apenas datasources Firebase (FirebaseAuth, Firestore, Storage)
/// - Sem armazenamento local (SharedPreferences removido)
/// - Sincronização automática entre dispositivos
library;

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Services
import '../../core/services/connectivity_service.dart';
// Data sources - Firebase
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firebase_chat_datasource.dart';
import '../../data/datasources/firebase_contracts_datasource.dart';
import '../../data/datasources/firebase_favorites_datasource.dart';
import '../../data/datasources/firebase_professionals_datasource.dart';
import '../../data/datasources/firebase_reviews_datasource.dart';
import '../../data/datasources/profile_storage_datasource.dart';
// Repositories
import '../../data/repositories/auth_repository_firebase_impl.dart';
import '../../data/repositories/chat_repository_firebase_impl.dart';
import '../../data/repositories/contracts_repository_impl.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/professionals_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/reviews_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/contracts_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/professionals_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/reviews_repository.dart';
// Use cases - Auth
import '../../domain/usecases/auth/check_authentication.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/login_user.dart';
import '../../domain/usecases/auth/logout_user.dart';
import '../../domain/usecases/auth/register_patient.dart';
import '../../domain/usecases/auth/register_professional.dart';
// Use cases - Chat
import '../../domain/usecases/chat/get_messages.dart';
import '../../domain/usecases/chat/get_user_conversations.dart';
import '../../domain/usecases/chat/mark_messages_as_read.dart';
import '../../domain/usecases/chat/send_message.dart';
// Use cases - Contracts
import '../../domain/usecases/contracts/create_contract.dart';
import '../../domain/usecases/contracts/get_contracts_by_patient.dart';
import '../../domain/usecases/contracts/get_contracts_by_professional.dart';
import '../../domain/usecases/contracts/update_contract_status.dart';
// Use cases - Favorites
import '../../domain/usecases/favorites/get_favorites.dart';
import '../../domain/usecases/favorites/toggle_favorite.dart';
// Use cases - Professionals
import '../../domain/usecases/professionals/get_all_professionals.dart';
import '../../domain/usecases/professionals/get_professional_by_id.dart';
import '../../domain/usecases/professionals/get_professionals_by_ids.dart';
import '../../domain/usecases/professionals/get_professionals_by_speciality.dart';
import '../../domain/usecases/professionals/search_professionals.dart';
// Use cases - Profile
import '../../domain/usecases/profile/delete_profile_image.dart';
import '../../domain/usecases/profile/get_profile_image.dart';
import '../../domain/usecases/profile/save_profile_image.dart';
import '../../domain/usecases/profile/update_patient_profile.dart';
import '../../domain/usecases/profile/update_professional_profile.dart';
// Use cases - Reviews
import '../../domain/usecases/reviews/add_review.dart';
import '../../domain/usecases/reviews/get_average_rating.dart';
import '../../domain/usecases/reviews/get_reviews_by_professional.dart';

// Service Locator global
final getIt = GetIt.instance;

/// Service Locator global (GetIt instance).
final sl = GetIt.instance;

/// Inicializa todas as dependências da aplicação.
///
/// **DEVE ser chamado no main.dart ANTES de runApp():**
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   await setupDependencyInjection();
///   runApp(MyApp());
/// }
/// ```
Future<void> setupDependencyInjection() async {
  // ══════════════════════════════════════════════════════════════════════════
  // ✅ CORE - Ferramentas fundamentais
  // ══════════════════════════════════════════════════════════════════════════

  // SharedPreferences (para armazenamento local de fotos de perfil)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Connectivity Service (Singleton)
  sl.registerLazySingleton<ConnectivityService>(ConnectivityService.new);

  // Logger (Singleton - uma instância global)
  sl.registerLazySingleton<Logger>(() => Logger(
        printer: PrettyPrinter(
          methodCount: 0, // Sem stack trace
          errorMethodCount: 5, // Stack trace apenas em erros
          lineLength: 80,
          dateTimeFormat: DateTimeFormat.onlyTime,
        ),
      ));

  // ══════════════════════════════════════════════════════════════════════════
  // ✅ DATA SOURCES - Firebase (100% cloud-based)
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<FirebaseAuthDataSource>(
    FirebaseAuthDataSource.new,
  );

  sl.registerLazySingleton<FirebaseChatDataSource>(
    FirebaseChatDataSource.new,
  );

  sl.registerLazySingleton<FirebaseProfessionalsDataSource>(
    FirebaseProfessionalsDataSource.new,
  );

  sl.registerLazySingleton<FirebaseReviewsDataSource>(
    FirebaseReviewsDataSource.new,
  );

  sl.registerLazySingleton<FirebaseContractsDataSource>(
    FirebaseContractsDataSource.new,
  );

  sl.registerLazySingleton<FirebaseFavoritesDataSource>(
    FirebaseFavoritesDataSource.new,
  );

  sl.registerLazySingleton<ProfileStorageDataSource>(
    () => ProfileStorageDataSource(prefs: sl()),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ✅ REPOSITORIES - Implementações Firebase 100%
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryFirebaseImpl(
      firebaseAuthDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ProfessionalsRepository>(
    () => ProfessionalsRepositoryImpl(
      firebaseProfessionalsDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ContractsRepository>(
    () => ContractsRepositoryImpl(
      dataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryFirebaseImpl(
      firebaseChatDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      dataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(
      dataSource: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      dataSource: sl(),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ✅ USE CASES - Lógica de negócio
  // ══════════════════════════════════════════════════════════════════════════

  // Auth use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterPatient(sl()));
  sl.registerLazySingleton(() => RegisterProfessional(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => CheckAuthentication(sl()));

  // Professionals use cases
  sl.registerLazySingleton(() => GetAllProfessionals(sl()));
  sl.registerLazySingleton(() => SearchProfessionals(sl()));
  sl.registerLazySingleton(() => GetProfessionalById(sl()));
  sl.registerLazySingleton(() => GetProfessionalsByIds(sl()));
  sl.registerLazySingleton(() => GetProfessionalsBySpeciality(sl()));

  // Contracts use cases
  sl.registerLazySingleton(() => CreateContract(sl()));
  sl.registerLazySingleton(() => GetContractsByPatient(sl()));
  sl.registerLazySingleton(() => GetContractsByProfessional(sl()));
  sl.registerLazySingleton(() => UpdateContractStatus(sl()));

  // Chat use cases
  sl.registerLazySingleton(() => GetUserConversations(sl()));
  sl.registerLazySingleton(() => GetMessages(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => MarkMessagesAsRead(sl()));

  // Favorites use cases
  sl.registerLazySingleton(() => GetFavorites(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));

  // Reviews use cases
  sl.registerLazySingleton(() => GetReviewsByProfessional(sl()));
  sl.registerLazySingleton(() => AddReview(sl()));
  sl.registerLazySingleton(() => GetAverageRating(sl()));

  // Profile use cases
  sl.registerLazySingleton(() => GetProfileImage(sl()));
  sl.registerLazySingleton(() => SaveProfileImage(sl()));
  sl.registerLazySingleton(() => DeleteProfileImage(sl()));
  sl.registerLazySingleton(() => UpdatePatientProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfessionalProfile(sl()));

  sl<Logger>().i('✅ Dependency Injection setup complete!');
}

/// Limpa todas as dependências (útil para testes).
Future<void> resetDependencyInjection() async {
  await sl.reset();
}
