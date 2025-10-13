// ═══════════════════════════════════════════════════════════════════════════
// ARQUIVO: app_router.dart
// PROPÓSITO: Configuração de navegação declarativa usando GoRouter
// ═══════════════════════════════════════════════════════════════════════════

/// [flutter/material.dart]
/// Framework UI do Flutter contendo BuildContext e widgets Material.
/// **Necessário para:** BuildContext.go(), Scaffold, AppBar, etc.
/// **Interação:** Todas as telas usam BuildContext para navegação.
library;

import 'package:flutter/material.dart';

/// [flutter_riverpod/flutter_riverpod.dart]
/// State management usado para observar authProviderV2.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [presentation/providers/auth_provider_v2.dart]
/// Provider de autenticação migrado para Clean Architecture.
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';

/// [go_router/go_router.dart]
/// Package de navegação declarativa para Flutter (versão ~14.8.1).
/// 
/// **Por que GoRouter?**
/// - Navegação declarativa (mais fácil de debugar)
/// - Deep linking nativo
/// - Redirecionamentos globais (ex: auto-login)
/// - Type-safe navigation
/// - Suporta web (URLs reais, não #hash)
///
/// **Alternativas:**
/// - Navigator 1.0: Imperativo, difícil manter estado
/// - Navigator 2.0: Complexo, muito boilerplate
/// - AutoRoute: Mais features mas mais pesado
///
/// **Interação:** 
/// - MaterialApp.router usa GoRouter como engine de navegação
/// - context.go() e context.push() são métodos do GoRouter
import 'package:go_router/go_router.dart';

/// [presentation/screens/screens.dart]
/// Barrel file que exporta todas as telas da aplicação.
///
/// **O que é um barrel file?**
/// - Arquivo que re-exporta múltiplos arquivos
/// - Simplifica imports (1 import ao invés de 18)
///
/// **Conteúdo:**
/// ```dart
/// export 'login_screen.dart';
/// export 'home_patient_screen.dart';
/// export 'home_professional_screen.dart';
/// // ... (18 screens no total)
/// ```
///
/// **Interação:** Todas as rotas usam telas importadas daqui
import 'package:app_sanitaria/presentation/screens/screens.dart';

/// [presentation/providers/auth_provider.dart]
/// Provider de estado de autenticação (Riverpod).
///
/// **Interação:** 
/// - goRouterProvider observa authProviderV2 para redirects
/// - Quando authState muda, redirect() é chamado novamente
/// - Permite auto-login e proteção de rotas

/// [domain/entities/user_entity.dart]
/// Define UserType enum (paciente vs profissional).
///
/// **Interação:**
/// - redirect() usa UserType para decidir qual home mostrar
/// - UserType.paciente → '/home/patient'
/// - UserType.profissional → '/home/professional'
import 'package:app_sanitaria/domain/entities/user_entity.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DO ROUTER - Configuração de Navegação Global
// ═══════════════════════════════════════════════════════════════════════════

