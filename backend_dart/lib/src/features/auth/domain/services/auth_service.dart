import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../../../core/exceptions.dart';
import '../../../../core/logger.dart';

class AuthService {

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();
  static final AuthService _instance = AuthService._internal();

  final String _jwtSecret = const String.fromEnvironment(
    'JWT_SECRET',
    defaultValue: 'your-secret-key-change-in-production',
  );

  final logger = AppLogger.instance;

  static AuthService get instance => _instance;

  /// ✅ Validates JWT token and returns userId
  /// Throws AuthenticationException if invalid or expired
  Future<String> validateToken(String token) async {
    try {
      // Remove 'Bearer ' prefix if present
      String cleanToken = token;
      if (token.startsWith('Bearer ')) {
        cleanToken = token.substring(7);
      }

      // Decode and verify JWT
      final jwt = JWT.verify(cleanToken, SecretKey(_jwtSecret));

      // Extract userId from payload
      final userId = jwt.payload['userId'] as String?;
      if (userId == null || userId.isEmpty) {
        throw AuthenticationException('Token does not contain userId');
      }

      logger.debug('✅ Token validated for user: $userId');
      return userId;
    } catch (e) {
      logger.error('❌ Token validation error', e);
      throw AuthenticationException('Erro ao validar token: $e');
    }
  }

  /// ✅ Generates JWT token for user
  /// Used for testing purposes
  String generateToken(String userId, {Duration? expiresIn}) {
    expiresIn ??= const Duration(hours: 24);

    final jwt = JWT(
      {
        'userId': userId,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000,
      },
    );

    return jwt.sign(SecretKey(_jwtSecret));
  }

  /// ✅ Checks if token belongs to admin
  /// (Can be extended to check Firestore admin flag)
  Future<bool> isAdmin(String userId) async {
    try {
      // In production, check Firestore users collection
      // for now, return false (can be enhanced later)
      return false;
    } catch (e) {
      logger.error('Error checking admin status', e);
      return false;
    }
  }

  /// ✅ Checks if token belongs to specific user
  bool isOwnUser(String tokenUserId, String targetUserId) {
    return tokenUserId == targetUserId;
  }

  /// ✅ Checks if user is admin OR owns the resource
  Future<bool> canAccessResource(String userId, String resourceOwnerId) async {
    final userIsAdmin = await isAdmin(userId);
    return userIsAdmin || userId == resourceOwnerId;
  }
}
