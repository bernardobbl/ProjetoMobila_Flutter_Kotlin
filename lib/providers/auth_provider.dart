import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/database_helper.dart';
import '../core/utils/password_hasher.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  UserModel? _currentUser;
  String? _error;

  AuthProvider(this._prefs) {
    _loadSavedUser();
  }

  UserModel? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Future<void> _loadSavedUser() async {
    final userId = _prefs.getInt('user_id');
    if (userId == null) return;
    _currentUser = await DatabaseHelper.instance.getUserById(userId);
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _error = null;
    try {
      final existing = await DatabaseHelper.instance.getUserByEmail(email);
      if (existing != null) {
        _error = 'Este e-mail já está cadastrado.';
        notifyListeners();
        return false;
      }

      // Nunca guardamos a senha em texto puro: apenas o hash + salt.
      final salt = PasswordHasher.generateSalt();
      final hashed = PasswordHasher.hash(password, salt);

      final user = UserModel(name: name, email: email, password: hashed, salt: salt);
      final id = await DatabaseHelper.instance.insertUser(user);
      _currentUser = UserModel(
        id: id,
        name: name,
        email: email,
        password: hashed,
        salt: salt,
      );
      await _prefs.setInt('user_id', id);
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('Erro register: $e\n$st');
      // Mensagem amigável para o usuário, sem expor detalhes técnicos.
      _error = 'Não foi possível concluir o cadastro. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _error = null;
    try {
      final user = await DatabaseHelper.instance.getUserByEmail(email);

      if (user == null) {
        _error = 'E-mail não encontrado.';
        notifyListeners();
        return false;
      }

      final bool senhaCorreta;
      if (user.isLegacy) {
        // Conta antiga (senha em texto puro). Confere e, se bater, migra para hash.
        senhaCorreta = user.password == password;
        if (senhaCorreta) {
          await _migrateLegacyPassword(user, password);
        }
      } else {
        senhaCorreta = PasswordHasher.verify(
          password: password,
          salt: user.salt!,
          expectedHash: user.password,
        );
      }

      if (!senhaCorreta) {
        _error = 'Senha incorreta.';
        notifyListeners();
        return false;
      }

      _currentUser = await DatabaseHelper.instance.getUserById(user.id!) ?? user;
      await _prefs.setInt('user_id', user.id!);
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('Erro login: $e\n$st');
      _error = 'Não foi possível entrar. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  /// Converte uma senha legada (texto puro) para hash + salt no primeiro login.
  Future<void> _migrateLegacyPassword(UserModel user, String password) async {
    final salt = PasswordHasher.generateSalt();
    final hashed = PasswordHasher.hash(password, salt);
    final migrated = user.copyWith(password: hashed, salt: salt);
    await DatabaseHelper.instance.updateUser(migrated);
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _error = null;
    try {
      final user = _currentUser!;
      final valid = user.isLegacy
          ? user.password == oldPassword
          : PasswordHasher.verify(
              password: oldPassword,
              salt: user.salt!,
              expectedHash: user.password,
            );
      if (!valid) {
        _error = 'Senha atual incorreta.';
        notifyListeners();
        return false;
      }
      final salt = PasswordHasher.generateSalt();
      final hashed = PasswordHasher.hash(newPassword, salt);
      final updated = user.copyWith(password: hashed, salt: salt);
      await DatabaseHelper.instance.updateUser(updated);
      _currentUser = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Não foi possível alterar a senha. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfilePhoto(String? sourcePath) async {
    final user = _currentUser!;
    String? destPath;

    if (sourcePath != null) {
      final docsDir = await getApplicationDocumentsDirectory();
      final fileName = 'avatar_${user.id}.jpg';
      final dest = File(p.join(docsDir.path, fileName));
      await File(sourcePath).copy(dest.path);
      destPath = dest.path;
    }

    // Remove foto anterior se existir e for diferente
    if (user.photoPath != null && user.photoPath != destPath) {
      final old = File(user.photoPath!);
      if (await old.exists()) await old.delete();
    }

    final updated = user.copyWith(photoPath: destPath, clearPhoto: destPath == null);
    await DatabaseHelper.instance.updateUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _prefs.remove('user_id');
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
