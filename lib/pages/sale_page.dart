// lib/pages/sale_page.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:peval/models/product.dart';
import 'package:peval/models/sale_item.dart';
import 'package:peval/services/product_service.dart';
import 'package:peval/services/sales_service.dart';
import 'package:peval/utils/formatter.dart';
import 'package:peval/widgets/app_drawer.dart';

class SalePage extends StatefulWidget {
  const SalePage({Key? key}) : super(key: key);

  @override
  _SalePageState createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  List<Product> _products = [];
  Map<int, int> _cartItems = {}; // Map<productId, quantity>
  final _productService = ProductService();
  final _salesService = SalesService();
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea produselor: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToCart(Product product) {
    setState(() {
      _cartItems[product.id] = (_cartItems[product.id] ?? 0) + 1;
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      if (_cartItems.containsKey(product.id)) {
        if (_cartItems[product.id]! > 1) {
          _cartItems[product.id] = _cartItems[product.id]! - 1;
        } else {
          _cartItems.remove(product.id);
        }
      }
    });
  }

  // Calculează totalul bonului
  double get _cartTotal {
    double total = 0.0;
    _cartItems.forEach((productId, quantity) {
      final product = _products.firstWhere((p) => p.id == productId, orElse: () => Product(name: '', price: 0));
      total += product.price * quantity;
    });
    return total;
  }

  // Obține produsele din coș cu cantitățile lor
  List<MapEntry<Product, int>> get _cartProducts {
    List<MapEntry<Product, int>> result = [];
    
    _cartItems.forEach((productId, quantity) {
      final product = _products.firstWhere((p) => p.id == productId, orElse: () => Product(name: 'Produs necunoscut', price: 0));
      result.add(MapEntry(product, quantity));
    });
    
    return result;
  }

  // Pregătește și salvează bonul fiscal
  Future<void> _processSale() async {
    if (_cartItems.isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Creăm un map de prețuri pentru fiecare produs din coș
      Map<int, double> productPrices = {};
      for (var product in _products) {
        if (_cartItems.containsKey(product.id)) {
          productPrices[product.id] = product.price;
        }
      }
      
      // Generăm elementele de vânzare
      final List<SaleItem> saleItems = _salesService.createSaleItems(_cartItems, productPrices);
      
      // Calculăm totalul (deși avem deja _cartTotal, folosim metoda din service pentru consistență)
      final double total = _salesService.calculateTotal(saleItems);
      
      // Salvăm vânzarea în baza de date
      final int saleId = await _salesService.saveSale(saleItems, total);
      
      if (mounted) {
        // Afișăm mesaj de succes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vânzare finalizată cu succes! ID: $saleId'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Golim coșul după finalizarea vânzării
        setState(() {
          _cartItems.clear();
          _isProcessing = false;
        });
        
        // Aici puteți adăuga logica pentru printarea bonului fiscal
        // _printReceipt(saleId, saleItems, total);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la procesarea vânzării: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vânzare Nouă'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Partea de sus - Grid cu produse
          Expanded(
            flex: 3,
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductCard(product);
              },
            ),
          ),
          
          // Linie de separare
          const Divider(height: 2, thickness: 2),
          
          // Partea de jos - Bon fiscal
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Header pentru bon
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Produs',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Cant.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Preț',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lista de produse din coș
                Expanded(
                  child: _cartProducts.isEmpty
                      ? Center(
                          child: Text(
                            'Niciun produs adăugat',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _cartProducts.length,
                          itemBuilder: (context, index) {
                            final entry = _cartProducts[index];
                            final product = entry.key;
                            final quantity = entry.value;
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 16.0,
                              ),
                              child: Row(
                                children: [
                                  // Numele produsului
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      product.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  
                                  // Cantitatea cu butoane +/-
                                  Expanded(
                                    flex: 2,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () => _removeFromCart(product),
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.red[100],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.remove, size: 14),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '$quantity',
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(width: 4),
                                          InkWell(
                                            onTap: () => _addToCart(product),
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.green[100],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.add, size: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Prețul unitar
                                  Expanded(
                                    flex: 2,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        Formatter.formatPrice(product.price),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                  
                                  // Prețul total
                                  Expanded(
                                    flex: 2,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        Formatter.formatPrice(product.price * quantity),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                // Total și buton de finalizare
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            Formatter.formatPrice(_cartTotal),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _cartProducts.isEmpty || _isProcessing
                              ? null
                              : _processSale,
                          child: _isProcessing
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  'EMITE BON FISCAL',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return InkWell(
      onTap: () => _addToCart(product),
      child: Card(
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  Icons.shopping_bag,
                  size: 48,
                  color: Colors.blue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    Formatter.formatPrice(product.price),
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}