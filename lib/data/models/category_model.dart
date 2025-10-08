import 'package:flutter/material.dart';

class CategoryModel {
  final String name; // El nombre que se mostrará (ej: "Personas")
  final String coverImagePath; // La ruta a la imagen de portada
  final String contentPath; // La ruta a la carpeta con las imágenes
  final Color color; // El color asociado a la categoría

  const CategoryModel({
    required this.name,
    required this.coverImagePath,
    required this.contentPath,
    required this.color,
  });
}