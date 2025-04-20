// lib/services/receipt_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:peval/models/sale.dart';
import 'package:peval/models/sale_item.dart';
import 'package:peval/models/product.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptService {
  // Singleton pattern
  static final ReceiptService _instance = ReceiptService._internal();
  factory ReceiptService() => _instance;
  ReceiptService._internal();

  final FlutterBluetoothPrinter _bluetoothPrinter = FlutterBluetoothPrinter.instance;
  
  // Generează un PDF cu bonul fiscal
  Future<Uint8List> generateReceiptPdf(
    Sale sale,
    List<SaleItem> saleItems,
    Map<int, Product> products,
    {bool forPrinting = false}
  ) async {
    final pdf = pw.Document();
    
    // Creează un font pentru text
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();
    
    // Încarcă logo-ul companiei dacă există
    pw.Image? logo;
    try {
      final logoData = await rootBundle.load('assets/logo.png');
      final logoImage = PdfImage.file(
        pdf.document,
        bytes: logoData.buffer.asUint8List(),
      );
      logo = pw.Image(logoImage, width: 100);
    } catch (e) {
      print('Nu s-a putut încărca logo-ul: $e');
    }

    // Stabilim lățimea și stilul bonului în funcție de destinație (pdf vizualizare sau pentru imprimantă)
    final pageWidth = forPrinting ? PdfPageFormat.roll80.width : PdfPageFormat.a4.width / 2;
    final pageTotalHeight = forPrinting 
        ? (150 + saleItems.length * 20).toDouble() // Estimare pentru înălțimea necesară pentru imprimantă
        : PdfPageFormat.a4.height;
        
    final pageFormat = PdfPageFormat(
      pageWidth,
      pageTotalHeight,
      marginAll: 8,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header cu logo și informații despre companie
              if (logo != null) logo,
              pw.SizedBox(height: 10),
              pw.Text(
                'Pe-Val.ro',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                ),
              ),
              pw.Text(
                'C.U.I.: RO12345678',
                style: pw.TextStyle(font: font, fontSize: 10),
              ),
              pw.Text(
                'Adresă: Strada Exemplu, Nr. 123, Constanța',
                style: pw.TextStyle(font: font, fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
              
              // Bon fiscal header
              pw.Text(
                'BON FISCAL',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                'Nr: ${sale.id} - Data: ${DateFormat('dd/MM/yyyy HH:mm').format(sale.date)}',
                style: pw.TextStyle(font: font, fontSize: 10),
              ),
              pw.SizedBox(height: 10),
              
              // Tabel cu produse
              pw.Table(
                border: pw.TableBorder(
                  bottom: pw.BorderSide(width: 0.5),
                  horizontalInside: pw.BorderSide(width: 0.5),
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(4),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                },
                children: [
                  // Header tabel
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                    ),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Produs',
                          style: pw.TextStyle(font: fontBold, fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Cant',
                          style: pw.TextStyle(font: fontBold, fontSize: 10),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Preț',
                          style: pw.TextStyle(font: fontBold, fontSize: 10),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(font: fontBold, fontSize: 10),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  
                  // Rânduri cu produse
                  ...saleItems.map((item) {
                    final product = products[item.productId];
                    final totalPrice = item.price * item.quantity;
                    
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            product?.name ?? 'Produs necunoscut',
                            style: pw.TextStyle(font: font, fontSize: 9),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            item.quantity.toString(),
                            style: pw.TextStyle(font: font, fontSize: 9),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '${item.price.toStringAsFixed(2)} RON',
                            style: pw.TextStyle(font: font, fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '${totalPrice.toStringAsFixed(2)} RON',
                            style: pw.TextStyle(font: font, fontSize: 9),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              
              pw.SizedBox(height: 10),
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(font: fontBold, fontSize: 12),
                  ),
                  pw.Text(
                    '${sale.totalAmount.toStringAsFixed(2)} RON',
                    style: pw.TextStyle(font: fontBold, fontSize: 12),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Footer
              pw.Text(
                'Vă mulțumim pentru vizită!',
                style: pw.TextStyle(font: font, fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'www.pe-val.ro',
                style: pw.TextStyle(font: font, fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Salvează PDF-ul pe dispozitiv și returnează calea fișierului
  Future<String> saveReceiptPdf(Uint8List pdfBytes, int saleId) async {
    final output = await getApplicationDocumentsDirectory();
    final fileName = 'bon_fiscal_${saleId}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    print('PDF salvat la: ${file.path}');
    return file.path;
  }

  // Deschide PDF-ul pentru vizualizare și opțiuni de imprimare
  Future<void> viewAndPrintReceipt(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  // Scanează și returnează imprimantele Bluetooth disponibile
  Future<List<BluetoothDevice>> scanForBluetoothPrinters() async {
    return await _bluetoothPrinter.scan();
  }

  // Imprimă bonul fiscal pe o imprimantă Bluetooth
  Future<bool> printReceiptToBluetooth(
    BluetoothDevice printer,
    Sale sale,
    List<SaleItem> saleItems,
    Map<int, Product> products,
  ) async {
    try {
      // Generăm PDF-ul optimizat pentru imprimantă
      final pdfBytes = await generateReceiptPdf(sale, saleItems, products, forPrinting: true);
      
      // Conectăm la imprimantă și trimitem PDF-ul
      await _bluetoothPrinter.connect(printer.address);
      final result = await _bluetoothPrinter.printBytes(pdfBytes);
      await _bluetoothPrinter.disconnect();
      
      return result;
    } catch (e) {
      print('Eroare la imprimare: $e');
      return false;
    }
  }
}