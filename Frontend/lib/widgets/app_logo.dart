import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool light;

  const AppLogo({super.key, this.size = 92, this.light = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.15,
      height: size * 1.15,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: light ? null : AppColors.primaryGradient,
              color: light ? Colors.white : null,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size * 0.42),
                topRight: Radius.circular(size * 0.32),
                bottomLeft: Radius.circular(size * 0.30),
                bottomRight: Radius.circular(size * 0.44),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientMid.withOpacity(0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          Positioned(
            top: size * 0.36,
            left: size * 0.30,
            child: _dot(size * 0.09, light ? AppColors.gradientEnd : Colors.white),
          ),
          Positioned(
            top: size * 0.36,
            right: size * 0.30,
            child: _dot(size * 0.09, light ? AppColors.gradientEnd : Colors.white),
          ),
          Positioned(
            top: size * 0.50,
            left: size * 0.16,
            child: _dot(size * 0.075, AppColors.coral.withOpacity(0.55)),
          ),
          Positioned(
            top: size * 0.50,
            right: size * 0.16,
            child: _dot(size * 0.075, AppColors.coral.withOpacity(0.55)),
          ),
          Positioned(
            top: -size * 0.08,
            right: size * 0.02,
            child: Icon(Icons.auto_awesome_rounded, size: size * 0.24, color: AppColors.yellow),
          ),
          Positioned(
            bottom: -size * 0.04,
            left: -size * 0.10,
            child: Icon(Icons.auto_awesome_rounded, size: size * 0.16, color: AppColors.coral),
          ),
          Positioned(
            top: -size * 0.10,
            left: size * 0.30,
            child: Transform.rotate(
              angle: -0.15,
              child: Icon(Icons.favorite_rounded, size: size * 0.20, color: AppColors.mint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
