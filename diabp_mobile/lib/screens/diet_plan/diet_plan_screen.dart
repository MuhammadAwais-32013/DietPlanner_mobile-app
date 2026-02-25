import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));
  Map<String, dynamic>? _dietPlan;
  bool _isLoading = false;
  bool _isGenerating = false;

  // Height/weight to calculate BMI locally for the API call
  final _heightCtrl = TextEditingController(text: '170');
  final _weightCtrl = TextEditingController(text: '70');

  double get _computedBmi {
    final h = double.tryParse(_heightCtrl.text) ?? 170;
    final w = double.tryParse(_weightCtrl.text) ?? 70;
    return w / ((h / 100) * (h / 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            _buildGenerateCard(),
            const SizedBox(height: 24),
            if (_dietPlan != null) _buildDietPlanCard(_dietPlan!),
          ]),
        )),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Dashboard'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.textGray, padding: EdgeInsets.zero),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Diet Plan', style: AppTheme.h2),
            Text('Get your personalized AI nutrition plan', style: AppTheme.bodySmall),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildGenerateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_awesome, color: AppTheme.primaryPurple, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Generate My Diet Plan', style: AppTheme.h3),
              Text('Personalized based on your BMI & health profile', style: AppTheme.bodySmall),
            ]),
          ]),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 400;
            return isWide
                ? Row(children: [
                    Expanded(child: _measField('Height (cm)', _heightCtrl, '170')),
                    const SizedBox(width: 12),
                    Expanded(child: _measField('Weight (kg)', _weightCtrl, '70')),
                  ])
                : Column(children: [
                    _measField('Height (cm)', _heightCtrl, '170'),
                    const SizedBox(height: 12),
                    _measField('Weight (kg)', _weightCtrl, '70'),
                  ]);
          }),
          const SizedBox(height: 16),
          // Show computed BMI preview
          if (_heightCtrl.text.isNotEmpty && _weightCtrl.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.calculate, color: AppTheme.primaryBlue, size: 16),
                const SizedBox(width: 8),
                Text('Computed BMI: ${_computedBmi.toStringAsFixed(1)}',
                    style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
              ]),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => context.push('/chat'),
              icon: const Icon(Icons.smart_toy_outlined, size: 20, color: Colors.white),
              label: const Text('Chat with AI for a Custom Plan',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Or get a quick plan based on your BMI:', style: AppTheme.bodySmall),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 46,
            child: OutlinedButton.icon(
              onPressed: _isGenerating ? null : _fetchOrGenerate,
              icon: _isGenerating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.calculate_outlined, size: 18),
              label: Text(_isGenerating ? 'Generating...' : 'Quick Plan from BMI'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _measField(String label, TextEditingController ctrl, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.labelStyle),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: hint),
        onChanged: (_) => setState(() {}),
      ),
    ]);
  }

  Widget _buildDietPlanCard(Map<String, dynamic> plan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Your Personalized Diet Plan', style: AppTheme.h3),
          ]),
          const SizedBox(height: 20),
          _mealSection('🌅 Breakfast', plan['breakfast']),
          _mealSection('☀️ Lunch', plan['lunch']),
          _mealSection('🌙 Dinner', plan['dinner']),
          _mealSection('🍎 Snacks', plan['snacks']),
          if (plan['tips'] != null) ...[
            const SizedBox(height: 16),
            const Text('💡 Health Tips', style: AppTheme.h3),
            const SizedBox(height: 8),
            ...(plan['tips'] as List).map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check, size: 14, color: AppTheme.successGreen),
                const SizedBox(width: 6),
                Expanded(child: Text(tip.toString(), style: AppTheme.bodySmall)),
              ]),
            )),
          ],
        ]),
      ),
    );
  }

  Widget _mealSection(String title, dynamic items) {
    if (items == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTheme.h3.copyWith(fontSize: 16)),
        const SizedBox(height: 6),
        ...(items as List).map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 8, top: 2),
                decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle)),
            Expanded(child: Text(item.toString(), style: AppTheme.bodySmall)),
          ]),
        )),
      ]),
    );
  }

  Future<void> _fetchOrGenerate() async {
    setState(() => _isGenerating = true);
    final auth = context.read<AuthProvider>();
    try {
      final bmi = _computedBmi;
      // Backend GET /api/diet-plan?bmi=X returns or generates plan
      final response = await _dio.get(
        AppConstants.dietPlanEndpoint,
        queryParameters: {'bmi': bmi},
        options: Options(headers: {'X-User-ID': auth.userId ?? '1'}),
      );
      final respData = response.data as Map<String, dynamic>;
      if (respData['success'] == true && respData['dietPlan'] != null) {
        setState(() { _dietPlan = respData['dietPlan'] as Map<String, dynamic>; });
      } else {
        throw Exception('No plan returned');
      }
    } catch (e) {
      // Fallback: use POST to generate
      try {
        final bmi = _computedBmi;
        final response = await _dio.post(
          AppConstants.dietPlanEndpoint,
          data: {'bmi': bmi},
          options: Options(headers: {'X-User-ID': auth.userId ?? '1'}),
        );
        final respData = response.data as Map<String, dynamic>;
        if (respData['success'] == true && respData['dietPlan'] != null) {
          setState(() { _dietPlan = respData['dietPlan'] as Map<String, dynamic>; });
        }
      } catch (e2) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e2'), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }
}
