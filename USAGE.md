# Flux Crash Handler - Quick Start Guide

## Basic Setup

### 1. Add dependency

```yaml
dependencies:
  flux_crash_handler: ^0.0.1
```

### 2. Initialize in main()

```dart
import 'package:flutter/material.dart';
import 'package:flux_crash_handler/flux_crash_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize crash handler
  await FluxCrashHandler.instance.initialize();
  
  // Check for previous crash
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  if (lastCrash != null) {
    // Handle the crash report
    print('App crashed previously!');
    print('Error: ${lastCrash.error}');
    print('Time: ${lastCrash.timestamp}');
    print('Stack: ${lastCrash.stackTrace}');
  }
  
  runApp(MyApp());
}
```

## API Reference

### FluxCrashHandler

Main class for crash handling operations.

#### Methods

**`FluxCrashHandler.instance`**

The singleton instance of FluxCrashHandler.

```dart
final instance = FluxCrashHandler.instance;
```

**`Future<void> initialize()`**

Initializes the crash handler. Must be called before crash capturing starts.

```dart
await FluxCrashHandler.instance.initialize();
```

**`Future<CrashReport?> getLastCrash()`**

Retrieves the last crash report and deletes the crash file. Returns `null` if no crash report exists.

```dart
final crash = await FluxCrashHandler.instance.getLastCrash();
if (crash != null) {
  // Handle crash
}
```

**`Future<void> triggerTestCrash()`**

Triggers a native crash for testing purposes. ⚠️ **WARNING: This will crash the app immediately!**

```dart
await FluxCrashHandler.instance.triggerTestCrash();
```

### CrashReport

Model representing a crash report.

#### Properties

- `String error` - The error message
- `String timestamp` - ISO 8601 timestamp (UTC) when crash occurred
- `String stackTrace` - Full stack trace of the crash

## Common Use Cases

### Send crash to analytics

```dart
final lastCrash = await FluxCrashHandler.instance.getLastCrash();
if (lastCrash != null) {
  // Send to your analytics service
  await Analytics.logCrash(
    error: lastCrash.error,
    stackTrace: lastCrash.stackTrace,
    timestamp: lastCrash.timestamp,
  );
}
```

### Show crash dialog to user

```dart
if (lastCrash != null) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('App crashed previously'),
      content: Text('Error: ${lastCrash.error}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

### Save crash to remote server

```dart
final lastCrash = await FluxCrashHandler.instance.getLastCrash();
if (lastCrash != null) {
  await http.post(
    Uri.parse('https://your-server.com/crashes'),
    body: json.encode({
      'error': lastCrash.error,
      'timestamp': lastCrash.timestamp,
      'stackTrace': lastCrash.stackTrace,
      'userId': currentUser.id,
    }),
  );
}
```

## Testing

To test the crash handler, use the built-in `triggerTestCrash()` method:

```dart
// Add a button to trigger a test crash
ElevatedButton(
  onPressed: () async {
    await FluxCrashHandler.instance.triggerTestCrash();
  },
  child: Text('Test Native Crash'),
)
```

**Or test with a Dart exception:**

```dart
ElevatedButton(
  onPressed: () {
    throw Exception('Test Dart crash!');
  },
  child: Text('Test Dart Crash'),
)
```

**Testing steps:**
1. Press the button
2. App will crash and close immediately
3. Restart the app
4. The crash will be available via `getLastCrash()`

## Important Notes

⚠️ **The crash file is deleted after reading** - Make sure to save/send the crash report before the next call to `getLastCrash()`

📝 **Only one crash is stored** - If multiple crashes occur, only the most recent is saved

🔒 **Privacy** - Crash files are stored in app-private directories and are not accessible to other apps

