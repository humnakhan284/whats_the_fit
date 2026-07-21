// lib/screens/outfit_generator_screen.dart
import 'package:flutter/material.dart';
import '../services/outfit_generator_service.dart';
import '../services/saved_looks_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/selection_chip.dart';

class OutfitGeneratorScreen extends StatefulWidget {
  const OutfitGeneratorScreen({super.key});

  @override
  State<OutfitGeneratorScreen> createState() => _OutfitGeneratorScreenState();
}

class _OutfitGeneratorScreenState extends State<OutfitGeneratorScreen> {
  static const events = ['Wedding', 'Work', 'Date Night', 'Party', 'Interview', 'Vacation'];
  static const styles = ['Minimal', 'Streetwear', 'Boho', 'Classic', 'Y2K', 'Old Money'];

  final OutfitGeneratorService _service = OutfitGeneratorService();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _event;
  String? _style;
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _analysisId;

  Future<void> _generate() async {
    if (_event == null) return;
    setState(() => _loading = true);
    try {
      final response = await _service.generate(
        event: _event!,
        style: _style,
        colorPreference: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        additionalPrompt: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      if (mounted) setState(() {
        _result = response.result;
        _analysisId = response.analysisId;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_analysisId == null) return;
    try {
      await SavedLooksService().saveLook(analysisId: _analysisId!, collectionName: 'Generated Outfits');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Generator')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Occasion', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: events.map((e) => SelectionChip(label: e, selected: _event == e, onTap: () => setState(() => _event = e))).toList(),
          ),
          const SizedBox(height: 20),
          Text('Style', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: styles.map((s) => SelectionChip(label: s, selected: _style == s, onTap: () => setState(() => _style = _style == s ? null : s))).toList(),
          ),
          const SizedBox(height: 20),
          TextField(controller: _colorController, decoration: InputDecoration(hintText: 'Color preference (optional)', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          const SizedBox(height: 12),
          TextField(controller: _notesController, maxLines: 2, decoration: InputDecoration(hintText: 'Additional notes (optional)', filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          const SizedBox(height: 24),
          GradientButton(
            onPressed: (_event != null && !_loading) ? _generate : null,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Text('Generate Look', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          if (_result != null) ...[
            const SizedBox(height: 28),
            ..._result!.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(e.value.toString()),
                    ],
                  ),
                )),
            OutlinedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.favorite_border_rounded),
              label: const Text('Save this look'),
            ),
          ],
        ],
      ),
    );
  }
}