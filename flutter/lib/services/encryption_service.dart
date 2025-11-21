import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Serviço para encriptação e desencriptação de dados sensíveis
///
/// Usa AES-256 para encriptação simétrica
/// A chave deve estar no arquivo .env como ENCRYPTION_KEY
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  late final Encrypter _encrypter;
  bool _initialized = false;

  /// Inicializa o serviço de encriptação
  /// Deve ser chamado após carregar o .env
  void initialize() {
    if (_initialized) return;

    final encryptionKey = dotenv.env['ENCRYPTION_KEY'];

    if (encryptionKey == null || encryptionKey.isEmpty) {
      throw Exception('ENCRYPTION_KEY não encontrada no .env. '
          'Gere uma chave de 32 caracteres e adicione ao .env');
    }

    if (encryptionKey.length != 32) {
      throw Exception('ENCRYPTION_KEY deve ter exatamente 32 caracteres. '
          'Atual: ${encryptionKey.length} caracteres');
    }

    final key = Key.fromBase64(base64.encode(utf8.encode(encryptionKey)));
    _encrypter = Encrypter(AES(key));
    _initialized = true;
  }

  /// Encripta um texto
  ///
  /// Exemplo:
  /// ```dart
  /// final encrypted = encryptionService.encrypt('dado sensível');
  /// ```
  String encrypt(String plainText) {
    if (!_initialized) {
      throw Exception(
          'EncryptionService não foi inicializado. Chame initialize() primeiro.');
    }

    try {
      final iv = IV.fromLength(16);
      final encrypted = _encrypter.encrypt(plainText, iv: iv);
      // Retorna IV + texto encriptado em base64
      return base64.encode(iv.bytes + encrypted.bytes);
    } catch (e) {
      throw Exception('Erro ao encriptar: $e');
    }
  }

  /// Desencripta um texto
  ///
  /// Exemplo:
  /// ```dart
  /// final decrypted = encryptionService.decrypt(encryptedString);
  /// ```
  String decrypt(String encryptedText) {
    if (!_initialized) {
      throw Exception(
          'EncryptionService não foi inicializado. Chame initialize() primeiro.');
    }

    try {
      final data = base64.decode(encryptedText);
      final iv = IV(data.sublist(0, 16));
      final encrypted = Encrypted(data.sublist(16));
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Erro ao desencriptar: $e');
    }
  }

  /// Encripta dados JSON
  ///
  /// Exemplo:
  /// ```dart
  /// final data = {'email': 'user@example.com', 'token': 'abc123'};
  /// final encrypted = encryptionService.encryptJson(data);
  /// ```
  String encryptJson(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return encrypt(jsonString);
  }

  /// Desencripta dados JSON
  ///
  /// Exemplo:
  /// ```dart
  /// final decrypted = encryptionService.decryptJson(encryptedString);
  /// print(decrypted['email']);
  /// ```
  Map<String, dynamic> decryptJson(String encryptedText) {
    final jsonString = decrypt(encryptedText);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Verifica se o serviço está inicializado
  bool get isInitialized => _initialized;
}
