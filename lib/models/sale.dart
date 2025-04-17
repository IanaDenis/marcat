import 'package:isar/isar.dart';

@Collection()
class Sale {
  Id id = Isar.autoIncrement; // Id automat generat
  late DateTime date; // Data vânzării
  late double totalAmount; // Totalul vânzării
  late double consumablesCost; // Costul consumabilelor
  late double profit; // Profitul obținut (calculat)

  // Proprietate pentru compatibilitate cu codul ReportService existent
  double get price => totalAmount;
  
  // Proprietate pentru compatibilitate cu codul ReportService existent
  String get productName => 'Vânzare #$id';

  Sale({
    required this.date,
    required this.totalAmount,
    required this.consumablesCost,
    required this.profit,
  });
}