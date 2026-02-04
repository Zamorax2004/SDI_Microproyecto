import 'package:flutter/material.dart';
import 'screens/game_page.dart';

void main() => runApp(const MemoryGameApp());

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Memoria',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const GamePage(),
    );
  }
}
