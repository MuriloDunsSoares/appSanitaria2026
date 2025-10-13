import 'package:app_sanitaria/core/utils/app_logger.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Serviço para gerenciar seleção e upload de imagens
///
/// Responsabilidades:
/// - Abrir câmera ou galeria
/// - Salvar imagem localmente
/// - Gerenciar paths das imagens
///
/// Princípios:
/// - Single Responsibility: Apenas manipulação de imagens
/// - Clean Architecture: Camada de Data
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Seleciona uma imagem da galeria
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _saveImagePermanently(image);
    } catch (e) {
      AppLogger.error('Erro ao selecionar imagem da galeria: $e');
      return null;
    }
  }

  /// Captura uma imagem com a câmera
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _saveImagePermanently(image);
    } catch (e) {
      AppLogger.error('Erro ao capturar imagem da câmera: $e');
      return null;
    }
  }

  /// Salva a imagem permanentemente no diretório da aplicação
  Future<String?> _saveImagePermanently(XFile image) async {
    try {
      // Obter diretório de documentos da aplicação
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Criar subdiretório para imagens de perfil
      final Directory profileImagesDir =
          Directory('${appDir.path}/profile_images');
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Gerar nome único para a imagem
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(image.path);
      final String fileName = 'profile_$timestamp$extension';
      final String savedPath = '${profileImagesDir.path}/$fileName';

      // Copiar imagem para o novo local
      final File sourceFile = File(image.path);
      await sourceFile.copy(savedPath);

      AppLogger.info('Imagem salva em: $savedPath');
      return savedPath;
    } catch (e) {
      AppLogger.error('Erro ao salvar imagem permanentemente: $e');
      return null;
    }
  }

  /// Deleta uma imagem pelo path
  Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('Imagem deletada: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Erro ao deletar imagem: $e');
      return false;
    }
  }

  /// Seleciona múltiplas imagens (para galeria de certificados)
  Future<List<String>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isEmpty) return [];

      final List<String> savedPaths = [];

      for (final image in images) {
        final String? savedPath = await _saveImagePermanently(image);
        if (savedPath != null) {
          savedPaths.add(savedPath);
        }
      }

      return savedPaths;
    } catch (e) {
      AppLogger.error('Erro ao selecionar múltiplas imagens: $e');
      return [];
    }
  }
}
