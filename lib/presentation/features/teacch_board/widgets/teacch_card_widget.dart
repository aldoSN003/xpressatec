import 'dart:io';
import 'package:flutter/material.dart';
import 'package:xpressatec/core/theme/app_fonts.dart';
import 'package:xpressatec/data/models/image_model.dart';


// Enum to define the type of content the card will display.
// This is used internally to keep the logic clean.
enum _CardContentType { text, image, icon }

class TeacchCardWidget extends StatelessWidget {
  // COMMON PROPERTIES
  final Color color;
  final String text;
  final bool isSelected;
  final bool showLabel;
  final double borderThickness;
  final void Function()? onTap;

  // TYPE-SPECIFIC PROPERTIES
  final _CardContentType _contentType;
  final ImageModel? imageModel;
  final IconData? iconData;
  final double? iconSize;

  /// Creates a card that displays only text.
  const TeacchCardWidget.text({
    super.key,
    required this.text,
    required this.color,
    this.isSelected = false,
    this.onTap,
    this.borderThickness = 7,
  })  : _contentType = _CardContentType.text,
        showLabel = false, // Not applicable for text-only cards
        imageModel = null,
        iconData = null,
        iconSize = null;

  /// Creates a card that displays an image, with an optional label below it.
  const TeacchCardWidget.image({
    super.key,
    required this.imageModel,
    required this.color,
    this.text = '', // The text for the optional label
    this.showLabel = false,
    this.isSelected = false,
    this.onTap,
    this.borderThickness = 7,
  })  : _contentType = _CardContentType.image,
        iconData = null,
        iconSize = null;

  /// Creates a card that displays an icon, with an optional label below it.
  const TeacchCardWidget.icon({
    super.key,
    required this.iconData,
    required this.color,
    this.text = '', // The text for the optional label
    this.showLabel = false,
    this.isSelected = false,
    this.onTap,
    this.iconSize,
    this.borderThickness = 7,
  })  : _contentType = _CardContentType.icon,
        imageModel = null;

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1, // Ensures the card is always square
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
              // Add a blue glow effect when the card is selected
              if (isSelected)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.9),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: color, width: borderThickness),
                borderRadius: BorderRadius.circular(12),
              ),
              // The switch statement cleanly selects the content to build
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  // --- CONTENT BUILDERS ---

  /// Determines which content widget to build based on the card type.
  Widget _buildContent() {
    switch (_contentType) {
      case _CardContentType.image:
        return _buildVisualWithLabel(
          visualContent: _buildImage(),
        );
      case _CardContentType.icon:
        return _buildVisualWithLabel(
          visualContent: _buildIcon(),
        );
      case _CardContentType.text:
      default:
        return _buildTextOnly();
    }
  }

  /// A generic layout for content that has a primary visual (image/icon)
  /// and an optional text label below it.
  Widget _buildVisualWithLabel({required Widget visualContent}) {
    return Column(
      children: [
        // The main visual element (image or icon)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: visualContent,
          ),
        ),
        // The optional label
        if (showLabel)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: const TextStyle(
                fontFamily: AppFonts.primary,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the text-only content.
  Widget _buildTextOnly() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Builds the icon content.
  Widget _buildIcon() {
    return FittedBox(
      fit: BoxFit.contain,
      child: Icon(
        iconData,
        size: iconSize ?? 64,
        color: color,
      ),
    );
  }

  /// Builds the image content using a FutureBuilder to handle async loading.
  Widget _buildImage() {
    return FutureBuilder<ImageProvider>(
      future: _loadImageProvider(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text(
              "Error al cargar la imagen",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Image(
          image: snapshot.data!,
          fit: BoxFit.contain,
        );
      },
    );
  }

  // --- HELPER METHODS ---

  /// Loads the appropriate ImageProvider (FileImage or AssetImage).
  Future<ImageProvider> _loadImageProvider() async {
    if (imageModel == null) {
      throw Exception("ImageModel no proporcionado");
    }
    if (imageModel!.isLocal) {
      final file = File(imageModel!.imagePath);
      if (await file.exists()) {
        return FileImage(file);
      } else {
        throw Exception("La imagen local no existe");
      }
    } else {
      return AssetImage(imageModel!.imagePath);
    }
  }
}