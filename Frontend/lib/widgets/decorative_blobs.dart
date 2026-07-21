import 'package:flutter/material.dart';

class DecorativeBlobs extends StatelessWidget {
  final bool light;

  const DecorativeBlobs({super.key, this.light = false});

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : Colors.black;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: _blob(120, color.withOpacity(light ? 0.12 : 0.03)),
          ),
          Positioned(
            top: 90,
            left: -50,
            child: _blob(100, color.withOpacity(light ? 0.10 : 0.025)),
          ),
          Positioned(
            top: 220,
            right: 20,
            child: _blob(40, color.withOpacity(light ? 0.18 : 0.05)),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
