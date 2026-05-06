import 'package:flutter/material.dart';

import 'package:suhbat/core/router/app_router.dart';

class RoomsScreen  extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: const Center(
        child: Text('Welcome to Chat Rooms'),
      ),
    );
  }
}
