import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/diet_service.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  final DietService _dietService = DietService();
  final ChatService _chatService = ChatService();
  List<dynamic> _plans = [];
  bool _isLoading = true;
  bool _isGenerating = false;
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlans());
  }

  Future<void> _loadPlans() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) return;
    try {
      final data = await _dietService.getDietPlans(auth.userId!);
      setState(() { _plans = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  _buildGenerateCard(),
                  const SizedBox(height: 24),
                  _buildPlansList(),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Diet Plan', style: AppTheme.h2),
            Text('${_plans.length} plans generated', style: AppTheme.bodySmall),
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
              decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_awesome, color: AppTheme.primaryPurple, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Generate New Diet Plan', style: AppTheme.h3),
              Text('AI creates a personalized plan based on your health profile', style: AppTheme.bodySmall),
            ]),
          ]),
          const SizedBox(height: 20),
          const Text('Plan Duration', style: AppTheme.labelStyle),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [7, 14, 21, 30].map((d) => ChoiceChip(
            label: Text('$d days'),
            selected: _selectedDays == d,
            onSelected: (_) => setState(() => _selectedDays = d),
            selectedColor: AppTheme.primaryBlue.withOpacity(0.12),
            labelStyle: TextStyle(color: _selectedDays == d ? AppTheme.primaryBlue : AppTheme.textGray, fontWeight: FontWeight.w500),
            side: BorderSide(color: _selectedDays == d ? AppTheme.primaryBlue : AppTheme.borderGray),
          )).toList()),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generatePlan,
              icon: _isGenerating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(_isGenerating ? 'Generating AI Plan...' : 'Generate $_selectedDays-Day Plan with AI'),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: TextButton.icon(
            onPressed: () => context.push('/chat'),
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Or chat with AI for a custom plan'),
          )),
        ]),
      ),
    );
  }

  Widget _buildPlansList() {
    if (_plans.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(child: Column(children: [
            Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No diet plans yet', style: AppTheme.h3),
            const SizedBox(height: 8),
            const Text('Generate your first AI diet plan above', style: AppTheme.bodySmall),
          ])),
        ),
      );
    }
    return Column(children: _plans.asMap().entries.map((e) => _planCard(e.key, e.value)).toList());
  }

  Widget _planCard(int i, Map<String, dynamic> plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
        ),
        title: Text('${plan['days'] ?? '?'}-Day Diet Plan', style: AppTheme.labelStyle),
        subtitle: Text(plan['created_at'] ?? '', style: AppTheme.bodySmall),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(plan['plan_content'] ?? plan['content'] ?? 'No content available.',
                style: AppTheme.bodySmall.copyWith(height: 1.7)),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    try {
      final sessionId = await _chatService.createSession();
      if (sessionId == null) throw Exception('Could not create session');
      await _chatService.generateDietPlan(sessionId: sessionId, days: _selectedDays);
      await _loadPlans();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diet plan generated! ✅'), backgroundColor: AppTheme.successGreen),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Start a chat session first'), backgroundColor: AppTheme.errorRed),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }
}
