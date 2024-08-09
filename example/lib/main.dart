import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dopos_print/dopos_print.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DoposPrint _doposPrintPlugin = DoposPrint();
  List<Map<String, String>> _printers = [];
  String _jsonInput = '';
  String? _selectedPrinter;

  final Map<String, dynamic> _SAMPLE_JSON_INSTRUCTION_ = {
    "startX": 0,
    "startY": 0,
    "data": [
      {
        "startX": 0,
        "endX": 190,
        "lineSpacing": 0,
        "imagePath": "C:\\image.png",
        "imageWidth": 30,
        "imageHeight": 30,
        "align": "center",
        "isNewLine": true
      },
      {
        "startX": 0,
        "endX": 190,
        "text": "Hello,",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": true
      },
      {
        "startX": 20,
        "endX": 80,
        "text": "My Name is ",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": false
      },
      {
        "startX": 81,
        "endX": 190,
        "text": "ABDUL AHAD",
        "fontSize": 8,
        "fontWeight": "Bold",
        "lineSpacing": 0,
        "align": "right",
        "isNewLine": true
      },
      {
        "startX": 0,
        "endX": 80,
        "text": "Item",
        "fontSize": 8,
        "fontWeight": "Bold",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": false
      },
      {
        "startX": 81,
        "endX": 190,
        "text": "Amount",
        "fontSize": 8,
        "fontWeight": "Bold",
        "lineSpacing": 0,
        "align": "right",
        "isNewLine": true
      },
      {
        "startX": 0,
        "endX": 80,
        "text": "Product 1",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": false
      },
      {
        "startX": 81,
        "endX": 190,
        "text": "200.00",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "right",
        "isNewLine": true
      },
      {
        "startX": 0,
        "endX": 80,
        "text": "Product 99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": false
      },
      {
        "startX": 81,
        "endX": 190,
        "text": "23568.99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "right",
        "isNewLine": true
      },
      {
        "startX": 0,
        "endX": 80,
        "text": "Product 99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": false
      },
      {
        "startX": 81,
        "endX": 190,
        "text": "23568.99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "right",
        "isNewLine": true
      },
      {
        "startX": 0,
        "endX": 80,
        "text": "Product 99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": false
      },
      {
        "startX": 81,
        "endX": 190,
        "text": "23568.99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "right",
        "isNewLine": true
      },
      {
        "startX": 0,
        "endX": 80,
        "text": "Product 99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": false
      },
      {
        "startX": 81,
        "endX": 190,
        "text": "23568.99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "right",
        "isNewLine": true
      },
      {
        "startX": 0,
        "endX": 80,
        "text": "Product 99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": false
      },
      {
        "startX": 81,
        "endX": 190,
        "text": "23568.99",
        "fontSize": 8,
        "fontWeight": "Normal",
        "lineSpacing": 0,
        "align": "right",
        "isNewLine": true
      },
      {
        "startX": 0,
        "endX": 80,
        "text": "TOTAL",
        "fontSize": 8,
        "fontWeight": "Bold",
        "lineSpacing": 0,
        "align": "left",
        "isNewLine": false
      },
      {
        "startX": 81,
        "endX": 190,
        "text": "99999.99",
        "fontSize": 8,
        "fontWeight": "Bold",
        "lineSpacing": 0,
        "align": "right",
        "isNewLine": true
      }
    ]
  };

  TextEditingController _jsonD = TextEditingController();

  @override
  void initState() {
    super.initState();
    _jsonD.text = jsonEncode(_SAMPLE_JSON_INSTRUCTION_).toString();
    _loadPrinters();
  }

  Future<void> _loadPrinters() async {
    try {
      final printers = await _doposPrintPlugin.listPrinters();
      setState(() {
        _printers = printers;
      });
    } catch (e) {
      log('Failed to load printers: $e');
    }
  }

  Future<void> _print() async {
    if (_selectedPrinter == null) {
      log('No printer selected.');
      return;
    }

    _jsonInput = _jsonD.text;

    if (_jsonInput.isEmpty) {
      log('Please enter JSON data.');
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/printInstructions.json');
      await tempFile.writeAsString(_jsonInput);

      await _doposPrintPlugin.print(
        int.parse(_selectedPrinter!),
        tempFile.path,
      );
      log('Print command sent successfully.');
    } on PlatformException catch (e) {
      log('Failed to send print command: ${e.message}');
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Printer App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Printer App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              if (_printers.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    // child: DropdownButton<String>(
                    //   hint: const Text('Select Printer'),
                    //   value: _selectedPrinter,
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       _selectedPrinter = newValue;
                    //     });
                    //   },
                    //   items: _printers.map((printer) {
                    //     final printerIndex = printer.keys.first;
                    //     final printerName = printer.values.first;
                    //     return DropdownMenuItem<String>(
                    //       value: printerIndex,
                    //       child: Row(
                    //         children: <Widget>[
                    //           const Icon(Icons.print),
                    //           const SizedBox(width: 10),
                    //           Text(printerName),
                    //         ],
                    //       ),
                    //     );
                    //   }).toList(),
                    // ),
                    child: DropdownButton<String>(
                      hint: const Text('Select Printer'),
                      value: _selectedPrinter,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPrinter = newValue;
                        });
                      },
                      items: _printers.map((printer) {
                        final printerIndex = printer.keys.first;
                        final printerName = printer.values.first;
                        log("$printerIndex===>$printerName");
                        return DropdownMenuItem<String>(
                          value: printerIndex, // Ensure printerIndex is unique
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.print),
                              const SizedBox(width: 10),
                              Text(printerName),
                            ],
                          ),
                        );
                      }).toList(),
                    )),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _jsonD,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter JSON Data',
                  ),
                  // onChanged: (value) {
                  //   setState(() {
                  //     _jsonInput = value;
                  //   });
                  // },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _print,
                child: const Text('Print'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
