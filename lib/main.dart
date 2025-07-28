import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';

import 'auth_page.dart';
import 'bottom_nav_screen.dart';
import 'firebase_options.dart';
import 'services/connectivity_service.dart';
import 'no_internet_screen.dart';
// import 'api/static_blood_bank_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  print(" Initializing app...");
  await _initializeApp();

  print(" Starting application...");
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  // Initialize connectivity service
  print(" Initializing connectivity service...");
  ConnectivityService.instance.initialize();

  // Initialize Firebase
  print("🔥 Initializing Firebase...");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load and upload blood bank data (only in debug mode)
  // if (kDebugMode) {
  //   print(" Debug mode detected - uploading initial data...");
  //   try {
  //     await StaticBloodBankService.uploadToFirebase();
  //     print(" Database updated successfully");
  //   } catch (e) {
  //     print(" Database update failed: $e");
  //   }
  // }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blood Bank App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: StreamBuilder<ConnectivityResult>(
        stream: ConnectivityService.instance.connectivityStream,
        initialData: ConnectivityResult.mobile,
        builder: (context, snapshot) {
          if (snapshot.data == ConnectivityResult.none) {
            print(" Offline mode detected");
            return const NoInternetScreen();
          }
          return const AuthGate();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while waiting for Firebase to initialize
        if (snapshot.connectionState == ConnectionState.waiting) {
          print(" Checking authentication state...");
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the snapshot has data, a user is logged in
        if (snapshot.hasData) {
          print(" User logged in: ${snapshot.data!.email}");
          return const BottomNavScreen();
        }
        // Otherwise, no user is logged in
        else {
          print(" No user logged in - showing auth page");
          return const AuthPage();
        }
      },
    );
  }
}
