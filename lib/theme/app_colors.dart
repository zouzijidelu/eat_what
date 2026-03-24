import 'package:flutter/material.dart';

/// Chisha 设计体系 - 与 HTML 版本一致的品牌色
class AppColors {
  AppColors._();

  static const Color brand50 = Color(0xFFFFF1F5);
  static const Color brand100 = Color(0xFFFEE4EC); // #ffe4ec
  static const Color brand500 = Color(0xFFFF4D7D);
  static const Color brand600 = Color(0xFFFF2F6D);
  static const Color ink = Color(0xFF1F2430);
  static const Color rose100 = Color(0xFFFFE4EC);
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [rose50, Colors.white, Colors.white],
  );
}
