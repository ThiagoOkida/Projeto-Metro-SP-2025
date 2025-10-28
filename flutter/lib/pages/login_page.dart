import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth.dart';
import 'package:go_router/go_router.dart';
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'admin@metro.sp.gov.br');
  final _password = TextEditingController(text: 'admin123');
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('São Paulo Stock Sync', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Acesse sua conta', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      validator: (v) => (v==null || v.isEmpty) ? 'Informe o e-mail' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(()=>_obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      validator: (v) => (v==null || v.isEmpty) ? 'Informe a senha' : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: loginState.isLoading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          await ref.read(loginControllerProvider.notifier).login(_email.text, _password.text);
                          if (mounted && !ref.read(loginControllerProvider).hasError) {
                            context.go('/');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha no login')));
                          }
                        }
                      },
                      child: loginState.isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Entrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}