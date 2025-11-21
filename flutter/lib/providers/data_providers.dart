import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/materiais_repository.dart';
import '../repositories/instrumentos_repository.dart';
import '../repositories/alertas_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/relatorios_repository.dart';
import '../repositories/usuarios_repository.dart' as repo;
import '../repositories/configuracoes_repository.dart';
import '../services/email_notification_service.dart';
import '../state/auth.dart';

// ===================================================================
// PROVIDERS DOS REPOSITÓRIOS
// ===================================================================

final materiaisRepositoryProvider = Provider<MateriaisRepository>((ref) {
  return MateriaisRepository();
});

final instrumentosRepositoryProvider = Provider<InstrumentosRepository>((ref) {
  return InstrumentosRepository();
});

final alertasRepositoryProvider = Provider<AlertasRepository>((ref) {
  return AlertasRepository();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final relatoriosRepositoryProvider = Provider<RelatoriosRepository>((ref) {
  return RelatoriosRepository();
});

final usuariosRepositoryProvider = Provider<repo.UsuariosRepository>((ref) {
  return repo.UsuariosRepository();
});

final configuracoesRepositoryProvider = Provider<ConfiguracoesRepository>((ref) {
  return ConfiguracoesRepository();
});

final emailNotificationServiceProvider = Provider<EmailNotificationService>((ref) {
  return EmailNotificationService();
});

// ===================================================================
// PROVIDERS DE DADOS (STREAMS)
// ===================================================================

/// Provider que retorna stream de todos os materiais
final materiaisProvider = StreamProvider<List<Material>>((ref) {
  final repository = ref.watch(materiaisRepositoryProvider);
  return repository.getMateriais();
});

/// Provider que retorna stream de materiais com estoque crítico
final materiaisCriticosProvider = StreamProvider<List<Material>>((ref) {
  final repository = ref.watch(materiaisRepositoryProvider);
  return repository.getMateriaisCriticos();
});

/// Provider que retorna stream de todos os instrumentos
final instrumentosProvider = StreamProvider<List<Instrumento>>((ref) {
  final repository = ref.watch(instrumentosRepositoryProvider);
  return repository.getInstrumentos();
});

/// Provider que retorna stream de instrumentos disponíveis
final instrumentosDisponiveisProvider =
    StreamProvider<List<Instrumento>>((ref) {
  final repository = ref.watch(instrumentosRepositoryProvider);
  return repository.getInstrumentosDisponiveis();
});

/// Provider que retorna stream de instrumentos emprestados
final instrumentosEmprestadosProvider =
    StreamProvider<List<Instrumento>>((ref) {
  final repository = ref.watch(instrumentosRepositoryProvider);
  return repository.getInstrumentosEmprestados();
});

/// Provider que retorna stream de alertas ativos
final alertasAtivosProvider = StreamProvider<List<Alerta>>((ref) {
  final repository = ref.watch(alertasRepositoryProvider);
  return repository.getAlertasAtivos();
});

/// Provider que retorna stream de alertas críticos
final alertasCriticosProvider = StreamProvider<List<Alerta>>((ref) {
  final repository = ref.watch(alertasRepositoryProvider);
  return repository.getAlertasCriticos();
});

/// Provider que retorna stream de todos os alertas (resolvidos e não resolvidos)
final alertasProvider = StreamProvider<List<Alerta>>((ref) {
  final repository = ref.watch(alertasRepositoryProvider);
  return repository.getAllAlertas();
});

// ===================================================================
// PROVIDERS DE ESTATÍSTICAS
// ===================================================================

/// Provider que retorna estatísticas do dashboard
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getStats();
});

/// Provider que retorna contagem de materiais
final totalMateriaisProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(materiaisRepositoryProvider);
  return repository.getTotalMateriais();
});

/// Provider que retorna contagem de instrumentos
final totalInstrumentosProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(instrumentosRepositoryProvider);
  return repository.getTotalInstrumentos();
});

/// Provider que retorna contagem de instrumentos ativos
final totalInstrumentosAtivosProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(instrumentosRepositoryProvider);
  return repository.getTotalInstrumentosAtivos();
});

/// Provider que retorna contagem de alertas ativos
final totalAlertasAtivosProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(alertasRepositoryProvider);
  return repository.getTotalAlertasAtivos();
});

/// Provider que retorna estatísticas para a página de relatórios
final relatoriosStatsProvider = FutureProvider.family<RelatoriosStats, int>((ref, dias) {
  final repository = ref.watch(relatoriosRepositoryProvider);
  return repository.getStats(dias: dias);
});

/// Provider que retorna stream de todos os usuários
final usuariosProvider = StreamProvider<List<repo.Usuario>>((ref) {
  final repository = ref.watch(usuariosRepositoryProvider);
  return repository.getUsuarios();
});

/// Provider que retorna configurações do sistema
final configuracoesProvider = FutureProvider<Configuracoes>((ref) {
  final repository = ref.watch(configuracoesRepositoryProvider);
  return repository.getConfiguracoes();
});

// ===================================================================
// PROVIDERS DE PERMISSÕES
// ===================================================================

/// Provider que retorna o usuário atual do Firestore
final currentUserProvider = FutureProvider<repo.Usuario?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value;
  
  if (user == null) return null;
  
  final repository = ref.watch(usuariosRepositoryProvider);
  return await repository.getUsuarioById(user.uid);
});

/// Provider que verifica se o usuário atual é gestor ou admin
final isGestorOrAdminProvider = Provider<bool>((ref) {
  final currentUserAsync = ref.watch(currentUserProvider);
  
  return currentUserAsync.when(
    data: (usuario) {
      if (usuario == null) {
        // Debug: usuário não encontrado no Firestore
        debugPrint('⚠️ isGestorOrAdminProvider: Usuário não encontrado no Firestore');
        return false;
      }
      
      // Verifica tanto 'role' quanto 'perfil' (case-insensitive)
      final role = usuario.role.toLowerCase().trim();
      final isAdmin = role == 'admin';
      final isGestor = role == 'gestor';
      
      // Debug para ajudar a identificar problemas
      if (!isAdmin && !isGestor) {
        debugPrint('⚠️ isGestorOrAdminProvider: Usuário com role/perfil: "$role" (não é admin nem gestor)');
      } else {
        debugPrint('✅ isGestorOrAdminProvider: Usuário autorizado (role: $role)');
      }
      
      return isAdmin || isGestor;
    },
    loading: () {
      debugPrint('⏳ isGestorOrAdminProvider: Carregando dados do usuário...');
      return false;
    },
    error: (error, stack) {
      debugPrint('❌ isGestorOrAdminProvider: Erro ao carregar usuário: $error');
      return false;
    },
  );
});

