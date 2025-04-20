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

  // Obține vânzările pentru o anumită dată - implementare alternativă
  Future<List<Sale>> getSalesByDate(DateTime date) async {
    final db = await _databaseService.isar;
    
    // Construim intervalul pentru data selectată (toată ziua)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    
    print('Căutare vânzări între ${startOfDay.toString()} și ${endOfDay.toString()}');
    
    try {
      // Metoda alternativă pentru findAll() în această versiune de Isar
      final jsonList = await db.sales.buildQuery().exportJson();
      print('Vânzări găsite în total: ${jsonList.length}');
      
      if (jsonList.isNotEmpty) {
        // Afișăm structura JSON pentru primul element pentru diagnosticare
        print('Exemplu JSON vânzare: ${jsonList.first}');
      }
      
      // Convertim manual din JSON în obiecte Sale
      final allSales = jsonList.map((json) {
        // Verificăm și convertim în mod sigur câmpul date
        DateTime dateValue;
        try {
          if (json['date'] is String) {
            dateValue = DateTime.parse(json['date'] as String);
          } else if (json['date'] is int) {
            // Aici e problema! Acest timestamp nu reprezintă milisecunde, ci microsecunde
            // Trebuie să împărțim la 1000 pentru a obține timestamp-ul corect în milisecunde
            final timestamp = (json['date'] as int) ~/ 1000;
            dateValue = DateTime.fromMillisecondsSinceEpoch(timestamp);
          } else {
            // Valoare implicită în caz de eroare
            print('Tip neașteptat pentru câmpul date: ${json['date'].runtimeType}');
            dateValue = DateTime.now();
          }
        } catch (e) {
          print('Eroare la parsarea datei: $e');
          dateValue = DateTime.now();
        }

        print('Date convertită: $dateValue');
        
        // Convertim valorile cu verificări pentru null/tipuri
        final sale = Sale(
          date: dateValue,
          totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
          consumablesCost: (json['consumablesCost'] as num?)?.toDouble() ?? 0.0,
          profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
        );
        sale.id = json['id'] as int;
        return sale;
      }).toList();
      
      // Filtrăm manual după dată
      final filteredSales = allSales.where((sale) {
        final saleDate = DateTime(sale.date.year, sale.date.month, sale.date.day);
        final targetDate = DateTime(startOfDay.year, startOfDay.month, startOfDay.day);
        
        print('Comparare dată vânzare: ${saleDate.toString()} cu ${targetDate.toString()}');
        
        // Comparam doar anul, luna și ziua
        return saleDate.year == targetDate.year && 
               saleDate.month == targetDate.month && 
               saleDate.day == targetDate.day;
      }).toList();
      
      print('Vânzări după filtrare pentru data ${date.toString()}: ${filteredSales.length}');
      
      // Verificare adițională pentru diagnosticare
      if (filteredSales.isEmpty && allSales.isNotEmpty) {
        print('Nu s-au găsit vânzări pentru data selectată, dar există vânzări în alte zile.');
        print('Exemplu date disponibile:');
        for (var i = 0; i < min(3, allSales.length); i++) {
          print('Data vânzare ${allSales[i].id}: ${allSales[i].date}');
        }
      }
      
      return filteredSales;
    } catch (e) {
      print('Eroare la încărcarea vânzărilor: $e');
      // Returnăm o listă goală în caz de eroare pentru a preveni crash-ul
      return [];
    }
  }

  // Adaugă o vânzare de test - pentru a verifica funcționalitatea
  Future<int> addTestSale() async {
    final db = await _databaseService.isar;
    final sale = Sale(
      date: DateTime.now(),
      totalAmount: 100.0,
      consumablesCost: 20.0,
      profit: 80.0,
    );
    
    int saleId = 0;
    await db.writeTxn(() async {
      saleId = await db.sales.put(sale);
      
      // Adăugăm și un item de test
      final saleItem = SaleItem(
        saleId: saleId,
        productId: 1, // Id-ul unui produs existent
        price: 100.0,
        quantity: 1,
      );
      
      await db.saleItems.put(saleItem);
    });
    
    print('Vânzare de test adăugată cu ID: $saleId');
    return saleId;
  }

  // Restul metodelor rămân la fel
  Future<List<SaleItem>> getSaleItems(int saleId) async {
    // ... cod existent
    final db = await _databaseService.isar;
    
    try {
      // Metoda alternativă pentru findAll() în această versiune de Isar
      final jsonList = await db.saleItems.buildQuery().exportJson();
      
      // Convertim manual din JSON în obiecte SaleItem
      final allItems = jsonList.map((json) {
        return SaleItem(
          saleId: json['saleId'] as int,
          productId: json['productId'] as int,
          price: (json['price'] as num?)?.toDouble() ?? 0.0,
          quantity: json['quantity'] as int,
        )..id = json['id'] as int;
      }).toList();
      
      // Filtrăm manual după saleId
      return allItems.where((item) => item.saleId == saleId).toList();
    } catch (e) {
      print('Eroare la încărcarea elementelor vânzării: $e');
      return [];
    }
  }

  Future<double> getTotalSalesByDate(DateTime date) async {
    final sales = await getSalesByDate(date);
    double total = 0.0;
    for (var sale in sales) {
      total += sale.totalAmount;
    }
    return total;
  }

  Future<int> getSalesCountByDate(DateTime date) async {
    final sales = await getSalesByDate(date);
    return sales.length;
  }

  Future<Sale?> getSaleById(int id) async {
    final db = await _databaseService.isar;
    return await db.sales.get(id);
  }
  
  Future<bool> deleteSale(int saleId) async {
    // ... cod existent
    final db = await _databaseService.isar;
    bool success = false;
    
    try {
      await db.writeTxn(() async {
        // Obținem toate elementele vânzării și le ștergem manual
        final jsonList = await db.saleItems.buildQuery().exportJson();
        
        // Convertim manual din JSON în obiecte SaleItem
        final allItems = jsonList.map((json) {
          return SaleItem(
            saleId: json['saleId'] as int,
            productId: json['productId'] as int,
            price: (json['price'] as num?)?.toDouble() ?? 0.0,
            quantity: json['quantity'] as int,
          )..id = json['id'] as int;
        }).toList();
        
        final itemsToDelete = allItems.where((item) => item.saleId == saleId).toList();
        
        for (final item in itemsToDelete) {
          await db.saleItems.delete(item.id);
        }
        
        // Ștergem vânzarea
        success = await db.sales.delete(saleId);
      });
    } catch (e) {
      print('Eroare la ștergerea vânzării: $e');
      success = false;
    }
    
    return success;
  }
}

// Funcție auxiliară
int min(int a, int b) {
  return a < b ? a : b;
}