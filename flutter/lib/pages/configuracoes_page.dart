import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/configuracoes_repository.dart';
import '../providers/data_providers.dart';
import '../providers/theme_provider.dart';

class ConfiguracoesPage extends ConsumerStatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  ConsumerState<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends ConsumerState<ConfiguracoesPage> {
  final _nomeEmpresaController = TextEditingController();
  final _smtpServerController = TextEditingController();
  final _smtpPortController = TextEditingController();
  final _smtpUserController = TextEditingController();
  final _smtpPasswordController = TextEditingController();
  final _retencaoController = TextEditingController();

  String _idioma = 'Português (Brasil)';
  String _fusoHorario = 'América/São Paulo (GMT-3)';
  String _tempoSessao = '30 minutos';
  String _frequenciaBackup = 'Diário';
  
  bool _modoEscuro = false;
  bool _notificacoesEmail = true;
  bool _alertasEstoqueBaixo = true;
  bool _alertasCalibracao = true;
  bool _resumoDiario = false;
  bool _autenticacaoDoisFatores = false;
  bool _registroAtividades = true;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nomeEmpresaController.dispose();
    _smtpServerController.dispose();
    _smtpPortController.dispose();
    _smtpUserController.dispose();
    _smtpPasswordController.dispose();
    _retencaoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    setState(() => _isLoading = true);
    try {
      final config = await ref.read(configuracoesRepositoryProvider).getConfiguracoes();
      final themeMode = ref.read(themeModeProvider);
      
      setState(() {
        _nomeEmpresaController.text = config.nomeEmpresa;
        _idioma = config.idioma;
        _fusoHorario = config.fusoHorario;
        // Sincroniza com o provider de tema
        _modoEscuro = themeMode == ThemeMode.dark;
        _notificacoesEmail = config.notificacoesEmail;
        _alertasEstoqueBaixo = config.alertasEstoqueBaixo;
        _alertasCalibracao = config.alertasCalibracao;
        _resumoDiario = config.resumoDiario;
        _tempoSessao = config.tempoSessao;
        _autenticacaoDoisFatores = config.autenticacaoDoisFatores;
        _registroAtividades = config.registroAtividades;
        _frequenciaBackup = config.frequenciaBackup;
        _retencaoController.text = config.retencaoDados.toString();
        _smtpServerController.text = config.smtpServer;
        _smtpPortController.text = config.smtpPort;
        _smtpUserController.text = config.smtpUser;
        _smtpPasswordController.text = config.smtpPassword.isNotEmpty ? '********' : '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar configurações: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarConfiguracoes() async {
    setState(() => _isSaving = true);
    try {
      final config = Configuracoes(
        nomeEmpresa: _nomeEmpresaController.text,
        idioma: _idioma,
        fusoHorario: _fusoHorario,
        modoEscuro: _modoEscuro,
        notificacoesEmail: _notificacoesEmail,
        alertasEstoqueBaixo: _alertasEstoqueBaixo,
        alertasCalibracao: _alertasCalibracao,
        resumoDiario: _resumoDiario,
        tempoSessao: _tempoSessao,
        autenticacaoDoisFatores: _autenticacaoDoisFatores,
        registroAtividades: _registroAtividades,
        frequenciaBackup: _frequenciaBackup,
        retencaoDados: int.tryParse(_retencaoController.text) ?? 365,
        smtpServer: _smtpServerController.text,
        smtpPort: _smtpPortController.text,
        smtpUser: _smtpUserController.text,
        smtpPassword: _smtpPasswordController.text == '********' 
            ? '' // Não atualiza se não foi alterado
            : _smtpPasswordController.text,
      );

      await ref.read(configuracoesRepositoryProvider).salvarConfiguracoes(config);
      
      // Sincroniza o tema com o provider
      final themeNotifier = ref.read(themeModeProvider.notifier);
      await themeNotifier.setThemeMode(
        _modoEscuro ? ThemeMode.dark : ThemeMode.light,
      );
      
      // Envia notificação por email para gestores e admins
      try {
        final emailService = ref.read(emailNotificationServiceProvider);
        await emailService.enviarNotificacao(
          assunto: 'Configurações Atualizadas',
          mensagem: 'As configurações do sistema foram atualizadas.',
          tipoAlteracao: 'atualizar',
          entidade: 'configuracao',
          detalhes: 'Nome da Empresa: ${config.nomeEmpresa}\n'
              'Idioma: ${config.idioma}\n'
              'Fuso Horário: ${config.fusoHorario}',
        );
      } catch (e) {
        debugPrint('Erro ao enviar notificação por email: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurações salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar configurações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _testarConexaoSMTP() async {
    setState(() => _isSaving = true);
    try {
      final sucesso = await ref.read(configuracoesRepositoryProvider).testarConexaoSMTP(
        _smtpServerController.text,
        _smtpPortController.text,
        _smtpUserController.text,
        _smtpPasswordController.text == '********' ? '' : _smtpPasswordController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sucesso 
                ? 'Teste de conexão realizado com sucesso!'
                : 'Falha ao conectar. Verifique as credenciais.'),
            backgroundColor: sucesso ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao testar conexão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com título e botão
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configurações',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gerencie as configurações do sistema',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _salvarConfiguracoes,
                  icon: _isSaving 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Salvar Alterações'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Seções de Configurações
            _buildSecaoConfiguracoesGerais(context),
            const SizedBox(height: 24),
            _buildSecaoNotificacoes(context),
            // Seções restritas a gestores e admins
            if (ref.watch(isGestorOrAdminProvider)) ...[
              const SizedBox(height: 24),
              _buildSecaoSeguranca(context),
              const SizedBox(height: 24),
              _buildSecaoBancoDados(context),
              const SizedBox(height: 24),
              _buildSecaoEmail(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoConfiguracoesGerais(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações Gerais',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Personalize a aparência e comportamento do sistema',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nomeEmpresaController,
              decoration: const InputDecoration(
                labelText: 'Nome da Empresa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _idioma,
              decoration: const InputDecoration(
                labelText: 'Idioma do Sistema',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Português (Brasil)', child: Text('Português (Brasil)')),
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Español', child: Text('Español')),
              ],
              onChanged: (value) => setState(() => _idioma = value ?? _idioma),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _fusoHorario,
              decoration: const InputDecoration(
                labelText: 'Fuso Horário',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'América/São Paulo (GMT-3)',
                  child: Text('América/São Paulo (GMT-3)'),
                ),
                DropdownMenuItem(
                  value: 'América/Manaus (GMT-4)',
                  child: Text('América/Manaus (GMT-4)'),
                ),
                DropdownMenuItem(
                  value: 'América/Rio_Branco (GMT-5)',
                  child: Text('América/Rio_Branco (GMT-5)'),
                ),
              ],
              onChanged: (value) => setState(() => _fusoHorario = value ?? _fusoHorario),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final themeMode = ref.watch(themeModeProvider);
                    final isDark = themeMode == ThemeMode.dark;
                    
                    return Switch(
                      value: isDark,
                      onChanged: (value) async {
                        // Aplica o tema em tempo real
                        final themeNotifier = ref.read(themeModeProvider.notifier);
                        await themeNotifier.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                        // Atualiza o estado local também
                        setState(() => _modoEscuro = value);
                      },
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modo Escuro'),
                      Text(
                        'Ativar tema escuro automaticamente',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoNotificacoes(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificações',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gerencie como você recebe notificações',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            _buildSwitchItem(
              'Notificações por Email',
              'Receber alertas importantes por email',
              _notificacoesEmail,
              (value) => setState(() => _notificacoesEmail = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Alertas de Estoque Baixo',
              'Notificar quando materiais estiverem em nível crítico',
              _alertasEstoqueBaixo,
              (value) => setState(() => _alertasEstoqueBaixo = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Alertas de Calibração',
              'Notificar sobre instrumentos próximos ao vencimento',
              _alertasCalibracao,
              (value) => setState(() => _alertasCalibracao = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Resumo Diário',
              'Receber relatório diário de atividades',
              _resumoDiario,
              (value) => setState(() => _resumoDiario = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoSeguranca(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Segurança',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configurações de segurança e acesso',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _tempoSessao,
              decoration: const InputDecoration(
                labelText: 'Tempo de Sessão (minutos)',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '15 minutos', child: Text('15 minutos')),
                DropdownMenuItem(value: '30 minutos', child: Text('30 minutos')),
                DropdownMenuItem(value: '60 minutos', child: Text('60 minutos')),
                DropdownMenuItem(value: '120 minutos', child: Text('120 minutos')),
              ],
              onChanged: (value) => setState(() => _tempoSessao = value ?? _tempoSessao),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Autenticação em Dois Fatores',
              'Adicionar camada extra de segurança no login',
              _autenticacaoDoisFatores,
              (value) => setState(() => _autenticacaoDoisFatores = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchItem(
              'Registro de Atividades',
              'Manter histórico de todas as ações realizadas',
              _registroAtividades,
              (value) => setState(() => _registroAtividades = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoBancoDados(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Banco de Dados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configurações de backup e manutenção',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _frequenciaBackup,
              decoration: const InputDecoration(
                labelText: 'Frequência de Backup',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Diário', child: Text('Diário')),
                DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
                DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
              ],
              onChanged: (value) => setState(() => _frequenciaBackup = value ?? _frequenciaBackup),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _retencaoController,
              decoration: const InputDecoration(
                labelText: 'Retenção de Dados (dias)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup iniciado...')),
                    );
                  },
                  icon: const Icon(Icons.backup),
                  label: const Text('Fazer Backup Agora'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                    );
                  },
                  icon: const Icon(Icons.restore),
                  label: const Text('Restaurar Backup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoEmail(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações de Email',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure o servidor SMTP para envio de emails',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _smtpServerController,
              decoration: const InputDecoration(
                labelText: 'Servidor SMTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _smtpPortController,
              decoration: const InputDecoration(
                labelText: 'Porta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _smtpUserController,
              decoration: const InputDecoration(
                labelText: 'Usuário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _smtpPasswordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _testarConexaoSMTP,
              icon: _isSaving 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle),
              label: const Text('Testar Conexão'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
