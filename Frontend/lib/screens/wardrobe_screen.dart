// lib/screens/wardrobe_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/wardrobe_item.dart';
import '../services/wardrobe_service.dart';
import '../theme/app_theme.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final WardrobeService _service = WardrobeService();
  final ImagePicker _picker = ImagePicker();
  List<WardrobeItem> _items = [];
  bool _loading = true;

  static const categories = ['shirts', 'dresses', 'pants', 'shoes', 'accessories', 'other'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _service.fetchItems();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Load failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(WardrobeItem item) async {
    try {
      await _service.deleteItem(item.id);
      if (mounted) setState(() => _items.removeWhere((e) => e.id == item.id));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _addItemFlow() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600);
    if (picked == null || !mounted) return;

    String category = categories.first;
    final nameController = TextEditingController();
    final colorController = TextEditingController();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add wardrobe item', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: categories.map((c) => ChoiceChip(
                  label: Text(c),
                  selected: category == c,
                  onSelected: (_) => setSheetState(() => category = c),
                )).toList(),
              ),
              const SizedBox(height: 12),
              TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Name (optional)')),
              const SizedBox(height: 8),
              TextField(controller: colorController, decoration: const InputDecoration(hintText: 'Color (optional)')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Add to wardrobe'),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final item = await _service.addItem(
        image: File(picked.path),
        category: category,
        name: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
        color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
      );
      if (mounted) setState(() => _items.insert(0, item));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Add failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Wardrobe')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItemFlow,
        backgroundColor: AppColors.gradientEnd,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Your wardrobe is empty', style: TextStyle(color: AppColors.textMuted)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    return GestureDetector(
                      onLongPress: () => _delete(item),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: AppColors.chipUnselected,
                                image: item.imageUrl != null
                                    ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(item.name ?? item.category, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}