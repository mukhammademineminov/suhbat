import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:suhbat/features/auth/presentation/login_screen.dart';
import 'package:suhbat/features/auth/presentation/register_screen.dart';
import 'package:suhbat/features/chat/presentation/rooms_screen.dart';
import 'package:suhbat/features/chat/presentation/chat_screen.dart';
import 'package:suhbat/features/profile/presentation/profile_screen.dart';

class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
}

final _authNotifier = AuthChangeNotifier();

final router = GoRouter(
  initialLocation: '/login',
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isAuthRute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (isLoggedIn && isAuthRute) {
      return '/rooms_chat';
    }
    if (!isLoggedIn && !isAuthRute) {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/rooms_chat',
      builder: (context, state) => const RoomsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    
    GoRoute(
      path: '/chat/:roomId/:roomName',
      builder: (context, state) {
      debugPrint('Router extra: ${state.extra}');
      return  ChatScreen(
        roomId: state.pathParameters['roomId']!,
        roomName: state.pathParameters['roomName']!,
        memberCount: (state.extra as int?) ?? 0,
      );
      }
    ),
  ],
);
