// lib/screens/trends_screen.dart
import 'package:flutter/material.dart';
import '../models/trend_item.dart';
import '../services/trends_service.dart';
import '../theme/app_theme.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final TrendsService _service = TrendsService();
  List<TrendItem> _trends = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final trends = await _service.fetchTrends();
      if (mounted) setState(() => _trends = trends);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load trends');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fashion Trends')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!), TextButton(onPressed: _load, child: const Text('Retry'))]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _trends.length,
                    itemBuilder: (context, i) {
                      final trend = _trends[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: i.isEven ? AppColors.primaryGradient : null,
                          color: i.isEven ? null : AppColors.surface,
                          border: i.isEven ? null : Border.all(color: AppColors.chipUnselected),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trend.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: i.isEven ? Colors.white : AppColors.textDark)),
                            const SizedBox(height: 6),
                            Text(trend.description, style: TextStyle(fontSize: 13, color: i.isEven ? Colors.white.withOpacity(0.9) : AppColors.textMuted)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}