import 'dart:developer';
import 'package:flutter/services.dart';

class DoposPrint {
  static const MethodChannel _channel = MethodChannel('dopos_print');

  Future<void> print(int printerIndex, String filePath) async {
    try {
      await _channel.invokeMethod('print', {
        'printerIndex': printerIndex,
        'filePath': filePath,
      });
    } on PlatformException catch (e) {
      log("Failed to print: '${e.message}'.");
    }
  }

  Future<List<Map<String, String>>> listPrinters() async {
    try {
      final List<dynamic> printerList =
          await _channel.invokeMethod('listPrinters');
      return printerList.map<Map<String, String>>((printer) {
        final Map<Object?, Object?> map = printer as Map<Object?, Object?>;
        return {
          map.keys.first as String: map.values.first as String,
        };
      }).toList();
    } on PlatformException catch (e) {
      log("Failed to list printers: '${e.message}'.");
      return [];
    }
  }
}
