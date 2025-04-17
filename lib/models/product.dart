import 'package:isar/isar.dart';

part 'product.g.dart'; // acest fișier va fi generat de Isar

@Collection()
class Product {
  Id id = Isar.autoIncrement; // Id automat generat
  late String name; // Numele produsului
  late double price; // Prețul produsului

Product({this.id = Isar.autoIncrement, required this.name, required this.price});}
