// External imports
import "package:flutter/material.dart";
import "package:frankenstein/core/services/storage_factory.dart";

// Project imports
import "core/services/global_list_manager.dart";
import "core/theme/theme_manager.dart";
import "core/theme/theme_manager_widget.dart";
import "features/home/widgets/initial_top.dart" show InitialTop, InitialTopKey;

void main() {
  runApp(const FrankensteinApp());
}

class FrankensteinApp extends StatefulWidget {
  const FrankensteinApp({super.key});

  @override
  State<FrankensteinApp> createState() => _FrankensteinAppState();
}

class _FrankensteinAppState extends State<FrankensteinApp> {
  late Future<void> _initializationClasses;

  @override
  void initState() {
    super.initState();
    _initializationClasses = _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize global list manager using the platform-appropriate storage
    // back end (file-based on desktop, localStorage on web).
    await GlobalListManager().initialise(createStorageService());

    // Initialize theme manager
    await ThemeManager.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationClasses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ThemeManagerWidget(
            child: InitialTop(key: InitialTopKey),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      "Please wait while the application saves or loads data",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
