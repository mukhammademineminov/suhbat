import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:suhbat/features/profile/data/profile_repository.dart';

import 'package:suhbat/features/profile/providers/profile_provider.dart';
import 'package:suhbat/utils/snackbar_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profilesprovider);
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    bool _initialized = false;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) {
          if (!_initialized) {
            _usernameController.text = profile.username;
            _initialized = true;
            
          }
          _usernameController.text = profile.username;
          return Center(
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
                      controller: TextEditingController(text: email),
                      decoration: const InputDecoration(labelText: 'Email'),
                      enabled: false,
                      
                    ),
                    Gap(16),

                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    Gap(16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      //obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                    

                    const SizedBox(height: 16),
                    if (profileAsync.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        child: const Text('Save'),
                        onPressed: () async {
                          try {
                            await ProfileRepository().updateProfile(
                              _usernameController.text.trim(),
                            );
                            if (_passwordController.text.trim().isNotEmpty) {
                              await ProfileRepository().updatePassword(
                                _passwordController.text.trim(),
                              );
                            }
                            
                            ref.invalidate(profilesprovider);
                            if (context.mounted) {
                              SnackbarUtils.showMessage(
                                context,
                                'Profile updated successfully!',
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              SnackbarUtils.showMessage(
                                context,
                                e.toString(),
                                isError: true,
                              );
                            }
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
