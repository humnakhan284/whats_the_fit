import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ResultCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool accentGradientIcon;

  const ResultCard({super.key, required this.icon, required this.title, required this.child, this.accentGradientIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.gradientMid.withOpacity(0.10), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: accentGradientIcon ? AppColors.primaryGradient : null,
                  color: accentGradientIcon ? null : AppColors.chipUnselected,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: accentGradientIcon ? Colors.white : AppColors.gradientEnd),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark))),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
