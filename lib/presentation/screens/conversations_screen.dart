import 'package:app_sanitaria/core/routes/app_router.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/chat_provider_v2.dart';
import 'package:app_sanitaria/presentation/widgets/conversation_card.dart';
import 'package:app_sanitaria/presentation/widgets/patient_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Tela de Lista de Conversas
///
/// Responsabilidades:
/// - Exibir lista de conversas/chats do usuário
/// - Mostrar última mensagem e status de leitura
/// - Navegar para chat individual
///
/// Princípios:
/// - Single Responsibility: Apenas UI de conversas
/// - Stateful: Gerencia lista de conversas
/// - Integrado com ChatProvider (futuro)
///
/// Navigation:
/// - Tela FULLSCREEN (sem bottom nav, sem floating buttons)
/// - Acessível por PACIENTES e PROFISSIONAIS
class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProviderV2);
    final authState = ref.watch(authProviderV2);
    final conversations = chatState.conversations;
    final totalUnread = chatState.totalUnreadCount;
    final isPatient = authState.userType == UserType.paciente;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Voltar para HOME ao clicar no botão voltar
          if (isPatient) {
            context.go('/home/patient');
          } else {
            context.go('/home/professional');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Conversas${totalUnread > 0 ? ' ($totalUnread)' : ''}',
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implementar busca de conversas
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Busca em desenvolvimento...'),
                  ),
                );
              },
            ),
          ],
        ),
        body: chatState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : chatState.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          chatState.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(chatProviderV2.notifier)
                                .loadConversations();
                          },
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  )
                : conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Suas Conversas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nenhuma conversa ainda',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (isPatient)
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Navegar para buscar profissionais (apenas pacientes)
                                  context.goToProfessionalsList();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Buscar Profissionais'),
                              ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(chatProviderV2.notifier)
                              .loadConversations();
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: isPatient
                                ? 80
                                : 16, // Padding maior para pacientes por causa do bottom nav
                          ),
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return ConversationCard(
                              conversation: conversation,
                              onTap: () {
                                // Marcar como lidas ao abrir
                                ref
                                    .read(chatProviderV2.notifier)
                                    .markAsRead(conversation.id);

                                // Navegar para o chat
                                context.goToChat(
                                  conversation.otherUserId,
                                  conversation.otherUserName,
                                );
                              },
                            );
                          },
                        ),
                      ),
        // Bottom Navigation apenas para pacientes
        bottomNavigationBar:
            isPatient ? const PatientBottomNav(currentIndex: 1) : null,
      ),
    );
  }
}
