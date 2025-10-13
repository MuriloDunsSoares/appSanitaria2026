// ═══════════════════════════════════════════════════════════════════════════
// IMPORTS - Dependências Externas e Internas
// ═══════════════════════════════════════════════════════════════════════════

/// [flutter/material.dart]
/// Framework UI do Flutter contendo widgets Material Design (Scaffold, AppBar, etc).
/// Necessário para construir a interface gráfica seguindo Material Design 3.
/// Interação: Base para todos os widgets visuais da aplicação.
library;

import 'package:flutter/material.dart';

/// [flutter_riverpod/flutter_riverpod.dart]
/// Sistema de gerenciamento de estado reativo baseado em providers.
/// Versão: ^2.6.1 (conforme pubspec.yaml)
/// Responsabilidades:
/// - Injeção de dependências (Dependency Injection)
/// - Gerenciamento de estado global e local
/// - Reatividade automática (rebuild quando estado muda)
/// Interação: Todos os providers (auth, chat, professionals, etc) dependem deste.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [core/constants/app_theme.dart]
/// Define o tema visual da aplicação (cores, tipografia, espaçamentos).
/// Interação: Aplicado globalmente via MaterialApp.theme.
import 'core/constants/app_theme.dart';

/// [core/di/injection_container.dart]
/// Service Locator para Dependency Injection usando GetIt.
/// Responsabilidade: Registrar e fornecer instâncias de Use Cases e Repositories.
import 'core/di/injection_container.dart';

/// [core/routes/app_router.dart]
/// Configuração de rotas usando GoRouter para navegação declarativa.
/// Interação: Define todas as telas e transições da aplicação.
import 'core/routes/app_router.dart';

/// [core/services/firebase_service.dart]
/// Serviço de inicialização e gerenciamento do Firebase.
import 'core/services/firebase_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY POINT - Função Principal da Aplicação
// ═══════════════════════════════════════════════════════════════════════════

