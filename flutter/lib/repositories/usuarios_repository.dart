import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Usuário
class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? cargo;
  final String? setor;
  final String role; // 'admin', 'gestor', 'contribuinte'
  final bool ativo;
  final DateTime? ultimoAcesso;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.cargo,
    this.setor,
    this.role = 'contribuinte',
    this.ativo = true,
    this.ultimoAcesso,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Converte ativo para bool, tratando casos onde pode vir como string
    bool ativo = true;
    if (data['ativo'] != null) {
      if (data['ativo'] is bool) {
        ativo = data['ativo'] as bool;
      } else if (data['ativo'] is String) {
        ativo = (data['ativo'] as String).toLowerCase() == 'true';
      }
    }
    
    return Usuario(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      telefone: data['telefone'],
      cargo: data['cargo'],
      setor: data['setor'],
      role: data['role'] ?? data['perfil'] ?? 'contribuinte',
      ativo: ativo,
      ultimoAcesso: data['ultimoAcesso']?.toDate(),
      criadoEm: data['criadoEm']?.toDate(),
      atualizadoEm: data['atualizadoEm']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cargo': cargo,
      'setor': setor,
      'role': role,
      'ativo': ativo,
      'ultimoAcesso': ultimoAcesso,
      'criadoEm': criadoEm,
      'atualizadoEm': atualizadoEm,
    };
  }

  String get iniciais {
    final partes = nome.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nome.substring(0, nome.length > 2 ? 2 : nome.length).toUpperCase();
  }
}

/// Repositório para gerenciar usuários no Firestore
class UsuariosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca todos os usuários
  Stream<List<Usuario>> getUsuarios() {
    return _firestore
        .collection('usuarios')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Usuario.fromFirestore(doc))
            .toList());
  }

  /// Busca um usuário por ID
  Future<Usuario?> getUsuarioById(String id) async {
    final doc = await _firestore.collection('usuarios').doc(id).get();
    if (doc.exists) {
      return Usuario.fromFirestore(doc);
    }
    return null;
  }

  /// Atualiza o último acesso do usuário
  Future<void> atualizarUltimoAcesso(String userId) async {
    await _firestore.collection('usuarios').doc(userId).update({
      'ultimoAcesso': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  /// Atualiza os dados de um usuário
  Future<void> atualizarUsuario(Usuario usuario) async {
    await _firestore.collection('usuarios').doc(usuario.id).update({
      'nome': usuario.nome,
      'email': usuario.email,
      'telefone': usuario.telefone,
      'cargo': usuario.cargo,
      'setor': usuario.setor,
      'role': usuario.role,
      'perfil': usuario.role, // Mantém compatibilidade
      'ativo': usuario.ativo,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  /// Deleta um usuário do Firestore
  Future<void> deletarUsuario(String userId) async {
    await _firestore.collection('usuarios').doc(userId).delete();
  }
}

