import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getProfile() async {
    final userID= _supabase.auth.currentUser!.id;
    return await _supabase
      .from('profiles')
      .select()
      .eq('id', userID)
      .single();
  }
}