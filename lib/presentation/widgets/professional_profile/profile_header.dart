import 'dart:io';
import 'package:flutter/material.dart';

/// Widget: Header do Perfil do Profissional
///
/// Responsabilidade: Exibir foto, nome, especialidade, COREN e selo de verificado
///
/// Princípios aplicados:
/// - Single Responsibility: Apenas renderiza o header
/// - Composição: Auto-contido e reutilizável
class ProfileHeader extends StatelessWidget {
  final String? profileImagePath;
  final String name;
  final String specialty;
  final String coren;
  final bool isVerified;

  const ProfileHeader({
    super.key,
    this.profileImagePath,
    required this.name,
    required this.specialty,
    required this.coren,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Foto do profissional
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              image: profileImagePath != null
                  ? DecorationImage(
                      image: FileImage(File(profileImagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profileImagePath == null
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey.shade600,
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Nome
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Especialidade
          Text(
            specialty,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // COREN + Verificado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                coren,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.verified,
                  size: 18,
                  color: Colors.lightGreenAccent,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Verificado',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.lightGreenAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


