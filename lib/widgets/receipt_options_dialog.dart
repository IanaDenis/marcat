// lib/widgets/receipt_options_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiptOptionsDialog extends StatefulWidget {
  final Function() onViewPdf;
  final Function() onSavePdf;
  final Function(BluetoothDevice) onPrintBluetooth;

  const ReceiptOptionsDialog({
    Key? key,
    required this.onViewPdf,
    required this.onSavePdf,
    required this.onPrintBluetooth,
  }) : super(key: key);

  @override
  _ReceiptOptionsDialogState createState() => _ReceiptOptionsDialogState();
}

class _ReceiptOptionsDialogState extends State<ReceiptOptionsDialog> {
  final FlutterBluetoothPrinter _bluetoothPrinter = FlutterBluetoothPrinter.instance;
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _bluetoothEnabled = false;
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  Future<void> _checkPermissionsAndScan() async {
    setState(() {
      _isScanning = true;
    });

    // Verificăm permisiunile (pentru Android 12+)
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    bool allGranted = true;
    
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });

    setState(() {
      _hasPermissions = allGranted;
    });

    if (!allGranted) {
      setState(() {
        _isScanning = false;
      });
      return;
    }

    try {
      bool isOn = await _bluetoothPrinter.isOn;
      
      setState(() {
        _bluetoothEnabled = isOn;
      });

      if (isOn) {
        final devices = await _bluetoothPrinter.scan();
        setState(() {
          _devices = devices;
        });
      }
    } catch (e) {
      print('Eroare la scanarea dispozitivelor Bluetooth: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Opțiuni bon fiscal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            Divider(),
            
            // Opțiuni principale
            ListTile(
              leading: Icon(Icons.visibility, color: Colors.blue),
              title: Text('Vizualizează bonul'),
              subtitle: Text('Deschide PDF-ul pentru previzualizare'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onViewPdf();
              },
            ),
            
            ListTile(
              leading: Icon(Icons.save_alt, color: Colors.green),
              title: Text('Salvează bonul'),
              subtitle: Text('Salvează PDF-ul pe dispozitiv'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onSavePdf();
              },
            ),
            
            Divider(),
            
            // Secțiunea pentru imprimante Bluetooth
            Text(
              'Imprimă pe Bluetooth',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            
            SizedBox(height: 8),
            
            if (!_hasPermissions)
              ListTile(
                leading: Icon(Icons.error, color: Colors.orange),
                title: Text('Permisiuni lipsă'),
                subtitle: Text('Acordați permisiunile pentru Bluetooth'),
                trailing: ElevatedButton(
                  child: Text('Permisiuni'),
                  onPressed: _checkPermissionsAndScan,
                ),
              )
            else if (!_bluetoothEnabled)
              ListTile(
                leading: Icon(Icons.bluetooth_disabled, color: Colors.grey),
                title: Text('Bluetooth dezactivat'),
                subtitle: Text('Activați Bluetooth pentru a scana dispozitive'),
              )
            else if (_isScanning)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Se caută dispozitive...'),
                  ],
                ),
              )
            else if (_devices.isEmpty)
              ListTile(
                leading: Icon(Icons.bluetooth_searching, color: Colors.blue),
                title: Text('Nicio imprimantă găsită'),
                subtitle: Text('Asigurați-vă că imprimanta este pornită și în apropiere'),
                trailing: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _checkPermissionsAndScan,
                ),
              )
            else
              Container(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return ListTile(
                      leading: Icon(Icons.print, color: Colors.blue),
                      title: Text(device.name),
                      subtitle: Text(device.address),
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onPrintBluetooth(device);
                      },
                    );
                  },
                ),
              ),
              
            SizedBox(height: 8),
            
            // Buton de reîmprospătare
            if (_bluetoothEnabled && !_isScanning)
              Center(
                child: TextButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Reîmprospătează lista'),
                  onPressed: _checkPermissionsAndScan,
                ),
              ),
          ],
        ),
      ),
    );
  }
}