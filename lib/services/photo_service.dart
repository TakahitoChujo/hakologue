import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();

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
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/photos/$projectId');
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${boxId}_$timestamp.jpg';
    final savedPath = '${photoDir.path}/$fileName';

    await File(image.path).copy(savedPath);
    return savedPath;
  }

  Future<void> deletePhoto(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  File getPhotoFile(String path) => File(path);
}
