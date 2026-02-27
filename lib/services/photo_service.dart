import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  static final _uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false);

  Future<String?> takePhoto(String projectId, String boxId) async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (image == null) return null;
    return _savePhoto(image, projectId, boxId);
  }

  Future<String?> pickFromGallery(String projectId, String boxId) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (image == null) return null;
    return _savePhoto(image, projectId, boxId);
  }

  Future<String> _savePhoto(
      XFile image, String projectId, String boxId) async {
    _validateId(projectId, 'projectId');
    _validateId(boxId, 'boxId');

    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/photos/$projectId');
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${boxId}_$timestamp.jpg';
    final savedPath = '${photoDir.path}/$fileName';

    _validatePathWithinApp(savedPath, appDir.path);

    try {
      final cleanBytes = await _stripExif(image.path);
      await File(savedPath).writeAsBytes(cleanBytes);
    } catch (_) {
      await File(image.path).copy(savedPath);
    }

    return savedPath;
  }

  void _validateId(String id, String name) {
    if (id == 'temp') return;
    if (!_uuidRegex.hasMatch(id)) {
      throw ArgumentError('Invalid $name: must be a valid UUID');
    }
  }

  void _validatePathWithinApp(String path, String appDirPath) {
    final normalized = Uri.parse(path).normalizePath().path;
    if (!normalized.startsWith(appDirPath)) {
      throw ArgumentError('Path traversal detected');
    }
  }

  Future<Uint8List> _stripExif(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Failed to decode image');
    return Uint8List.fromList(img.encodeJpg(decoded, quality: 80));
  }

  Future<void> deletePhoto(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort deletion
    }
  }

  File getPhotoFile(String path) => File(path);
}
