import 'dart:convert';
import '../models/history_item.dart';

class HistoryService {
  /// Fetches all history items
  Future<List<HistoryItem>> fetchHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [];
  }

  /// Fetches detail of a single history item
  Future<HistoryItem?> fetchHistoryDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  /// Deletes a history item by ID
  Future<bool> deleteHistoryItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}