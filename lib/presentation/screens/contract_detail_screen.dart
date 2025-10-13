import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_sanitaria/domain/entities/contract_entity.dart';
import 'package:app_sanitaria/domain/entities/contract_status.dart';
import 'package:app_sanitaria/presentation/providers/auth_provider_v2.dart';
// LocalStorageDataSource removido - usando providers V2
import 'package:intl/intl.dart';

/// Tela de detalhes do contrato
///
/// Exibe todas as informações detalhadas de um contrato específico
class ContractDetailScreen extends ConsumerWidget {
  final ContractEntity contract;
  final bool isPatient;

  const ContractDetailScreen({
    super.key,
    required this.contract,
    this.isPatient = true,
  });

  Color _getStatusColor() {
    switch (contract.status) {
      case ContractStatus.pending:
        return Colors.orange;
      case ContractStatus.confirmed:
        return Colors.blue;
      case ContractStatus.active:
        return Colors.green;
      case ContractStatus.completed:
        return Colors.grey;
      case ContractStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (contract.status) {
      case ContractStatus.pending:
        return Icons.hourglass_empty;
      case ContractStatus.confirmed:
        return Icons.check_circle;
      case ContractStatus.active:
        return Icons.play_circle;
      case ContractStatus.completed:
        return Icons.done_all;
      case ContractStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName =
        isPatient ? contract.professionalName : contract.patientName;
    final dateFormatted = DateFormat('dd/MM/yyyy').format(contract.date);
    final createdAtFormatted =
        DateFormat('dd/MM/yyyy HH:mm').format(contract.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Contrato'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(),
                      size: 24,
                      color: _getStatusColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      contract.status.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Card: Informações das Partes
            _buildCard(
              title: isPatient ? 'Profissional Contratado' : 'Paciente',
              icon: isPatient ? Icons.person : Icons.elderly,
              children: [
                _buildDetailRow('Nome', displayName),
                _buildDetailRow('Tipo de Serviço', contract.serviceType),
              ],
            ),

            const SizedBox(height: 16),

            // Card: Detalhes do Serviço
            _buildCard(
              title: 'Detalhes do Serviço',
              icon: Icons.medical_services,
              children: [
                _buildDetailRow('Data', dateFormatted),
                _buildDetailRow('Horário', contract.time),
                _buildDetailRow('Período', contract.period),
                _buildDetailRow('Duração', '${contract.duration} horas/dia'),
                _buildDetailRow('Endereço', contract.address),
              ],
            ),

            const SizedBox(height: 16),

            // Card: Observações (se houver)
            if (contract.observations != null &&
                contract.observations!.isNotEmpty)
              _buildCard(
                title: 'Observações',
                icon: Icons.notes,
                children: [
                  Text(
                    contract.observations!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),

            if (contract.observations != null &&
                contract.observations!.isNotEmpty)
              const SizedBox(height: 16),

            // Card: Valor
            _buildCard(
              title: 'Pagamento',
              icon: Icons.payments,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Valor Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R\$ ${contract.totalValue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card: Metadados
            _buildCard(
              title: 'Informações Adicionais',
              icon: Icons.info_outline,
              children: [
                _buildDetailRow('ID do Contrato', contract.id),
                _buildDetailRow('Criado em', createdAtFormatted),
                if (contract.updatedAt != null)
                  _buildDetailRow(
                    'Atualizado em',
                    DateFormat('dd/MM/yyyy HH:mm').format(contract.updatedAt!),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Botão "Avaliar Profissional" (apenas para pacientes com contrato concluído)
            if (contract.status == ContractStatus.completed && isPatient)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Obter ID do paciente atual
                    final authState = ref.read(authProviderV2);
                    final patientId = authState.user?.id;

                    if (patientId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erro: Usuário não autenticado.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // TODO: Implementar verificação se já avaliou usando reviewsProviderV2
                    // final hasReviewed = await ref.read(reviewsProviderV2.notifier).hasUserReviewed(patientId, contract.professionalId);
                    // if (hasReviewed && context.mounted) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text('Você já avaliou este profissional!'),
                    //       backgroundColor: Colors.orange,
                    //     ),
                    //   );
                    //   return;
                    // }

                    // Navegar para tela de avaliação
                    if (context.mounted) {
                      context.go(
                        '/add-review?professionalId=${contract.professionalId}&professionalName=${Uri.encodeComponent(contract.professionalName)}',
                      );
                    }
                  },
                  icon: const Icon(Icons.star_rate),
                  label: const Text('Avaliar Profissional'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

            if (contract.status == ContractStatus.completed && isPatient)
              const SizedBox(height: 12),

            // Botões de Ação (placeholder para futuras funcionalidades)
            if (contract.status == ContractStatus.pending && isPatient)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Cancelamento de contrato em desenvolvimento...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar Contrato'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

            if (contract.status == ContractStatus.pending && !isPatient) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Confirmação de contrato em desenvolvimento...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar Contrato'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Recusa de contrato em desenvolvimento...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Recusar Contrato'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
