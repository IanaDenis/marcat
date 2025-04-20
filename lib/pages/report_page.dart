// lib/pages/report_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peval/models/sale.dart';
import 'package:peval/models/sale_item.dart';
import 'package:peval/models/product.dart';
import 'package:peval/services/report_service.dart';
import 'package:peval/services/product_service.dart';
import 'package:peval/utils/formatter.dart';
import 'package:peval/widgets/app_drawer.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ReportService _reportService = ReportService();
  final ProductService _productService = ProductService();
  DateTime _selectedDate = DateTime.now();
  List<Sale> _sales = [];
  bool _isLoading = true;
  double _totalSales = 0;

  @override
  void initState() {
    super.initState();
    _loadSalesForDate(_selectedDate);
  }

  Future<void> _loadSalesForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Încărcăm vânzările pentru data selectată
      final sales = await _reportService.getSalesByDate(date);
      
      // Calculăm totalul vânzărilor
      double total = 0;
      for (var sale in sales) {
        total += sale.totalAmount;
      }

      setState(() {
        _sales = sales;
        _totalSales = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea vânzărilor: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Funcție pentru a adăuga o vânzare de test pentru debugging
  Future<void> _addTestSale() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _reportService.addTestSale();
      
      // Reîncărcăm vânzările după ce am adăugat una de test
      await _loadSalesForDate(_selectedDate);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vânzare de test adăugată cu succes!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la adăugarea vânzării de test: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ro', 'RO'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadSalesForDate(_selectedDate);
    }
  }

  Future<void> _showSaleDetails(Sale sale) async {
    // Încărcăm elementele vânzării
    List<SaleItem> saleItems = await _reportService.getSaleItems(sale.id);
    
    // Creăm un map pentru a ține evidența produselor și cantităților
    Map<Product, int> productQuantities = {};
    
    // Încărcăm produsele pentru fiecare element
    for (var item in saleItems) {
      Product? product = await _productService.getProductById(item.productId);
      if (product != null) {
        if (productQuantities.containsKey(product)) {
          productQuantities[product] = productQuantities[product]! + item.quantity;
        } else {
          productQuantities[product] = item.quantity;
        }
      }
    }
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Detalii Vânzare #${sale.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(sale.date)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Produse:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: productQuantities.length,
                      itemBuilder: (context, index) {
                        final entry = productQuantities.entries.elementAt(index);
                        final product = entry.key;
                        final quantity = entry.value;
                        final totalPrice = product.price * quantity;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(product.name),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'x$quantity',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  Formatter.formatPrice(totalPrice),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          Formatter.formatPrice(sale.totalAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('ÎNCHIDE'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('RETIPĂREȘTE BON'),
                onPressed: () {
                  // Implementați logica pentru retipărirea bonului fiscal
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Retipărirea bonului fiscal - în dezvoltare'),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapoarte Vânzări'),
        actions: [
          // Buton pentru adăugarea unei vânzări de test (doar pentru debugging)
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _addTestSale,
            tooltip: 'Adaugă vânzare de test',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadSalesForDate(_selectedDate),
            tooltip: 'Reîncarcă raportul',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Selector dată
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Raport Zilnic',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMMM yyyy', 'ro').format(_selectedDate),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                  child: const Text('SCHIMBĂ DATA'),
                ),
              ],
            ),
          ),
          
          // Lista de vânzări sau mesaj "nicio vânzare"
          _isLoading 
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _sales.isEmpty
                  ? _buildEmptyState()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _sales.length,
                        itemBuilder: (context, index) {
                          final sale = _sales[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                'Vânzare #${sale.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Data: ${DateFormat('HH:mm:ss').format(sale.date)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Text(
                                Formatter.formatPrice(sale.totalAmount),
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: const Icon(
                                  Icons.receipt,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () => _showSaleDetails(sale),
                            ),
                          );
                        },
                      ),
                    ),
          
          // Footer cu totalul
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL VÂNZĂRI:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  Formatter.formatPrice(_totalSales),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nu există vânzări pentru ${DateFormat('dd MMMM yyyy', 'ro').format(_selectedDate)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Selectați o altă dată sau adăugați vânzări noi',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Vânzare Nouă'),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/sale');
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Adaugă Vânzare de Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _addTestSale,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}