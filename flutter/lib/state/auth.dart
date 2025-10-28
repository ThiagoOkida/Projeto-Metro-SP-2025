import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final authStateProvider = StateProvider<bool>((ref) => false);
class AuthRepository {
  final String baseUrl;
  AuthRepository({String? baseUrl}): baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:8080');
  Future<String> login(String email, String password) async {
    final resp = await http.post(Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['token'] as String;
    }
    throw Exception('Login inválido');
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
class LoginController extends StateNotifier<AsyncValue<void>> {
  LoginController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final token = await ref.read(authRepositoryProvider).login(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      ref.read(authStateProvider.notifier).state = true;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.read(authStateProvider.notifier).state = false;
  }
}
final loginControllerProvider = StateNotifierProvider<LoginController, AsyncValue<void>>(
  (ref) => LoginController(ref),
);