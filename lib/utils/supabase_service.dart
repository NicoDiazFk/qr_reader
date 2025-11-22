import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ---------------------------
  // USUARIOS
  // ---------------------------

  Future<void> insertUser(String email, String password) async {
    await _client.from('users').insert({
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final data = await _client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    return data; // null si no existe
  }

  Future<bool> userLogin(String email, String password) async {
    // Buscar usuario por email
    final user = await getUserByEmail(email);

    // Si no existe el usuario → false
    if (user == null) return false;

    // Comparar contraseñas (texto plano)
    final storedPassword = user['password'];

    return storedPassword == password;
  }

  // ---------------------------
  // SCANS
  // ---------------------------

  Future<void> insertScan(String tipo, String valor) async {
    await _client.from('scans').insert({'type': tipo, 'value': valor});
  }

  Future<List<Map<String, dynamic>>> getScansByType(String tipo) async {
    final data = await _client.from('scans').select().eq('type', tipo);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> deleteScan(String id) async {
    await _client.from('scans').delete().eq('id', id);
  }
}
