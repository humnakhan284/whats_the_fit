// lib/screens/color_palette_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/color_palette_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class ColorPaletteScreen extends StatefulWidget {
  const ColorPaletteScreen({super.key});

  @override
  State<ColorPaletteScreen> createState() => _ColorPaletteScreenState();
}

class _ColorPaletteScreenState extends State<ColorPaletteScreen> {
  final ImagePicker _picker = ImagePicker();
  final ColorPaletteService _service = ColorPaletteService();
  File? _image;
  bool _loading = false;
  Map<String, dynamic>? _result;

  Future<void> _pick() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600);
    if (picked != null) setState(() { _image = File(picked.path); _result = null; });
  }

  Future<void> _analyze() async {
    if (_image == null) return;
    setState(() => _loading = true);
    try {
      final response = await _service.analyze(_image!);
// Line 33 ko is tarah replace karein:
if (mounted) setState(() => _result = response['result'] ?? response);    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _colorChips(String title, List<dynamic> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: colors.map((c) => Chip(label: Text(c.toString()))).toList()),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color Palette Analyzer')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GestureDetector(
            onTap: _pick,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.chipUnselected,
                image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
              ),
              child: _image == null
                  ? const Center(child: Icon(Icons.add_a_photo_rounded, color: AppColors.gradientEnd, size: 36))
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            onPressed: (_image != null && !_loading) ? _analyze : null,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Text('Analyze Colors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _colorChips('Dominant Colors', _result!['dominant_colors'] as List),
            _colorChips('Matching Colors', _result!['matching_colors'] as List),
            _colorChips('Complementary Colors', _result!['complementary_colors'] as List),
            Text(_result!['explanation'].toString(), style: const TextStyle(color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}