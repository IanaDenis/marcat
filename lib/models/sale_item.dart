import 'package:isar/isar.dart';
import 'package:peval/models/product.dart';
import 'package:peval/models/sale.dart';

part 'sale_item.g.dart'; // acest fișier va fi generat de Isar

@Collection()
class SaleItem {
  Id id = Isar.autoIncrement; // Id automat generat
  
  final sale = IsarLink<Sale>();
  
  late int productId; // Id-ul produsului vândut
  late double price; // Prețul produsului vândut
  late int quantity; // Cantitatea vândută

  SaleItem({
    required this.productId,
    required this.price,
    required this.quantity,
  });
}