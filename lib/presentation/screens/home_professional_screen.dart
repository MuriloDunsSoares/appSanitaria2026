import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_sanitaria/domain/entities/professional_entity.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/chat_provider_v2.dart';
import 'package:app_sanitaria/presentation/widgets/professional_floating_buttons.dart';
import 'package:app_sanitaria/presentation/widgets/home_professional/professional_header.dart';
import 'package:app_sanitaria/presentation/widgets/home_professional/stats_cards_row.dart';
import 'package:app_sanitaria/presentation/widgets/home_professional/view_profile_button.dart';
import 'package:app_sanitaria/presentation/widgets/home_professional/conversations_feed.dart';
import 'package:app_sanitaria/presentation/widgets/home_professional/quick_actions_section.dart';
import 'package:app_sanitaria/core/routes/app_router.dart';

/// Tela Home para PROFISSIONAIS - REFATORADA
///
/// Responsabilidades:
/// - Orquestração dos widgets modulares
/// - Gerenciamento de estado de conversas e estatísticas
/// - Navegação para outras telas
///
/// Refatoração aplicada:
/// - 599 linhas → ~220 linhas (-63% de redução!)
/// - 6 widgets modulares extraídos
/// - Single Responsibility: Apenas coordena o dashboard
/// - Composição: Usa widgets reutilizáveis
///
/// Benefícios:
/// - ✅ Testabilidade: Cada widget pode ser testado isoladamente
/// - ✅ Manutenibilidade: Mudanças localizadas
/// - ✅ Reusabilidade: Widgets podem ser usados em outros contextos
class HomeProfessionalScreen extends ConsumerStatefulWidget {
  const HomeProfessionalScreen({super.key});

  @override
  ConsumerState<HomeProfessionalScreen> createState() =>
      _HomeProfessionalScreenState();
}

class _HomeProfessionalScreenState extends ConsumerState<HomeProfessionalScreen>
    with SingleTickerProviderStateMixin {
  // ══════════════════════════════════════════════════════════
  // STATE
  // ══════════════════════════════════════════════════════════
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  // CALLBACKS
  // ══════════════════════════════════════════════════════════

  Future<void> _refreshData() async {
    await ref.read(chatProviderV2.notifier).loadConversations();
    setState(() {});
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda e Suporte'),
        content: const Text(
          'Entre em contato conosco:\n\n'
          '📧 Email: suporte@appsanitaria.com\n'
          '📱 WhatsApp: (84) 99999-9999\n\n'
          'Horário: Segunda a Sexta, 8h às 18h',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProviderV2);
    final chatState = ref.watch(chatProviderV2);
    final user = authState.user;
    final firstName = user?.nome.split(' ').first ?? 'Profissional';

    // Estatísticas reais
    final activeConversations = chatState.conversations.length;
    final unreadMessages = chatState.totalUnreadCount;
    final rating =
        (user is ProfessionalEntity) ? user.avaliacao.toString() : '0.0';
    final reviewCount = 0; // TODO: Adicionar contador de avaliações

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(unreadMessages),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saudação
                    ProfessionalHeader(firstName: firstName),
                    const SizedBox(height: 24),

                    // Cards de estatísticas
                    StatsCardsRow(
                      activeConversations: activeConversations,
                      unreadMessages: unreadMessages,
                      rating: rating,
                      reviewCount: reviewCount,
                    ),
                    const SizedBox(height: 24),

                    // Botão Ver Meu Perfil
                    ViewProfileButton(
                      onTap: () {
                        final professionalId = user?.id ?? '';
                        if (professionalId.isNotEmpty) {
                          context.goToProfessionalProfile(professionalId);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Feed de últimas conversas
                    ConversationsFeed(
                      conversations: chatState.conversations,
                      onConversationTap: (userId, userName) {
                        context.goToChat(userId, userName);
                      },
                      onSeeAllTap: () {
                        context.goToConversations();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Ações Rápidas
                    QuickActionsSection(
                      onEditProfileTap: () {
                        context.goToProfile();
                      },
                      onHelpTap: _showHelpDialog,
                    ),

                    const SizedBox(height: 120), // Espaço para floating buttons
                  ],
                ),
              ),
            ),
          ),

          // Botões flutuantes (Perfil + Conversas)
          const ProfessionalFloatingButtons(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(int unreadMessages) {
    return AppBar(
      title: const Text('App Sanitária'),
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        // Badge de notificações
        if (unreadMessages > 0)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  context.goToConversations();
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadMessages > 9 ? '9+' : unreadMessages.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          )
        else
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.goToConversations();
            },
          ),
      ],
    );
  }
}
