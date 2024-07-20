#include "dopos_print_plugin.h"
#include <windows.h>
#include <VersionHelpers.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <memory>
#include <sstream>
#include <filesystem>

namespace fs = std::filesystem;

namespace dopos_print {

// static
void DoposPrintPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "dopos_print",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<DoposPrintPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

DoposPrintPlugin::DoposPrintPlugin() {}

DoposPrintPlugin::~DoposPrintPlugin() {}

void DoposPrintPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("print") == 0) {
    const auto* args = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (args) {
      auto it = args->find(flutter::EncodableValue("printerIndex"));
      if (it != args->end()) {
        int printerIndex = std::get<int>(it->second);

        it = args->find(flutter::EncodableValue("filePath"));
        if (it != args->end()) {
          std::string filePath = std::get<std::string>(it->second);

          char exePath[MAX_PATH];
          GetModuleFileNameA(NULL, exePath, MAX_PATH);
          std::string::size_type pos = std::string(exePath).find_last_of("\\/");
          std::string dir = std::string(exePath).substr(0, pos);

          // Navigate up two directories
          pos = dir.find_last_of("\\/");
          dir = dir.substr(0, pos);
          pos = dir.find_last_of("\\/");
          dir = dir.substr(0, pos);

          // Construct the path to the executable in the assets directory
          std::string printExePath = dir + "\\assets\\ThermalPrinterTest.exe";          
          
          std::string testCommand = "cmd.exe /C "+printExePath+" print "+std::to_string(printerIndex)+" "+filePath;
          PrintCommand(testCommand);

          result->Success(flutter::EncodableValue("Print command executed"));
          return;
        }
      }
    }
    result->Error("INVALID_ARGUMENT", "Invalid arguments for print method");
  } else if (method_call.method_name().compare("listPrinters") == 0) {
    ListPrinters(std::move(result));
  } else {
    result->NotImplemented();
  }
}

void DoposPrintPlugin::PrintCommand(const std::string& command) {
    std::wstring wideCommand(command.begin(), command.end());
    wideCommand.push_back(L'\0');

    STARTUPINFO startupInfo = { sizeof(startupInfo) };
    PROCESS_INFORMATION processInfo;

    if (CreateProcess(
        nullptr,
        &wideCommand[0],
        nullptr,
        nullptr,
        FALSE,
        0,
        nullptr,
        nullptr,
        &startupInfo,
        &processInfo)) {
        WaitForSingleObject(processInfo.hProcess, INFINITE);
        CloseHandle(processInfo.hProcess);
        CloseHandle(processInfo.hThread);
        OutputDebugString(L"Command executed successfully.");
    } else {
        DWORD error = GetLastError();
        std::wstring errorMessage = L"Failed to execute command, error code: " + std::to_wstring(error);
        OutputDebugString(errorMessage.c_str());
    }
}

void DoposPrintPlugin::ListPrinters(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  char exePath[MAX_PATH];
  GetModuleFileNameA(NULL, exePath, MAX_PATH);
  std::string::size_type pos = std::string(exePath).find_last_of("\\/");
  std::string dir = std::string(exePath).substr(0, pos);

  // Navigate up two directories
  pos = dir.find_last_of("\\/");
  dir = dir.substr(0, pos);
  pos = dir.find_last_of("\\/");
  dir = dir.substr(0, pos);

  // Construct the path to the executable in the assets directory
  std::string printExePath = dir + "\\assets\\ThermalPrinterTest.exe";

  std::string listCommand = "cmd.exe /C " + printExePath + " list";
  std::string output;

  // Execute the command and capture the output
  FILE* pipe = _popen(listCommand.c_str(), "r");
  if (!pipe) {
    result->Error("COMMAND_ERROR", "Failed to execute list command");
    return;
  }

  char buffer[128];
  while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
    output += buffer;
  }
  _pclose(pipe);

  // Process the output to extract printer list
  auto printers = std::make_unique<flutter::EncodableList>();
  std::istringstream stream(output);
  std::string line;
  while (std::getline(stream, line)) {
    if (line.empty() || line.find("Available printers:") != std::string::npos) {
      continue;
    }
    size_t colonPos = line.find(':');
    if (colonPos != std::string::npos) {
      std::string index = line.substr(0, colonPos);
      std::string name = line.substr(colonPos + 2);
      auto printer = std::make_unique<flutter::EncodableMap>();
      (*printer)[flutter::EncodableValue(index)] = flutter::EncodableValue(name);
      printers->push_back(std::move(*printer));
    }
  }

  result->Success(flutter::EncodableValue(*printers));
}


}  // namespace dopos_print
