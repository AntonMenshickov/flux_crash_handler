import 'package:flutter_test/flutter_test.dart';
import 'package:flux_crash_handler/flux_crash_handler.dart';
import 'package:flux_crash_handler/flux_crash_handler_platform_interface.dart';
import 'package:flux_crash_handler/flux_crash_handler_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFluxCrashHandlerPlatform
    with MockPlatformInterfaceMixin
    implements FluxCrashHandlerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FluxCrashHandlerPlatform initialPlatform = FluxCrashHandlerPlatform.instance;

  test('$MethodChannelFluxCrashHandler is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFluxCrashHandler>());
  });

  test('getPlatformVersion', () async {
    FluxCrashHandler fluxCrashHandlerPlugin = FluxCrashHandler();
    MockFluxCrashHandlerPlatform fakePlatform = MockFluxCrashHandlerPlatform();
    FluxCrashHandlerPlatform.instance = fakePlatform;

    expect(await fluxCrashHandlerPlugin.getPlatformVersion(), '42');
  });
}
