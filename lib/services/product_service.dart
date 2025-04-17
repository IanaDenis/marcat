// lib/services/product_service.dart
import 'package:peval/models/product.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ProductService {
  // Singleton pattern
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  // Lazily initialize Isar
  Isar? _isar;
  Future<Isar> get isar async {
    if (_isar == null) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [ProductSchema],
        directory: dir.path,
      );
    }
    return _isar!;
  }

  // Preia toate produsele
  Future<List<Product>> getProducts() async {
    final db = await isar;
    return await db.products.where().sortByName().findAll();
  }

  // Adaugă un produs nou
  Future<int> addProduct(Product product) async {
    final db = await isar;
    return db.writeTxn(() async {
      return await db.products.put(product);
    });
  }

  // Actualizează un produs existent
  Future<int> updateProduct(Product product) async {
    final db = await isar;
    return db.writeTxn(() async {
      return await db.products.put(product); // Put va actualiza produsul dacă există
    });
  }

  // Șterge un produs
  Future<bool> deleteProduct(int id) async {
    final db = await isar;
    return db.writeTxn(() async {
      return await db.products.delete(id);
    });
  }

  // Caută produse după nume
  Future<List<Product>> searchProducts(String query) async {
    final db = await isar;
    return await db.products
        .filter()
        .nameContains(query, caseSensitive: false)
        .sortByName()
        .findAll();
  }

  // Găsește un produs după ID
  Future<Product?> getProductById(int id) async {
    final db = await isar;
    return await db.products.get(id);
  }

  // Închide baza de date (când aplicația se închide)
  Future<void> close() async {
    final dbInstance = await isar;
    await dbInstance.close();
    _isar = null;
  }
}