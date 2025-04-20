// lib/services/database_service.dart
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peval/models/product.dart';
import 'package:peval/models/sale.dart';
import 'package:peval/models/sale_item.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;
  bool _isInitializing = false;

  Future<Isar> get isar async {
    if (_isar != null) {
      return _isar!;
    }

    if (_isInitializing) {
      // Așteptăm până când inițializarea curentă este completă
      while (_isInitializing) {
        await Future.delayed(Duration(milliseconds: 50));
      }
      return _isar!;
    }

    _isInitializing = true;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [ProductSchema, SaleSchema, SaleItemSchema],
        directory: dir.path,
      );
      return _isar!;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }
}