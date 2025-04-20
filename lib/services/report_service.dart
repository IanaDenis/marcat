// lib/services/report_service.dart
import 'package:get_it/get_it.dart';
import 'package:peval/models/sale.dart';
import 'package:peval/models/sale_item.dart';
import 'package:peval/services/database_service.dart';

class ReportService {
  // Singleton pattern
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final DatabaseService _databaseService = GetIt.I<DatabaseService>();

  // Obține vânzările pentru o anumită dată
  Future<List<Sale>> getSalesByDate(DateTime date) async {
    final db = await _databaseService.isar;
    
    // Construim intervalul pentru data selectată (toată ziua)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    
    // Interogăm vânzările din intervalul de timp
    return await db.collection<Sale>()
      .filter()
      .dateBetween(startOfDay, endOfDay)
      .findAll();
  }

  // Obține elementele unei vânzări specifice
  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await _databaseService.isar;
    return await db.collection<SaleItem>()
      .filter()
      .saleIdEqualTo(saleId)
      .findAll();
  }

  // Obține totalul vânzărilor pentru o anumită dată
  Future<double> getTotalSalesByDate(DateTime date) async {
    final sales = await getSalesByDate(date);
    double total = 0.0;
    for (var sale in sales) {
      total += sale.totalAmount;
    }
    return total;
  }

  // Obține numărul de vânzări pentru o anumită dată
  Future<int> getSalesCountByDate(DateTime date) async {
    final sales = await getSalesByDate(date);
    return sales.length;
  }

  // Obține vânzarea după ID
  Future<Sale?> getSaleById(int id) async {
    final db = await _databaseService.isar;
    return await db.collection<Sale>().get(id);
  }
  
  // Șterge o vânzare și elementele sale
  Future<bool> deleteSale(int saleId) async {
    final db = await _databaseService.isar;
    bool success = false;
    
    await db.writeTxn(() async {
      // Ștergem elementele vânzării
      final saleItems = await db.collection<SaleItem>()
        .filter()
        .saleIdEqualTo(saleId)
        .findAll();
      
      for (final item in saleItems) {
        await db.collection<SaleItem>().delete(item.id);
      }
      
      // Ștergem vânzarea
      success = await db.collection<Sale>().delete(saleId);
    });
    
    return success;
  }
}