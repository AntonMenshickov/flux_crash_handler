
import 'flux_crash_handler_platform_interface.dart';

/// Represents a crash report with error details, timestamp and stack trace
class CrashReport {
  final String error;
  final String timestamp;
  final String stackTrace;

  CrashReport({
    required this.error,
    required this.timestamp,
    required this.stackTrace,
  });

  factory CrashReport.fromJson(Map<String, dynamic> json) {
    return CrashReport(
      error: json['error'] as String,
      timestamp: json['timestamp'] as String,
      stackTrace: json['stackTrace'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'timestamp': timestamp,
      'stackTrace': stackTrace,
    };
  }
}

class FluxCrashHandler {
  FluxCrashHandler._();

  static final FluxCrashHandler _instance = FluxCrashHandler._();

  /// The singleton instance of [FluxCrashHandler]
  static FluxCrashHandler get instance => _instance;

  /// Initialize the crash handler to start capturing unhandled exceptions
  Future<void> initialize() {
    return FluxCrashHandlerPlatform.instance.initialize();
  }

  /// Get the last crash report if available, and delete the crash file
  /// Returns null if there is no crash report
  Future<CrashReport?> getLastCrash() {
    return FluxCrashHandlerPlatform.instance.getLastCrash();
  }

  /// Trigger a test crash to verify crash handling is working
  /// WARNING: This will crash the app immediately!
  Future<void> triggerTestCrash() {
    return FluxCrashHandlerPlatform.instance.triggerTestCrash();
  }
}
