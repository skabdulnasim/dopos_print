#include "include/dopos_print/dopos_print_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "dopos_print_plugin.h"

void DoposPrintPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  dopos_print::DoposPrintPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
