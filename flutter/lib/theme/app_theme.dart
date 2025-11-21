import 'package:flutter/material.dart';

/// Tema claro (padrão)
ThemeData appThemeLight() {
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

/// Tema escuro
ThemeData appThemeDark() {
  final base = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      shadowColor: Color(0x44000000),
    ),
    listTileTheme: ListTileThemeData(
      textColor: Colors.white,
      iconColor: Colors.indigo.shade300,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    ),
    textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF1E1E1E),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.indigo),
      ),
    ),
  );
}

/// Função legada para compatibilidade (retorna tema claro)
@Deprecated('Use appThemeLight() ou appThemeDark()')
ThemeData appTheme() {
  return appThemeLight();
}
