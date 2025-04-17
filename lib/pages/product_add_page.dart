// lib/pages/product_add_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peval/models/product.dart';
import 'package:peval/services/product_service.dart';
import 'package:peval/widgets/app_drawer.dart';


class ProductAddPage extends StatefulWidget {
  const ProductAddPage({Key? key}) : super(key: key);

  @override
  _ProductAddPageState createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;
  final _productService = ProductService();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text.replaceAll(',', '.'));

      final product = Product(
        name: name,
        price: price,
      );

      final productId = await _productService.addProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produsul "$name" a fost adăugat cu succes!'),
            backgroundColor: Colors.green,
          ),
        );

        // Golim formularul pentru un nou produs sau revenim la pagina anterioară
        if (_shouldStayOnPage()) {
          _nameController.clear();
          _priceController.clear();
          // Setăm focusul pe primul câmp
          FocusScope.of(context).requestFocus(FocusNode());
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la salvarea produsului: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Funcție pentru a decide dacă utilizatorul ar trebui să rămână pe pagina de adăugare
  // după ce a adăugat un produs
  bool _shouldStayOnPage() {
    // Pentru simplitate, returnăm true (utilizatorul rămâne pe pagină)
    // În practică, ați putea adăuga o opțiune de configurare sau un checkbox
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaugă Produs Nou'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titlu
              const Text(
                'Informații produs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Nume produs
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nume produs',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduceți numele produsului';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              
              // Preț produs
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preț (RON)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                   FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduceți prețul produsului';
                  }
                  
                  final price = double.tryParse(value.replaceAll(',', '.'));
                  if (price == null || price <= 0) {
                    return 'Prețul trebuie să fie un număr pozitiv';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Buton de salvare
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'SALVEAZĂ PRODUSUL',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Buton pentru a adăuga și continua sau a reveni la lista de produse
              if (!_isLoading)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('RENUNȚĂ ȘI REVINO LA LISTĂ'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}