import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../core/theme.dart';
import '../../services/chat_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  String? _sessionId;
  bool _isStarted = false;
  bool _isLoading = false;
  bool _isSending = false;

  // Setup form fields
  final _formKey = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _diabetesSelection = 'No';
  // BP: only Yes / No
  String _bpSelection = 'No';
  final _bpSystolicCtrl = TextEditingController();
  final _bpDiastolicCtrl = TextEditingController();
  List<PlatformFile> _selectedFiles = [];

  // Common hint text style – lighter than body text
  static const TextStyle _hintStyle = TextStyle(
    color: Color(0xFFBBC0CC),
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _msgCtrl.dispose();
    _bpSystolicCtrl.dispose();
    _bpDiastolicCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Row(children: [
          // Fix 4: Prettier chatbot icon using a stacked design
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34D399),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Diet Assistant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text('Diabetes & BP Diet Planner', style: TextStyle(fontSize: 11, color: AppTheme.textGray)),
          ]),
        ]),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.go('/')),
        actions: [
          if (_isStarted) TextButton(
            onPressed: _resetSession,
            child: const Text('Exit', style: TextStyle(color: AppTheme.textGray)),
          ),
        ],
      ),
      body: _isStarted ? _buildChatView() : _buildSetupView(),
    );
  }

  Widget _buildSetupView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Welcome to Your AI Diet Assistant!', style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.primaryBlue,
                    )),
                    SizedBox(height: 4),
                    Text('Please provide your health information to get started.',
                        style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13)),
                  ]),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  return isWide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: _inputField('Height (cm)', _heightCtrl, 'e.g. 170', _heightValidator)),
                          const SizedBox(width: 12),
                          Expanded(child: _inputField('Weight (kg)', _weightCtrl, 'e.g. 70', _weightValidator)),
                        ])
                      : Column(children: [
                          _inputField('Height (cm)', _heightCtrl, 'e.g. 170', _heightValidator),
                          const SizedBox(height: 12),
                          _inputField('Weight (kg)', _weightCtrl, 'e.g. 70', _weightValidator),
                        ]);
                }),
                const SizedBox(height: 16),
                // Diabetes dropdown (Yes - Type 1 / Type 2 / Borderline / No)
                _dropdownField(
                  'Do you have Diabetes?',
                  _diabetesSelection,
                  ['No', 'Yes - Type 1', 'Yes - Type 2', 'Borderline'],
                  (v) => setState(() => _diabetesSelection = v!),
                ),
                const SizedBox(height: 16),
                // Fix 2: BP dropdown → only Yes / No, with conditional value input
                _bpDropdownField(),
                const SizedBox(height: 16),
                const Text('Medical Documents (Optional)', style: AppTheme.labelStyle),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickFiles,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4), style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(10),
                      color: AppTheme.primaryBlue.withOpacity(0.03),
                    ),
                    child: Column(children: [
                      const Icon(Icons.upload_file, color: AppTheme.primaryBlue, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFiles.isEmpty
                            ? 'Click to upload medical files'
                            : '${_selectedFiles.length} file(s) selected',
                        style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                      ),
                      const Text('Only PDF files up to 25MB', style: AppTheme.bodySmall),
                    ]),
                  ),
                ),
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._selectedFiles.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      const Icon(Icons.picture_as_pdf, color: AppTheme.errorRed, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(f.name, style: AppTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                      IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _selectedFiles.remove(f))),
                    ]),
                  )),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _startChat,
                    icon: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.chat_bubble, size: 18),
                    label: Text(_isLoading ? 'Starting...' : 'Start Chat'),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // Fix 1: Validation callbacks
  String? _heightValidator(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null || n <= 0) return 'Enter a valid height (> 0)';
    if (n > 300) return 'Height seems too large';
    return null;
  }

  String? _weightValidator(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null || n <= 0) return 'Enter a valid weight (> 0)';
    if (n > 600) return 'Weight seems too large';
    return null;
  }

  // Fix 3: Lighter placeholder hintStyle applied
  Widget _inputField(String label, TextEditingController ctrl, String hint, String? Function(String?) validator) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.labelStyle),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: _hintStyle,
        ),
        validator: validator,
      ),
    ]);
  }

  Widget _dropdownField(String label, String value, List<String> options, void Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.labelStyle),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(),
        items: options.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: onChanged,
      ),
    ]);
  }

  // Fix 2: BP-specific widget — Yes/No only, with Systolic + Diastolic fields + validation
  Widget _bpDropdownField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Do you have Blood Pressure issues?', style: AppTheme.labelStyle),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: _bpSelection,
        decoration: const InputDecoration(),
        items: const [
          DropdownMenuItem(value: 'No', child: Text('No')),
          DropdownMenuItem(value: 'Yes', child: Text('Yes')),
        ],
        onChanged: (v) => setState(() {
          _bpSelection = v!;
          if (v == 'No') {
            _bpSystolicCtrl.clear();
            _bpDiastolicCtrl.clear();
          }
        }),
      ),
      // Conditionally show Systolic + Diastolic fields when user selects Yes
      if (_bpSelection == 'Yes') ...[
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Systolic (mmHg)', style: AppTheme.labelStyle),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bpSystolicCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 130',
                    hintStyle: TextStyle(color: Color(0xFFBBC0CC), fontSize: 14),
                    prefixIcon: Icon(Icons.arrow_upward, size: 16, color: AppTheme.errorRed),
                    helperText: 'Upper number',
                  ),
                  validator: (v) {
                    if (_bpSelection != 'Yes') return null;
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Required';
                    if (n < 60 || n > 300) return 'Between 60–300';
                    return null;
                  },
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Diastolic (mmHg)', style: AppTheme.labelStyle),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _bpDiastolicCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 85',
                    hintStyle: TextStyle(color: Color(0xFFBBC0CC), fontSize: 14),
                    prefixIcon: Icon(Icons.arrow_downward, size: 16, color: AppTheme.primaryBlue),
                    helperText: 'Lower number',
                  ),
                  validator: (v) {
                    if (_bpSelection != 'Yes') return null;
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Required';
                    if (n < 40 || n > 200) return 'Between 40–200';
                    return null;
                  },
                ),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Normal BP: 120/80 mmHg. Enter your latest reading.',
          style: AppTheme.bodySmall.copyWith(color: const Color(0xFFBBC0CC)),
        ),
      ],
    ]);
  }

  Widget _buildChatView() {
    return Column(children: [
      Expanded(
        child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length,
          itemBuilder: (_, i) => _messageItem(_messages[i]),
        ),
      ),
      if (_isSending)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            CircleAvatar(radius: 14, backgroundColor: AppTheme.primaryBlue,
                child: Text('AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
            SizedBox(width: 10),
            Text('Typing...', style: AppTheme.bodySmall),
          ]),
        ),
      _buildInputBar(),
    ]);
  }

  Widget _messageItem(Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16, backgroundColor: AppTheme.primaryBlue,
              child: const Text('AI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Text(
                msg['content'] as String,
                style: TextStyle(color: isUser ? Colors.white : AppTheme.textDark, fontSize: 14, height: 1.5),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryPurple,
                child: Icon(Icons.person, color: Colors.white, size: 16)),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.white,
      child: Row(children: [
        Expanded(
          child: TextFormField(
            controller: _msgCtrl,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Ask about your diet, blood sugar, nutrition...',
              hintStyle: _hintStyle,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppTheme.borderGray)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onFieldSubmitted: (_) => _sendMessage(),
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 22, backgroundColor: AppTheme.primaryBlue,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white, size: 18),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ),
      ]),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true);
    if (result != null) setState(() => _selectedFiles = result.files);
  }

  Future<void> _startChat() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);
    try {
      final bpValue = _bpSelection == 'Yes'
          ? '${_bpSystolicCtrl.text.trim()}/${_bpDiastolicCtrl.text.trim()} mmHg'
          : 'No';

      final medicalData = {
        'height': double.parse(_heightCtrl.text),
        'weight': double.parse(_weightCtrl.text),
        'diabetes': _diabetesSelection,
        'blood_pressure': bpValue,
      };
      final files = <MultipartFile>[];
      for (final f in _selectedFiles) {
        if (f.bytes != null) {
          files.add(MultipartFile.fromBytes(f.bytes!, filename: f.name));
        }
      }
      final sessionId = await _chatService.createSession(medicalCondition: medicalData, files: files.isEmpty ? null : files);
      if (sessionId == null) throw Exception('Failed');
      setState(() {
        _sessionId = sessionId;
        _isStarted = true;
        _isLoading = false;
        _messages.add({
          'role': 'assistant',
          'content': 'Hello! I am your DiaBP AI Diet Assistant. I have received your health profile and I am ready to help you with personalized nutrition advice. What would you like to know about your diet?',
        });
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start session: $e'), backgroundColor: AppTheme.errorRed),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sessionId == null) return;
    _msgCtrl.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isSending = true;
    });
    _scrollToBottom();
    try {
      final resp = await _chatService.sendMessage(
        sessionId: _sessionId!,
        message: text,
        chatHistory: _messages.map((m) => {'role': m['role'], 'content': m['content']}).toList(),
      );
      setState(() {
        _messages.add({'role': 'assistant', 'content': resp['response'] ?? 'No response'});
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Sorry, I encountered an error. Please try again.'});
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _resetSession() {
    setState(() {
      _sessionId = null;
      _isStarted = false;
      _messages.clear();
      _selectedFiles.clear();
      _bpSystolicCtrl.clear();
      _bpDiastolicCtrl.clear();
      _bpSelection = 'No';
    });
  }
}
