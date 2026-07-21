// lib/widgets/trending_preview_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Simple trending preview — wire to GET /api/trends the same way as DailyTipCard
// once you build the trends model + service (batch 2).
class TrendingPreviewCard extends StatelessWidget {
  final VoidCallback? onSeeAll;
  const TrendingPreviewCard({super.key, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Check out this week\'s fashion trends', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('See all'),
          ),
        ],
      ),
    );
  }
}