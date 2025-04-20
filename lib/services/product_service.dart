// lib/services/product_service.dart
import 'package:get_it/get_it.dart';
import 'package:peval/models/product.dart';
import 'package:peval/services/database_service.dart';

class ProductService {
  // Singleton pattern
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final DatabaseService _databaseService = GetIt.I<DatabaseService>();

  // Preia toate produsele
  Future<List<Product>> getProducts() async {
    final db = await _databaseService.isar;
    
    // Metoda alternativă pentru findAll() în această versiune de Isar
    final jsonList = await db.products.buildQuery().exportJson();
    
    // Convertim manual din JSON în obiecte Product
    return jsonList.map((json) {
      return Product(
        id: json['id'] as int,
        name: json['name'] as String,
        price: json['price'] as double,
      );
    }).toList();
  }

  // Adaugă un produs nou
  Future<int> addProduct(Product product) async {
    final db = await _databaseService.isar;
    return db.writeTxn(() async {
      return await db.products.put(product);
    });
  }

  // Actualizează un produs existent
  Future<int> updateProduct(Product product) async {
    final db = await _databaseService.isar;
    return db.writeTxn(() async {
      return await db.products.put(product); // Put va actualiza produsul dacă există
    });
  }

  // Șterge un produs
  Future<bool> deleteProduct(int id) async {
    final db = await _databaseService.isar;
    return db.writeTxn(() async {
      return await db.products.delete(id);
    });
  }

  // Caută produse după nume - implementare alternativă
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return getProducts();
    }
    
    // Obținem toate produsele și filtrăm manual
    final allProducts = await getProducts();
    return allProducts.where((product) => 
      product.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Găsește un produs după ID
  Future<Product?> getProductById(int id) async {
    final db = await _databaseService.isar;
    return await db.products.get(id);
  }
}