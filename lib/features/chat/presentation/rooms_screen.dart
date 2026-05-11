import 'package:flutter/material.dart';

//import 'package:suhbat/core/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: Center(
        child: TextButton(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
