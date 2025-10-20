import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flux_crash_handler_platform_interface.dart';
import 'flux_crash_handler.dart';

/// An implementation of [FluxCrashHandlerPlatform] that uses method channels.
class MethodChannelFluxCrashHandler extends FluxCrashHandlerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flux_crash_handler');

  @override
  Future<void> initialize() async {
    await methodChannel.invokeMethod<void>('initialize');
  }

  @override
  Future<CrashReport?> getLastCrash() async {
    final Map<dynamic, dynamic>? result = 
        await methodChannel.invokeMethod<Map<dynamic, dynamic>>('getLastCrash');
    
    if (result == null) {
      return null;
    }

    return CrashReport.fromJson(Map<String, dynamic>.from(result));
  }

  @override
  Future<void> triggerTestCrash() async {
    await methodChannel.invokeMethod<void>('triggerTestCrash');
  }
}
