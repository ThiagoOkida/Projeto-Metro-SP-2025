import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/usuarios_repository.dart' as repo;
import '../providers/data_providers.dart';

/// Dialog para editar um usuário
class EditarUsuarioDialog extends ConsumerStatefulWidget {
  final repo.Usuario usuario;

  const EditarUsuarioDialog({
    super.key,
    required this.usuario,
  });

  @override
  ConsumerState<EditarUsuarioDialog> createState() => _EditarUsuarioDialogState();
}

class _EditarUsuarioDialogState extends ConsumerState<EditarUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _cargoController;
  late TextEditingController _setorController;
  late String _role;
  late bool _ativo;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _emailController = TextEditingController(text: widget.usuario.email);
    _telefoneController = TextEditingController(text: widget.usuario.telefone ?? '');
    _cargoController = TextEditingController(text: widget.usuario.cargo ?? '');
    _setorController = TextEditingController(text: widget.usuario.setor ?? '');
    _role = widget.usuario.role;
    _ativo = widget.usuario.ativo;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cargoController.dispose();
    _setorController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final usuarioAtualizado = repo.Usuario(
          id: widget.usuario.id,
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          telefone: _telefoneController.text.trim().isEmpty 
              ? null 
              : _telefoneController.text.trim(),
          cargo: _cargoController.text.trim().isEmpty 
              ? null 
              : _cargoController.text.trim(),
          setor: _setorController.text.trim().isEmpty 
              ? null 
              : _setorController.text.trim(),
          role: _role,
          ativo: _ativo,
          criadoEm: widget.usuario.criadoEm,
          ultimoAcesso: widget.usuario.ultimoAcesso,
        );

        final repository = ref.read(usuariosRepositoryProvider);
        await repository.atualizarUsuario(usuarioAtualizado);

        // Envia notificação por email para gestores e admins
        try {
          final emailService = ref.read(emailNotificationServiceProvider);
          await emailService.enviarNotificacao(
            assunto: 'Usuário Atualizado',
            mensagem: 'Os dados de um usuário foram atualizados no sistema.',
            tipoAlteracao: 'atualizar',
            entidade: 'usuario',
            detalhes: 'Usuário: ${usuarioAtualizado.nome} (${usuarioAtualizado.email})\n'
                'Perfil: ${usuarioAtualizado.role}\n'
                'Status: ${usuarioAtualizado.ativo ? "Ativo" : "Inativo"}',
          );
        } catch (e) {
          debugPrint('Erro ao enviar notificação por email: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar usuário: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Usuário'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o email.';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, informe um email válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                  hintText: '(11) 99999-9999',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cargoController,
                decoration: const InputDecoration(
                  labelText: 'Cargo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _setorController,
                decoration: const InputDecoration(
                  labelText: 'Setor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Perfil/Role *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                  DropdownMenuItem(value: 'gestor', child: Text('Gestor')),
                  DropdownMenuItem(value: 'contribuinte', child: Text('Contribuinte')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _role = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Usuário Ativo'),
                subtitle: const Text('Permite ou bloqueia o acesso ao sistema'),
                value: _ativo,
                onChanged: (value) {
                  setState(() {
                    _ativo = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _salvar,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

