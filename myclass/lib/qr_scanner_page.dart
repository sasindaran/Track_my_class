import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'database_helper.dart'; // Import your database helper class
import 'package:intl/intl.dart';

class ScannedData {
  final String className;
  final String registerNumber;
  final DateTime currentDate;

  ScannedData({
    required this.className,
    required this.registerNumber,
    required this.currentDate,
  });
}

class QRScannerPage extends StatefulWidget {
  final String className; // Pass the class name as a parameter

  QRScannerPage({required this.className});

  @override
  State<StatefulWidget> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  String scannedData = '';

  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Scanned Data: $scannedData',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _onAcceptPressed,
            child: Text('Accept'), // Add an "Accept" button
          ),
          SizedBox(
            height: 70,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code ?? '';
      });
    });
  }

  void _onAcceptPressed() async {
    if (scannedData.isNotEmpty) {
      final scannedDataModel = ScannedData(
        className: widget.className,
        registerNumber: scannedData,
        currentDate: DateTime.now(),
      );

      final row = {
        'className': scannedDataModel.className,
        'registerNumber': scannedDataModel.registerNumber,
        'currentDate': DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(scannedDataModel.currentDate),
      };

      final id = await dbHelper.insertScannedData(row);

      setState(() {
        scannedData = '';
      });
      final snackBar = SnackBar(
        content: Text('${scannedDataModel.registerNumber} is Present'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context)
                .hideCurrentSnackBar(); // Dismiss the Snackbar
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
