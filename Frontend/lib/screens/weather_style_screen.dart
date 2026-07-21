// lib/screens/weather_style_screen.dart
import 'package:flutter/material.dart';
import '../services/weather_style_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class WeatherStyleScreen extends StatefulWidget {
  const WeatherStyleScreen({super.key});

  @override
  State<WeatherStyleScreen> createState() => _WeatherStyleScreenState();
}

class _WeatherStyleScreenState extends State<WeatherStyleScreen> {
  final WeatherStyleService _service = WeatherStyleService();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  Future<void> _suggest() async {
    setState(() => _loading = true);
    try {
      final response = await _service.suggest(
        weatherDescription: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        temperatureC: double.tryParse(_tempController.text.trim()),
      );
      if (mounted) setState(() => _result = response.result);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _list(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 6),
        ...items.map((i) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $i'))),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Styling')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _descController, decoration: InputDecoration(hintText: 'e.g. "light rain and humid"', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          const SizedBox(height: 12),
          TextField(controller: _tempController, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'Temperature °C (optional)', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          const SizedBox(height: 20),
          GradientButton(
            onPressed: !_loading ? _suggest : null,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Text('Get Suggestions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            _list('Clothing Suggestions', _result!['clothing_suggestions'] as List),
            _list('Fabric Suggestions', _result!['fabric_suggestions'] as List),
            _list('Layering Ideas', _result!['layering_ideas'] as List),
            Text(_result!['summary'].toString(), style: const TextStyle(color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}