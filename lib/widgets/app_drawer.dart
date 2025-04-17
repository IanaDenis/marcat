// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pe-Val POS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistem de vânzări',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Vânzare nouă'),
            selected: ModalRoute.of(context)!.settings.name == '/sale' || 
                       ModalRoute.of(context)!.settings.name == '/',
            onTap: () {
              Navigator.pop(context); // închide drawer-ul
              if (ModalRoute.of(context)!.settings.name != '/sale' && 
                  ModalRoute.of(context)!.settings.name != '/') {
                Navigator.pushReplacementNamed(context, '/sale');
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Gestiune produse'),
            selected: ModalRoute.of(context)!.settings.name == '/products',
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)!.settings.name != '/products') {
                Navigator.pushReplacementNamed(context, '/products');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Adaugă produs nou'),
            selected: ModalRoute.of(context)!.settings.name == '/products/add',
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)!.settings.name != '/products/add') {
                Navigator.pushReplacementNamed(context, '/products/add');
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Raport zilnic'),
            selected: ModalRoute.of(context)!.settings.name == '/report',
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)!.settings.name != '/report') {
                Navigator.pushReplacementNamed(context, '/report');
              }
            },
          ),
        ],
      ),
    );
  }
}