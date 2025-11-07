import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Common style for AppBar titles.
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.normal,
    fontSize: 20,
    color: AppColors.disabled,
  );

  static const TextStyle smallButtonLabel = TextStyle(
    fontFamily: AppFonts.thin,
    fontWeight: FontWeight.normal,
    fontSize: 12,
    color: AppColors.disabled,
  );
}
