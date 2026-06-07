import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getProfile() async {
    final userID = _supabase.auth.currentUser!.id;
    return await _supabase.from('profiles').select().eq('id', userID).single();
  }

  Future<void> updateProfile(String username) async {
    final userID = _supabase.auth.currentUser!.id;
    await _supabase
        .from('profiles')
        .update({'username': username})
        .eq('id', userID);
  }

  Future<void> updateEmail(String email) async {
    await _supabase.auth.updateUser(UserAttributes(email: email));
  }

  Future<void> updatePassword(String password) async {
    await _supabase.auth.updateUser(UserAttributes(password: password));
  }
}
