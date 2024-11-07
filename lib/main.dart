import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quizz_app/Screens/home.dart';
import 'package:quizz_app/constants/colors.dart';
import 'package:quizz_app/firebase_options.dart';

void main() {
  setup().then((_) {
    runApp(const MyApp());
  });
}

Future<void> setup() async {
  // setup firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Firebase app is initialized!');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
