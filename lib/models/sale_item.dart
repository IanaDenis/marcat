import 'package:isar/isar.dart';
import 'package:peval/models/product.dart';

part 'sale_item.g.dart'; // acest fișier va fi generat de Isar

@Collection()
class SaleItem {
  
  Id id = Isar.autoIncrement; // Id automat generat
  late int saleId; // Id-ul vânzării la care aparține acest produs
  late int productId; // Id-ul produsului vândut
  late double price; // Prețul produsului vândut
  late int quantity; // Cantitatea vândută

  SaleItem({
    required this.saleId,
    required this.productId,
    required this.price,
    required this.quantity,
  });
}