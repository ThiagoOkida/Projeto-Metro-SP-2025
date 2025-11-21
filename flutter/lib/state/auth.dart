import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.asData?.value != null;
});

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Efetua login com email e senha usando Firebase Auth
  Future<UserCredential> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Salva o token de ID (opcional, para compatibilidade com código existente)
      if (userCredential.user != null) {
        final token = await userCredential.user!.getIdToken();
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Usuário não encontrado');
      } else if (e.code == 'wrong-password') {
        throw Exception('Senha incorreta');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email inválido');
      } else {
        throw Exception('Erro no login: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Cria uma nova conta com email e senha
  Future<UserCredential> cadastrar(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('A senha é muito fraca');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Este email já está em uso');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email inválido');
      } else {
        throw Exception('Erro no cadastro: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro ao cadastrar: $e');
    }
  }

  /// Salva dados do usuário no Firestore
  Future<void> salvarUsuarioNoFirestore(String uid, String nome, String email) async {
    try {
      await _firestore.collection('usuarios').doc(uid).set({
        'nome': nome,
        'email': email,
        'perfil': 'contribuinte',
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erro ao salvar dados do usuário: $e');
    }
  }

  /// Efetua logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  /// Retorna o usuário atual
  User? get currentUser => _auth.currentUser;

  /// Retorna o stream de mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
