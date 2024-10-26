import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'welcome.dart'; // Assuming 'welcome.dart' is the file containing your Welcome widget

//
void main() async {
  // Ensure that plugin services are initialized before app startup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Setting the system UI overlay style for the status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        fontFamily: 'inter', // Ensure this font is included in pubspec.yaml
        useMaterial3: true, // Enables Material 3 design components
      ),
      home: const Welcome(), // Entry point of the app
    );
  }
}

// Function to convert hex color strings to Color
int hexColor(String c) {
  String sColor = '0xff$c'; // Prepend '0xff' for full opacity
  sColor = sColor.replaceAll('#', ''); // Remove '#' if present
  int dColor = int.parse(sColor); // Parse to int
  return dColor; // Return the integer color value
}


// i have fluter project and I am bus booking for my college so how it looks like that there are some slots in which the buses are running like A,b,C and something upto E, and in each slot there can be some buses running means let say slot A has 2 buses running bus 1 and bus2 in this way so I want to create the firestore database for this and want to integrate in teh f