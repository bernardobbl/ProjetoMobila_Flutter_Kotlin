import 'package:flutter_test/flutter_test.dart';
import 'package:finanflow/core/utils/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
    test('o mesmo salt e senha produzem sempre o mesmo hash', () {
      final salt = PasswordHasher.generateSalt();
      final h1 = PasswordHasher.hash('minhaSenha123', salt);
      final h2 = PasswordHasher.hash('minhaSenha123', salt);
      expect(h1, equals(h2));
    });

    test('salts diferentes geram hashes diferentes para a mesma senha', () {
      final h1 = PasswordHasher.hash('senha', 'saltA');
      final h2 = PasswordHasher.hash('senha', 'saltB');
      expect(h1, isNot(equals(h2)));
    });

    test('o hash nunca é igual à senha em texto puro', () {
      const senha = 'segredo';
      final hash = PasswordHasher.hash(senha, 'salt');
      expect(hash, isNot(equals(senha)));
      expect(hash.length, greaterThan(senha.length));
    });

    test('verify aceita a senha correta e rejeita a errada', () {
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hash('correta', salt);
      expect(
        PasswordHasher.verify(password: 'correta', salt: salt, expectedHash: hash),
        isTrue,
      );
      expect(
        PasswordHasher.verify(password: 'errada', salt: salt, expectedHash: hash),
        isFalse,
      );
    });

    test('generateSalt produz valores diferentes a cada chamada', () {
      final a = PasswordHasher.generateSalt();
      final b = PasswordHasher.generateSalt();
      expect(a, isNot(equals(b)));
      expect(a, isNotEmpty);
    });
  });
}
