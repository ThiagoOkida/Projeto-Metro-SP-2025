import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 1. Removi os imports de 'auth.dart' e 'login_controller.dart'
// import '../state/auth.dart';
// import '../state/login_controller.dart';

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
    final metroBlue = const Color(0xFF003C8A);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imagens/img_metro.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Card com padding para o logo
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 50),

                            // O código do seu 'Image.asset' (que estava dentro do card)
                            Image.asset(
                              "assets/imagens/logo.png",
                              height: 60,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      'Logo não encontrado!',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'Metro SP - Gestão de Processos',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _email,
                              decoration: const InputDecoration(
                                labelText: 'Login',
                                hintText: 'admin@metro.sp.gov.br',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Informe o e-mail'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                hintText: '••••••••••••',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              obscureText: _obscure,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Informe a senha'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.go('/');
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: metroBlue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Entrar',
                                  style: TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                context.go('/cadastro');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: metroBlue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Cadastre um novo contribuinte',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
