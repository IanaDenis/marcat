import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'models/product.dart';
import 'models/sale.dart';
import 'models/sale_item.dart';

class DatabaseService {
  late final Isar isar;

  // Deschide baza de date
  Future<void> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [ProductSchema, SaleSchema, SaleItemSchema],
      directory: dir.path,
    );
  }

  // Adaugă un produs în baza de date
  Future<void> addProduct(Product product) async {
    await isar.writeTxn((isar) async {
      await isar.products.put(product);
    });
  }

  // Obține toate produsele
  Future<List<Product>> getProducts() async {
    return await isar.products.where().findAll();
  }

  // Modifică un produs existent
  Future<void> updateProduct(Product product) async {
    await isar.writeTxn((isar) async {
      await isar.products.put(product);
    });
  }

  // Șterge un produs
  Future<void> deleteProduct(Product product) async {
    await isar.writeTxn((isar) async {
      await isar.products.delete(product.id);
    });
  }

  // Creează o vânzare
  Future<void> createSale(Sale sale) async {
    await isar.writeTxn((isar) async {
      await isar.sales.put(sale);
    });
  }

  // Creează un item de vânzare (pentru bonul fiscal)
  Future<void> createSaleItem(SaleItem saleItem) async {
    await isar.writeTxn((isar) async {
      await isar.saleItems.put(saleItem);
    });
  }

  // Obține vânzările dintr-o anumită zi
  Future<List<Sale>> getSalesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return await isar.sales
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .findAll();
  }

  // Obține toate produsele dintr-o vânzare
  Future<List<SaleItem>> getSaleItems(int saleId) async {
    return await isar.saleItems.filter().saleIdEqualTo(saleId).findAll();
  }

  // Salvează modificările într-o tranzacție
  Future<void> saveChanges() async {
    await isar.writeTxn((isar) async {
      // Cod pentru salvarea oricăror modificări
    });
  }

  // Închide baza de date
  Future<void> close() async {
    await isar.close();
  }
}
