// lib/screens/saved_looks_screen.dart
import 'package:flutter/material.dart';
import '../models/saved_look.dart';
import '../services/saved_looks_service.dart';

class SavedLooksScreen extends StatefulWidget {
  const SavedLooksScreen({super.key});

  @override
  State<SavedLooksScreen> createState() => _SavedLooksScreenState();
}

class _SavedLooksScreenState extends State<SavedLooksScreen> {
  final SavedLooksService _looksService = SavedLooksService();
  List<SavedLook> _looks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLooks();
  }

  Future<void> _loadLooks() async {
    setState(() => _loading = true);
    try {
      final looks = await _looksService.fetchLooks();
      if (mounted) setState(() => _looks = looks);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading saved looks: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteLook(String id) async {
    try {
      await _looksService.deleteLook(id);
      if (mounted) {
        setState(() => _looks.removeWhere((l) => l.id == id));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Look removed')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Looks'), backgroundColor: Colors.transparent, elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _looks.isEmpty
              ? const Center(child: Text('No saved looks yet! ❤️'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _looks.length,
                  itemBuilder: (context, i) {
                    final look = _looks[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(look.collectionName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(look.note ?? 'Saved AI Recommendation'),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                          onPressed: () => _deleteLook(look.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}