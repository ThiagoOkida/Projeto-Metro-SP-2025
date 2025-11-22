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
  
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Arquivo .env carregado com sucesso');
    final hasWebApiKey = dotenv.env['FIREBASE_WEB_API_KEY'] != null;
    final hasProjectId = dotenv.env['FIREBASE_WEB_PROJECT_ID'] != null;
    if (hasWebApiKey && hasProjectId) {
      debugPrint('✅ Variáveis do Firebase encontradas no .env');
    } else {
      debugPrint('⚠️ Algumas variáveis do Firebase não foram encontradas no .env');
    }
  } catch (e) {
    debugPrint('⚠️ Aviso: Arquivo .env não encontrado ou erro ao carregar: $e');
    debugPrint('⚠️ Usando valores padrão do firebase_options.dart');
  }
  
  try {
    EncryptionService().initialize();
  } catch (e) {
    debugPrint('Aviso: EncryptionService não inicializado: $e');
  }
  
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.apiKey.contains('YOUR_') || 
        options.projectId.contains('YOUR_') ||
        options.appId.contains('YOUR_')) {
      debugPrint('⚠️ AVISO: Firebase não está configurado corretamente!');
      debugPrint('⚠️ Execute: flutterfire configure');
      debugPrint('⚠️ Ou configure o arquivo .env com as credenciais do Firebase');
    }
    
    await Firebase.initializeApp(options: options);
    debugPrint('✅ Firebase inicializado com sucesso');
    debugPrint('   Project ID: ${options.projectId}');
    debugPrint('   API Key: ${options.apiKey.substring(0, 10)}...');
  } catch (e, stackTrace) {
    debugPrint('❌ ERRO ao inicializar Firebase: $e');
    debugPrint('Stack trace: $stackTrace');
  }
  
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
