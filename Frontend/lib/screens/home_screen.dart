// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/decorative_blobs.dart';
import '../widgets/recent_analyses_row.dart';
import '../widgets/trending_preview_card.dart';

// Imports for screen navigation
import 'category_screen.dart';
import 'color_palette_screen.dart';
import 'history_screen.dart';
import 'outfit_generator_screen.dart';
import 'saved_looks_screen.dart';
import 'settings_screen.dart';
import 'trends_screen.dart';
import 'wardrobe_screen.dart';
import 'weather_style_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Header Banner
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(child: DecorativeBlobs(light: true)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hey gorgeous',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to slay today\'s look?',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _statChip(Icons.auto_awesome_rounded, '4', 'Categories'),
                              _vDivider(),
                              _statChip(Icons.favorite_rounded, 'New', 'Tips daily'),
                              _vDivider(),
                              _statChip(Icons.chat_bubble_rounded, '24/7', 'Stylist chat'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Daily Tips & Recent Activity Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: const [
                    DailyTipCard(),
                    SizedBox(height: 16),
                    RecentAnalysesRow(),
                    SizedBox(height: 16),
                    TrendingPreviewCard(),
                  ],
                ),
              ),
            ),

            // Category Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = kCategories[index];
                    final tilt = index.isEven ? 0.02 : -0.02;
                    return CategoryCard(
                      category: category,
                      tilt: tilt,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CategoryScreen(category: category),
                        ),
                      ),
                    );
                  },
                  childCount: kCategories.length,
                ),
              ),
            ),

            // More AI Tools Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'More AI Tools',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _toolChip(context, 'Outfit Generator', Icons.auto_awesome_rounded, const OutfitGeneratorScreen()),
                        _toolChip(context, 'Color Palette', Icons.palette_rounded, const ColorPaletteScreen()),
                        _toolChip(context, 'Weather Styling', Icons.wb_sunny_rounded, const WeatherStyleScreen()),
                        _toolChip(context, 'Wardrobe', Icons.checkroom_rounded, const WardrobeScreen()),
                        _toolChip(context, 'Trends', Icons.trending_up_rounded, const TrendsScreen()),
                        _toolChip(context, 'History', Icons.history_rounded, const HistoryScreen()),
                        _toolChip(context, 'Saved Looks', Icons.favorite_rounded, const SavedLooksScreen()),
                        _toolChip(context, 'Settings', Icons.settings_rounded, const SettingsScreen()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Tool Chip
  Widget _toolChip(BuildContext context, String label, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.chipUnselected,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.gradientEnd),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Header Stat Chip
  Widget _statChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // Helper Widget: Vertical Divider
  Widget _vDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.3),
    );
  }
}