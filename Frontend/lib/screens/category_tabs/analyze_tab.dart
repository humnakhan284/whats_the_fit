// lib/screens/category_tabs/analyze_tab.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category.dart';
import '../../models/category_result.dart';
import '../../services/category_service.dart';
import '../../services/saved_looks_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/selection_chip.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/result_card.dart';

class AnalyzeTab extends StatefulWidget {
  final Category category;
  const AnalyzeTab({super.key, required this.category});

  @override
  State<AnalyzeTab> createState() => _AnalyzeTabState();
}

class _AnalyzeTabState extends State<AnalyzeTab> {
  static const occasions = ['Casual', 'Work', 'Date Night', 'Party', 'Wedding', 'Interview', 'Formal Event', 'Vacation'];

  final ImagePicker _picker = ImagePicker();
  final CategoryService _service = CategoryService();
  final SavedLooksService _savedLooksService = SavedLooksService();
  final TextEditingController _notesController = TextEditingController();

  File? _image;
  File? _faceImage;
  String? _occasion;
  bool _isAnalyzing = false;
  bool _isSavingLook = false;
  bool _isLookSaved = false;
  CategoryResult? _result;

  bool get _needsFaceImage => widget.category.id == 'makeup' || widget.category.id == 'hairstyle';
  bool get _canAnalyze => _image != null && _occasion != null && !_isAnalyzing;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1600);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = null;
        _isLookSaved = false;
      });
    }
  }

  Future<void> _pickFaceImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1600);
    if (picked != null) {
      setState(() => _faceImage = File(picked.path));
    }
  }

  Future<void> _analyze() async {
    if (!_canAnalyze) return;
    setState(() {
      _isAnalyzing = true;
      _isLookSaved = false;
    });
    try {
      final result = await _service.analyze(
        image: _image!,
        categoryId: widget.category.id,
        occasion: _occasion!,
        notes: _notesController.text,
        faceImage: _faceImage,
      );
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveLook() async {
    if (_result == null || _isLookSaved || _isSavingLook) return;
    setState(() => _isSavingLook = true);
    try {
      await _savedLooksService.saveLook(
        analysisId: _result!.analysisId,
        collectionName: widget.category.title,
        note: 'Analyzed for $_occasion',
      );
      if (mounted) {
        setState(() => _isLookSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to your looks! ❤️')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save look: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingLook = false);
    }
  }

  void _reset() {
    setState(() {
      _image = null;
      _faceImage = null;
      _result = null;
      _occasion = null;
      _isLookSaved = false;
      _notesController.clear();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) return _buildResult(_result!);
    if (_image != null) return _buildCustomize();
    return _buildUploadPrompt();
  }

  Widget _buildUploadPrompt() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.category.gradient),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Icon(widget.category.icon, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text('Upload a photo for ${widget.category.title.toLowerCase()} analysis',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        GradientButton(
          onPressed: () => _pickImage(ImageSource.camera),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Capture Photo', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library_rounded),
          label: const Text('Upload from Gallery'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.gradientEnd),
            foregroundColor: AppColors.gradientEnd,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomize() {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: AppColors.primaryGradient),
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(aspectRatio: 3 / 4, child: Image.file(_image!, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Occasion / Event', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: occasions.map((o) => SelectionChip(label: o, selected: _occasion == o, onTap: () => setState(() => _occasion = o))).toList(),
            ),
            if (_needsFaceImage) ...[
              const SizedBox(height: 24),
              Text('Face photo (optional)', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (_faceImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_faceImage!, height: 140, width: 140, fit: BoxFit.cover),
                ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _pickFaceImage(ImageSource.gallery),
                icon: const Icon(Icons.face_retouching_natural_rounded),
                label: Text(_faceImage == null ? 'Add face photo' : 'Change face photo'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gradientEnd),
                  foregroundColor: AppColors.gradientEnd,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('Additional details (optional)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. "I want something more office-appropriate"',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: GradientButton(
            onPressed: _canAnalyze ? _analyze : null,
            child: _isAnalyzing
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Text('Analyze', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(CategoryResult result) {
    final entries = result.result.entries.where((e) {
      final v = e.value;
      if (v == null) return false;
      if (v is String) return v.trim().isNotEmpty;
      if (v is List) return v.isNotEmpty;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24)),
          child: Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(_image!, width: 76, height: 76, fit: BoxFit.cover)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.category.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Analysis for $_occasion', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                onPressed: _isSavingLook ? null : _saveLook,
                icon: Icon(
                  _isLookSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...entries.map(
          (e) => ResultCard(
            icon: widget.category.icon,
            title: _prettifyKey(e.key),
            child: _buildValue(e.value),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _reset,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.gradientEnd),
            foregroundColor: AppColors.gradientEnd,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Analyze Another Photo'),
        ),
      ],
    );
  }

  String _prettifyKey(String key) {
    return key
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Widget _buildValue(dynamic value) {
    if (value is List) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: value
            .map((v) => Chip(label: Text(v.toString()), backgroundColor: AppColors.chipUnselected, side: BorderSide.none))
            .toList(),
      );
    }
    return Text(value.toString());
  }
}