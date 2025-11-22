import 'package:flutter/material.dart';
import '../utils/supabase_service.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  String _userId = '';
  String get userId => _userId;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String email, String password) async {
    // Validar usuario y contraseña
    final user = await _supabaseService.getUserByEmail(email);

    // Si el usuario no existe
    if (user == null) return false;

    // Comparar passwords
    if (user['password'] != password) return false;

    // Login exitoso → guardamos id
    _userId = user['id'];
    _isLoggedIn = true;

    notifyListeners();
    return true;
  }

  void logout() {
    _userId = '';
    _isLoggedIn = false;
    notifyListeners();
  }
}
