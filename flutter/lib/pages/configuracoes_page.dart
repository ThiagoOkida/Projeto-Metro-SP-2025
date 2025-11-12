import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  // Variáveis para guardar o estado dos switches
  bool _modoEscuro = false;
  bool _notificacoesEmail = true;
  bool _alertasEstoque = true;
  bool _alertasCalibracao = true;
  bool _resumoDiario = false;
  bool _doisFatores = false;
  bool _registroAtividades = true;

  @override
  Widget build(BuildContext context) {
    final metroBlue = const Color(0xFF003C8A); // Cor Padrão

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TÍTULOS DA PÁGINA E BOTÃO SALVAR ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Coluna para os textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configurações',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Definir configurações gerais do sistema',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[700],
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16), // Espaço entre o texto e o botão
                  // Botão de Salvar Alterações
                  ElevatedButton.icon(
                    onPressed: () {
                      // Ação para Salvar
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Salvar Alterações',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: metroBlue, // Cor do Metrô
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- SEÇÕES DE CONFIGURAÇÃO ---
              // Vamos usar um LayoutBuilder para dividir em colunas em telas grandes
              LayoutBuilder(
                builder: (context, constraints) {
                  // Em telas largas, duas colunas
                  if (constraints.maxWidth > 1000) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildCardGeral(context),
                              const SizedBox(height: 16),
                              _buildCardNotificacoes(context),
                              const SizedBox(height: 16),
                              _buildCardSeguranca(context),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              _buildCardBancoDeDados(context),
                              const SizedBox(height: 16),
                              _buildCardEmail(context),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  
                  // Em telas estreitas, uma coluna só
                  return Column(
                    children: [
                      _buildCardGeral(context),
                      const SizedBox(height: 16),
                      _buildCardNotificacoes(context),
                      const SizedBox(height: 16),
                      _buildCardSeguranca(context),
                      const SizedBox(height: 16),
                      _buildCardBancoDeDados(context),
                      const SizedBox(height: 16),
                      _buildCardEmail(context),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO DE SEÇÕES ---

  Widget _buildCardGeral(BuildContext context) {
    return _SettingsCard(
      icon: Icons.settings_outlined,
      title: 'Configurações Gerais',
      subtitle: 'Configurações de aparência e funcionamento do sistema',
      child: Column(
        children: [
          _buildTextField(label: 'Nome da Empresa', initialValue: 'Empresa XYZ Ltda'),
          _buildDropdown(
            label: 'Idioma do Sistema',
            value: 'pt-br',
            items: [
              const DropdownMenuItem(value: 'pt-br', child: Text('Português (Brasil)')),
              const DropdownMenuItem(value: 'en-us', child: Text('Inglês (EUA)')),
            ],
          ),
          _buildDropdown(
            label: 'Fuso Horário',
            value: 'gmt-3',
            items: [
              const DropdownMenuItem(value: 'gmt-3', child: Text('América/São Paulo (GMT-3)')),
              const DropdownMenuItem(value: 'gmt-0', child: Text('UTC (GMT+0)')),
            ],
          ),
          _buildSwitchTile(
            title: 'Modo Escuro',
            subtitle: 'Ativar tema escuro automaticamente',
            value: _modoEscuro,
            onChanged: (val) => setState(() => _modoEscuro = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCardNotificacoes(BuildContext context) {
    return _SettingsCard(
      icon: Icons.notifications_outlined,
      title: 'Notificações',
      subtitle: 'Gerenciar como você recebe notificações',
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Notificações por Email',
            subtitle: 'Receber alertas importantes por email',
            value: _notificacoesEmail,
            onChanged: (val) => setState(() => _notificacoesEmail = val),
          ),
          _buildSwitchTile(
            title: 'Alertas de Estoque Baixo',
            subtitle: 'Notificar quando materiais atingirem o nível crítico',
            value: _alertasEstoque,
            onChanged: (val) => setState(() => _alertasEstoque = val),
          ),
          _buildSwitchTile(
            title: 'Alertas de Calibração',
            subtitle: 'Notificar sobre instrumentos próximos ao vencimento',
            value: _alertasCalibracao,
            onChanged: (val) => setState(() => _alertasCalibracao = val),
          ),
          _buildSwitchTile(
            title: 'Resumo Diário',
            subtitle: 'Receber relatório diário de atividades',
            value: _resumoDiario,
            onChanged: (val) => setState(() => _resumoDiario = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSeguranca(BuildContext context) {
    return _SettingsCard(
      icon: Icons.security_outlined,
      title: 'Segurança',
      subtitle: 'Configurações de segurança e acesso',
      child: Column(
        children: [
           _buildDropdown(
            label: 'Tempo de Sessão (minutos)',
            value: '30',
            items: [
              const DropdownMenuItem(value: '15', child: Text('15 minutos')),
              const DropdownMenuItem(value: '30', child: Text('30 minutos')),
              const DropdownMenuItem(value: '60', child: Text('60 minutos')),
              const DropdownMenuItem(value: 'nunca', child: Text('Nunca expirar')),
            ],
          ),
           _buildSwitchTile(
            title: 'Autenticação em Dois Fatores',
            subtitle: 'Exigir um segundo fator de segurança no login',
            value: _doisFatores,
            onChanged: (val) => setState(() => _doisFatores = val),
          ),
           _buildSwitchTile(
            title: 'Registro de Atividades',
            subtitle: 'Manter histórico de todas as ações realizadas',
            value: _registroAtividades,
            onChanged: (val) => setState(() => _registroAtividades = val),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBancoDeDados(BuildContext context) {
    return _SettingsCard(
      icon: Icons.storage_outlined,
      title: 'Banco de Dados',
      subtitle: 'Configurações de backup e manutenção',
      child: Column(
        children: [
          _buildDropdown(
            label: 'Frequência de Backup',
            value: 'diario',
            items: [
              const DropdownMenuItem(value: 'diario', child: Text('Diário')),
              const DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
            ],
          ),
          _buildTextField(label: 'Retenção de Dados (dias)', initialValue: '365'),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003C8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text('Fazer Backup Agora'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF003C8A),
                  side: const BorderSide(color: Color(0xFF003C8A)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text('Restaurar Backup'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCardEmail(BuildContext context) {
    return _SettingsCard(
      icon: Icons.mail_outline,
      title: 'Configurações de Email',
      subtitle: 'Configurações do servidor SMTP para envio de emails',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildTextField(label: 'Servidor SMTP', initialValue: 'smtp.exemplo.com'),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildTextField(label: 'Porta', initialValue: '587'),
              ),
            ],
          ),
          _buildTextField(label: 'Usuário', initialValue: 'usuario@exemplo.com'),
          _buildTextField(label: 'Senha', initialValue: '••••••••••••', obscureText: true),
          const SizedBox(height: 16),
           Align(
             alignment: Alignment.centerLeft,
             child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text('Testar Conexão'),
              ),
           ),
        ],
      ),
    );
  }

  // --- WIDGETS DE FORMULÁRIO (REUTILIZÁVEIS) ---

  /// Um SwitchListTile padronizado
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF003C8A),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Um TextField padronizado
  Widget _buildTextField({
    required String label,
    String initialValue = '',
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  /// Um Dropdown padronizado
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: (val) {},
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}


// --- WIDGET DE SUPORTE (PRIVADO) ---

/// Um "molde" de Card para as seções de configuração
class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do Card
            Row(
              children: [
                Icon(icon, color: Colors.grey[700], size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32, thickness: 0.5),
            child,
          ],
        ),
      ),
    );
  }
}