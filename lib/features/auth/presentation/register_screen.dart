import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:suhbat/features/auth/data/auth_repository.dart';
import 'package:suhbat/utils/snackbar_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailTextFieldCntroller = TextEditingController();
  final passwordTextFieldCntroller = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap(16),
              Text(
                'Suhbat',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              Gap(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create an account!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Enter your Name, Email and Password for sign up.'),
                  
                  Row(
                    children: [
                      Text("Already have an account?"),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text('Log In'),
                      ),
                    ],
                  ),
                ],
              ),

              Gap(32),
              TextField(
                controller: emailTextFieldCntroller,
                decoration: InputDecoration(labelText: 'Enter your email'),
              ),
              Gap(16),
              TextField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: passwordTextFieldCntroller,
                decoration: InputDecoration(labelText: 'Enter your password'),
              ),
              Gap(16),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        final authRepo = AuthRepository();
                        try {
                          final response = await authRepo.signIn(
                            emailTextFieldCntroller.text.trim(),
                            passwordTextFieldCntroller.text.trim(),
                          );
                          if (response.session != null && context.mounted) {
                            context.go('/rooms_chat');
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          setState(() {
                            _isLoading = false;
                          });
                          SnackbarUtils.showMessage(
                            context,
                            e.toString(),
                            isError: true,
                          );
                        }
                      },
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(),
                      )
                    : Text('Sign Up'),
              ),
              Gap(14),
            ],
          ),
        ),
      ),
    );
  }
}
