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

  bool _isGameActive = false; 

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> _saveHighScore(int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    if (_highScore == 0 || newScore < _highScore) {
      await prefs.setInt('highScore', newScore);
      setState(() {
        _highScore = newScore;
      });
    }
  }
  void _initializeGame() {
    _timer?.cancel();
    _flippedIndices.clear();
    _isProcessing = false;
    _moves = 0;
    _secondsElapsed = 0;
    _isGameOver = false;
    _isGameActive = false; // El juego está listo, pero no activo (reloj parado)

    List<IconData> icons = [
      Icons.ac_unit, Icons.access_alarm, Icons.airport_shuttle, Icons.all_inclusive,
      Icons.beach_access, Icons.cake, Icons.camera_alt, Icons.audiotrack,
      Icons.directions_bike, Icons.emoji_events, Icons.flight, Icons.golf_course,
      Icons.headphones, Icons.icecream, Icons.local_dining, Icons.map,
      Icons.navigation, Icons.pets
    ];

    List<CardModel> tempCards = [];
    for (int i = 0; i < (gridSize * gridSize) ~/ 2; i++) {
      final icon = icons[i % icons.length];
      tempCards.add(CardModel(id: i, icon: icon));
      tempCards.add(CardModel(id: i, icon: icon));
    }

    tempCards.shuffle(Random());
    
    setState(() {
      _cards = tempCards;
    });
    
    // NOTA: Ya no llamamos a _startTimer() aquí.
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }