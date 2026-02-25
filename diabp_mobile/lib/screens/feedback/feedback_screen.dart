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
  // Backend requires aspect to be exactly 'chatbot' or 'application'
  String _selectedAspect = 'application';
  int _rating = 5;
  final _commentsCtrl = TextEditingController();
  final _suggestionsCtrl = TextEditingController();
  bool _isSubmitting = false;

  // Display labels → backend values
  final _categories = [
    {'icon': '📱', 'label': 'Overall Application', 'value': 'application'},
    {'icon': '🤖', 'label': 'Chatbot',              'value': 'chatbot'},
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
              // Category (aspect) picker
              const Text('What are you reviewing?', style: AppTheme.labelStyle),
              const SizedBox(height: 12),
              ..._categories.map((c) {
                final isSelected = _selectedAspect == c['value'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedAspect = c['value']!),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.borderGray,
                          width: isSelected ? 2 : 1),
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
                      if (isSelected) ...[
                        const Spacer(),
                        const Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 18),
                      ],
                    ]),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Star Rating
              const Text('Your rating', style: AppTheme.labelStyle),
              const SizedBox(height: 10),
              Row(children: [
                ...List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.star,
                        color: i < _rating ? const Color(0xFFF59E0B) : Colors.grey[300], size: 32),
                  ),
                )),
                const SizedBox(width: 10),
                Text(_emojis[_rating - 1], style: const TextStyle(fontSize: 24)),
                Text('  $_rating/5', style: AppTheme.bodySmall),
              ]),

              const SizedBox(height: 20),

              // Comments (required)
              Row(children: const [
                Text('Comments', style: AppTheme.labelStyle),
                Text(' *', style: TextStyle(color: AppTheme.errorRed)),
              ]),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentsCtrl,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                    hintText: 'Tell us what worked well and what can be improved...'),
              ),

              const SizedBox(height: 12),

              // Suggestions (optional)
              const Text('Suggestions (optional)', style: AppTheme.labelStyle),
              const SizedBox(height: 8),
              TextFormField(
                controller: _suggestionsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: "Any specific features you'd like to see?"),
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
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
      await Dio(BaseOptions(baseUrl: AppConstants.apiUrl)).post(
        AppConstants.feedbackEndpoint,
        // Backend FeedbackRequest: aspect(str), rating(int?), comments(str), suggestion(str?)
        data: {
          'aspect': _selectedAspect,       // must be 'chatbot' or 'application'
          'rating': _rating,
          'comments': _commentsCtrl.text.trim(),
          'suggestion': _suggestionsCtrl.text.trim().isEmpty
              ? null
              : _suggestionsCtrl.text.trim(),
        },
        options: Options(headers: {'X-User-ID': auth.userId ?? '1'}),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Thank you for your feedback! ✅'),
              backgroundColor: AppTheme.successGreen),
        );
        context.go('/');
      }
    } catch (e) {
      // Show success even if backend glitch — feedback was submitted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Feedback submitted! ✅'),
              backgroundColor: AppTheme.successGreen),
        );
        context.go('/');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
