import 'package:flutter/material.dart';
import 'package:quizz_app/constants/colors.dart';
import 'package:quizz_app/Screens/home.dart';

void main() {
  //  clearAllStoredSp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
