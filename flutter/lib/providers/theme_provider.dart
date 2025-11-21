import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/configuracoes_repository.dart';

/// Provider para gerenciar o modo do tema (claro/escuro)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _prefsKey = 'theme_mode';
  
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  /// Carrega o modo do tema salvo
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefsKey);
      
      if (savedMode != null) {
        switch (savedMode) {
          case 'dark':
            state = ThemeMode.dark;
            break;
          case 'light':
            state = ThemeMode.light;
            break;
          case 'system':
            state = ThemeMode.system;
            break;
        }
      } else {
        // Se não houver preferência salva, tenta buscar do Firestore
        await _loadFromFirestore();
      }
    } catch (e) {
      debugPrint('Erro ao carregar modo do tema: $e');
    }
  }

  /// Carrega o modo do tema do Firestore
  Future<void> _loadFromFirestore() async {
    try {
      final repository = ConfiguracoesRepository();
      final config = await repository.getConfiguracoes();
      
      if (config.modoEscuro) {
        state = ThemeMode.dark;
        await _saveThemeMode('dark');
      } else {
        state = ThemeMode.light;
        await _saveThemeMode('light');
      }
    } catch (e) {
      debugPrint('Erro ao carregar modo do tema do Firestore: $e');
    }
  }

  /// Salva o modo do tema
  Future<void> _saveThemeMode(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode);
    } catch (e) {
      debugPrint('Erro ao salvar modo do tema: $e');
    }
  }

  /// Define o modo do tema
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    
    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    
    await _saveThemeMode(modeString);
    
    // Atualiza também no Firestore
    try {
      final repository = ConfiguracoesRepository();
      final config = await repository.getConfiguracoes();
      final updatedConfig = Configuracoes(
        nomeEmpresa: config.nomeEmpresa,
        idioma: config.idioma,
        fusoHorario: config.fusoHorario,
        modoEscuro: mode == ThemeMode.dark,
        notificacoesEmail: config.notificacoesEmail,
        alertasEstoqueBaixo: config.alertasEstoqueBaixo,
        alertasCalibracao: config.alertasCalibracao,
        resumoDiario: config.resumoDiario,
        tempoSessao: config.tempoSessao,
        autenticacaoDoisFatores: config.autenticacaoDoisFatores,
        registroAtividades: config.registroAtividades,
        frequenciaBackup: config.frequenciaBackup,
        retencaoDados: config.retencaoDados,
        smtpServer: config.smtpServer,
        smtpPort: config.smtpPort,
        smtpUser: config.smtpUser,
        smtpPassword: config.smtpPassword,
      );
      await repository.salvarConfiguracoes(updatedConfig);
    } catch (e) {
      debugPrint('Erro ao salvar modo do tema no Firestore: $e');
    }
  }

  /// Alterna entre claro e escuro
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

