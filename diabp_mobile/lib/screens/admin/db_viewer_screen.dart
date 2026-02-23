import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/admin_service.dart';

class DbViewerScreen extends StatefulWidget {
  const DbViewerScreen({super.key});

  @override
  State<DbViewerScreen> createState() => _DbViewerScreenState();
}

class _DbViewerScreenState extends State<DbViewerScreen> {
  final AdminService _service = AdminService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String _activeTable = 'users';

  final _tableConfigs = {
    'users': {'label': 'Users', 'icon': Icons.people, 'color': const Color(0xFF3B4AE8)},
    'bmi': {'label': 'BMI Records', 'icon': Icons.monitor_weight, 'color': const Color(0xFF10B981)},
    'diet_plans': {'label': 'Diet Plans', 'icon': Icons.restaurant_menu, 'color': const Color(0xFFF59E0B)},
    'records': {'label': 'Medical Records', 'icon': Icons.medical_information, 'color': const Color(0xFFEF4444)},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _service.getDashboardData();
      setState(() { _data = data; _isLoading = false; });
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
            : _buildContent()),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white70),
          label: const Text('Back to Dashboard', style: TextStyle(color: Colors.white70)),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.storage, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Database Viewer', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            Text('All tables in real-time tabular view', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ]),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _tableConfigs.entries.map((e) {
            final count = (_data?[e.key] as List?)?.length ?? 0;
            final isActive = _activeTable == e.key;
            return GestureDetector(
              onTap: () => setState(() => _activeTable = e.key),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Icon(e.value['icon'] as IconData,
                      color: isActive ? e.value['color'] as Color : Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$count', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: isActive ? e.value['color'] as Color : Colors.white,
                    )),
                    Text(e.value['label'] as String, style: TextStyle(
                      fontSize: 11, color: isActive ? AppTheme.textGray : Colors.white70,
                    )),
                  ]),
                ]),
              ),
            );
          }).toList()),
        ),
      ]),
    );
  }

  Widget _buildContent() {
    if (_data == null) {
      return const Center(child: Text('Unable to load data. Is the backend running?', style: AppTheme.bodySmall));
    }
    final tableData = (_data![_activeTable] as List?) ?? [];
    final config = _tableConfigs[_activeTable]!;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(config['icon'] as IconData, color: config['color'] as Color, size: 20),
          const SizedBox(width: 8),
          Text(config['label'] as String, style: AppTheme.h3),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: (config['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${tableData.length} records', style: TextStyle(color: config['color'] as Color, fontSize: 12)),
          ),
        ]),
      ),
      Expanded(child: tableData.isEmpty
          ? const Center(child: Text('No records found', style: AppTheme.bodySmall))
          : _buildTable(tableData)),
    ]);
  }

  Widget _buildTable(List tableData) {
    if (tableData.isEmpty) return const SizedBox();
    final headers = (tableData.first as Map).keys.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Card(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppTheme.lightGray),
            headingTextStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.textGray, letterSpacing: 0.5),
            dataTextStyle: const TextStyle(fontSize: 13, color: AppTheme.textDark),
            columns: headers.map((h) => DataColumn(label: Text(h.toString().toUpperCase()))).toList(),
            rows: tableData.map((row) {
              final r = row as Map;
              return DataRow(cells: headers.map((h) {
                final v = r[h];
                return DataCell(_cellWidget(h, v));
              }).toList());
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _cellWidget(String key, dynamic value) {
    if (key == 'name' || key == 'username') {
      return Row(children: [
        CircleAvatar(
          radius: 14, backgroundColor: AppTheme.primaryBlue,
          child: Text((value?.toString() ?? 'U')[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Text(value?.toString() ?? '—'),
      ]);
    }
    return Text(value?.toString() ?? '—');
  }
}
