import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  String _password = '';

  // Password rules
  bool get _hasMinLen     => _password.length > 6;
  bool get _hasUppercase  => _password.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase  => _password.contains(RegExp(r'[a-z]'));
  bool get _hasDigit      => _password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial    => _password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/~`]'));
  bool get _isPasswordValid => _hasMinLen && _hasUppercase && _hasLowercase && _hasDigit && _hasSpecial;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _leftPanel(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: _form(auth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DiaBP', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('DIET CONSULTANT', style: TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Join DiaBP Today',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Start your personalized health journey with AI-powered diet planning.',
              style: TextStyle(color: Color(0xFFD1D5E8), fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.check_circle, 'Free to start'),
              _chip(Icons.restaurant_menu, 'Diet Plans'),
              _chip(Icons.monitor_heart, 'BMI Tracking'),
              _chip(Icons.chat_bubble_outline, 'AI Chatbot'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white70, size: 13),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _form(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Account', style: AppTheme.h2),
          const SizedBox(height: 4),
          const Text('Join thousands managing their health with DiaBP', style: AppTheme.bodySmall),
          const SizedBox(height: 24),
          const Text('Full Name', style: AppTheme.labelStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
            validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          const Text('Email Address', style: AppTheme.labelStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (v) => v?.isEmpty == true ? 'Email is required' : null,
          ),
          const SizedBox(height: 16),
          const Text('Password', style: AppTheme.labelStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            onChanged: (v) => setState(() => _password = v),
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 20),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (!_hasMinLen)    return 'Must be more than 6 characters';
              if (!_hasUppercase) return 'Must contain at least 1 uppercase letter';
              if (!_hasLowercase) return 'Must contain at least 1 lowercase letter';
              if (!_hasDigit)     return 'Must contain at least 1 number';
              if (!_hasSpecial)   return 'Must contain at least 1 special character';
              return null;
            },
          ),
          if (_password.isNotEmpty) ...[
            const SizedBox(height: 10),
            _passwordChecklist(),
          ],
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(auth.errorMessage!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _handleSignup,
              child: auth.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Create Account →'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Sign in →'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordChecklist() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rule(_hasMinLen,    'More than 6 characters'),
          _rule(_hasUppercase, '1 uppercase letter (A–Z)'),
          _rule(_hasLowercase, '1 lowercase letter (a–z)'),
          _rule(_hasDigit,     '1 number (0–9)'),
          _rule(_hasSpecial,   '1 special character (!@#\$%...)'),
        ],
      ),
    );
  }

  Widget _rule(bool passed, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(
          passed ? Icons.check_circle : Icons.cancel,
          size: 14,
          color: passed ? AppTheme.successGreen : const Color(0xFFCBD5E1),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(
          fontSize: 12,
          color: passed ? AppTheme.successGreen : AppTheme.textGray,
          fontWeight: passed ? FontWeight.w500 : FontWeight.normal,
        )),
      ]),
    );
  }

  void _handleSignup() async {
    if (_formKey.currentState?.validate() != true) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signup(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please log in.'), backgroundColor: AppTheme.successGreen),
      );
      context.go('/login');
    }
  }
}
