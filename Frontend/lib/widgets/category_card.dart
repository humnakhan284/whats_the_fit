import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final double tilt;

  const CategoryCard({super.key, required this.category, required this.onTap, this.tilt = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: category.bgColor,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 8)),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: category.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: category.gradient.last.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 14),
                  Text(category.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(category.subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Try it', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: category.gradient.last)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: category.gradient.last),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
