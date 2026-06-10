import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suhbat/features/chat/data/room.dart';
import 'package:suhbat/features/profile/data/profile.dart';

class SearchRepository {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> search(String query) async {
    final currentUserId = _supabase.auth.currentUser!.id;

    final rooms = await _supabase
        .from('rooms')
        .select()
        .ilike('name', '%$query%');

    final users = await _supabase
        .from('profiles')
        .select()
        .ilike('username', '%$query%')
        .neq('id', currentUserId);

    return {
      'rooms': (rooms as List).map((e) => Room.fromMap(e)).toList(),
      'users': (users as List).map((e) => Profile.fromMap(e)).toList(),
    };
  }
}
