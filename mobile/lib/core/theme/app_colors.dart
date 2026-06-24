import 'package:flutter/material.dart';

class AppColors {
  // ── Primarios ─────────────────────────────────────────────────────────────
  static const Color primary       = Color(0xFF9B59B6); // morado principal
  static const Color primaryDark   = Color(0xFF7D3C98); // morado oscuro (hover / pressed)
  static const Color primaryLight  = Color(0xFFEDE5F7); // morado muy claro (chips, fills)
  static const Color primaryMedium = Color(0xFFBE90D4); // morado medio (bordes activos)

  // ── Fondo / Superficie ────────────────────────────────────────────────────
  static const Color background    = Color(0xFFF7F3FC); // lavanda off-white — aire mental
  static const Color surface       = Color(0xFFFFFFFF); // blanco puro — cards
  static const Color surfaceAlt    = Color(0xFFFAF7FF); // blanco con toque lavanda
  static const Color divider       = Color(0xFFEDE5F7); // divisor suave

  // ── Texto ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A2E); // casi negro azulado
  static const Color textSecondary = Color(0xFF6B7280); // gris medio — metadata
  static const Color textMuted     = Color(0xFFB0B8C1); // gris claro — placeholders
  static const Color textLink      = Color(0xFF9B59B6); // morado — links / hashtags

  // ── AppBar ────────────────────────────────────────────────────────────────
  static const Color appBarBg      = Color(0xFFFFFFFF);
  static const Color appBarTitle   = Color(0xFF9B59B6);

  // ── Nav ───────────────────────────────────────────────────────────────────
  static const Color navActive     = Color(0xFF9B59B6);
  static const Color navInactive   = Color(0xFFB0B8C1);

  // ── Estados ───────────────────────────────────────────────────────────────
  static const Color error         = Color(0xFFE74C3C);
  static const Color success       = Color(0xFF27AE60);
  static const Color warning       = Color(0xFFF59E0B);

  // ── Sombra ────────────────────────────────────────────────────────────────
  /// Sombra difusa de tarjeta — morado muy opaco
  static const Color shadowCard    = Color(0x149B59B6); // ~8% opacity

  // ── Extras (compat) ───────────────────────────────────────────────────────
  static const Color bgLight       = Color(0xFFFFFFFF);
  static const Color bgMedium      = Color(0xFFEDE5F7);
  static const Color darkGray      = Color(0xFF1A1A2E);
  static const Color mediumGray    = Color(0xFF6B7280);
  static const Color lightGray     = Color(0xFFF7F3FC);
}