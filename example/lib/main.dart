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

  @override
  void initState() {
    super.initState();
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
                      return DropdownMenuItem<String>(
                        value: printerIndex,
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.print),
                            const SizedBox(width: 10),
                            Text(printerName),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter JSON Data',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _jsonInput = value;
                    });
                  },
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
