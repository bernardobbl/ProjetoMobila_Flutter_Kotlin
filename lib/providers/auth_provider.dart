import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/database/database_helper.dart';
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

      final user = UserModel(name: name, email: email, password: password);
      final id = await DatabaseHelper.instance.insertUser(user);
      _currentUser = UserModel(id: id, name: name, email: email, password: password);
      await _prefs.setInt('user_id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao cadastrar. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _error = null;
    final user = await DatabaseHelper.instance.getUserByEmail(email);

    if (user == null) {
      _error = 'E-mail não encontrado.';
      notifyListeners();
      return false;
    }

    if (user.password != password) {
      _error = 'Senha incorreta.';
      notifyListeners();
      return false;
    }

    _currentUser = user;
    await _prefs.setInt('user_id', user.id!);
    notifyListeners();
    return true;
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
