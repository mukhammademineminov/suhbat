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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(16),
              const Text(
                'Suhbat',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Gap(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create an account!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Gap(4),
                  Text(
                    _otpSent
                        ? 'Confirmation code has been sent to your email. Enter it to sign up.'
                        : 'Enter your Name, Email and Password to sign up.',
                  ),
                  Row(
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(32),

              if (!_otpSent) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Enter your name'),
                ),
                const Gap(16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Enter your email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const Gap(16),
                TextField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Enter your password'),
                ),
                const Gap(16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Sign Up'),
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: 'Enter Confirmation code'),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                ),
                const Gap(16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Confirm'),
                ),
              ],

              const Gap(14),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    final authRepo = AuthRepository();
    try {
      await authRepo.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _otpSent = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarUtils.showMessage(context, e.toString(), isError: true);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    final authRepo = AuthRepository();
    try {
      await authRepo.verifyOTP(
        _emailController.text.trim(),
        _otpController.text.trim(),
      );
      if (!mounted) return;
      context.go('/rooms_chat');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackbarUtils.showMessage(context, e.toString(), isError: true);
    }
  }
}