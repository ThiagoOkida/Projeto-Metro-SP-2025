import 'package:flutter/material.dart';

ThemeData appTheme() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      shadowColor: Color(0x22000000),
    ),
    listTileTheme: ListTileThemeData(
      textColor: Colors.black87,
      iconColor: Colors.indigo.shade700,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    ),
    textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 2,
    ),
  );
}
