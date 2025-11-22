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
    debugPrint('✅ Arquivo .env carregado com sucesso');
    // Verifica se as variáveis principais estão presentes
    final hasWebApiKey = dotenv.env['FIREBASE_WEB_API_KEY'] != null;
    final hasProjectId = dotenv.env['FIREBASE_WEB_PROJECT_ID'] != null;
    if (hasWebApiKey && hasProjectId) {
      debugPrint('✅ Variáveis do Firebase encontradas no .env');
    } else {
      debugPrint('⚠️ Algumas variáveis do Firebase não foram encontradas no .env');
    }
  } catch (e) {
    // Se não encontrar .env, continua com valores padrão
    // Isso permite desenvolvimento sem .env (usando valores do firebase_options.dart)
    debugPrint('⚠️ Aviso: Arquivo .env não encontrado ou erro ao carregar: $e');
    debugPrint('⚠️ Usando valores padrão do firebase_options.dart');
  }
  
  // Inicializa serviço de encriptação (opcional - só se ENCRYPTION_KEY estiver no .env)
  try {
    EncryptionService().initialize();
  } catch (e) {
    debugPrint('Aviso: EncryptionService não inicializado: $e');
  }
  
  // Inicializa Firebase com tratamento de erro
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    
    // Verifica se as opções são válidas (não são placeholders)
    if (options.apiKey.contains('YOUR_') || 
        options.projectId.contains('YOUR_') ||
        options.appId.contains('YOUR_')) {
      debugPrint('⚠️ AVISO: Firebase não está configurado corretamente!');
      debugPrint('⚠️ Execute: flutterfire configure');
      debugPrint('⚠️ Ou configure o arquivo .env com as credenciais do Firebase');
      // Continua mesmo assim para não travar o app
    }
    
    await Firebase.initializeApp(options: options);
    debugPrint('✅ Firebase inicializado com sucesso');
    debugPrint('   Project ID: ${options.projectId}');
    debugPrint('   API Key: ${options.apiKey.substring(0, 10)}...');
  } catch (e, stackTrace) {
    debugPrint('❌ ERRO ao inicializar Firebase: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continua mesmo assim para não travar o app completamente
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
