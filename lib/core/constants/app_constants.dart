import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../theme/app_colors.dart';

class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // App Information
  static const String appName = 'XpressaTec';
  static const String appVersion = '1.0.0';

  // Main Categories
  static final List<CategoryModel> mainCategories = [
    CategoryModel(
      name: '¿Quién es?',
      color: AppColors.colorMap['amarillo']!,
      contentPath: 'assets/images/amarillo',
      coverImagePath: '',
    ),
    CategoryModel(
      name: '¿Qué es?',
      color: AppColors.colorMap['rosa']!,
      contentPath: 'assets/images/rosa',
      coverImagePath: '',
    ),
    CategoryModel(
      name: '¿Qué hace?',
      color: AppColors.colorMap['verde']!,
      contentPath: 'assets/images/verde',
      coverImagePath: '',
    ),
    CategoryModel(
      name: '¿Cómo?',
      color: AppColors.colorMap['azul']!,
      contentPath: 'assets/images/azul',
      coverImagePath: '',
    ),
    CategoryModel(
      name: '¿Dónde?',
      color: AppColors.colorMap['cafe']!,
      contentPath: 'assets/images/cafe',
      coverImagePath: '',
    ),
    CategoryModel(
      name: '¿Cuándo?',
      color: AppColors.colorMap['rojo']!,
      contentPath: 'assets/images/rojo',
      coverImagePath: '',
    ),
    CategoryModel(
      name: '¿Por qué?',
      color: AppColors.colorMap['morado']!,
      contentPath: 'assets/images/morado',
      coverImagePath: '',
    ),
    CategoryModel(
      name: '¿Para qué?',
      color: AppColors.colorMap['naranja']!,
      contentPath: 'assets/images/naranja',
      coverImagePath: '',
    ),
  ];

  // Category Icons (corresponding to mainCategories order)
  static const List<IconData> categoryIcons = [
    Icons.face,              // ¿Quién es?
    Icons.help_outline,      // ¿Qué es?
    Icons.sports_gymnastics, // ¿Qué hace?
    Icons.settings,          // ¿Cómo?
    Icons.place,             // ¿Dónde?
    Icons.schedule,          // ¿Cuándo?
    Icons.lightbulb_outline, // ¿Por qué?
    Icons.flag,              // ¿Para qué?
  ];

  // // Animation Durations
  // static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  // static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  // static const Duration longAnimationDuration = Duration(milliseconds: 500);
  //
  // // Pagination
  // static const int defaultPageSize = 20;
  // static const int maxPageSize = 100;
  //
  // // Timeouts
  // static const Duration apiTimeout = Duration(seconds: 30);
  // static const Duration websocketTimeout = Duration(seconds: 5);
}