import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/usuarios_repository.dart' as repo;
import '../providers/data_providers.dart';
import '../widgets/editar_usuario_dialog.dart';

class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key});

  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuariosProvider);
    final isGestorOrAdmin = ref.watch(isGestorOrAdminProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    currentUserAsync.whenData((usuario) {
      if (usuario != null) {
        debugPrint('🔍 Usuário atual: ${usuario.nome} (${usuario.email})');
        debugPrint('🔍 Role/Perfil: ${usuario.role}');
        debugPrint('🔍 isGestorOrAdmin: $isGestorOrAdmin');
      } else {
        debugPrint('⚠️ Usuário não encontrado no Firestore');
      }
    });

    if (!isGestorOrAdmin) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Acesso Negado',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Você não tem permissão para acessar esta página.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apenas gestores e administradores podem visualizar e gerenciar usuários.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  currentUserAsync.when(
                    data: (usuario) {
                      if (usuario == null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Card(
                            color: Colors.orange[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(Icons.warning, color: Colors.orange[700]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Usuário não encontrado no Firestore',
                                    style: TextStyle(
                                      color: Colors.orange[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Verifique se o documento do usuário existe na coleção "usuarios" com o UID do Firebase Auth.',
                                    style: TextStyle(
                                      color: Colors.orange[800],
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.blue[700]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Informações do Usuário',
                                      style: TextStyle(
                                        color: Colors.blue[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Email: ${usuario.email}',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Nome: ${usuario.nome}',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Role/Perfil: ${usuario.role}',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Para ter acesso, o campo "role" ou "perfil" deve ser "admin" ou "gestor".',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Card(
                        color: Colors.red[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Erro ao carregar dados do usuário: $error',
                            style: TextStyle(color: Colors.red[800], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gerenciamento de Usuários',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Controle de acesso e perfis de usuário',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Novo Usuário'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            usuariosAsync.when(
              data: (usuarios) {
                final total = usuarios.length;
                final ativos = usuarios.where((u) => u.ativo).length;
                final inativos = usuarios.where((u) => !u.ativo).length;

                return _buildSummaryCards(context, total, ativos, inativos);
              },
              loading: () => _buildSummaryCardsLoading(context),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 24),
            usuariosAsync.when(
              data: (usuarios) {
                final filtrados = _filtrarUsuarios(usuarios);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Lista de Usuários',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar usuários...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTabelaUsuarios(context, filtrados),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Erro ao carregar usuários: $error',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<repo.Usuario> _filtrarUsuarios(List<repo.Usuario> usuarios) {
    if (_searchController.text.isEmpty) return usuarios;
    
    final busca = _searchController.text.toLowerCase();
    return usuarios.where((u) {
      return u.nome.toLowerCase().contains(busca) ||
          u.email.toLowerCase().contains(busca) ||
          (u.cargo?.toLowerCase().contains(busca) ?? false) ||
          (u.setor?.toLowerCase().contains(busca) ?? false);
    }).toList();
  }

  Widget _buildAcoesUsuario(BuildContext context, repo.Usuario usuario) {
    final isGestorOrAdmin = ref.watch(isGestorOrAdminProvider);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          tooltip: 'Editar usuário',
          onPressed: () => _editarUsuario(context, usuario),
        ),
        if (isGestorOrAdmin)
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            tooltip: 'Deletar usuário',
            onPressed: () => _deletarUsuario(context, usuario),
          ),
      ],
    );
  }

  Future<void> _editarUsuario(BuildContext context, repo.Usuario usuario) async {
    final result = await showDialog(
      context: context,
      builder: (context) => EditarUsuarioDialog(usuario: usuario),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deletarUsuario(BuildContext context, repo.Usuario usuario) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tem certeza que deseja deletar o usuário:'),
            const SizedBox(height: 8),
            Text(
              usuario.nome,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              usuario.email,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita. O usuário será removido permanentemente do sistema.',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmacao == true && mounted) {
      try {
        final repository = ref.read(usuariosRepositoryProvider);
        final usuarioNome = usuario.nome;
        final usuarioEmail = usuario.email;
        await repository.deletarUsuario(usuario.id);
        try {
          final emailService = ref.read(emailNotificationServiceProvider);
          await emailService.enviarNotificacao(
            assunto: 'Usuário Deletado',
            mensagem: 'Um usuário foi removido do sistema.',
            tipoAlteracao: 'deletar',
            entidade: 'usuario',
            detalhes: 'Usuário deletado: $usuarioNome ($usuarioEmail)',
          );
        } catch (e) {
          debugPrint('Erro ao enviar notificação por email: $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usuário "$usuarioNome" deletado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao deletar usuário: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildSummaryCards(BuildContext context, int total, int ativos, int inativos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 900) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.8, 
          children: [
            _SummaryCard(
              title: 'Total de Usuários',
              value: total.toString(),
              subtitle: 'Cadastrados no sistema',
              icon: Icons.people_outline,
              color: Colors.blue,
            ),
            _SummaryCard(
              title: 'Usuários Ativos',
              value: ativos.toString(),
              subtitle: 'Com acesso liberado',
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            _SummaryCard(
              title: 'Usuários Inativos',
              value: inativos.toString(),
              subtitle: 'Sem acesso ao sistema',
              icon: Icons.cancel_outlined,
              color: Colors.grey,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCardsLoading(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth < 900) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          children: List.generate(3, (index) => const _SummaryCardLoading()),
        );
      },
    );
  }

  Widget _buildTabelaUsuarios(BuildContext context, List<repo.Usuario> usuarios) {
    if (usuarios.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum usuário encontrado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 24.0,
                horizontalMargin: 16.0,
                headingRowHeight: 56.0,
                dataRowMinHeight: 64.0,
                dataRowMaxHeight: 80.0,
                columns: const [
                  DataColumn(label: Text('Usuário', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Contato', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cargo/Setor', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Último Acesso', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
          rows: usuarios.map((usuario) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Text(
                          usuario.iniciais,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            usuario.nome,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            usuario.email,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(usuario.email, style: const TextStyle(fontSize: 12)),
                      if (usuario.telefone != null)
                        Text(
                          usuario.telefone!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (usuario.cargo != null)
                        Text(usuario.cargo!, style: const TextStyle(fontSize: 12)),
                      if (usuario.setor != null)
                        Text(
                          usuario.setor!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: usuario.ativo
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: usuario.ativo
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      usuario.ativo ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        color: usuario.ativo ? Colors.blue : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  usuario.ultimoAcesso != null
                      ? Text(
                          '${usuario.ultimoAcesso!.day.toString().padLeft(2, '0')}/${usuario.ultimoAcesso!.month.toString().padLeft(2, '0')}, ${usuario.ultimoAcesso!.hour.toString().padLeft(2, '0')}:${usuario.ultimoAcesso!.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12),
                        )
                      : const Text('-', style: TextStyle(fontSize: 12)),
                ),
                DataCell(
                  _buildAcoesUsuario(context, usuario),
                ),
              ],
            );
          }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCardLoading extends StatelessWidget {
  const _SummaryCardLoading();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
