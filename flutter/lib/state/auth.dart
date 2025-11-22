import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

// Provider que observa o estado de autenticação do Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  try {
    return FirebaseAuth.instance.authStateChanges();
  } catch (e) {
    // Se o Firebase não estiver inicializado, retorna um stream vazio
    // Isso evita que o app trave com tela branca
    debugPrint('⚠️ Firebase Auth não disponível: $e');
    return Stream.value(null);
  }
});

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepository();

  /// Faz login com email e senha usando Firebase Auth
  Future<UserCredential> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Credenciais inválidas');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email inválido');
      } else {
        throw Exception('Erro ao fazer login: ${e.message}');
      }
    }
  }

  /// Cria uma nova conta com email e senha usando Firebase Auth
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
        throw Exception('Erro ao cadastrar: ${e.message}');
      }
    }
  }

  /// Salva os dados do usuário no Firestore
  Future<void> salvarUsuarioNoFirestore(
    String uid,
    String nome,
    String email,
  ) async {
    try {
      await _firestore.collection('usuarios').doc(uid).set({
        'nome': nome,
        'email': email,
        'perfil': 'contribuinte',
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao salvar usuário no Firestore: $e');
    }
  }

  /// Faz logout do Firebase Auth
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }
}
