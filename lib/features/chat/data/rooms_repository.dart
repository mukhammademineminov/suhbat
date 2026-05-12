import 'package:suhbat/features/chat/data/room.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomsRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Room>> getRooms() async {
    final data = await _supabase
        .from('rooms')
        .select()
        .order('created_at', ascending: true);

    return (data as List).map((e) => Room.fromMap(e)).toList();
  }
}