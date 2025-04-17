// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:peval/services/product_service.dart';
import 'package:peval/pages/sale_page.dart';
import 'package:peval/pages/product_list_page.dart';
import 'package:peval/pages/product_add_page.dart';
import 'package:peval/pages/report_page.dart';

// Cheie globală pentru acces navigator din orice context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  GetIt.I.registerSingleton<ProductService>(ProductService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeVal',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
      routes: {
        '/sale': (context) => const SalePage(),
        '/products': (context) => const ProductListPage(),
        '/products/add': (context) => const ProductAddPage(),
        '/report': (context) => const ReportPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SalePage();
  }
}