/// Entry Point da Aplicação AppSanitaria
///
/// **Responsabilidades:**
/// 1. Inicializar binding do Flutter (necessário para operações async antes do runApp)
/// 2. Inicializar Firebase (Auth, Firestore, Storage, Messaging)
/// 3. Configurar Dependency Injection (GetIt)
/// 4. Configurar ProviderScope (container de injeção de dependências do Riverpod)
/// 5. Iniciar a árvore de widgets da aplicação
///
/// **Fluxo de Execução:**
/// ```
/// main() → ensureInitialized() → Firebase.initialize()
///   → setupDependencyInjection() → ProviderScope → AppSanitaria → MaterialApp.router
/// ```
///
/// **Arquitetura:**
/// - Pattern: Dependency Injection via ProviderScope + GetIt
/// - Lifecycle: Executada uma única vez ao iniciar o app
/// - Thread: Main thread (UI thread)
///
/// **Modificador async:**
/// Necessário porque Firebase.initialize() e setupDependencyInjection() são assíncronos.
void main() async {
  // ───────────────────────────────────────────────────────────────────────
  // INICIALIZAÇÃO DO FLUTTER BINDING
  // ───────────────────────────────────────────────────────────────────────

  /// Garante que o binding do Flutter esteja inicializado antes de operações async.
  ///
  /// **Por que é necessário?**
  /// - runApp() espera que o binding já esteja pronto
  /// - Operações async (await) antes de runApp() requerem binding ativo
  /// - Firebase.initialize() precisa do binding ativo
  ///
  /// **O que faz internamente:**
  /// - Inicializa WidgetsBinding (gerenciador de widgets)
  /// - Configura rendering engine
  /// - Prepara event loop para gestures e inputs
  ///
  /// **Performance:** ~5-10ms de overhead (executado apenas 1x)
  WidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────
  // INICIALIZAÇÃO DO FIREBASE
  // ───────────────────────────────────────────────────────────────────────

  /// Inicializa Firebase Core e Cloud Messaging.
  ///
  /// **O que faz:**
  /// - Conecta o app ao projeto Firebase (app-sanitaria)
  /// - Configura Firebase Auth (autenticação)
  /// - Inicializa Cloud Firestore (banco de dados NoSQL em tempo real)
  /// - Configura Firebase Storage (armazenamento de arquivos)
  /// - Inicializa Firebase Cloud Messaging (notificações push)
  ///
  /// **Importante:** DEVE ser executado antes de qualquer operação Firebase
  ///
  /// **Performance:** ~100-300ms (executado apenas 1x)
  await FirebaseService().initialize();

  // ───────────────────────────────────────────────────────────────────────
  // INICIALIZAÇÃO DO DEPENDENCY INJECTION (GetIt)
  // ───────────────────────────────────────────────────────────────────────

  /// Configura Dependency Injection usando GetIt.
  ///
  /// **O que faz:**
  /// - Registra todos os Use Cases (domain layer)
  /// - Registra todos os Repositories (data layer)
  /// - Registra todos os DataSources Firebase (data layer)
  /// - Registra serviços auxiliares (Logger, Connectivity, etc)
  ///
  /// **Performance:** ~50-100ms (executado apenas 1x)
  /// **Importância:** Essencial para Clean Architecture
  await setupDependencyInjection();

  // ───────────────────────────────────────────────────────────────────────
  // LINHAS 21-31: Inicialização da Árvore de Widgets
  // ───────────────────────────────────────────────────────────────────────

  /// Inicia a aplicação Flutter com ProviderScope como raiz.
  ///
  /// **runApp():**
  /// - Função do Flutter que infla a árvore de widgets
  /// - Torna o widget fornecido a raiz da aplicação
  /// - Agenda o primeiro frame para renderização
  ///
  /// **Thread:** Main thread (UI thread)
  /// **Lifecycle:** Executado 1x, mas a árvore é reconstruída reativamente
  runApp(
    // ─────────────────────────────────────────────────────────────────────
    // LINHA 22: ProviderScope - Container de Injeção de Dependências
    // ─────────────────────────────────────────────────────────────────────

    /// Container raiz do Riverpod que gerencia todos os providers da aplicação.
    ///
    /// **Responsabilidades:**
    /// - Armazenar estado de todos os providers
    /// - Gerenciar lifecycle dos providers (criação, destruição, cache)
    /// - Propagar mudanças de estado para widgets dependentes
    /// - Permitir overrides de providers para testes ou inicialização
    ///
    /// **Hierarquia:**
    /// ```
    /// ProviderScope (raiz)
    ///   └─ AppSanitaria
    ///       └─ MaterialApp.router
    ///           └─ GoRouter
    ///               └─ Screens (podem acessar providers via ref.watch/read)
    /// ```
    ///
    /// **Performance:**
    /// - Overhead mínimo (~1-2ms)
    /// - Cache inteligente (providers só recalculam quando dependências mudam)
    const ProviderScope(
      // ───────────────────────────────────────────────────────────────────
      // WIDGET RAIZ DA APLICAÇÃO
      // ───────────────────────────────────────────────────────────────────

      /// Widget raiz que será renderizado dentro do ProviderScope.
      ///
      /// **const:**
      /// - Otimização: widget é imutável e pode ser reutilizado
      /// - Reduz alocações de memória
      /// - Melhora performance de rebuild
      ///
      /// **Tipo:** AppSanitaria extends ConsumerWidget
      /// - ConsumerWidget: Permite acesso a providers via WidgetRef
      ///
      /// **ProviderScope:**
      /// - Container raiz do Riverpod que gerencia todos os providers
      /// - Armazena estado de todos os providers
      /// - Gerencia lifecycle (criação, destruição, cache)
      /// - Propaga mudanças de estado para widgets dependentes
      child: AppSanitaria(),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET RAIZ - Configuração do MaterialApp
// ═══════════════════════════════════════════════════════════════════════════

/// Widget raiz da aplicação AppSanitaria.
///
/// **Responsabilidades:**
/// 1. Configurar MaterialApp com tema e navegação
/// 2. Observar goRouterProvider para atualizações de rotas
/// 3. Aplicar tema global (cores, tipografia, etc)
///
/// **Tipo:** ConsumerWidget
/// - Diferença de StatelessWidget: Tem acesso a WidgetRef (Riverpod)
/// - Permite usar ref.watch() para observar providers
/// - Rebuild automático quando providers observados mudam
///
/// **Lifecycle:**
/// - build() chamado quando:
///   1. Widget é inserido na árvore (primeira vez)
///   2. goRouterProvider muda (ex: navegação)
///   3. Ancestor widget força rebuild
///
/// **Performance:**
/// - Rebuilds são baratos (MaterialApp.router é eficiente)
/// - GoRouter gerencia stack de navegação sem reconstruir toda a árvore
class AppSanitaria extends ConsumerWidget {
  /// Construtor const para otimização de performance.
  ///
  /// **super.key:**
  /// - Passa key para o construtor da classe pai (ConsumerWidget)
  /// - Key é usada pelo Flutter para identificar widgets na árvore
  /// - Útil para preservar estado durante rebuilds
  ///
  /// **const:**
  /// - Garante que instância é criada em tempo de compilação
  /// - Reduz alocações em runtime
  const AppSanitaria({super.key});

  // ───────────────────────────────────────────────────────────────────────
  // MÉTODO BUILD - Construção da UI
  // ───────────────────────────────────────────────────────────────────────

  /// Constrói a árvore de widgets da aplicação.
  ///
  /// **Parâmetros:**
  /// - [context]: BuildContext fornecido pelo Flutter (acesso à árvore de widgets)
  /// - [ref]: WidgetRef fornecido pelo Riverpod (acesso aos providers)
  ///
  /// **Retorno:** Widget (MaterialApp.router)
  ///
  /// **Chamado quando:**
  /// - Widget é inserido na árvore
  /// - Providers observados (ref.watch) mudam
  /// - Ancestor força rebuild via setState()
  ///
  /// **Performance:** O(1) - operação leve, apenas configura MaterialApp
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ─────────────────────────────────────────────────────────────────────
    // LINHA 40: Observação do GoRouter Provider
    // ─────────────────────────────────────────────────────────────────────

    /// Observa o provider de configuração de rotas.
    ///
    /// **ref.watch():**
    /// - Cria dependência reativa entre AppSanitaria e goRouterProvider
    /// - Se goRouterProvider mudar, build() é chamado novamente
    /// - Retorna instância de GoRouter configurada
    ///
    /// **goRouterProvider:**
    /// - Definido em: core/routes/app_router.dart
    /// - Tipo: Provider<GoRouter>
    /// - Contém: Todas as rotas da aplicação (login, home, chat, etc)
    ///
    /// **Interação com navegação:**
    /// ```dart
    /// context.go('/home') → GoRouter intercepta
    ///   → Verifica redirect (auto-login)
    ///     → Renderiza tela correspondente
    /// ```
    ///
    /// **Lifecycle do router:**
    /// - Criado: 1x quando AppSanitaria é construída
    /// - Cached: Riverpod mantém instância em memória
    /// - Destruído: Quando app fecha
    final router = ref.watch(goRouterProvider);

    // ─────────────────────────────────────────────────────────────────────
    // LINHAS 42-47: MaterialApp.router - Configuração da Aplicação
    // ─────────────────────────────────────────────────────────────────────

    /// Widget raiz que configura a aplicação Material Design.
    ///
    /// **MaterialApp.router vs MaterialApp:**
    /// - MaterialApp: Usa Navigator tradicional (rotas nomeadas simples)
    /// - MaterialApp.router: Usa RouterConfig (GoRouter, navegação declarativa)
    ///
    /// **Responsabilidades do MaterialApp:**
    /// - Aplicar tema global
    /// - Gerenciar navegação via router
    /// - Fornecer MediaQuery, Theme, Localizations para descendentes
    /// - Gerenciar Overlay (Snackbars, Dialogs)
    ///
    /// **Performance:**
    /// - Rebuilds são otimizados (apenas widgets afetados reconstruem)
    /// - Router gerencia stack sem reconstruir MaterialApp
    return MaterialApp.router(
      /// Título da aplicação exibido no task switcher do sistema operacional.
      ///
      /// **Uso:**
      /// - Android: Aparece no "Recent Apps"
      /// - iOS: Aparece no App Switcher
      /// - Web: Título da aba do navegador
      ///
      /// **Não confundir com:**
      /// - AppBar title (título da tela atual)
      /// - Nome do app (definido em AndroidManifest.xml / Info.plist)
      title: 'App Sanitária',

      /// Remove banner "DEBUG" do canto superior direito.
      ///
      /// **Valores:**
      /// - false: Remove banner (produção)
      /// - true: Mostra banner (útil em desenvolvimento)
      ///
      /// **Nota:** Banner só aparece em debug mode, não em release builds.
      debugShowCheckedModeBanner: false,

      /// Tema visual da aplicação (cores, tipografia, espaçamentos).
      ///
      /// **Origem:** AppTheme.lightTheme (definido em core/constants/app_theme.dart)
      ///
      /// **Conteúdo:**
      /// - ColorScheme: Cores primárias, secundárias, backgrounds
      /// - TextTheme: Estilos de texto (headlines, body, captions)
      /// - Component themes: AppBar, Button, Card, etc.
      ///
      /// **Acesso em descendentes:**
      /// ```dart
      /// Theme.of(context).colorScheme.primary
      /// ```
      ///
      /// **Interação:**
      /// - Todos os widgets Material (Button, Card, etc) usam este tema
      /// - Pode ser sobrescrito localmente com Theme(data: ...)
      theme: AppTheme.lightTheme,

      /// Configuração de rotas usando GoRouter.
      ///
      /// **Tipo:** GoRouter (do package go_router)
      ///
      /// **Responsabilidades:**
      /// - Mapear URLs para telas (ex: '/login' → LoginScreen)
      /// - Gerenciar stack de navegação (push, pop, replace)
      /// - Implementar redirects (ex: auto-login)
      /// - Passar parâmetros entre telas
      ///
      /// **Rotas definidas (em app_router.dart):**
      /// - / → LoginScreen
      /// - /selection → SelectionScreen
      /// - /register/patient → PatientRegistrationScreen
      /// - /register/professional → ProfessionalRegistrationScreen
      /// - /home/patient → HomePatientScreen
      /// - /home/professional → HomeProfessionalScreen
      /// - /professionals → ProfessionalsListScreen
      /// - /professional/:id → ProfessionalProfileDetailScreen
      /// - /conversations → ConversationsScreen
      /// - /chat/:conversationId → IndividualChatScreen
      /// - /favorites → FavoritesScreen
      /// - /profile → ProfileScreen
      /// - /hiring/:professionalId → HiringScreen
      /// - /contracts → ContractsScreen
      /// - /contract/:contractId → ContractDetailScreen
      /// - /add-review → AddReviewScreen
      ///
      /// **Navegação declarativa:**
      /// ```dart
      /// context.go('/home/patient')  // Substitui rota atual
      /// context.push('/chat/123')    // Empilha nova rota
      /// context.pop()                // Volta para rota anterior
      /// ```
      ///
      /// **Performance:**
      /// - Lazy loading: Telas só são construídas quando navegadas
      /// - Transições animadas gerenciadas automaticamente
      /// - Deep linking suportado (URLs diretas para telas)
      routerConfig: router,
    );
  }
}
