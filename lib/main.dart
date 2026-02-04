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
    _isGameActive = false;

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
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }
  void _onCardTap(int index) {
    if (_isProcessing || _cards[index].isFlipped || _cards[index].isMatched) return;

    if (!_isGameActive) {
      _isGameActive = true;
      _startTimer();
    }

    setState(() {
      _cards[index].isFlipped = true;
      _flippedIndices.add(index);
    });

    if (_flippedIndices.length == 2) {
      _isProcessing = true;
      _moves++;
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    int index1 = _flippedIndices[0];
    int index2 = _flippedIndices[1];

    if (_cards[index1].id == _cards[index2].id) {
      setState(() {
        _cards[index1].isMatched = true;
        _cards[index2].isMatched = true;
        _flippedIndices.clear();
        _isProcessing = false;
      });
      _checkWinCondition();
    } else {
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _cards[index1].isFlipped = false;
            _cards[index2].isFlipped = false;
            _flippedIndices.clear();
            _isProcessing = false;
          });
        }
      });
    }
  }

  void _checkWinCondition() {
    if (_cards.every((card) => card.isMatched)) {
      _timer?.cancel();
      _isGameOver = true;
      _saveHighScore(_moves);
      _showWinDialog();
    }
  }
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("¡Felicidades!"),
        content: Text("Completaste el juego en $_moves intentos y $_secondsElapsed segundos."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            child: const Text("Jugar de nuevo"),
          )
        ],
      ),
    );
  }
  // ─── Widgets auxiliares ────────────────────────────────────────────

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildCard(CardModel card) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: card.isMatched 
            ? Colors.green.shade300 
            : (card.isFlipped ? Colors.white : Colors.indigo),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.indigo.shade900),
      ),
      child: Center(
        child: card.isFlipped || card.isMatched
            ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    card.icon, 
                    color: card.isMatched ? Colors.white : Colors.indigo,
                  ),
                ),
              )
            : const Icon(
                Icons.help_outline, 
                color: Colors.white54, 
                size: 20,
              ),
      ),
    );
  }
}