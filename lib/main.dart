// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:peval/services/database_service.dart';
import 'package:peval/services/product_service.dart';
import 'package:peval/services/sales_service.dart';
import 'package:peval/services/report_service.dart';
import 'package:peval/pages/sale_page.dart';
import 'package:peval/pages/product_list_page.dart';
import 'package:peval/pages/product_add_page.dart';
import 'package:peval/pages/report_page.dart';

// Cheie globală pentru acces navigator din orice context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inițializăm formatarea datelor în română
  await initializeDateFormatting('ro', null);
  
  // Înregistrăm serviciul de bază de date
  GetIt.I.registerSingleton<DatabaseService>(DatabaseService());
  
  // Înregistrăm celelalte servicii singleton
  GetIt.I.registerSingleton<ProductService>(ProductService());
  GetIt.I.registerSingleton<SalesService>(SalesService());
  GetIt.I.registerSingleton<ReportService>(ReportService());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeVal',
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ro', 'RO'), // Română
        Locale('en', 'US'), // Engleză (fallback)
      ],
      locale: const Locale('ro', 'RO'), // Setăm locale-ul default la română
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