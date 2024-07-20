#ifndef FLUTTER_PLUGIN_DOPOS_PRINT_PLUGIN_H_
#define FLUTTER_PLUGIN_DOPOS_PRINT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace dopos_print {

class DoposPrintPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DoposPrintPlugin();

  virtual ~DoposPrintPlugin();

  // Disallow copy and assign.
  DoposPrintPlugin(const DoposPrintPlugin&) = delete;
  DoposPrintPlugin& operator=(const DoposPrintPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  void PrintCommand(const std::string& command);
  void ListPrinters(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace dopos_print

#endif  // FLUTTER_PLUGIN_DOPOS_PRINT_PLUGIN_H_
