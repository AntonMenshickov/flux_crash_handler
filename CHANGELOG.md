## 0.0.1

* Initial release of flux_crash_handler plugin
* Capture unhandled exceptions on Android and iOS
* Save crash reports to JSON file with error message, timestamp, and stack trace
* Retrieve crash reports on next app launch via `getLastCrash()`
* Automatic cleanup of crash files after reading
* Support for both NSException and signal-based crashes on iOS
* Thread-based exception handling on Android
* Built-in `triggerTestCrash()` method for testing crash handling
* Singleton pattern with `FluxCrashHandler.instance` for easy access
