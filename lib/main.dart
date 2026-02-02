import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  runApp(const MemoryGameApp());
}

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

class CardModel {
  final int id;
  final IconData icon;
  bool isFlipped;
  bool isMatched;

  CardModel({
    required this.id,
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final int gridSize = 6;
  List<CardModel> _cards = [];
  
  List<int> _flippedIndices = [];
  bool _isProcessing = false;
  int _moves = 0;
  int _secondsElapsed = 0;
  Timer? _timer;
  int _highScore = 0;
  bool _isGameOver = false;