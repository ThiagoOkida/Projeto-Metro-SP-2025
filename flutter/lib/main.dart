import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'routing.dart';
import 'theme/app_theme.dart';
import 'services/encryption_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega variáveis de ambiente do arquivo .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Se não encontrar .env, continua com valores padrão
    // Isso permite desenvolvimento sem .env (usando valores do firebase_options.dart)
    debugPrint('Aviso: Arquivo .env não encontrado. Usando valores padrão.');
  }
  
  // Inicializa serviço de encriptação (opcional - só se ENCRYPTION_KEY estiver no .env)
  try {
    EncryptionService().initialize();
  } catch (e) {
    debugPrint('Aviso: EncryptionService não inicializado: $e');
  }
  
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'São Paulo Stock Sync',
      theme: appThemeLight(),
      darkTheme: appThemeDark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
