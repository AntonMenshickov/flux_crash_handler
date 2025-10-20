import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flux_crash_handler_method_channel.dart';
import 'flux_crash_handler.dart';

abstract class FluxCrashHandlerPlatform extends PlatformInterface {
  /// Constructs a FluxCrashHandlerPlatform.
  FluxCrashHandlerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FluxCrashHandlerPlatform _instance = MethodChannelFluxCrashHandler();

  /// The default instance of [FluxCrashHandlerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFluxCrashHandler].
  static FluxCrashHandlerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FluxCrashHandlerPlatform] when
  /// they register themselves.
  static set instance(FluxCrashHandlerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<CrashReport?> getLastCrash() {
    throw UnimplementedError('getLastCrash() has not been implemented.');
  }

  Future<void> triggerTestCrash() {
    throw UnimplementedError('triggerTestCrash() has not been implemented.');
  }
}
