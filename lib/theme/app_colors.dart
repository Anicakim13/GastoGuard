import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // stops anyone from creating an AppColors object

  // Backgrounds and surfaces
  static const Color background = Color(0xFFDFF5E7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardTint = Color(0xFFF6FCF8); // approximate

  // Greens
  static const Color primary = Color(0xFF0F9D58);
  static const Color primaryDark = Color(0xFF087F46);
  static const Color primaryDeep = Color(0xFF257E4A);

  // Button gradient (approximate, sampled from the Canva design)
  static const Color buttonGradientTop = Color(0xFF14954B);
  static const Color buttonGradientBottom = Color(0xFF346D06);
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [buttonGradientTop, buttonGradientBottom],
  );

  // Dashboard balance card (approximate, sampled from the Canva design)
  static const Color balanceCardTop = Color(0xFF43B27A);
  static const Color balanceCardBottom = Color(0xFF618C3A);
  static const LinearGradient balanceCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [balanceCardTop, balanceCardBottom],
  );
  static const Color progressFill = Color(0xFFCEE9D4);
  static const Color progressBorder = Color(0xB3FFFFFF);

  // Income / Spent cards and bottom navigation (approximate)
  static const Color income = Color(0xFF56AD75);
  static const Color incomeBorder = Color(0xFF3D9C6E);
  static const Color expenseBorder = Color(0xFFF6625E);
  static const Color navDivider = Color(0xFF6B6B6B);

  // Text
  static const Color textPrimary = Color(0xFF000000);
  static const Color textOnGreen = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF6B6B6B);

  // Status
  static const Color expense = Color(0xFFFF3131);

  // Categories
  static const Color food = Color(0xFFF9930D);
  static const Color transportation = Color(0xFF275EDB);
  static const Color data = Color(0xFF5F26D9);
  static const Color schoolSupplies = Color(0xFFEEE628);
  static const Color entertainment = Color(0xFFF72CAC);
  static const Color others = Color(0xFF257E4A);

  // Add Transaction screen (sampled from the Canva design)
  static const Color dataIcon = Color(0xFF6D1D9A); // deeper purple Data icon
  static const Color schoolSuppliesIcon = Color(0xFFFFF596); // pale notebook icon
  static const Color cardShadow = Color(0x59000000); // soft shadow under category cards

  // Spending Summary chart (sampled from the Canva design)
  static const Color chartGridLine = Color(0xFFA7B7AD);
}
