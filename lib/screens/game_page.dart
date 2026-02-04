import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';
import '../widgets/card_widget.dart';
import '../widgets/stat_item.dart';
import 'dart:math';

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
  bool _isGameActive = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _initializeGame();
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
    _isGameActive = false;

    List<IconData> icons = [
      Icons.ac_unit,
      Icons.access_alarm,
      Icons.airport_shuttle,
      Icons.all_inclusive,
      Icons.beach_access,
      Icons.cake,
      Icons.camera_alt,
      Icons.audiotrack,
      Icons.directions_bike,
      Icons.emoji_events,
      Icons.flight,
      Icons.golf_course,
      Icons.headphones,
      Icons.icecream,
      Icons.local_dining,
      Icons.map,
      Icons.navigation,
      Icons.pets
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memoria 6x6"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeGame,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.indigo.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItem(label: "Intentos", value: "$_moves"),
                StatItem(label: "Tiempo", value: "${_secondsElapsed}s"),
                StatItem(label: "Récord", value: "$_highScore"),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: GridView.builder(
                itemCount: _cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6),
                itemBuilder: (context, index) => CardWidget(
                  card: _cards[index],
                  onTap: () => _onCardTap(index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
