import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

  // Diabetes fields
  String _diabetesSelection = 'No';   // No | Yes
  String _diabetesType = '';          // type1 | type2
  String _diabetesLevel = '';         // controlled | uncontrolled

  // BP fields
  String _bpSelection = 'No';         // No | Yes
  final _bpSystolicCtrl = TextEditingController();
  final _bpDiastolicCtrl = TextEditingController();

  List<PlatformFile> _selectedFiles = [];

  // --- Chat view state ---
  // Collapsible health-profile banner
  bool _showMedicalPanel = true;
  Map<String, dynamic>? _medicalData;  // fetched from /medical-data

  // Diet plan generator
  String _dietPlanDuration = '7_days';
  bool _isGeneratingPlan = false;

  static const TextStyle _hintStyle = TextStyle(
    color: Color(0xFFBBC0CC),
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const List<Map<String, String>> _durationOptions = [
    {'label': '7 Days (1 Week)', 'value': '7_days'},
    {'label': '10 Days', 'value': '10_days'},
    {'label': '14 Days (2 Weeks)', 'value': '14_days'},
    {'label': '21 Days (3 Weeks)', 'value': '21_days'},
    {'label': '30 Days (1 Month)', 'value': '30_days'},
  ];

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
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle),
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

  // ─────────────────────────────────────── SETUP VIEW ───────────────────────
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
                // Welcome banner
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

                // Height + Weight
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

                // ── Diabetes section ──────────────────────────────────────
                _simpleDropdown(
                  label: 'Do you have Diabetes?',
                  value: _diabetesSelection,
                  options: const ['No', 'Yes'],
                  onChanged: (v) => setState(() {
                    _diabetesSelection = v!;
                    _diabetesType = '';
                    _diabetesLevel = '';
                  }),
                ),
                if (_diabetesSelection == 'Yes') ...[
                  const SizedBox(height: 12),
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 500;
                    final typeField = _conditionalDropdown(
                      label: 'Type of Diabetes',
                      value: _diabetesType,
                      options: const ['', 'type1', 'type2'],
                      labels: const ['Select', 'Type 1', 'Type 2'],
                      validator: (v) => (v == null || v.isEmpty) ? 'Select diabetes type' : null,
                      onChanged: (v) => setState(() => _diabetesType = v!),
                    );
                    final levelField = _conditionalDropdown(
                      label: 'Diabetes Level',
                      value: _diabetesLevel,
                      options: const ['', 'controlled', 'uncontrolled'],
                      labels: const ['Select', 'Controlled', 'Uncontrolled'],
                      validator: (v) => (v == null || v.isEmpty) ? 'Select diabetes level' : null,
                      onChanged: (v) => setState(() => _diabetesLevel = v!),
                    );
                    return isWide
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: typeField),
                            const SizedBox(width: 12),
                            Expanded(child: levelField),
                          ])
                        : Column(children: [typeField, const SizedBox(height: 12), levelField]);
                  }),
                ],
                const SizedBox(height: 16),

                // ── Blood Pressure section ────────────────────────────────
                _simpleDropdown(
                  label: 'Do you have Blood Pressure issues?',
                  value: _bpSelection,
                  options: const ['No', 'Yes'],
                  onChanged: (v) => setState(() {
                    _bpSelection = v!;
                    if (v == 'No') {
                      _bpSystolicCtrl.clear();
                      _bpDiastolicCtrl.clear();
                    }
                  }),
                ),
                if (_bpSelection == 'Yes') ...[
                  const SizedBox(height: 12),
                  LayoutBuilder(builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 500;
                    final systolicField = _numericSubField(
                      label: 'Systolic (mmHg)',
                      ctrl: _bpSystolicCtrl,
                      hint: 'e.g. 130',
                      icon: Icons.arrow_upward,
                      iconColor: AppTheme.errorRed,
                      helperText: 'Upper number',
                      validator: (v) {
                        if (_bpSelection != 'Yes') return null;
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Required';
                        if (n < 60 || n > 300) return 'Between 60–300';
                        return null;
                      },
                    );
                    final diastolicField = _numericSubField(
                      label: 'Diastolic (mmHg)',
                      ctrl: _bpDiastolicCtrl,
                      hint: 'e.g. 85',
                      icon: Icons.arrow_downward,
                      iconColor: AppTheme.primaryBlue,
                      helperText: 'Lower number',
                      validator: (v) {
                        if (_bpSelection != 'Yes') return null;
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Required';
                        if (n < 40 || n > 200) return 'Between 40–200';
                        return null;
                      },
                    );
                    return isWide
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: systolicField),
                            const SizedBox(width: 12),
                            Expanded(child: diastolicField),
                          ])
                        : Column(children: [systolicField, const SizedBox(height: 12), diastolicField]);
                  }),
                  const SizedBox(height: 4),
                  Text('Normal BP: 120/80 mmHg. Enter your latest reading.',
                      style: AppTheme.bodySmall.copyWith(color: const Color(0xFFBBC0CC))),
                ],
                const SizedBox(height: 16),

                // ── Medical Documents ─────────────────────────────────────
                const Text('Medical Documents (Optional)', style: AppTheme.labelStyle),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickFiles,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4)),
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
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _selectedFiles.remove(f)),
                      ),
                    ]),
                  )),
                ],
                const SizedBox(height: 20),

                // ── Start Chat ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _startChat,
                    icon: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.chat_bubble, size: 18),
                    label: Text(_isLoading ? 'Setting up...' : 'Start Chat'),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────── CHAT VIEW ────────────────────────
  Widget _buildChatView() {
    return Column(children: [
      // ── 1. Collapsible Health Profile Banner ──────────────────────────────
      _buildHealthProfileBanner(),

      // ── 2. Diet Plan Generator Bar ────────────────────────────────────────
      _buildDietPlanBar(),

      // ── 3. Messages ───────────────────────────────────────────────────────
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

      // ── 4. Input Bar ──────────────────────────────────────────────────────
      _buildInputBar(),
    ]);
  }

  Widget _buildHealthProfileBanner() {
    final hasDiabetes = _diabetesSelection == 'Yes';
    final hasBP = _bpSelection == 'Yes';
    final height = double.tryParse(_heightCtrl.text) ?? 0;
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final bmi = (height > 0 && weight > 0)
        ? (weight / ((height / 100) * (height / 100))).toStringAsFixed(1)
        : 'N/A';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFF86EFAC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        // Header row — always visible
        GestureDetector(
          onTap: () => setState(() => _showMedicalPanel = !_showMedicalPanel),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              AnimatedRotation(
                turns: _showMedicalPanel ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more, size: 18, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text('Your Health Profile',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
              ),
              Text(_showMedicalPanel ? 'Hide' : 'Show',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
            ]),
          ),
        ),

        // Expanded content
        if (_showMedicalPanel) ...[
          const Divider(color: Color(0xFF86EFAC), height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(children: [
              // User-entered data
              _profileRow(Icons.height, 'Height', '${_heightCtrl.text} cm'),
              _profileRow(Icons.monitor_weight_outlined, 'Weight', '${_weightCtrl.text} kg'),
              _profileRow(Icons.calculate, 'BMI', bmi),
              _profileRow(
                Icons.water_drop,
                'Diabetes',
                hasDiabetes
                    ? '${_diabetesType.replaceFirst('type', 'Type ')} — ${_diabetesLevel}'
                    : 'No',
              ),
              _profileRow(
                Icons.favorite,
                'Blood Pressure',
                hasBP
                    ? '${_bpSystolicCtrl.text}/${_bpDiastolicCtrl.text} mmHg'
                    : 'Normal',
              ),
              // PDF-extracted medical data
              if (_medicalData != null) ...[
                const SizedBox(height: 6),
                const Divider(color: Color(0xFF86EFAC), height: 1),
                const SizedBox(height: 6),
                _profileRow(
                  Icons.biotech,
                  'Lab Data',
                  (_medicalData!['medical_data']?['lab_results']?['has_lab_data'] ?? 'No').toString(),
                ),
                if ((_medicalData!['medical_data']?['diabetes_info']?['diagnosis'] ?? 'No') != 'No')
                  _profileRow(
                    Icons.science,
                    'Glucose',
                    (_medicalData!['medical_data']?['diabetes_info']?['glucose_levels'] ?? 'No').toString(),
                  ),
                if ((_medicalData!['medical_data']?['blood_pressure_info']?['readings'] ?? 'No') != 'No')
                  _profileRow(
                    Icons.monitor_heart,
                    'BP Reading',
                    (_medicalData!['medical_data']?['blood_pressure_info']?['readings'] ?? 'No').toString(),
                  ),
              ],
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.picture_as_pdf, size: 14, color: AppTheme.errorRed),
                  const SizedBox(width: 6),
                  Text('${_selectedFiles.length} PDF file(s) uploaded',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF15803D))),
                ]),
              ],
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 13, color: const Color(0xFF16A34A)),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 11, color: Color(0xFF15803D)),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }

  Widget _buildDietPlanBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        const Icon(Icons.restaurant_menu, size: 16, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _dietPlanDuration,
              isDense: true,
              style: const TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w500),
              items: _durationOptions.map((opt) => DropdownMenuItem<String>(
                value: opt['value'],
                child: Text(opt['label']!),
              )).toList(),
              onChanged: (v) => setState(() => _dietPlanDuration = v!),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: _isGeneratingPlan ? null : _generateDietPlan,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: _isGeneratingPlan
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Generate Plan'),
          ),
        ),
      ]),
    );
  }

  Widget _messageItem(Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    final isDietPlan = msg['isDietPlan'] == true;
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
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
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
                // Diet plan badge + Download PDF
                if (isDietPlan) ...[                  
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Generated badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.check_circle, size: 12, color: Color(0xFF10B981)),
                          const SizedBox(width: 3),
                          Text(
                            '${_durationLabel(msg['duration'] as String?)} Plan Generated',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 6),
                      // Download PDF button
                      InkWell(
                        onTap: () => _downloadDietPlan(
                          content: msg['content'] as String,
                          duration: msg['duration'] as String? ?? _dietPlanDuration,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.35)),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.picture_as_pdf, size: 12, color: Color(0xFF2563EB)),
                            SizedBox(width: 3),
                            Text('Download PDF',
                              style: TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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

  String _durationLabel(String? dur) {
    final opt = _durationOptions.firstWhere(
      (o) => o['value'] == dur,
      orElse: () => {'label': dur ?? ''},
    );
    return opt['label'] ?? '';
  }

  /// Builds a PDF from the diet plan content and downloads it
  Future<void> _downloadDietPlan({required String content, required String duration}) async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final filename = 'diet_plan_${duration}_$dateStr.pdf';

    final doc = pw.Document();

    // Patient info
    final hVal = double.tryParse(_heightCtrl.text) ?? 0;
    final wVal = double.tryParse(_weightCtrl.text) ?? 0;
    final bmiVal = (hVal > 0 && wVal > 0)
        ? (wVal / ((hVal / 100) * (hVal / 100))).toStringAsFixed(1)
        : 'N/A';

    final diabetesStr = _diabetesSelection == 'Yes'
        ? '$_diabetesType ($_diabetesLevel)'
        : 'No';
    final bpStr = _bpSelection == 'Yes'
        ? '${_bpSystolicCtrl.text}/${_bpDiastolicCtrl.text} mmHg'
        : 'Normal';

    final patientLines = [
      'Height: ${_heightCtrl.text} cm',
      'Weight: ${_weightCtrl.text} kg',
      'BMI: $bmiVal kg/m\u00b2',
      'Diabetes: $diabetesStr',
      'Blood Pressure: $bpStr',
    ];

    final contentLines = content.split('\n');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (_) => pw.Container(
          color: PdfColors.blue800,
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Personalized Diet Plan',
                  style: pw.TextStyle(
                      color: PdfColors.white, fontSize: 16,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text('AI-Powered Nutrition Guidance',
                  style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}  \u2022  Generated by AI Diet Assistant',
            style: const pw.TextStyle(color: PdfColors.grey, fontSize: 9),
          ),
        ),
        build: (_) => [
          // Patient info box
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            margin: const pw.EdgeInsets.only(bottom: 16, top: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              border: pw.Border.all(color: PdfColors.blue200),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Patient Information',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900)),
                pw.SizedBox(height: 6),
                ...patientLines.map((l) => pw.Text('\u2022 $l',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.blueGrey800))),
              ],
            ),
          ),
          // Diet plan lines
          ...contentLines.map((line) {
            final t = line.trim();
            if (t.isEmpty) return pw.SizedBox(height: 4);
            if (RegExp(r'^Day \d+:', caseSensitive: false).hasMatch(t)) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(top: 10, bottom: 4),
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(t,
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900)),
              );
            }
            if (t.endsWith(':') && !t.startsWith('-') && !t.startsWith('\u2022')) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8, bottom: 2),
                child: pw.Text(t,
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800)),
              );
            }
            return pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
              child: pw.Text(t,
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.blueGrey700)),
            );
          }),
          // Disclaimer
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              border: pw.Border.all(color: PdfColors.orange200),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Text(
              'DISCLAIMER: This AI-generated diet plan is for educational purposes only '
              'and is NOT a substitute for professional medical advice. Always consult your '
              'healthcare provider before making significant dietary changes.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.orange900),
            ),
          ),
        ],
      ),
    );

    // Trigger a direct file download in Chrome web via dart:html
    final bytes = await doc.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
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
              hintText: 'Ask about diet, nutrition, generate a plan...',
              hintStyle: _hintStyle,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.borderGray)),
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

  // ───────────────────────────────────── FORM HELPERS ───────────────────────
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

  Widget _inputField(String label, TextEditingController ctrl, String hint, String? Function(String?) validator) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.labelStyle),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(hintText: hint, hintStyle: _hintStyle),
        validator: validator,
      ),
    ]);
  }

  Widget _simpleDropdown({
    required String label,
    required String value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
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

  Widget _conditionalDropdown({
    required String label,
    required String value,
    required List<String> options,
    required List<String> labels,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.labelStyle),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(),
        items: List.generate(options.length, (i) =>
            DropdownMenuItem(value: options[i], child: Text(labels[i]))).toList(),
        validator: validator,
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _numericSubField({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required String helperText,
    required String? Function(String?) validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTheme.labelStyle),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: _hintStyle,
          prefixIcon: Icon(icon, size: 16, color: iconColor),
          helperText: helperText,
        ),
        validator: validator,
      ),
    ]);
  }

  // ───────────────────────────────────── ACTIONS ────────────────────────────
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: true);
    if (result != null) setState(() => _selectedFiles = result.files);
  }

  Future<void> _startChat() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);
    try {
      final bpValue = _bpSelection == 'Yes'
          ? '${_bpSystolicCtrl.text.trim()}/${_bpDiastolicCtrl.text.trim()} mmHg'
          : 'No';

      // Build medical payload matching the web app's format
      final medicalCondition = {
        'hasDiabetes': _diabetesSelection == 'Yes',
        'diabetesType': _diabetesType,
        'diabetesLevel': _diabetesLevel,
        'hasHypertension': _bpSelection == 'Yes',
        'systolic': _bpSelection == 'Yes' ? _bpSystolicCtrl.text.trim() : '',
        'diastolic': _bpSelection == 'Yes' ? _bpDiastolicCtrl.text.trim() : '',
        'height': double.tryParse(_heightCtrl.text) ?? 0,
        'weight': double.tryParse(_weightCtrl.text) ?? 0,
        // Legacy fields used by backend prompts
        'diabetes': _diabetesSelection == 'Yes' ? '$_diabetesType ($_diabetesLevel)' : 'No',
        'blood_pressure': bpValue,
      };

      final files = <MultipartFile>[];
      for (final f in _selectedFiles) {
        if (f.bytes != null) {
          files.add(MultipartFile.fromBytes(f.bytes!, filename: f.name));
        }
      }

      final sessionId = await _chatService.createSession(
        medicalCondition: medicalCondition,
        files: files.isEmpty ? null : files,
      );
      if (sessionId == null) throw Exception('Failed to create session');

      // Fetch medical data extracted from PDFs (if any files uploaded)
      Map<String, dynamic>? medicalData;
      if (_selectedFiles.isNotEmpty) {
        medicalData = await _chatService.fetchMedicalData(sessionId);
      }

      final height = double.tryParse(_heightCtrl.text) ?? 0;
      final weight = double.tryParse(_weightCtrl.text) ?? 0;
      final bmi = (height > 0 && weight > 0)
          ? (weight / ((height / 100) * (height / 100))).toStringAsFixed(1)
          : 'N/A';

      setState(() {
        _sessionId = sessionId;
        _isStarted = true;
        _isLoading = false;
        _medicalData = medicalData;
        _messages.add({
          'role': 'assistant',
          'content':
              'Hello! I am your DiaBP AI Diet Assistant. I have received your health profile:\n\n'
              '• Diabetes: ${_diabetesSelection == 'Yes' ? '$_diabetesType ($_diabetesLevel)' : 'No'}\n'
              '• Blood Pressure: $bpValue\n'
              '• BMI: $bmi kg/m²\n\n'
              'I can create personalized diet plans for 7, 10, 14, 21, or 30 days.\n\n'
              '💡 Use the "Generate Plan" bar above or ask me:\n'
              '  • "Generate a 7 day diet plan"\n'
              '  • "What foods help with diabetes?"\n'
              '  • "Give me DASH diet tips"\n\n'
              '⚠️ This is for educational purposes only. Always consult your healthcare provider.',
        });
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start session: $e'), backgroundColor: AppTheme.errorRed),
      );
    }
  }

  Future<void> _generateDietPlan() async {
    if (_sessionId == null) return;
    setState(() => _isGeneratingPlan = true);
    final dLabel = _durationLabel(_dietPlanDuration);
    // Show a placeholder message while generating
    setState(() {
      _messages.add({'role': 'user', 'content': 'Generate a $dLabel diet plan for me.'});
      _isSending = true;
    });
    _scrollToBottom();
    try {
      final resp = await _chatService.generateDietPlan(
        sessionId: _sessionId!,
        duration: _dietPlanDuration,
      );
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': resp['diet_plan'] as String? ?? 'No plan generated.',
          'isDietPlan': true,
          'duration': _dietPlanDuration,
        });
        _isSending = false;
        _isGeneratingPlan = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant',
            'content': 'Sorry, failed to generate the diet plan. Please try again.'});
        _isSending = false;
        _isGeneratingPlan = false;
      });
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
      final content = resp['response'] as String? ?? 'No response';
      final isDietPlan = content.toLowerCase().contains('day 1:') &&
          (content.toLowerCase().contains('breakfast:') || content.toLowerCase().contains('lifestyle recommendations'));
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': content,
          if (isDietPlan) 'isDietPlan': true,
        });
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
      _diabetesSelection = 'No';
      _diabetesType = '';
      _diabetesLevel = '';
      _medicalData = null;
      _showMedicalPanel = true;
    });
  }
}
