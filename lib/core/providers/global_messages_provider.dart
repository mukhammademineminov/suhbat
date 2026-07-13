import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final globalMessagesProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) => data.isNotEmpty ? data.first : null);
});

final globalDmMessagesProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('direct_messages')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((data) => data.isNotEmpty ? data.first : null);
});