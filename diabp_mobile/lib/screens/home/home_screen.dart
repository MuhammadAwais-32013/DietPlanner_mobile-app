import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildNavBar(auth),
              SliverToBoxAdapter(child: _buildHeroSection(auth)),
              SliverToBoxAdapter(child: _buildFeaturesSection(auth)),
              SliverToBoxAdapter(child: _buildFaqSection(auth)),
              SliverToBoxAdapter(child: _buildFooter()),
            ],
          ),
          // Floating chatbot button
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryBlue,
              onPressed: () {
                if (auth.isLoggedIn) {
                  context.push('/chat');
                } else {
                  context.push('/login');
                }
              },
              label: const Text('AI Diet Assistant',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 22),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(AuthProvider auth) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 1,
      toolbarHeight: 70,
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('DiaBP', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: AppTheme.primaryBlue,
                letterSpacing: -0.5,
              )),
              const Text('DIET CONSULTANT', style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w600,
                color: AppTheme.textGray, letterSpacing: 1.2,
              )),
            ],
          ),
        ],
      ),
      actions: [
        if (auth.isLoggedIn) ...[
          TextButton(onPressed: () => context.push('/bmi'), child: const Text('BMI')),
          TextButton(onPressed: () => context.push('/diet-plan'), child: const Text('Diet Plan')),
          TextButton(onPressed: () => context.push('/records'), child: const Text('Health Records')),
          TextButton(onPressed: () => context.push('/admin'), child: const Text('Admin')),
          TextButton(onPressed: () => context.push('/feedback'), child: const Text('Feedback')),
          PopupMenuButton<String>(
            child: CircleAvatar(
              backgroundColor: AppTheme.primaryBlue,
              radius: 16,
              child: Text(
                auth.userName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            onSelected: (v) { if (v == 'logout') auth.logout(); },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Signed in as', style: AppTheme.bodySmall),
                  Text(auth.userName ?? '', style: AppTheme.labelStyle),
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Row(children: [
                Icon(Icons.logout, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('Sign out', style: TextStyle(color: Colors.red)),
              ])),
            ],
          ),
          const SizedBox(width: 16),
        ] else ...[
          TextButton(
            onPressed: () => context.push('/login'),
            child: const Text('Log in', style: TextStyle(color: AppTheme.textDark)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.push('/signup'),
            child: const Text('Get Started →'),
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildHeroSection(AuthProvider auth) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return isWide
              ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(flex: 5, child: _heroText(auth)),
                  const SizedBox(width: 40),
                  Expanded(flex: 4, child: _heroCard()),
                ])
              : Column(children: [_heroText(auth), const SizedBox(height: 32), _heroCard()]);
        }),
      ),
    );
  }

  Widget _heroText(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(
              color: Color(0xFF10B981), shape: BoxShape.circle,
            )),
            const SizedBox(width: 6),
            const Text('AI-Powered Clinical Nutrition',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('Smart Diet Solutions', style: TextStyle(
          fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1,
        )),
        const Text('For Better Health', style: TextStyle(
          fontSize: 42, fontWeight: FontWeight.w800,
          color: Color(0xFFBFD3FF), height: 1.1,
        )),
        const SizedBox(height: 20),
        const Text(
          'Personalized nutrition plans, BMI tracking, and expert AI guidance — designed specifically for diabetes and blood pressure patients.',
          style: TextStyle(color: Color(0xFFD1D5E8), fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 32),
        // Show auth-specific CTAs
        if (!auth.isLoggedIn)
          Row(children: [
            TextButton(
              onPressed: () => context.push('/signup'),
              child: const Text('Get Started Free →', style: TextStyle(color: Color(0xFFBFD3FF))),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Sign In', style: TextStyle(color: Color(0xFFBFD3FF))),
            ),
          ])
        else
          Row(children: [
            TextButton(
              onPressed: () => context.push('/chat'),
              child: const Text('Chat with AI →', style: TextStyle(color: Color(0xFFBFD3FF))),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () => context.push('/diet-plan'),
              child: const Text('My Diet Plan', style: TextStyle(color: Color(0xFFBFD3FF))),
            ),
          ]),
        const SizedBox(height: 40),
        Row(children: [
          _heroStat('1–30', 'DAY DIET PLANS'),
          const SizedBox(width: 32),
          _heroStat('AI', 'EVIDENCE-BASED'),
          const SizedBox(width: 32),
          _heroStat('100%', 'SECURE & PRIVATE'),
        ]),
      ],
    );
  }

  Widget _heroStat(String value, String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(
        fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
      )),
      Text(label, style: const TextStyle(
        fontSize: 11, color: Color(0xFFBFD3FF), letterSpacing: 0.5,
      )),
    ]);
  }

  Widget _heroCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(children: [
              _macDot(const Color(0xFFFF5F56)),
              const SizedBox(width: 6),
              _macDot(const Color(0xFFFFBD2E)),
              const SizedBox(width: 6),
              _macDot(const Color(0xFF27C93F)),
              const SizedBox(width: 12),
              const Text('DiaBP AI Analysis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ]),
          ),
          ClipRRect(
            child: Image.network(
              'https://images.unsplash.com/photo-1547592180-85f173990554?w=600',
              height: 180, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey[200],
                child: const Icon(Icons.fastfood, size: 60, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(
                  radius: 18, backgroundColor: AppTheme.primaryBlue,
                  child: const Text('AI', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('DiaBP Assistant', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Just now', style: AppTheme.bodySmall),
                ]),
              ]),
              const SizedBox(height: 12),
              RichText(text: const TextSpan(
                style: TextStyle(color: AppTheme.textDark, fontSize: 13, height: 1.5),
                children: [
                  TextSpan(text: 'Based on your profile, I recommend a '),
                  TextSpan(text: 'balanced diet', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                  TextSpan(text: ' with 30% protein, 45% complex carbs, and '),
                  TextSpan(text: '25% healthy fats', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                  TextSpan(text: ' to support your blood pressure management.'),
                ],
              )),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(
                  onPressed: () => context.push('/chat'),
                  child: const Text('View full analysis →', style: TextStyle(fontSize: 13)),
                ),
                Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(
                    color: Color(0xFF10B981), shape: BoxShape.circle,
                  )),
                  const SizedBox(width: 4),
                  Text('AI-generated', style: AppTheme.bodySmall),
                ]),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _macDot(Color color) {
    return Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Widget _buildFeaturesSection(AuthProvider auth) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.bolt, size: 14, color: AppTheme.primaryBlue),
            const SizedBox(width: 4),
            const Text('POWERED BY CLINICAL AI', style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue, letterSpacing: 1,
            )),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Everything You Need for Better Health',
            textAlign: TextAlign.center, style: AppTheme.h2),
        const SizedBox(height: 8),
        const Text('Advanced AI analyzes your health metrics for personalized nutrition guidance',
            textAlign: TextAlign.center, style: AppTheme.bodyLarge),
        const SizedBox(height: 40),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return isWide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: _featureCards().map((c) => Expanded(child: c)).toList())
              : Column(children: _featureCards().map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList());
        }),
        const SizedBox(height: 40),
        // Only show sign-up/login CTA when NOT logged in
        if (!auth.isLoggedIn)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(onPressed: () => context.push('/signup'), child: const Text('Start Your Free Journey →')),
            const SizedBox(width: 16),
            TextButton(onPressed: () => context.push('/login'), child: const Text('Already a member? Sign in')),
          ])
        else
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(onPressed: () => context.push('/chat'), child: const Text('Open AI Diet Assistant →')),
            const SizedBox(width: 16),
            TextButton(onPressed: () => context.push('/bmi'), child: const Text('Check my BMI')),
          ]),
      ]),
    );
  }

  List<Widget> _featureCards() {
    final features = [
      {
        'icon': Icons.bar_chart, 'iconBg': const Color(0xFFEFF3FF),
        'iconColor': AppTheme.primaryBlue,
        'title': 'Advanced Analytics',
        'desc': 'Our AI continuously analyzes your health metrics and dietary patterns to identify trends.',
        'items': ['Data-driven insights', 'Progress tracking', 'Personalized reports'],
      },
      {
        'icon': Icons.favorite, 'iconBg': const Color(0xFFF3E8FF),
        'iconColor': AppTheme.primaryPurple,
        'title': 'Personalized Diet Plans',
        'desc': 'Get a diet plan tailored to your unique health metrics, diabetes, or blood pressure needs.',
        'items': ['1-30 day custom plans', 'Nutritional balance', 'Adaptable recommendations'],
      },
      {
        'icon': Icons.auto_awesome, 'iconBg': const Color(0xFFE8FFF6),
        'iconColor': const Color(0xFF10B981),
        'title': 'AI Diet Assistant',
        'desc': 'Chat with our clinical AI for real-time nutrition tips and evidence-based guidance.',
        'items': ['24/7 Nutrition advice', 'Medical document analysis', 'Health goal tracking'],
      },
    ];

    return features.map((f) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: f['iconBg'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(f['icon'] as IconData, color: f['iconColor'] as Color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(f['title'] as String, style: AppTheme.h3),
          const SizedBox(height: 8),
          Text(f['desc'] as String, style: AppTheme.bodySmall),
          const SizedBox(height: 12),
          ...(f['items'] as List<String>).map((item) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              const Icon(Icons.check, size: 14, color: AppTheme.primaryBlue),
              const SizedBox(width: 6),
              Text(item, style: AppTheme.bodySmall),
            ]),
          )),
        ]),
      ),
    )).toList();
  }

  Widget _buildFaqSection(AuthProvider auth) {
    final faqs = [
      {'q': 'How does the AI create my diet plan?', 'a': 'Our AI analyzes your BMI, health metrics, dietary preferences, and goals to generate a personalized nutrition plan optimized for your specific needs.'},
      {'q': 'Can I customize my diet plan?', 'a': 'Yes! You can specify dietary preferences, food allergies, and specific foods you want to include or exclude. The AI adapts your plan while maintaining nutritional balance.'},
      {'q': 'How often should I update my health metrics?', 'a': 'For best results, update your health metrics weekly. This allows our AI to track your progress and adjust your diet plan accordingly.'},
      {'q': 'Is my health data secure and private?', 'a': 'Absolutely. All your health data is encrypted, stored securely, and never shared with third parties. You maintain full control over your information.'},
    ];

    return Container(
      color: AppTheme.lightGray,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(children: [
        const Text('Frequently Asked Questions', style: AppTheme.h2),
        const SizedBox(height: 32),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          if (isWide) {
            return Column(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _faqCard(faqs[0])),
                const SizedBox(width: 16),
                Expanded(child: _faqCard(faqs[1])),
              ]),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _faqCard(faqs[2])),
                const SizedBox(width: 16),
                Expanded(child: _faqCard(faqs[3])),
              ]),
            ]);
          }
          return Column(children: faqs.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _faqCard(f),
          )).toList());
        }),
        const SizedBox(height: 32),
        if (!auth.isLoggedIn)
          TextButton(
            onPressed: () => context.push('/signup'),
            child: const Text('Get Started Free Today →', style: TextStyle(fontSize: 15)),
          )
        else
          TextButton(
            onPressed: () => context.push('/chat'),
            child: const Text('Ask the AI Assistant →', style: TextStyle(fontSize: 15)),
          ),
      ]),
    );
  }

  Widget _faqCard(Map<String, String> faq) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(faq['q']!, style: AppTheme.h3.copyWith(fontSize: 15)),
          const SizedBox(height: 8),
          Text(faq['a']!, style: AppTheme.bodySmall),
        ]),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          if (isWide) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: _footerBrand()),
              Expanded(child: _footerLinks('FEATURES', ['BMI Calculator', 'Diet Plans', 'Health Records', 'AI Chatbot'])),
              Expanded(child: _footerLinks('RESOURCES', ['Nutrition Blog', 'Health Tips', 'FAQ'])),
            ]);
          }
          return _footerBrand();
        }),
        const SizedBox(height: 24),
        const Divider(color: Colors.white24),
        const SizedBox(height: 12),
        const Text('© 2026 DiaBP Diet Consultant. All rights reserved.',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
      ]),
    );
  }

  Widget _footerBrand() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          gradient: AppTheme.heroGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 20),
      ),
      const SizedBox(height: 8),
      const Text('DiaBP', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
      const Text('DIET CONSULTANT', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5)),
      const SizedBox(height: 12),
      const Text('AI-powered personalized diet plans and health tracking for diabetes and blood pressure patients.',
          style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6)),
      const SizedBox(height: 16),
      Row(children: [Icons.facebook, Icons.language, Icons.link].map((i) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6)),
          child: Icon(i, color: Colors.white54, size: 16),
        ),
      )).toList()),
    ]);
  }

  Widget _footerLinks(String title, List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      const SizedBox(height: 12),
      ...items.map((i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(i, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      )),
    ]);
  }
}
