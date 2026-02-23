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
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Card(
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              child: LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide
                    ? IntrinsicHeight(
                        child: Row(children: [
                          Expanded(child: _buildLeftPanel()),
                          Expanded(child: _buildForm(auth)),
                        ]),
                      )
                    : Column(children: [
                        _buildLeftPanel(),
                        _buildForm(auth),
                      ]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          const Text('DiaBP', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const Text('DIET CONSULTANT', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 32),
          const Text('Your Personalized Health Journey Starts Here',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, height: 1.3)),
          const SizedBox(height: 12),
          const Text(
            'AI-powered nutrition guidance specially designed for patients managing diabetes and hypertension.',
            style: TextStyle(color: Color(0xFFD1D5E8), fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 32),
          ...[
            {'icon': Icons.psychology, 'text': 'Clinical Dietitian AI'},
            {'icon': Icons.lock, 'text': 'Secure & Private'},
            {'icon': Icons.bar_chart, 'text': 'Evidence-Based Plans'},
          ].map((item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(item['icon'] as IconData, color: Colors.white70, size: 18),
              const SizedBox(width: 10),
              Text(item['text'] as String, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildForm(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome Back', style: AppTheme.h2),
            const SizedBox(height: 4),
            const Text('Sign in to access your personalized diet plans', style: AppTheme.bodySmall),
            const SizedBox(height: 32),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 8),
            if (auth.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(auth.errorMessage!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13)),
              ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            const Center(child: Text('New to DiaBP?', style: AppTheme.bodySmall)),
            Center(
              child: TextButton(
                onPressed: () => context.go('/signup'),
                child: const Text('Create a free account →'),
              ),
            ),
          ],
        ),
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
