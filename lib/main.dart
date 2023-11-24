import 'package:flutter/material.dart';
import 'pages/intro.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Categorizer (2)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 236, 0, 0)),
        useMaterial3: true,
      ),
      home: const IntroPage(),
    );
  }
}

