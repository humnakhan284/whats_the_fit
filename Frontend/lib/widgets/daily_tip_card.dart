// lib/widgets/daily_tip_card.dart
import 'package:flutter/material.dart';
import '../models/daily_tip.dart';
import '../services/daily_tip_service.dart';
import '../theme/app_theme.dart';

class DailyTipCard extends StatefulWidget {
  const DailyTipCard({super.key});

  @override
  State<DailyTipCard> createState() => _DailyTipCardState();
}

class _DailyTipCardState extends State<DailyTipCard> {
  final DailyTipService _service = DailyTipService();
  DailyTip? _tip;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tip = await _service.fetchTip();
      if (mounted) setState(() => _tip = tip);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load tip');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.chipUnselected),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.yellowSoft, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.lightbulb_rounded, color: AppColors.yellow),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Style Tip', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                const SizedBox(height: 6),
                if (_loading)
                  const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                else if (_error != null)
                  Text(_error!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))
                else
                  Text(_tip?.tip ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.gradientEnd, size: 20),
          ),
        ],
      ),
    );
  }
}