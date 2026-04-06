// to run backend type python -m uvicorn main:app --reload
// to run flutter run emulator and press f5

import 'package:flutter/material.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_edit_screen.dart';
import 'screens/application_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internship Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
        useMaterial3: true,
      ),
      // App opens on Register screen first
      //initialRoute: '/register',
      initialRoute: '/home',
      routes: {
        //'/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/add': (context) => const AddEditScreen(),
        '/list': (context) => const ApplicationListScreen(),
      },
    );
  }
}
