import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Helpers para exibir SnackBars padronizados (sucesso e erro).
class AppSnackbar {
  AppSnackbar._();

  static void _show(
    ScaffoldMessengerState messenger,
    String message,
    Color color,
    IconData icon,
  ) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  static void success(BuildContext context, String message) {
    _show(ScaffoldMessenger.of(context), message, AppColors.income,
        Icons.check_circle_outline);
  }

  static void error(BuildContext context, String message) {
    _show(ScaffoldMessenger.of(context), message, AppColors.expense,
        Icons.error_outline);
  }

  /// Versão que recebe o messenger diretamente — útil quando o contexto será
  /// destruído logo em seguida (ex.: após fechar um bottom sheet).
  static void successWith(ScaffoldMessengerState messenger, String message) {
    _show(messenger, message, AppColors.income, Icons.check_circle_outline);
  }

  static void errorWith(ScaffoldMessengerState messenger, String message) {
    _show(messenger, message, AppColors.expense, Icons.error_outline);
  }
}
