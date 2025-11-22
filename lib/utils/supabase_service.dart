import 'package:qr_reader/models/scan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ---------------------------
  // USUARIOS
  // ---------------------------

  Future<bool> insertUser(String email, String password) async {
    try {
      await _client.from('users').insert({
        'email': email,
        'password': password,
      });

      return true; // Se insertó sin error
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final data = await _client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    return data; // null si no existe
  }

  // ---------------------------
  // SCANS
  // ---------------------------

  Future<void> insertScan(String userId, String tipo, String valor) async {
    await _client.from('scans').insert({
      'user_id': userId,
      'tipo': tipo,
      'valor': valor,
    });
  }

  Future<List<Map<String, dynamic>>> getScansByType(String tipo) async {
    final data = await _client.from('scans').select().eq('tipo', tipo);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<ScanModel>> getScansByUser(String userId) async {
    final response = await _client
        .from('scans')
        .select()
        .eq('user_id', userId)
        .order('id', ascending: true);

    // response es List<dynamic> con jsons
    final scans = response.map<ScanModel>((item) {
      return ScanModel.fromJson(item);
    }).toList();

    return scans;
  }

  Future<bool> deleteScan(String userId, int scanId) async {
    try {
      final response = await _client
          .from('scans')
          .delete()
          .eq('id', scanId)
          .eq('user_id', userId);

      // Si no borra nada, significa que no coincidió userId o id
      if (response == null) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
