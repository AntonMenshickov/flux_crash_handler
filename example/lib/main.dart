import 'package:flutter/material.dart';
import 'package:flux_crash_handler/flux_crash_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize crash handler
  await FluxCrashHandler.instance.initialize();
  
  // Check for last crash report
  final lastCrash = await FluxCrashHandler.instance.getLastCrash();
  
  runApp(MyApp(lastCrash: lastCrash));
}

class MyApp extends StatelessWidget {
  final CrashReport? lastCrash;
  
  const MyApp({super.key, this.lastCrash});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flux Crash Handler Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MyHomePage(lastCrash: lastCrash),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final CrashReport? lastCrash;
  
  const MyHomePage({super.key, this.lastCrash});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    
    // Show last crash report if available
    if (widget.lastCrash != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCrashDialog(widget.lastCrash!);
      });
    }
  }

  void _showCrashDialog(CrashReport crash) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Previous Crash Detected'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Time: ${crash.timestamp}', 
                     style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Error: ${crash.error}',
                     style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Stack Trace:',
                     style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[200],
                  child: Text(
                    crash.stackTrace,
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _triggerCrash() async {
    // This will trigger a native crash
    await FluxCrashHandler.instance.triggerTestCrash();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flux Crash Handler Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 100,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Flux Crash Handler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This plugin captures unhandled exceptions and saves crash reports.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              if (widget.lastCrash != null)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        const Text(
                          'Last crash detected!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Time: ${widget.lastCrash!.timestamp}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showCrashDialog(widget.lastCrash!),
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _triggerCrash,
                icon: const Icon(Icons.bug_report),
                label: const Text('Trigger Test Crash'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Press the button to test crash handling.\nRestart the app to see the crash report.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
