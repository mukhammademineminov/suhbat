import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suhbat/services/notification_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:suhbat/core/router/app_router.dart';

import 'package:suhbat/core/theme/app_theme.dart';


void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await dotenv.load(fileName: ".env");
    } on FileNotFoundError catch (_) {
      // Fallback to loading from local filesystem if the asset bundle fails.
      final envFile = File('.env');
      if (await envFile.exists()) {
        final envContents = await envFile.readAsString();
        dotenv.testLoad(fileInput: envContents);
      } else {
        rethrow;
      }
    }

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    await NotificationService.init();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
      if (details.stack != null) debugPrint(details.stack.toString());
    };

    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error');
    debugPrint(stack.toString());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
    );
  }
}

