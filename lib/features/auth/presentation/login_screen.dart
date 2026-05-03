import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              Center(
                child: Text(
                  'Suhbat',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Gap(8),
              Center(
                child: Text('Welcome Back!')
              ),
              Gap(32),
              TextField(
                decoration: InputDecoration(labelText: 'Enter your login'),
              ),
              Gap(16),
              TextField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(labelText: 'Enter your password'),
              ),
              Gap(16),
              ElevatedButton(onPressed: () {}, child: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}
