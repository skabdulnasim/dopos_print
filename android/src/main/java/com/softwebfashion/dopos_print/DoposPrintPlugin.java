package com.softwebfashion.dopos_print;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** DoposPrintPlugin */
public class DoposPrintPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "dopos_print");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "listPrinters":
                listPrinters(result);
                break;
            case "print":
                print(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void listPrinters(Result result) {
        // Return a list of dummy printers
        List<Map<String, String>> printers = new ArrayList<>();
        
        Map<String, String> printerA = new HashMap<>();
        printerA.put("0", "Printer A");

        Map<String, String> printerB = new HashMap<>();
        printerB.put("1", "Printer B");

        Map<String, String> printerC = new HashMap<>();
        printerC.put("2", "Printer C");

        printers.add(printerA);
        printers.add(printerB);
        printers.add(printerC);

        result.success(printers);
    }

    private void print(MethodCall call, Result result) {
        // Simulate printing process
        int printerIndex = call.argument("printerIndex");
        String filePath = call.argument("filePath");

        // Log printing action
        System.out.println("Printing to Printer Index: " + printerIndex);
        System.out.println("File Path: " + filePath);

        // Return success message
        result.success("Successfully printed!");
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}