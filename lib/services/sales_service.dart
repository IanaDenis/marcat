import 'package:peval/db.dart';
import 'package:peval/models/sale.dart';
import 'package:peval/models/product.dart';

Future<void> saveSale(List<SaleItem> saleItems) async {
  final totalAmount = saleItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  final sale = Sale(
    saleDate: DateTime.now(),
    totalAmount: totalAmount,
  );

  await isar.writeTxn(() async {
    await isar.sales.put(sale);

    for (var item in saleItems) {
      await isar.saleItems.put(item);
      sale.saleItems.add(item);
    }
    await isar.sales.put(sale);
  });
}
