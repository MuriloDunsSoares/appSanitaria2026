import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/core/routes/app_router.dart';
import 'package:app_sanitaria/presentation/widgets/home_patient/patient_home_header.dart';
import 'package:app_sanitaria/presentation/widgets/home_patient/patient_home_search_bar.dart';
import 'package:app_sanitaria/presentation/widgets/home_patient/patient_services_grid.dart';
import 'package:app_sanitaria/presentation/widgets/home_patient/publish_ad_button.dart';
import 'package:app_sanitaria/presentation/widgets/home_patient/city_selector_modal.dart';
import 'package:app_sanitaria/presentation/widgets/common/exit_confirmation_wrapper.dart';
import 'package:app_sanitaria/presentation/widgets/patient_bottom_nav.dart';

/// Tela Home para Pacientes - REFATORADA
///
/// Responsabilidades:
/// - Orquestração dos widgets modulares
/// - Gerenciamento de estado local (cidade selecionada, busca)
/// - Navegação para outras telas
///
/// Refatoração aplicada:
/// - 671 linhas → ~180 linhas (-73%)
/// - 8 widgets modulares extraídos
/// - Single Responsibility: Apenas coordena os widgets
/// - Composição: Usa widgets reutilizáveis
///
/// Benefícios:
/// - ✅ Testabilidade: Cada widget pode ser testado isoladamente
/// - ✅ Manutenibilidade: Mudanças localizadas em cada widget
/// - ✅ Reusabilidade: Widgets podem ser usados em outras telas
class HomePatientScreen extends ConsumerStatefulWidget {
  const HomePatientScreen({super.key});

  @override
  ConsumerState<HomePatientScreen> createState() => _HomePatientScreenState();
}

class _HomePatientScreenState extends ConsumerState<HomePatientScreen> {
  // ══════════════════════════════════════════════════════════
  // STATE
  // ══════════════════════════════════════════════════════════
  final _searchController = TextEditingController();
  String _selectedCity = 'Todas as cidades';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  // CALLBACKS
  // ══════════════════════════════════════════════════════════

  /// Mostra modal de seleção de cidade
  void _showCityModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CitySelectorModal(
        onCitySelected: (city) {
          setState(() {
            _selectedCity = city;
          });
        },
      ),
    );
  }

  /// Navega para lista de profissionais
  void _navigateToProfessionals({String? specialty}) {
    context.goToProfessionalsList(specialty: specialty);
  }

  /// Mostra placeholder de publicar anúncio
  void _showPublishAdPlaceholder() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🚀 '),
            Text('Em Breve'),
          ],
        ),
        content: const Text(
          'A funcionalidade "Publicar um anúncio" estará disponível em breve!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Callback de busca (futuro: sugestões)
  void _onSearchChanged(String value) {
    // TODO: Implementar sugestões de busca em tempo real
  }

  /// Callback de submit de busca
  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      _navigateToProfessionals();
    }
  }

  /// Callback de tap em card de serviço
  void _onServiceTap(String specialty) {
    _navigateToProfessionals(specialty: specialty);
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProviderV2);
    final userName = authState.userName ?? 'Visitante';

    return ExitConfirmationWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header com saudação e localização
                PatientHomeHeader(
                  userName: userName,
                  selectedCity: _selectedCity,
                  onCityTap: _showCityModal,
                ),
                const SizedBox(height: 20),

                // Barra de busca
                PatientHomeSearchBar(
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged,
                  onSearchSubmitted: _onSearchSubmitted,
                ),
                const SizedBox(height: 24),

                // Grid de serviços
                PatientServicesGrid(
                  onServiceTap: _onServiceTap,
                ),
                const SizedBox(height: 24),

                // Botão publicar anúncio
                PublishAdButton(
                  onPressed: _showPublishAdPlaceholder,
                ),
                const SizedBox(height: 80), // Espaço para bottom navigation
              ],
            ),
          ),
        ),
        
        // Bottom Navigation (índice 0 = Home)
        bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
      ),
    );
  }
}
