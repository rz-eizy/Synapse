import 'package:flutter/material.dart';

class AppColors {
    // ----------(por ajustar al figma)---------------
  // Primarios ----------------------
  static const Color primary        = Color(0xFF9B59B6); // morado principal (botones, tabs activos)
  static const Color primaryLight   = Color(0xFFE8D5F5); // morado muy claro (fondo tabs, chips)
  static const Color primaryMedium  = Color(0xFFBE90D4); // morado medio (bordes, detalles)

  //Fondo / Sobrefondo ----------------------
  static const Color background     = Color(0xFFFFFFFF); // blanco puro
  static const Color surface        = Color(0xFFF9F4FD); // blanco lavanda (fondo cards leve)
  static const Color divider        = Color(0xFFEEE5F5); // línea separadora

  // Texto --------------------
  static const Color textPrimary    = Color(0xFF1A1A2E); // casi negro azulado
  static const Color textSecondary  = Color(0xFF7F8C8D); // gris medio
  static const Color textMuted      = Color(0xFFB2BABB); // gris claro
  static const Color textLink       = Color(0xFF9B59B6); // morado (links, hashtags)

  // AppBar / Header ---------------------------
  static const Color appBarBg       = Color(0xFFFFFFFF);
  static const Color appBarTitle    = Color(0xFF9B59B6); // "APPOYO" en morado

  // Bottom Nav --------------------------------------
  static const Color navActive      = Color(0xFF9B59B6);
  static const Color navInactive    = Color(0xFFB2BABB);

  // Estados -----------------------------
  static const Color error          = Color(0xFFE74C3C);
  static const Color success        = Color(0xFF27AE60);

  // Extras ------------------
  static const Color bgLight        = Color(0xFFFFFFFF);
  static const Color bgMedium       = Color(0xFFE8D5F5);
  static const Color darkGray       = Color(0xFF1A1A2E);
  static const Color mediumGray     = Color(0xFF7F8C8D);
  static const Color lightGray      = Color(0xFFF9F4FD);
}