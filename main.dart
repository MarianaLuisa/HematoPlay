import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hematoplay/login.dart';
import 'firebase_options.dart';

//Este pode mudar, mas precisa ser multiplo do total.
int totalQuestions = 5;

//Não mudar
int questionCounter = 1;
int correctCounter = 0;
Map<String, List<String>> answereds = {'1':[]};

bool isFinished = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HematoPlay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}
