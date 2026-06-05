import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:suhbat/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profilesprovider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) => Center(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Gap(16),
                  CircleAvatar(
                    radius: 50,
                    child: Text(
                      profile.avatarChar,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Gap(16),
                  TextField(
                    controller: TextEditingController(text: profile.username),
                  ),

          
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () async {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
