import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../models/attendance_record.dart';

class HistoryScreen extends StatefulWidget {
  final List<AttendanceRecord> records;
  const HistoryScreen({super.key, required this.records});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'All';
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AttendanceRecord> get _filteredRecords {
    final list = widget.records.isEmpty
        ? AttendanceRecord.demoList
        : widget.records;
    return list.where((r) {
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Present' && r.isPresent) ||
          (_filter == 'Absent' && !r.isPresent);
      final matchesQuery = _query.isEmpty ||
          r.eventTitle.toLowerCase().contains(_query.toLowerCase()) ||
          r.eventVenue.toLowerCase().contains(_query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Title Header
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance History',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    const Text('Complete record of your biometric verifications',
                        style: TextStyle(color: AppTheme.textSub, fontSize: 13)),
                  ],
                ),
              ),
            ),

            // Search Bar & Filter Chips
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceLg),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Search events or venues...',
                          hintStyle:
                              TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          prefixIcon: Icon(Icons.search,
                              color: AppTheme.textMuted, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceLg),
                    child: Row(
                      children: ['All', 'Present', 'Absent'].map((f) {
                        final selected = _filter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(f),
                            selected: selected,
                            onSelected: (_) => setState(() => _filter = f),
                            backgroundColor: AppTheme.bgSurface,
                            selectedColor: AppTheme.cyan.withValues(alpha: 0.2),
                            checkmarkColor: AppTheme.cyan,
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppTheme.cyan
                                  : AppTheme.textSub,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                              side: BorderSide(
                                color: selected
                                    ? AppTheme.cyan
                                    : AppTheme.border,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spaceLg)),

            // Records List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = _filteredRecords[i];
                    return _HistoryCard(record: item);
                  },
                  childCount: _filteredRecords.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AttendanceRecord record;
  const _HistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = record.isPresent ? AppTheme.green : AppTheme.red;
    final dateFmt = DateFormat('EEEE, MMM d, yyyy');
    final timeFmt = DateFormat('hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(record.eventTitle,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  record.isPresent ? 'Present' : 'Absent',
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppTheme.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(record.eventVenue,
                  style: const TextStyle(color: AppTheme.textSub, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${dateFmt.format(record.timestamp)} • ${timeFmt.format(record.timestamp)}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              Text(
                'Cosine Sim: ${(record.similarityScore * 100).toInt()}%',
                style: const TextStyle(
                    color: AppTheme.textSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
