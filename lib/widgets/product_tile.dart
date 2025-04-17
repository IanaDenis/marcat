// lib/widgets/product_tile.dart
import 'package:flutter/material.dart';
import 'package:peval/models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final Function onAddToCart;

  const ProductTile({Key? key, required this.product, required this.onAddToCart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      trailing: IconButton(
        icon: const Icon(Icons.add_shopping_cart),
        onPressed: () => onAddToCart(),
      ),
    );
  }
}
