import 'package:isar/isar.dart';

part 'product.g.dart';

@collection
class Product {
  Id id = Isar.autoIncrement;
  late String name;
  late double price;

  Product({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.price,
  });
}
