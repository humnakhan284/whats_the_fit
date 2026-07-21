// lib/widgets/recent_analyses_row.dart
import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class RecentAnalysesRow extends StatefulWidget {
  const RecentAnalysesRow({super.key});

  @override
  State<RecentAnalysesRow> createState() => _RecentAnalysesRowState();
}

class _RecentAnalysesRowState extends State<RecentAnalysesRow> {
  final HistoryService _service = HistoryService();
  List<HistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.fetchHistory();
      if (mounted) setState(() => _items = items.take(6).toList());
    } catch (_) {
      // silently ignore on home screen
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 90, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = _items[i];
          final imageUrl = item.primaryImageUrl ?? item.secondaryImageUrl;

          return Container(
            width: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.chipUnselected,
              image: imageUrl != null
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(8),
            child: Text(
              item.category,
              style: const TextStyle(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          );
        },
      ),
    );
  }
}