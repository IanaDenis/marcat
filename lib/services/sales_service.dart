// lib/services/sales_service.dart
import 'package:get_it/get_it.dart';
import 'package:peval/models/sale.dart';
import 'package:peval/models/sale_item.dart';
import 'package:peval/services/database_service.dart';

class SalesService {
  // Singleton pattern
  static final SalesService _instance = SalesService._internal();
  factory SalesService() => _instance;
  SalesService._internal();

  final DatabaseService _databaseService = GetIt.I<DatabaseService>();

  // Salvează o vânzare completă cu elementele sale
  Future<int> saveSale(List<SaleItem> saleItems, double totalAmount) async {
    final db = await _databaseService.isar;
    
    // Creăm obiectul de vânzare
    final sale = Sale(
      date: DateTime.now(),
      totalAmount: totalAmount,
      consumablesCost: 0, // Puteți adăuga această funcționalitate ulterior
      profit: totalAmount, // Profit simplificat (totalAmount - consumablesCost)
    );
    
    int saleId = 0;
    
    await db.writeTxn(() async {
      // Salvăm vânzarea și obținem ID-ul
      saleId = await db.collection<Sale>().put(sale);
      
      // Actualizăm ID-ul vânzării în fiecare element și îl salvăm
      for (var item in saleItems) {
        item.saleId = saleId;
        await db.collection<SaleItem>().put(item);
      }
    });
    
    return saleId;
  }
  
  // Generează elemente de vânzare din produse și cantități
  List<SaleItem> createSaleItems(Map<int, int> productQuantities, Map<int, double> productPrices) {
    List<SaleItem> items = [];
    
    productQuantities.forEach((productId, quantity) {
      if (quantity > 0) {
        items.add(SaleItem(
          saleId: 0, // Va fi actualizat când se salvează vânzarea
          productId: productId,
          price: productPrices[productId] ?? 0.0,
          quantity: quantity,
        ));
      }
    });
    
    return items;
  }
  
  // Calculează totalul pentru o listă de elemente de vânzare
  double calculateTotal(List<SaleItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}