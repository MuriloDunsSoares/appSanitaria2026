import 'dart:io';

import 'package:app_sanitaria/data/services/image_picker_service.dart';
import 'package:flutter/material.dart';

/// Widget para seleção de foto de perfil
///
/// Permite escolher entre câmera ou galeria
class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({
    super.key,
    this.initialImagePath,
    required this.onImageSelected,
    this.size = 120,
  });
  final String? initialImagePath;
  final void Function(String imagePath) onImageSelected;
  final double size;

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  String? _currentImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.initialImagePath;
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escolha uma opção',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Opção: Câmera
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(fromCamera: true);
                },
              ),

              // Opção: Galeria
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.teal),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(fromCamera: false);
                },
              ),

              // Opção: Remover (se já tiver foto)
              if (_currentImagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover Foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    setState(() => _isLoading = true);

    try {
      final String? imagePath = fromCamera
          ? await _imagePickerService.pickImageFromCamera()
          : await _imagePickerService.pickImageFromGallery();

      if (imagePath != null) {
        setState(() => _currentImagePath = imagePath);
        widget.onImageSelected(imagePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto atualizada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeImage() async {
    if (_currentImagePath != null) {
      await _imagePickerService.deleteImage(_currentImagePath!);
      setState(() => _currentImagePath = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto removida'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Stack(
        children: [
          // Avatar circular com imagem ou placeholder
          CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: Colors.grey[300],
            backgroundImage: _currentImagePath != null
                ? FileImage(File(_currentImagePath!))
                : null,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : _currentImagePath == null
                    ? Icon(
                        Icons.person,
                        size: widget.size / 2,
                        color: Colors.grey[600],
                      )
                    : null,
          ),

          // Badge de edição
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
