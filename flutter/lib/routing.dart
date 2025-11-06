import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/materiais_page.dart';
import 'pages/instrumentos_page.dart';
import 'pages/relatorios_page.dart';
import 'pages/alertas_page.dart';
import 'pages/usuarios_page.dart';
import 'pages/configuracoes_page.dart';
import 'shell/shell_scaffold.dart';
import 'pages/cadastro_page.dart'; // <--- Importação que você já tinha

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),

    // Rota de cadastro adicionada aqui, fora do ShellRoute
    GoRoute(
      path: '/cadastro',
      builder: (context, state) => CadastroPage(),
    ),

    ShellRoute(
      builder: (context, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/materiais', builder: (_, __) => const MateriaisPage()),
        GoRoute(
            path: '/instrumentos',
            builder: (_, __) => const InstrumentosPage()),
        GoRoute(
            path: '/relatorios', builder: (_, __) => const RelatoriosPage()),
        GoRoute(path: '/alertas', builder: (_, __) => const AlertasPage()),
        GoRoute(path: '/usuarios', builder: (_, __) => const UsuariosPage()),
        GoRoute(
            path: '/configuracoes',
            builder: (_, __) => const ConfiguracoesPage()),
      ],
    ),
  ],
);