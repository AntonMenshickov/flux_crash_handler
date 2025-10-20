# Integration Examples

This document provides examples of integrating Flux Crash Handler with popular analytics and crash reporting services.

## Firebase Crashlytics

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flux_crash_handler/flux_crash_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FluxCrashHandler.instance.initialize();
  
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  if (lastCrash != null) {
    // Report to Firebase Crashlytics
    await FirebaseCrashlytics.instance.recordError(
      Exception(lastCrash.error),
      StackTrace.fromString(lastCrash.stackTrace),
      reason: 'Crash from previous session at ${lastCrash.timestamp}',
    );
  }
  
  runApp(MyApp());
}
```

## Sentry

```dart
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flux_crash_handler/flux_crash_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FluxCrashHandler.instance.initialize();
  
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
    },
    appRunner: () => runApp(MyApp()),
  );
  
  if (lastCrash != null) {
    await Sentry.captureException(
      Exception(lastCrash.error),
      stackTrace: StackTrace.fromString(lastCrash.stackTrace),
    );
  }
}
```

## Custom Backend

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flux_crash_handler/flux_crash_handler.dart';

Future<void> sendCrashToBackend(CrashReport crash) async {
  try {
    final response = await http.post(
      Uri.parse('https://api.yourapp.com/crash-reports'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'error': crash.error,
        'timestamp': crash.timestamp,
        'stackTrace': crash.stackTrace,
        'appVersion': '1.0.0',
        'platform': Platform.isAndroid ? 'android' : 'ios',
      }),
    );
    
    if (response.statusCode == 200) {
      print('Crash report sent successfully');
    }
  } catch (e) {
    print('Failed to send crash report: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FluxCrashHandler.instance.initialize();
  
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  if (lastCrash != null) {
    await sendCrashToBackend(lastCrash);
  }
  
  runApp(MyApp());
}
```

## Slack Notification

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flux_crash_handler/flux_crash_handler.dart';

Future<void> sendCrashToSlack(CrashReport crash) async {
  const slackWebhookUrl = 'YOUR_SLACK_WEBHOOK_URL';
  
  final message = {
    'text': '🚨 App Crash Detected!',
    'attachments': [
      {
        'color': 'danger',
        'fields': [
          {
            'title': 'Error',
            'value': crash.error,
            'short': false,
          },
          {
            'title': 'Time',
            'value': crash.timestamp,
            'short': true,
          },
          {
            'title': 'Stack Trace',
            'value': '```${crash.stackTrace.substring(0, 500)}...```',
            'short': false,
          },
        ],
      },
    ],
  };
  
  await http.post(
    Uri.parse(slackWebhookUrl),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(message),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FluxCrashHandler.instance.initialize();
  
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  if (lastCrash != null) {
    await sendCrashToSlack(lastCrash);
  }
  
  runApp(MyApp());
}
```

## Local Storage for Later Analysis

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flux_crash_handler/flux_crash_handler.dart';

Future<void> saveCrashLocally(CrashReport crash) async {
  final prefs = await SharedPreferences.getInstance();
  final crashes = prefs.getStringList('crash_history') ?? [];
  
  crashes.add(json.encode({
    'error': crash.error,
    'timestamp': crash.timestamp,
    'stackTrace': crash.stackTrace,
  }));
  
  // Keep only last 10 crashes
  if (crashes.length > 10) {
    crashes.removeAt(0);
  }
  
  await prefs.setStringList('crash_history', crashes);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FluxCrashHandler.instance.initialize();
  
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  if (lastCrash != null) {
    await saveCrashLocally(lastCrash);
  }
  
  runApp(MyApp());
}
```

## Email Notification

```dart
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flux_crash_handler/flux_crash_handler.dart';

Future<void> emailCrashReport(CrashReport crash) async {
  final smtpServer = gmail('your-email@gmail.com', 'your-password');
  
  final message = Message()
    ..from = Address('your-email@gmail.com', 'App Crash Reporter')
    ..recipients.add('dev-team@yourcompany.com')
    ..subject = 'App Crash Detected - ${crash.timestamp}'
    ..text = '''
App crashed with the following details:

Error: ${crash.error}
Time: ${crash.timestamp}

Stack Trace:
${crash.stackTrace}
''';

  try {
    await send(message, smtpServer);
    print('Email sent successfully');
  } catch (e) {
    print('Failed to send email: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FluxCrashHandler.instance.initialize();
  
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  if (lastCrash != null) {
    await emailCrashReport(lastCrash);
  }
  
  runApp(MyApp());
}
```

## Multiple Services

You can combine multiple reporting methods:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FluxCrashHandler.instance.initialize();
  
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  if (lastCrash != null) {
    // Send to multiple services in parallel
    await Future.wait([
      FirebaseCrashlytics.instance.recordError(
        Exception(lastCrash.error),
        StackTrace.fromString(lastCrash.stackTrace),
      ),
      sendCrashToBackend(lastCrash),
      saveCrashLocally(lastCrash),
    ]);
  }
  
  runApp(MyApp());
}
```

