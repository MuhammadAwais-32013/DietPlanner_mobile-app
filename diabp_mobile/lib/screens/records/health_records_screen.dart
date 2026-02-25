import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/records_service.dart';
import 'package:intl/intl.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  final RecordsService _service = RecordsService();
  List<dynamic> _records = [];
  bool _isLoading = true;
  String _filter = 'All Time';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  Future<void> _loadRecords() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) return;
    try {
      final data = await _service.getRecords(auth.userId!);
      setState(() { _records = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// backend to_dict() returns: { bloodPressure: "120/80", bloodSugar: 100.0, date: "2024-01-01", notes }
  double? _avgBp(String type) {
    if (type == 'systolic') {
      final vals = _records
          .where((r) => r['bloodPressure'] != null)
          .map((r) {
            final parts = (r['bloodPressure'] as String).split('/');
            return parts.isNotEmpty ? double.tryParse(parts[0]) : null;
          })
          .whereType<double>()
          .toList();
      if (vals.isEmpty) return null;
      return vals.reduce((a, b) => a + b) / vals.length;
    } else if (type == 'diastolic') {
      final vals = _records
          .where((r) => r['bloodPressure'] != null)
          .map((r) {
            final parts = (r['bloodPressure'] as String).split('/');
            return parts.length > 1 ? double.tryParse(parts[1]) : null;
          })
          .whereType<double>()
          .toList();
      if (vals.isEmpty) return null;
      return vals.reduce((a, b) => a + b) / vals.length;
    } else {
      final vals = _records
          .where((r) => r['bloodSugar'] != null)
          .map((r) => (r['bloodSugar'] as num).toDouble())
          .toList();
      if (vals.isEmpty) return null;
      return vals.reduce((a, b) => a + b) / vals.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgSystolic = _avgBp('systolic');
    final avgDiastolic = _avgBp('diastolic');
    final avgSugar = _avgBp('sugar');

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  _buildStatCards(avgSystolic, avgDiastolic, avgSugar),
                  const SizedBox(height: 20),
                  _buildRecordHistory(),
                ]),
              )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: _showAddRecordDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Record', style: TextStyle(color: Colors.white)),
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
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF10B981)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.article_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Health Records', style: AppTheme.h2),
            Text('${_records.length} records in your health history', style: AppTheme.bodySmall),
          ]),
        ]),
      ]),
    );
  }

  Widget _buildStatCards(double? avgSys, double? avgDia, double? avgSugar) {
    final cards = [
      {
        'label': 'AVG BLOOD PRESSURE',
        'value': avgSys != null && avgDia != null
            ? '${avgSys.round()}/${avgDia.round()}'
            : '—',
        'unit': 'mmHg · ${_records.length} records',
        'icon': Icons.shield_outlined,
        'color': AppTheme.primaryBlue,
      },
      {
        'label': 'AVG BLOOD SUGAR',
        'value': avgSugar != null ? avgSugar.round().toString() : '—',
        'unit': 'mg/dL · Fasting glucose',
        'icon': Icons.bolt,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'TOTAL RECORDS',
        'value': _records.length.toString(),
        'unit': 'Health monitoring entries',
        'icon': Icons.bar_chart,
        'color': AppTheme.primaryPurple,
      },
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      return isWide
          ? Row(children: cards.map((c) => Expanded(child: _statCard(c))).toList())
          : Column(children: cards.map((c) => _statCard(c)).toList());
    });
  }

  Widget _statCard(Map<String, dynamic> c) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: (c['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c['label'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textGray, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(c['value'] as String, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: c['color'] as Color, height: 1.1)),
            Text(c['unit'] as String, style: AppTheme.bodySmall),
          ])),
        ]),
      ),
    );
  }

  Widget _buildRecordHistory() {
    final filters = ['All Time', 'Last Month', '3 Months', '6 Months'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Record History', style: AppTheme.h3),
            const Spacer(),
            ...filters.map((f) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ChoiceChip(
                label: Text(f, style: const TextStyle(fontSize: 12)),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
                selectedColor: AppTheme.primaryBlue.withOpacity(0.1),
                labelStyle: TextStyle(color: _filter == f ? AppTheme.primaryBlue : AppTheme.textGray),
                side: BorderSide(color: _filter == f ? AppTheme.primaryBlue : AppTheme.borderGray),
              ),
            )),
          ]),
          const SizedBox(height: 16),
          if (_records.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No records yet. Add your first health record!', style: AppTheme.bodySmall),
            ))
          else
            ..._records.reversed.map((r) => _recordItem(r)),
        ]),
      ),
    );
  }

  Widget _recordItem(Map<String, dynamic> r) {
    // Backend returns: date, bloodPressure ("120/80"), bloodSugar (float), notes
    DateTime? date;
    try { date = DateTime.parse(r['date'] ?? r['created_at'] ?? ''); } catch (_) {}
    final bp = r['bloodPressure'] as String?;
    final sugar = r['bloodSugar'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Column(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: const Color(0xFFEFF3FF), borderRadius: BorderRadius.circular(8)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(date != null ? DateFormat('dd').format(date) : '—',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.primaryBlue)),
              Text(date != null ? DateFormat('MMM').format(date) : '',
                  style: const TextStyle(fontSize: 9, color: AppTheme.textGray)),
            ]),
          ),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(date != null ? DateFormat('MMM d, yyyy').format(date) : 'Unknown date',
              style: AppTheme.labelStyle),
          const SizedBox(height: 4),
          Wrap(spacing: 8, children: [
            if (bp != null && bp.isNotEmpty)
              _badge('💧 $bp mmHg', const Color(0xFFEFF3FF), AppTheme.primaryBlue),
            if (sugar != null)
              _badge('🩸 $sugar mg/dL', const Color(0xFFFFF3F3), AppTheme.errorRed),
          ]),
          if (r['notes'] != null && (r['notes'] as String).isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(r['notes'], style: AppTheme.bodySmall.copyWith(fontStyle: FontStyle.italic)),
          ],
        ])),
        Text('#${_records.indexOf(r) + 1}', style: AppTheme.bodySmall),
      ]),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  void _showAddRecordDialog() {
    final sysCtrl = TextEditingController();
    final diaCtrl = TextEditingController();
    final sugarCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Health Record'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: TextFormField(controller: sysCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Systolic (mmHg)', hintText: '120'))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: diaCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Diastolic', hintText: '80'))),
          ]),
          const SizedBox(height: 12),
          TextFormField(controller: sugarCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Blood Sugar (mg/dL)', hintText: '100')),
          const SizedBox(height: 12),
          TextFormField(controller: notesCtrl, maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes (optional)')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              try {
                await _service.addRecord(
                  userId: auth.userId ?? '',
                  systolic: sysCtrl.text.isNotEmpty ? sysCtrl.text : null,
                  diastolic: diaCtrl.text.isNotEmpty ? diaCtrl.text : null,
                  bloodSugar: sugarCtrl.text.isNotEmpty ? sugarCtrl.text : null,
                  notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                );
                if (mounted) { Navigator.pop(context); _loadRecords(); }
              } catch (e) {
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save Record'),
          ),
        ],
      ),
    );
  }
}
