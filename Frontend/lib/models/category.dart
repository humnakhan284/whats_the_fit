import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Category {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color bgColor;

  const Category({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.bgColor,
  });
}

const List<Category> kCategories = [
  Category(
    id: 'clothing',
    title: 'Clothing',
    subtitle: 'Full outfit analysis',
    icon: Icons.checkroom_rounded,
    gradient: [Color(0xFFFF8FC7), Color(0xFF7C4DFF)],
    bgColor: AppColors.lilacSoft,
  ),
  Category(
    id: 'accessories',
    title: 'Accessories',
    subtitle: 'Jewelry, bags & more',
    icon: Icons.diamond_rounded,
    gradient: [Color(0xFFFFC371), Color(0xFFFF5F6D)],
    bgColor: AppColors.yellowSoft,
  ),
  Category(
    id: 'hairstyle',
    title: 'Hairstyle',
    subtitle: 'Cuts & styling ideas',
    icon: Icons.content_cut_rounded,
    gradient: [Color(0xFF6DD5FA), Color(0xFF2980B9)],
    bgColor: AppColors.skySoft,
  ),
  Category(
    id: 'makeup',
    title: 'Makeup',
    subtitle: 'Looks that complement you',
    icon: Icons.face_retouching_natural_rounded,
    gradient: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
    bgColor: AppColors.coralSoft,
  ),
];
