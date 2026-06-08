import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Utilitário de segurança para senhas.
///
/// As senhas nunca são armazenadas em texto puro: guardamos apenas o hash
/// SHA-256 combinado com um "salt" aleatório gerado por usuário. Isso impede
/// que, mesmo com acesso ao banco, alguém recupere a senha original.
class PasswordHasher {
  PasswordHasher._();

  /// Gera um salt aleatório (string base64) para um novo usuário.
  static String generateSalt([int length = 16]) {
    final rng = Random.secure();
    final bytes = List<int>.generate(length, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Calcula o hash SHA-256 de (salt + senha).
  static String hash(String password, String salt) {
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }

  /// Confere se a senha informada corresponde ao hash armazenado.
  static bool verify({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    return hash(password, salt) == expectedHash;
  }
}
