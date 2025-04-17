// lib/pages/report_page.dart
import 'package:flutter/material.dart';
import 'package:peval/services/report_service.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reportService = ReportService();

    return Scaffold(
      appBar: AppBar(title: const Text('Raportul Zilei')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reportService.sales.length,
              itemBuilder: (context, index) {
                final sale = reportService.sales[index];
                return ListTile(
                  title: Text(sale.productName),
                  subtitle: Text('\$${sale.price.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Vânzări: \$${reportService.getTotalSales().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
