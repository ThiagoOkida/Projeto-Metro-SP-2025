import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth.dart';

class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'São Paulo Stock Sync',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (loggedIn) const _UserMenu(),
        ],
      ),
      drawer: Drawer(
        elevation: 6,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1565C0)),
              child: Center(
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
            _navItem(context, '/usuarios', 'Usuários', Icons.people),
            _navItem(context, '/configuracoes', 'Configurações', Icons.settings),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
    );
  }

  Widget _navItem(BuildContext context, String route, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo.shade600),
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
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: const [
              Icon(Icons.person_outline, color: Colors.indigo),
              SizedBox(width: 8),
              Text(
                'admin@metro.sp.gov.br',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.indigo),
            ],
          ),
        ),
      ),
    );
  }
}
