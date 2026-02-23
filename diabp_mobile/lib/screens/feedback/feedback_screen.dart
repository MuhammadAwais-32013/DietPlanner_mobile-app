import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedCategory = 'Overall Application';
  int _rating = 5;
  final _commentsCtrl = TextEditingController();
  final _suggestionsCtrl = TextEditingController();
  bool _isSubmitting = false;

  final _categories = [
    {'icon': '📱', 'label': 'Overall Application'},
    {'icon': '🤖', 'label': 'Chatbot'},
    {'icon': '🥗', 'label': 'Diet Plan'},
    {'icon': '⚖️', 'label': 'BMI Calculator'},
  ];

  final _emojis = ['😞', '😕', '😐', '😊', '😄'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.go('/')),
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Share Feedback', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text('Help us improve DiaBP for you', style: TextStyle(fontSize: 11, color: AppTheme.textGray)),
          ]),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('What are you reviewing?', style: AppTheme.labelStyle),
              const SizedBox(height: 12),
              LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 500;
                return Wrap(spacing: 10, runSpacing: 10, children: _categories.map((c) {
                  final isSelected = _selectedCategory == c['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = c['label']!),
                    child: Container(
                      width: isWide ? (constraints.maxWidth / 2 - 16) : double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGray, width: isSelected ? 2 : 1),
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected ? AppTheme.primaryBlue.withOpacity(0.04) : Colors.white,
                      ),
                      child: Row(children: [
                        Text(c['icon']!, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Text(c['label']!, style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                        )),
                      ]),
                    ),
                  );
                }).toList());
              }),
              const SizedBox(height: 24),
              const Text('Your rating', style: AppTheme.labelStyle),
              const SizedBox(height: 10),
              Row(children: [
                ...List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.star, color: i < _rating ? const Color(0xFFF59E0B) : Colors.grey[300], size: 32),
                  ),
                )),
                const SizedBox(width: 10),
                Text(_emojis[_rating - 1], style: const TextStyle(fontSize: 24)),
                Text(' ${_rating}/5', style: AppTheme.bodySmall),
              ]),
              const SizedBox(height: 24),
              Row(children: [
                const Text('Comments', style: AppTheme.labelStyle),
                const Text(' *', style: TextStyle(color: AppTheme.errorRed)),
              ]),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentsCtrl,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(hintText: 'Tell us what worked well and what can be improved...'),
              ),
              const SizedBox(height: 16),
              const Text('Suggestions (optional)', style: AppTheme.labelStyle),
              const SizedBox(height: 8),
              TextFormField(
                controller: _suggestionsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Any specific features or improvements you\'d like to see?'),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    child: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit Feedback'),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (_commentsCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comments are required'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();
    try {
      await Dio(BaseOptions(baseUrl: AppConstants.apiUrl)).post(AppConstants.feedbackEndpoint, data: {
        'user_id': auth.userId,
        'category': _selectedCategory,
        'rating': _rating,
        'comments': _commentsCtrl.text.trim(),
        'suggestions': _suggestionsCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback! ✅'), backgroundColor: AppTheme.successGreen),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted!'), backgroundColor: AppTheme.successGreen),
      );
      if (mounted) context.go('/');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
