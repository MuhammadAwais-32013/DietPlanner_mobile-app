import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/bmi_service.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final BmiService _bmiService = BmiService();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  double? get _bmi => _result != null ? (_result!['bmi'] as num?)?.toDouble() : null;

  Color _bmiColor(double? bmi) {
    if (bmi == null) return AppTheme.textGray;
    if (bmi < 18.5) return const Color(0xFF3B4AE8);
    if (bmi < 25) return const Color(0xFF10B981);
    if (bmi < 30) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _bmiCategory(double? bmi) {
    if (bmi == null) return '';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                _buildBmiCategories(),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return isWide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: _buildInputCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildResultCard()),
                        ])
                      : Column(children: [_buildInputCard(), const SizedBox(height: 16), _buildResultCard()]);
                }),
              ]),
            ),
          ),
        ],
      ),
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
            child: const Icon(Icons.bar_chart, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('BMI Calculator', style: AppTheme.h2),
            Text('Calculate your Body Mass Index & get personalized diet guidance', style: AppTheme.bodySmall),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildBmiCategories() {
    final cats = [
      {'label': 'Underweight', 'range': 'Below 18.5', 'color': const Color(0xFF3B4AE8), 'bg': const Color(0xFFEFF3FF)},
      {'label': 'Normal', 'range': '18.5 – 24.9', 'color': const Color(0xFF10B981), 'bg': const Color(0xFFE8FFF6)},
      {'label': 'Overweight', 'range': '25 – 29.9', 'color': const Color(0xFFF59E0B), 'bg': const Color(0xFFFFFBEB)},
      {'label': 'Obese', 'range': '30 & above', 'color': const Color(0xFFEF4444), 'bg': const Color(0xFFFFF1F1)},
    ];
    return Row(children: cats.map((c) => Expanded(child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c['bg'] as Color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: (c['color'] as Color).withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(c['label'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: c['color'] as Color)),
        const SizedBox(height: 2),
        Text(c['range'] as String, style: TextStyle(fontSize: 10, color: c['color'] as Color)),
      ]),
    ))).toList());
  }

  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your Measurements', style: AppTheme.h3),
            const Text('Enter your height and weight to get your BMI score', style: AppTheme.bodySmall),
            const SizedBox(height: 24),
            const Text('Height', style: AppTheme.labelStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _heightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 170',
                prefixIcon: Icon(Icons.height, size: 20),
                suffixText: 'cm',
                helperText: 'Example: 170 cm (5 ft 7 in)',
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Enter a valid height';
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Weight', style: AppTheme.labelStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 70',
                prefixIcon: Icon(Icons.monitor_weight_outlined, size: 20),
                suffixText: 'kg',
                helperText: 'Example: 70 kg (154 lbs)',
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Enter a valid weight';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _calculate,
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.calculate, size: 18),
                label: Text(_isLoading ? 'Calculating...' : 'Calculate BMI'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_result == null) {
      return Card(
        color: const Color(0xFFF0F4FF),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.bolt, color: AppTheme.primaryBlue, size: 32),
            ),
            const SizedBox(height: 20),
            const Text('Ready to calculate?', style: AppTheme.h3),
            const SizedBox(height: 8),
            const Text(
              'Enter your height and weight on the left to see your BMI result and personalized health tips.',
              textAlign: TextAlign.center, style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ...[
              {'color': const Color(0xFF3B4AE8), 'label': 'Underweight', 'range': 'Below 18.5'},
              {'color': const Color(0xFF10B981), 'label': 'Normal', 'range': '18.5 – 24.9'},
              {'color': const Color(0xFFF59E0B), 'label': 'Overweight', 'range': '25 – 29.9'},
              {'color': const Color(0xFFEF4444), 'label': 'Obese', 'range': '30 & above'},
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(item['label'] as String, style: AppTheme.labelStyle),
                const Spacer(),
                Text(item['range'] as String, style: AppTheme.bodySmall),
              ]),
            )),
          ]),
        ),
      );
    }

    final bmi = _bmi!;
    final color = _bmiColor(bmi);
    final category = _bmiCategory(bmi);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your BMI Result', style: AppTheme.h3),
          const SizedBox(height: 20),
          Center(child: Column(children: [
            Text(bmi.toStringAsFixed(1), style: TextStyle(fontSize: 72, fontWeight: FontWeight.w800, color: color, height: 1)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(category, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ])),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: (bmi.clamp(10, 40) - 10) / 30,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          if (_result!['recommendation'] != null) ...[
            const Text('Health Tips', style: AppTheme.labelStyle),
            const SizedBox(height: 8),
            Text(_result!['recommendation'].toString(), style: AppTheme.bodySmall.copyWith(height: 1.6)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 44,
            child: ElevatedButton(
              onPressed: () => context.push('/chat'),
              child: const Text('Get Personalized Diet Plan →'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _calculate() async {
    if (_formKey.currentState?.validate() != true) return;
    final auth = context.read<AuthProvider>();
    setState(() => _isLoading = true);
    try {
      final result = await _bmiService.calculateBmi(
        height: double.parse(_heightCtrl.text),
        weight: double.parse(_weightCtrl.text),
        userId: auth.userId ?? '',
      );
      setState(() { _result = result; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().substring(0, 50)}'), backgroundColor: AppTheme.errorRed),
      );
    }
  }
}
