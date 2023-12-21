import 'package:flutter/material.dart';
import 'pages/intro.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:categorizer2/firebase_options.dart  ';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Categorizer 2',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 236, 0, 0)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 236, 0, 0)),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),
        ),
        // Add other theme properties here
      ),
      home: const IntroPage(),
    );
  }
}

