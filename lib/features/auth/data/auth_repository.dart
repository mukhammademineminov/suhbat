import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }
  Future<AuthResponse> signUp(String email, String password, String name) async {
  final response = await _supabase.auth.signUp(
    email: email,
    password: password,
    data: {'full_name': name},
  );

  if (response.user != null) {
    await _supabase.from('profiles').insert({
      'id': response.user!.id,
      'username': name,
    });
  }

  return response;
}
  Future<AuthResponse> verifyOTP(String email, String token) async {
    final response = await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
    return response;
  }
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
