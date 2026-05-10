import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF0A1628);       // deep midnight navy
  static const Color primaryLight = Color(0xFF1A3A5C);  // navy mid
  static const Color accent = Color(0xFF00D4AA);        // teal-mint
  static const Color accentDark = Color(0xFF00A882);    // deeper teal
  static const Color gold = Color(0xFFFFB830);          // warm amber-gold

  // Backgrounds
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4FF);
  static const Color cardShadow = Color(0x1A0A1628);
  static const Color divider = Color(0xFFEEF1F7);

  // Status
  static const Color statusPending = Color(0xFFFF9F43);
  static const Color statusSubmitted = Color(0xFF5B86E5);
  static const Color statusApproved = Color(0xFF1DD1A1);
  static const Color statusRejected = Color(0xFFFF6B6B);

  // Charts
  static const Color chartBar = Color(0xFF00D4AA);
  static const Color chartLine = Color(0xFFFFB830);
  static const Color chartPaid = Color(0xFF1DD1A1);
  static const Color chartPending = Color(0xFFFF9F43);
  static const Color chartRejected = Color(0xFFFF6B6B);

  // Gradient stops
  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF1A3A5C), Color(0xFF0D5C4A)],
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4AA), Color(0xFF00A882)],
  );

  static const Gradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB830), Color(0xFFFF8C00)],
  );

  // Text
  static const Color textPrimary = Color(0xFF0A1628);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color textHint = Color(0xFFAAB4C8);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkSub = Color(0xB3FFFFFF);
}
