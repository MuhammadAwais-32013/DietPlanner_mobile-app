import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Compact top panel
              _buildLeftPanel(),
              // Form section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: _buildForm(auth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
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
                child: const Icon(Icons.favorite, color: Colors.white, size: 20),
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
          const Text('Your Personalized Health Journey Starts Here',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, height: 1.3)),
          const SizedBox(height: 8),
          const Text(
            'AI-powered nutrition guidance for diabetes and hypertension patients.',
            style: TextStyle(color: Color(0xFFD1D5E8), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildChip(Icons.psychology, 'Clinical AI'),
              const SizedBox(width: 8),
              _buildChip(Icons.lock, 'Secure'),
              const SizedBox(width: 8),
              _buildChip(Icons.bar_chart, 'Evidence-Based'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
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

  Widget _buildForm(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome Back', style: AppTheme.h2),
          const SizedBox(height: 4),
          const Text('Sign in to access your personalized diet plans', style: AppTheme.bodySmall),
          const SizedBox(height: 24),
          const Text('Email Address', style: AppTheme.labelStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (v) => v?.isEmpty == true ? 'Email is required' : null,
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Password', style: AppTheme.labelStyle),
            TextButton(onPressed: () {}, child: const Text('Forgot password?', style: TextStyle(fontSize: 13))),
          ]),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 20),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) => v?.isEmpty == true ? 'Password is required' : null,
          ),
          if (auth.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(auth.errorMessage!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13)),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _handleLogin,
              child: auth.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Sign In to Account →'),
            ),
          ),
          const SizedBox(height: 20),
          const Center(child: Text('New to DiaBP?', style: AppTheme.bodySmall)),
          Center(
            child: TextButton(
              onPressed: () => context.go('/signup'),
              child: const Text('Create a free account →'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() != true) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (success && mounted) context.go('/');
  }
}
