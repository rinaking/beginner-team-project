import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF6F8FB);
  static const card = Colors.white;
  static const navy = Color(0xFF1B2A4A);
  static const navySoft = Color(0xFF4A5872);
  static const muted = Color(0xFF8A94A6);
  static const primary = Color(0xFF1C8C72);
  static const primaryDeep = Color(0xFF14695A);
  static const mint = Color(0xFFE7F6F1);
  static const mintStrong = Color(0xFFD7F0E8);
  static const border = Color(0xFFE6EAF0);
  static const warningBg = Color(0xFFFFF6ED);
  static const warningText = Color(0xFF9A3412);
  static const stage = Color(0xFFE7F3F4);
  static const timeWell = Color(0xFFF2F5F8);
}

class AppType {
  static const brand = TextStyle(
    color: AppColors.primary,
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.6,
  );
  static const hero = TextStyle(
    color: AppColors.navy,
    fontSize: 32,
    height: 1.18,
    fontWeight: FontWeight.w800,
  );
  static const screen = TextStyle(
    color: AppColors.navy,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w800,
  );
  static const section = TextStyle(
    color: AppColors.navy,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );
  static const title = TextStyle(
    color: AppColors.navy,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w800,
  );
  static const body = TextStyle(
    color: AppColors.navy,
    fontSize: 15,
    height: 1.6,
  );
  static const caption = TextStyle(
    color: AppColors.navySoft,
    fontSize: 13,
    height: 1.45,
  );
}

class AppSpace {
  static const page = 20.0;
  static const card = 16.0;
  static const gap = 12.0;
  static const radius = 18.0;
  static const radiusSm = 12.0;
}
