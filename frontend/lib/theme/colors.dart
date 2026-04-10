import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF060C14);
  static const surface = Color(0xFF0E1726);
  static const card = Color(0xFF111B2E);
  static const emerald = Color(0xFF10B981);
  static const blue = Color(0xFF3B82F6);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const yellow = Color(0xFFFBBF24);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0x80FFFFFF);
  static const border = Color(0x1AFFFFFF);

  static const emeraldGradient = LinearGradient(
    colors: [emerald, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [Color(0xFF060C14), Color(0xFF0A1628)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

Color severityColor(String s) {
  switch (s) {
    case 'High':
      return AppColors.red;
    case 'Medium':
      return AppColors.orange;
    case 'Low':
      return AppColors.emerald;
    default:
      return AppColors.textSecondary;
  }
}

Color statusColor(String s) {
  switch (s) {
    case 'Pending':
      return AppColors.red;
    case 'In Progress':
      return AppColors.orange;
    case 'Cleaned':
      return AppColors.emerald;
    default:
      return AppColors.textSecondary;
  }
}
