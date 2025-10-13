import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_sanitaria/domain/entities/user_entity.dart';
import 'package:app_sanitaria/presentation/providers/contracts_provider_v2.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
import 'package:app_sanitaria/presentation/widgets/contract_card.dart';
import 'package:app_sanitaria/presentation/screens/contract_detail_screen.dart';

/// Tela de histórico de contratos
///
/// Exibe todos os contratos do usuário (paciente ou profissional)
/// com possibilidade de filtrar por status
class ContractsScreen extends ConsumerStatefulWidget {
  const ContractsScreen({super.key});

  @override
  ConsumerState<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends ConsumerState<ContractsScreen> {
  String _selectedFilter = 'Todos';

  final List<String> _filters = [
    'Todos',
    'Aguardando Confirmação',
    'Confirmado',
    'Em Andamento',
    'Finalizado',
    'Cancelado',
  ];

  @override
  void initState() {
    super.initState();
    // Carregar contratos ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContracts();
    });
  }

  void _loadContracts() {
    ref.read(contractsProviderV2.notifier).loadContracts();
  }

  String _getStatusKey(String label) {
    switch (label) {
      case 'Aguardando Confirmação':
        return 'pending';
      case 'Confirmado':
        return 'confirmed';
      case 'Em Andamento':
        return 'active';
      case 'Finalizado':
        return 'completed';
      case 'Cancelado':
        return 'cancelled';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractsState = ref.watch(contractsProviderV2);
    final authState = ref.watch(authProviderV2);
    final currentUser = authState.user;

    final isPatient = currentUser?.tipo == UserType.paciente;

    // Filtrar contratos baseado no filtro selecionado
    final filteredContracts = _selectedFilter == 'Todos'
        ? contractsState.contracts
        : contractsState.contracts.where((contract) {
            return contract.status == _getStatusKey(_selectedFilter);
          }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Voltar para a tela de Perfil ao clicar no botão voltar
          context.go('/profile');
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Meus Contratos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros horizontais
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Lista de contratos
          Expanded(
            child: contractsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : contractsState.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              contractsState.errorMessage!,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadContracts,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      )
                    : filteredContracts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedFilter == 'Todos'
                                      ? 'Nenhum contrato encontrado'
                                      : 'Nenhum contrato com status "$_selectedFilter"',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isPatient
                                      ? 'Contrate um profissional para começar!'
                                      : 'Aguarde contratações de pacientes.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              _loadContracts();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filteredContracts.length,
                              itemBuilder: (context, index) {
                                final contract = filteredContracts[index];
                                return ContractCard(
                                  contract: contract,
                                  isPatient: isPatient,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (context) =>
                                            ContractDetailScreen(
                                          contract: contract,
                                          isPatient: isPatient,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      ),
    );
  }
}
