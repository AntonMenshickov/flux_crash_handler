# flux_crash_handler

A Flutter plugin for capturing unhandled exceptions and crashes on Android and iOS platforms. The plugin saves crash reports to a JSON file, which can be retrieved on the next app launch.

## Features

- 🚨 Captures unhandled exceptions on both Android and iOS
- 💾 Saves crash data to JSON file (error message, timestamp, stack trace)
- 📱 Works seamlessly with native crash handlers
- 🔄 Retrieves crash reports on next app launch
- 🗑️ Automatically deletes crash file after reading
- ⚡ Simple and lightweight API with singleton pattern
- 🧪 Built-in test crash method for easy testing

## Platform Support

| Android | iOS |
|---------|-----|
| ✅      | ✅  |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flux_crash_handler: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Initialize the crash handler

Call `initialize()` as early as possible in your app, preferably in the `main()` function:

```dart
import 'package:flutter/material.dart';
import 'package:flux_crash_handler/flux_crash_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize crash handler to start capturing crashes
  await FluxCrashHandler.instance.initialize();
  
  // Check for previous crash
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  if (lastCrash != null) {
    print('Last crash detected:');
    print('Error: ${lastCrash.error}');
    print('Time: ${lastCrash.timestamp}');
    print('Stack trace: ${lastCrash.stackTrace}');
    
    // Send crash report to your analytics service
    // Analytics.logCrash(lastCrash);
  }
  
  runApp(MyApp());
}
```

### API Methods

**`Future<void> initialize()`**

Initializes the crash handler to start capturing crashes.

**`Future<CrashReport?> getLastCrash()`**

Retrieves the last crash report and deletes the crash file. Returns `null` if no crash exists.

**`Future<void> triggerTestCrash()`**

Triggers a native crash for testing purposes. ⚠️ **WARNING: This will crash the app immediately!**

### CrashReport Model

The `getLastCrash()` method returns a `CrashReport` object with the following properties:

```dart
class CrashReport {
  final String error;       // Error message
  final String timestamp;   // ISO 8601 timestamp
  final String stackTrace;  // Full stack trace
}
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flux_crash_handler/flux_crash_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FluxCrashHandler.instance.initialize();
  
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  runApp(MyApp(lastCrash: lastCrash));
}

class MyApp extends StatelessWidget {
  final CrashReport? lastCrash;
  
  const MyApp({Key? key, this.lastCrash}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Crash Handler Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (lastCrash != null) ...[
                Text('Previous crash detected!'),
                Text('Error: ${lastCrash!.error}'),
                Text('Time: ${lastCrash!.timestamp}'),
              ] else
                Text('No previous crashes'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // This will trigger a native crash
                  await FluxCrashHandler.instance.triggerTestCrash();
                },
                child: Text('Trigger Crash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## How It Works

### Android

The plugin uses `Thread.setDefaultUncaughtExceptionHandler()` to capture unhandled exceptions. When a crash occurs:
1. The exception details are serialized to JSON
2. The JSON is saved to the app's internal storage
3. On next launch, the file is read and returned via `getLastCrash()`
4. The crash file is automatically deleted after reading

### iOS

The plugin uses `NSSetUncaughtExceptionHandler()` and signal handlers to capture crashes. The process is similar to Android:
1. Exception/signal details are captured
2. Data is saved as JSON in the app's Documents directory
3. File is read on next launch and then deleted

## Important Notes

- ⚠️ The crash file is automatically deleted after being read with `getLastCrash()`, so make sure to handle the crash report appropriately
- 📝 Only the most recent crash is stored (new crashes overwrite the previous file)
- 🔒 Crash files are stored in app-private directories and are not accessible to other apps
- ⏰ Timestamps are in ISO 8601 format (UTC)

## Testing

To test crash handling, use the built-in `triggerTestCrash()` method:

```dart
// Trigger a native crash for testing
await FluxCrashHandler.instance.triggerTestCrash();
```

**Testing steps:**
1. Call `initialize()` in your app
2. Call `triggerTestCrash()` to trigger a native crash
3. The app will terminate immediately
4. Restart the app
5. Call `getLastCrash()` to retrieve the crash report

**Alternative:** You can also test with Dart exceptions:
```dart
throw Exception('Test crash from Flutter');
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

