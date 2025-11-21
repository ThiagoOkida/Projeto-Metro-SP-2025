import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importa tanto o estado quanto o controller de login
import '../state/auth.dart';
import '../state/login_controller.dart';
import '../providers/data_providers.dart';

class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.asData?.value != null;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text(
          'São Paulo Stock Sync',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isLoggedIn) const _UserMenu(),
        ],
      ),
      drawer: Drawer(
        elevation: 6,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Center(
                child: Text(
                  'Menu Principal',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _navItem(context, '/', 'Dashboard', Icons.dashboard),
            _navItem(context, '/materiais', 'Materiais', Icons.inventory_2),
            _navItem(context, '/instrumentos', 'Instrumentos', Icons.build),
            _navItem(context, '/relatorios', 'Relatórios', Icons.bar_chart),
            _navItem(context, '/alertas', 'Alertas', Icons.warning_amber),
            // Mostra item de usuários apenas para gestores e admins
            // Usa Consumer para reagir a mudanças no provider
            Consumer(
              builder: (context, ref, child) {
                final isGestorOrAdmin = ref.watch(isGestorOrAdminProvider);
                final currentUserAsync = ref.watch(currentUserProvider);
                
                // Debug no console
                currentUserAsync.whenData((usuario) {
                  if (usuario != null) {
                    debugPrint('🔍 Menu - Usuário: ${usuario.email}, Role: ${usuario.role}, isGestorOrAdmin: $isGestorOrAdmin');
                  } else {
                    debugPrint('⚠️ Menu - Usuário não encontrado no Firestore');
                  }
                });
                
                // Widget de debug (remover depois)
                if (kDebugMode) {
                  return Column(
                    children: [
                      if (isGestorOrAdmin)
                        _navItem(context, '/usuarios', 'Usuários', Icons.people)
                      else
                        ListTile(
                          leading: Icon(Icons.people, color: Colors.grey[400]),
                          title: Text(
                            'Usuários (sem permissão)',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          subtitle: currentUserAsync.when(
                            data: (usuario) => Text(
                              usuario == null 
                                ? 'Usuário não encontrado no Firestore'
                                : 'Role: ${usuario.role}',
                              style: TextStyle(color: Colors.red[700], fontSize: 10),
                            ),
                            loading: () => const Text('Carregando...', style: TextStyle(fontSize: 10)),
                            error: (_, __) => const Text('Erro ao carregar', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                    ],
                  );
                }
                
                if (isGestorOrAdmin) {
                  return _navItem(context, '/usuarios', 'Usuários', Icons.people);
                }
                return const SizedBox.shrink();
              },
            ),
            _navItem(
                context, '/configuracoes', 'Configurações', Icons.settings),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
    );
  }

  Widget _navItem(
      BuildContext context, String route, String label, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(label),
      onTap: () {
        context.go(route);
        Navigator.of(context).pop();
      },
    );
  }
}

class _UserMenu extends ConsumerStatefulWidget {
  const _UserMenu();

  @override
  ConsumerState<_UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends ConsumerState<_UserMenu> {
  void _showMenu(BuildContext context, Offset offset) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<int>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(offset.dx, offset.dy, 200, 100),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<int>>[
        const PopupMenuItem<int>(
          value: 0,
          child: Text('Perfil'),
        ),
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Configurações'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(
          value: 2,
          child: Text(
            'Sair',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
      elevation: 6,
    );

    if (result == 2) {
      await ref.read(loginControllerProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTapDown: (details) => _showMenu(context, details.globalPosition),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'admin@metro.sp.gov.br',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
