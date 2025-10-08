// data/models/image_model.dart

class ImageModel {
  final String imagePath;
  final bool isLocal;

  const ImageModel({
    required this.imagePath,
    this.isLocal = false, // Por defecto, asumimos que no es local
  });
}