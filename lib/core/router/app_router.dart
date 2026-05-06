//import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:suhbat/features/auth/presentation/login_screen.dart';
import 'package:suhbat/features/auth/presentation/register_screen.dart';
import 'package:suhbat/features/chat/presentation/rooms_screen.dart';


final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/rooms_chat',
      builder: (context, state) => const RoomsScreen(),
    ),

  ],
);