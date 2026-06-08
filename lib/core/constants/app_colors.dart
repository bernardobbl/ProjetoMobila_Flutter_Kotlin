import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Marca (azul) ─────────────────────────────────────────────────────
  static const primary = Color(0xFF3D7BFF);
  static const primaryLight = Color(0xFF6F9DFF);
  static const primaryDark = Color(0xFF2C5FE0);

  // ─── Entrada (teal) / Saída (vermelho suave) ──────────────────────────
  static const income = Color(0xFF1FC8A4);
  static const incomeLight = Color(0xFFE2F7F1);

  static const expense = Color(0xFFF26D6D);
  static const expenseLight = Color(0xFFFCE9E9);

  // Orçamento / alerta
  static const warning = Color(0xFFF5A524);

  // ─── Superfícies — tema claro ─────────────────────────────────────────
  static const background = Color(0xFFF4F6FA);
  static const card = Colors.white;

  // ─── Superfícies — tema escuro ────────────────────────────────────────
  static const darkBackground = Color(0xFF0E1116);
  static const darkCard = Color(0xFF181C24);
  static const darkBorder = Color(0xFF262B33);
  static const darkTextPrimary = Color(0xFFE8EBF0);

  // ─── Texto (tema claro) ───────────────────────────────────────────────
  static const textPrimary = Color(0xFF1A1F2B);
  static const textSecondary = Color(0xFF8A93A3);
  static const textHint = Color(0xFFB4BBC7);

  static const divider = Color(0xFFECEEF3);

  static const List<Color> categoryColors = [
    Color(0xFF3D7BFF),
    Color(0xFF1FC8A4),
    Color(0xFFF5A524),
    Color(0xFFF26D6D),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFFFB7185),
    Color(0xFF14B8A6),
    Color(0xFF64748B),
  ];
}
