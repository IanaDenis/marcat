// lib/services/report_service.dart
import 'package:peval/models/sale.dart';

class ReportService {
  List<Sale> sales = [];

  double getTotalSales() {
    return sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
  }

  void addSale(Sale sale) {
    sales.add(sale);
  }
}