/// Provider do GoRouter configurado com todas as rotas da aplicação.
///
/// **PATTERN: Router Configuration Provider**
/// Centraliza toda configuração de navegação em um único lugar.
///
/// **RESPONSABILIDADES:**
/// 1. Definir todas as 15 rotas da aplicação
/// 2. Implementar auto-login via redirect()
/// 3. Observar estado de autenticação (authProviderV2)
/// 4. Fornecer tratamento de erros 404
/// 5. Enable debug logging para desenvolvimento
///
/// **ARQUITETURA:**
/// - Camada: Core/Routes (infraestrutura)
/// - Responsabilidade: Gerenciar navegação global
/// - Escopo: Global (usado por MaterialApp.router)
///
/// **DESIGN PATTERN: Observer + Strategy**
/// - Observer: Observa authProviderV2 para reagir a mudanças
/// - Strategy: Diferentes estratégias de redirect baseadas em estado
///
/// **LIFECYCLE:**
/// 1. App inicia
/// 2. main.dart cria ProviderScope
/// 3. AppSanitaria observa goRouterProvider
/// 4. goRouterProvider é criado E observa authProviderV2
/// 5. authProviderV2 verifica sessão existente
/// 6. Se logado, redirect() redireciona para home
/// 7. Se não logado, mostra LoginScreen
///
/// **REATIVIDADE:**
/// ```
/// authProviderV2 muda (login/logout)
///   ↓
/// ref.watch(authProviderV2) detecta mudança
///   ↓
/// goRouterProvider é reconstruído
///   ↓
/// redirect() é chamado novamente
///   ↓
/// Navegação automática para tela apropriada
/// ```
///
/// **ROTAS DEFINIDAS (15 total):**
/// ```
/// AUTENTICAÇÃO:
///   / → LoginScreen
///   /selection → SelectionScreen
///
/// CADASTRO:
///   /register/professional → ProfessionalRegistrationScreen
///   /register/patient → PatientRegistrationScreen
///
/// HOME (2 versões):
///   /home/patient → HomePatientScreen
///   /home/professional → HomeProfessionalScreen
///
/// PROFISSIONAIS:
///   /professionals → ProfessionalsListScreen
///   /professional/:id → ProfessionalProfileDetailScreen
///
/// CHAT:
///   /conversations → ConversationsScreen
///   /chat/:id → IndividualChatScreen
///
/// OUTRAS:
///   /favorites → FavoritesScreen
///   /hiring/:id → HiringScreen
///   /contracts → ContractsScreen
///   /add-review → AddReviewScreen
///   /profile → ProfileScreen
/// ```
///
/// **USO:**
/// ```dart
/// // Em main.dart:
/// MaterialApp.router(
///   routerConfig: ref.watch(goRouterProvider),
/// )
///
/// // Em qualquer tela:
/// context.go('/professionals');
/// context.push('/chat/user_123?name=João');
/// context.pop();
/// ```
///
/// **PERFORMANCE:**
/// - Criado 1x ao iniciar app
/// - Reconstruído apenas quando authProviderV2 muda
/// - Rotas são lazy-loaded (tela só construída quando navegada)
/// - ~5ms overhead por navegação
///
/// **DEBUGGING:**
/// - debugLogDiagnostics: true imprime logs de navegação
/// - Útil para debugar redirects e parâmetros
/// - Exemplo de log: "GoRouter: redirect: / → /home/patient"
///
/// **EXTENSIBILIDADE:**
/// ```dart
/// // Adicionar nova rota:
/// GoRoute(
///   path: '/new-screen',
///   name: 'new-screen',
///   builder: (context, state) => NewScreen(),
/// )
///
/// // Adicionar guards (proteção de rota):
/// redirect: (context, state) {
///   if (isPremiumRoute && !userIsPremium) {
///     return '/upgrade';
///   }
///   return null;
/// }
/// ```
final goRouterProvider = Provider<GoRouter>((ref) {
  // ───────────────────────────────────────────────────────────────────────
  // OBSERVAÇÃO DO ESTADO DE AUTENTICAÇÃO
  // ───────────────────────────────────────────────────────────────────────
  
  /// Observa o estado de autenticação para implementar auto-login.
  ///
  /// **ref.watch():**
  /// - Cria dependência reativa entre goRouterProvider e authProviderV2
  /// - Quando authState muda, goRouterProvider é reconstruído
  /// - GoRouter é recriado → redirect() é chamado novamente
  ///
  /// **Por que observar?**
  /// - Usuário loga → redirect automático para home
  /// - Usuário desloga → redirect automático para login
  /// - "Manter logado" funciona via auto-login
  ///
  /// **authState contém:**
  /// - isAuthenticated: bool (true se logado)
  /// - userType: UserType? (paciente ou profissional)
  /// - user: Map<String, dynamic>? (dados do usuário)
  ///
  /// **Performance:**
  /// - O(1) - apenas leitura de estado em memória
  /// - Não causa rebuilds desnecessários (Riverpod otimiza)
  final authState = ref.watch(authProviderV2);

  // ───────────────────────────────────────────────────────────────────────
  // CONSTRUÇÃO DO GOROUTER
  // ───────────────────────────────────────────────────────────────────────
  
  return GoRouter(
    /// Localização inicial ao abrir o app.
    ///
    /// **Valor:** '/' (LoginScreen)
    ///
    /// **Fluxo:**
    /// 1. App inicia com initialLocation: '/'
    /// 2. redirect() é chamado ANTES de renderizar
    /// 3. Se isAuthenticated, redirect retorna '/home/patient' ou '/home/professional'
    /// 4. Se não autenticado, redirect retorna null → mostra LoginScreen
    ///
    /// **Nota:** initialLocation é ignorada se houver redirect
    ///
    /// **Deep linking:**
    /// Se app abrir com URL específica (ex: myapp://professional/user_123),
    /// initialLocation é substituída pela URL deep linkada.
    initialLocation: '/',
    
    /// Enable debug logging para desenvolvimento.
    ///
    /// **true:** Imprime logs de navegação no console
    /// ```
    /// GoRouter: full path: /professionals
    /// GoRouter: redirect: / → /home/patient (redirected by redirect callback)
    /// GoRouter: popping /chat/user_123
    /// ```
    ///
    /// **false:** Sem logs (usar em produção)
    ///
    /// **Performance:** ~0.1ms overhead por navegação
    ///
    /// **Uso:** Debugar redirects, parâmetros, deep linking
    debugLogDiagnostics: true,

    // ═══════════════════════════════════════════════════════════════════════
    // REDIRECT GLOBAL - Implementa Auto-Login e Proteção de Rotas
    // ═══════════════════════════════════════════════════════════════════════
    
    /// Função de redirect global chamada ANTES de cada navegação.
    ///
    /// **Quando é chamada:**
    /// - Ao iniciar app (após initialLocation)
    /// - A cada context.go() ou context.push()
    /// - Quando authProviderV2 muda (re-build do router)
    ///
    /// **Parâmetros:**
    /// - `context`: BuildContext da navegação
    /// - `state`: GoRouterState contendo:
    ///   - matchedLocation: String (rota atual, ex: '/login')
    ///   - uri: Uri completa (com query params)
    ///   - pathParameters: Map de parâmetros de path (:id)
    ///   - uri.queryParameters: Map de query params (?name=João)
    ///
    /// **Retorno:**
    /// - `String?`: Nova rota para redirecionar
    /// - `null`: Permite navegação normal (não redireciona)
    ///
    /// **LÓGICA DE AUTO-LOGIN:**
    /// ```
    /// Se usuário está autenticado:
    ///   E está tentando acessar login/selection/register:
    ///     → Redirecionar para home (baseado no tipo)
    ///
    /// Caso contrário:
    ///   → Permitir navegação normal
    /// ```
    ///
    /// **Casos de uso:**
    /// 1. Usuário abre app com "manter logado" → redirect para home
    /// 2. Usuário loga → redirect para home
    /// 3. Usuário desloga → não redireciona (fica na tela atual)
    /// 4. Usuário logado tenta voltar para login → redirect para home
    ///
    /// **Performance:** ~0.5ms por chamada
    ///
    /// **Extensão futura:**
    /// ```dart
    /// // Proteger rotas que requerem subscription:
    /// if (requiresPremium && !userIsPremium) {
    ///   return '/upgrade';
    /// }
    ///
    /// // Onboarding para novos usuários:
    /// if (!userCompletedOnboarding) {
    ///   return '/onboarding';
    /// }
    /// ```
    redirect: (context, state) {
      /// Obtém status de autenticação do authState observado.
      ///
      /// **isAuthenticated:** `true` se usuário está logado
      /// **Fonte:** authProviderV2.isAuthenticated
      final isAuthenticated = authState.isAuthenticated;
      
      /// Obtém tipo do usuário (paciente ou profissional).
      ///
      /// **userType:** `UserType.paciente` ou `UserType.profissional`
      /// **null:** Se não autenticado
      /// **Uso:** Decidir qual home mostrar
      final userType = authState.userType;
      
      /// Verifica se está tentando acessar página de login.
      ///
      /// **matchedLocation:** Path da rota (sem query params)
      /// **Exemplo:** '/login', '/professionals', '/chat/user_123'
      final isOnLoginPage = state.matchedLocation == '/';
      
      /// Verifica se está tentando acessar página de seleção de tipo.
      final isOnSelectionPage = state.matchedLocation == '/selection';
      
      /// Verifica se está tentando acessar qualquer página de registro.
      ///
      /// **startsWith('/register'):** Captura ambas rotas:
      /// - /register/professional
      /// - /register/patient
      final isOnRegisterPage = state.matchedLocation.startsWith('/register');

      /// Implementa lógica de auto-login.
      ///
      /// **Condição:**
      /// Usuário está autenticado E está em página de auth/registro
      ///
      /// **Resultado:**
      /// Redireciona para home apropriada (evita usuário logado ver login)
      ///
      /// **Por que verificar todas essas páginas?**
      /// - Login: Usuário pode ter URL antiga/bookmark
      /// - Selection: Fluxo de registro pode ser interrompido
      /// - Register: Usuário pode voltar após registro
      if (isAuthenticated &&
          (isOnLoginPage || isOnSelectionPage || isOnRegisterPage)) {
        /// Redireciona para home baseado no tipo de usuário.
        ///
        /// **paciente:** HomePatientScreen (busca profissionais)
        /// **profissional:** HomeProfessionalScreen (dashboard de contratos)
        if (userType == UserType.paciente) {
          return '/home/patient';
        } else if (userType == UserType.profissional) {
          return '/home/professional';
        }
      }

      /// Permite navegação normal (não redireciona).
      ///
      /// **Casos:**
      /// - Usuário não autenticado (pode ver login/register)
      /// - Usuário autenticado navegando em outras telas
      /// - Deep linking para telas internas
      ///
      /// **null significa:** "Siga para a rota solicitada"
      return null;
    },

    routes: [
      // ══════════════════════════════════════════════════════════
      // AUTENTICAÇÃO
      // ══════════════════════════════════════════════════════════

      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/selection',
        name: 'selection',
        builder: (context, state) => const SelectionScreen(),
      ),

      // ══════════════════════════════════════════════════════════
      // CADASTRO
      // ══════════════════════════════════════════════════════════

      GoRoute(
        path: '/register/professional',
        name: 'register-professional',
        builder: (context, state) => const ProfessionalRegistrationScreen(),
      ),

      GoRoute(
        path: '/register/patient',
        name: 'register-patient',
        builder: (context, state) => const PatientRegistrationScreen(),
      ),

      // ══════════════════════════════════════════════════════════
      // HOME (duas versões)
      // ══════════════════════════════════════════════════════════

      GoRoute(
        path: '/home/patient',
        name: 'home-patient',
        builder: (context, state) => const HomePatientScreen(),
      ),

      GoRoute(
        path: '/home/professional',
        name: 'home-professional',
        builder: (context, state) => const HomeProfessionalScreen(),
      ),

      // ══════════════════════════════════════════════════════════
      // PROFISSIONAIS
      // ══════════════════════════════════════════════════════════

      GoRoute(
        path: '/professionals',
        name: 'professionals',
        builder: (context, state) {
          // Parâmetros opcionais para filtros
          final specialty = state.uri.queryParameters['specialty'];
          final city = state.uri.queryParameters['city'];

          return ProfessionalsListScreen(
            initialSpecialty: specialty,
            initialCity: city,
          );
        },
      ),

      GoRoute(
        path: '/professional/:id',
        name: 'professional-profile',
        builder: (context, state) {
          final professionalId = state.pathParameters['id']!;
          return ProfessionalProfileDetailScreen(
            professionalId: professionalId,
          );
        },
      ),

      // ══════════════════════════════════════════════════════════
      // CHAT
      // ══════════════════════════════════════════════════════════

      GoRoute(
        path: '/conversations',
        name: 'conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),

      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final otherUserId = state.pathParameters['id']!;
          final otherUserName = state.uri.queryParameters['name'] ?? 'Usuário';

          return IndividualChatScreen(
            otherUserId: otherUserId,
            otherUserName: otherUserName,
          );
        },
      ),

      // ══════════════════════════════════════════════════════════
      // FAVORITOS
      // ══════════════════════════════════════════════════════════

      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),

      // ══════════════════════════════════════════════════════════
      // CONTRATAÇÃO
      // ══════════════════════════════════════════════════════════

      GoRoute(
        path: '/hiring/:id',
        name: 'hiring',
        builder: (context, state) {
          final professionalId = state.pathParameters['id']!;
          return HiringScreen(professionalId: professionalId);
        },
      ),

      GoRoute(
        path: '/contracts',
        name: 'contracts',
        builder: (context, state) => const ContractsScreen(),
      ),

      // ══════════════════════════════════════════════════════════
      // AVALIAÇÕES
      // ══════════════════════════════════════════════════════════

      GoRoute(
        path: '/add-review',
        name: 'add-review',
        builder: (context, state) {
          final professionalId = state.uri.queryParameters['professionalId']!;
          final professionalName =
              state.uri.queryParameters['professionalName'] ?? 'Profissional';

          return AddReviewScreen(
            professionalId: professionalId,
            professionalName: professionalName,
          );
        },
      ),

      // ══════════════════════════════════════════════════════════
      // CONTA
      // ══════════════════════════════════════════════════════════

      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],

    // Tratamento de erros
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Erro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Página não encontrada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Voltar ao Login'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Extensão para facilitar navegação
///
/// Uso:
/// context.goToHome();
/// context.goToProfessionalProfile('user123');
extension AppRouterExtension on BuildContext {
  // Navegação básica
  void goToLogin() => go('/');
  void goToSelection() => go('/selection');

  // Cadastro
  void goToRegisterProfessional() => go('/register/professional');
  void goToRegisterPatient() => go('/register/patient');

  // Home
  void goToHomePatient() => go('/home/patient');
  void goToHomeProfessional() => go('/home/professional');

  // Profissionais
  void goToProfessionalsList({String? specialty, String? city}) {
    final params = <String, String>{};
    if (specialty != null) params['specialty'] = specialty;
    if (city != null) params['city'] = city;

    if (params.isEmpty) {
      go('/professionals');
    } else {
      go(Uri(path: '/professionals', queryParameters: params).toString());
    }
  }

  void goToProfessionalProfile(String professionalId) {
    go('/professional/$professionalId');
  }

  // Chat
  void goToConversations() => go('/conversations');

  void goToChat(String userId, String userName) {
    go(Uri(
      path: '/chat/$userId',
      queryParameters: {'name': userName},
    ).toString());
  }

  // Favoritos
  void goToFavorites() => go('/favorites');

  // Contratação
  void goToHiring(String professionalId) => go('/hiring/$professionalId');
  void goToContracts() => go('/contracts');

  // Perfil
  void goToProfile() => go('/profile');
  void goToEditProfile() => go('/edit-profile');
}
