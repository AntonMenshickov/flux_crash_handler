import Flutter
import UIKit

public class FluxCrashHandlerPlugin: NSObject, FlutterPlugin {
  private static let crashFileName = "flux_crash_report.json"
  private static var previousExceptionHandler: (@convention(c) (NSException) -> Void)?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flux_crash_handler", binaryMessenger: registrar.messenger())
    let instance = FluxCrashHandlerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      initializeCrashHandler()
      result(nil)
    case "getLastCrash":
      let crashReport = getLastCrashReport()
      result(crashReport)
    case "triggerTestCrash":
      result(nil)
      // Trigger crash after returning result
      DispatchQueue.main.async {
        NSException(name: NSExceptionName("TestCrash"), 
                    reason: "Test crash triggered by FluxCrashHandler", 
                    userInfo: nil).raise()
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func initializeCrashHandler() {
    FluxCrashHandlerPlugin.previousExceptionHandler = NSGetUncaughtExceptionHandler()
    
    NSSetUncaughtExceptionHandler { exception in
      FluxCrashHandlerPlugin.saveCrashReport(exception: exception)
      FluxCrashHandlerPlugin.previousExceptionHandler?(exception)
    }
    
    // Handle signals for crashes that don't throw NSException
    signal(SIGABRT) { signal in
      FluxCrashHandlerPlugin.saveCrashReportForSignal(signal: signal)
      exit(signal)
    }
    
    signal(SIGILL) { signal in
      FluxCrashHandlerPlugin.saveCrashReportForSignal(signal: signal)
      exit(signal)
    }
    
    signal(SIGSEGV) { signal in
      FluxCrashHandlerPlugin.saveCrashReportForSignal(signal: signal)
      exit(signal)
    }
    
    signal(SIGFPE) { signal in
      FluxCrashHandlerPlugin.saveCrashReportForSignal(signal: signal)
      exit(signal)
    }
    
    signal(SIGBUS) { signal in
      FluxCrashHandlerPlugin.saveCrashReportForSignal(signal: signal)
      exit(signal)
    }
  }
  
  private static func saveCrashReport(exception: NSException) {
    do {
      let timestamp = ISO8601DateFormatter().string(from: Date())
      
      let callStackSymbols = exception.callStackSymbols.joined(separator: "\n")
      let stackTrace = """
      Exception: \(exception.name.rawValue)
      Reason: \(exception.reason ?? "Unknown")
      
      Stack Trace:
      \(callStackSymbols)
      """
      
      let errorMessage = exception.reason ?? exception.name.rawValue
      
      let crashData: [String: Any] = [
        "error": errorMessage,
        "timestamp": timestamp,
        "stackTrace": stackTrace
      ]
      
      if let jsonData = try? JSONSerialization.data(withJSONObject: crashData, options: .prettyPrinted) {
        let fileURL = getCrashFileURL()
        try jsonData.write(to: fileURL)
      }
    } catch {
      print("Failed to save crash report: \(error)")
    }
  }
  
  private static func saveCrashReportForSignal(signal: Int32) {
    do {
      let timestamp = ISO8601DateFormatter().string(from: Date())
      
      let signalName: String
      switch signal {
      case SIGABRT:
        signalName = "SIGABRT"
      case SIGILL:
        signalName = "SIGILL"
      case SIGSEGV:
        signalName = "SIGSEGV"
      case SIGFPE:
        signalName = "SIGFPE"
      case SIGBUS:
        signalName = "SIGBUS"
      default:
        signalName = "Signal \(signal)"
      }
      
      let stackTrace = Thread.callStackSymbols.joined(separator: "\n")
      
      let crashData: [String: Any] = [
        "error": "Signal: \(signalName)",
        "timestamp": timestamp,
        "stackTrace": stackTrace
      ]
      
      if let jsonData = try? JSONSerialization.data(withJSONObject: crashData, options: .prettyPrinted) {
        let fileURL = getCrashFileURL()
        try jsonData.write(to: fileURL)
      }
    } catch {
      print("Failed to save crash report: \(error)")
    }
  }
  
  private func getLastCrashReport() -> [String: String]? {
    do {
      let fileURL = FluxCrashHandlerPlugin.getCrashFileURL()
      
      guard FileManager.default.fileExists(atPath: fileURL.path) else {
        return nil
      }
      
      let data = try Data(contentsOf: fileURL)
      try FileManager.default.removeItem(at: fileURL)
      
      if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
         let error = json["error"] as? String,
         let timestamp = json["timestamp"] as? String,
         let stackTrace = json["stackTrace"] as? String {
        return [
          "error": error,
          "timestamp": timestamp,
          "stackTrace": stackTrace
        ]
      }
      
      return nil
    } catch {
      print("Failed to read crash report: \(error)")
      return nil
    }
  }
  
  private static func getCrashFileURL() -> URL {
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentDirectory.appendingPathComponent(crashFileName)
  }
}
