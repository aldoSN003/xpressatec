import 'package:flutter/material.dart';

class AppColors {
  // This class is not meant to be instantiated.
  AppColors._();

  static   Map<String, Color> colorMap = {
    'amarillo': Colors.yellow.shade700,
    'azul': Colors.blue.shade500,
    'cafe': Colors.brown.shade500,
    'morado': Colors.purple.shade500,
    'naranja': Colors.orange.shade500,
    'rojo': Colors.red.shade500,
    'rosa': Colors.pink.shade300,
    'verde': Colors.green.shade500,
  };

  // Métodos helper para acceder a colores
  static Color getColor(String colorName) {
    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }
  // Add your primary color as a static constant
  static const Color primary = Color(0xFFE00289);
  static const Color secondary = Color(0xFF22abe5);



}