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
                    ? IntrinsicHeight(child: Row(children: [
                        Expanded(child: _leftPanel()),
                        Expanded(child: _form(auth)),
                      ]))
                    : Column(children: [_leftPanel(), _form(auth)]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _leftPanel() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), bottomLeft: Radius.circular(20),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 14),
        const Text('DiaBP', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 32),
        const Text('Join DiaBP Today', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        const Text('Start your personalized health journey with AI-powered diet planning.',
            style: TextStyle(color: Color(0xFFD1D5E8), fontSize: 14, height: 1.6)),
        const SizedBox(height: 28),
        ...[
          {'icon': Icons.check_circle, 'text': 'Free to get started'},
          {'icon': Icons.check_circle, 'text': 'Personalized diet plan'},
          {'icon': Icons.check_circle, 'text': 'BMI & health tracking'},
          {'icon': Icons.check_circle, 'text': 'AI-powered chatbot'},
        ].map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Icon(item['icon'] as IconData, color: const Color(0xFF10B981), size: 18),
            const SizedBox(width: 10),
            Text(item['text'] as String, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ]),
        )),
      ]),
    );
  }

  Widget _form(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Create Account', style: AppTheme.h2),
          const SizedBox(height: 4),
          const Text('Join thousands managing their health with DiaBP', style: AppTheme.bodySmall),
          const SizedBox(height: 28),
          const Text('Full Name', style: AppTheme.labelStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'Enter your full name', prefixIcon: Icon(Icons.person_outline, size: 20)),
            validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          const Text('Email Address', style: AppTheme.labelStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Enter your email', prefixIcon: Icon(Icons.email_outlined, size: 20)),
            validator: (v) => v?.isEmpty == true ? 'Email is required' : null,
          ),
          const SizedBox(height: 16),
          const Text('Password', style: AppTheme.labelStyle),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 20),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
          ),
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
          const SizedBox(height: 20),
          Center(child: TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Already have an account? Sign in →'),
          )),
        ]),
      ),
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
