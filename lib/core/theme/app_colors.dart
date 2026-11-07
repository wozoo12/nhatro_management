import 'package:flutter/material.dart';

class AppColors {
  // LOZIDO brand palette from ABC_Design/rules/brand.json.
  static const Color brandInk = Color(0xFF1E293B);
  static const Color accentAmber = Color(0xFFFF9800);
  static const Color paper = Color(0xFFF5F5F5);
  static const Color muted = Color(0xFF757575);

  // Keep legacy names so existing screens inherit the updated brand palette.
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color mintBg = Color(0xFFF3FAF4);

  // Room and invoice status colors. Their meaning is consistent across the app.
  static const Color paidGreen = primaryGreen;
  static const Color unpaidRed = Color(0xFFD32F2F);
  static const Color bookedBlue = Color(0xFF1976D2);
  static const Color availableAmber = Color(0xFFFF9800);
  static const Color maintenanceGray = Color(0xFF5B6B7B);

  // Legacy action names map to the brand status palette.
  static const Color blueCTA = bookedBlue;
  static const Color alertOrange = availableAmber;
  static const Color warningOrange = availableAmber;
  static const Color dangerRed = unpaidRed;

  // Text and surface colors.
  static const Color navyText = brandInk;
  static const Color grayText = muted;
  static const Color lightGrayBg = paper;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
