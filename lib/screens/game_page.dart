import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/card_model.dart';
import '../widgets/card_widget.dart';
import '../widgets/stat_item.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final int gridSize = 6;

  List<CardModel> _cards = [];

  final List<int> _flippedIndices = [];

  bool _isProcessing = false;
  bool _isGameActive = false;

  int _moves = 0;
  int _secondsElapsed = 0;
  int _highScore = 0;

  Timer? _timer;

  // ─────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────

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

  // ─────────────────────────────────────
  // Persistence
  // ─────────────────────────────────────

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

  // ─────────────────────────────────────
  // Game Logic
  // ─────────────────────────────────────

  void _initializeGame() {
    _timer?.cancel();

    _flippedIndices.clear();
    _isProcessing = false;
    _isGameActive = false;

    _moves = 0;
    _secondsElapsed = 0;

    final icons = [
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
      Icons.pets,
    ];

    final tempCards = <CardModel>[];

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing ||
        _cards[index].isFlipped ||
        _cards[index].isMatched) {
      return;
    }

    if (!_isGameActive) {
      _isGameActive = true;
      _startTimer();
    }

    setState(() {
      _cards[index] =
          _cards[index].copyWith(isFlipped: true);

      _flippedIndices.add(index);
    });

    if (_flippedIndices.length == 2) {
      _isProcessing = true;
      _moves++;

      _checkForMatch();
    }
  }

  void _checkForMatch() {
    final index1 = _flippedIndices[0];
    final index2 = _flippedIndices[1];

    if (_cards[index1].id == _cards[index2].id) {
      setState(() {
        _cards[index1] =
            _cards[index1].copyWith(isMatched: true);

        _cards[index2] =
            _cards[index2].copyWith(isMatched: true);

        _flippedIndices.clear();
        _isProcessing = false;
      });

      _checkWinCondition();
    } else {
      Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;

        setState(() {
          _cards[index1] =
              _cards[index1].copyWith(isFlipped: false);

          _cards[index2] =
              _cards[index2].copyWith(isFlipped: false);

          _flippedIndices.clear();
          _isProcessing = false;
        });
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

  // ─────────────────────────────────────
  // UI Helpers
  // ─────────────────────────────────────

  String _formattedTime() {
    final minutes = _secondsElapsed ~/ 60;
    final seconds = _secondsElapsed % 60;

    return "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  void _confirmRestart() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Reiniciar juego?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
            },
            child: const Text("Reiniciar"),
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("¡Felicidades!"),
        content: Text(
          "Completaste el juego en $_moves intentos\n"
          "Tiempo: ${_formattedTime()}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
            },
            child: const Text("Jugar de nuevo"),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // UI
  // ─────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memoria 6x6"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _confirmRestart,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.indigo.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItem(label: "Intentos", value: "$_moves"),
                StatItem(label: "Tiempo", value: _formattedTime()),
                StatItem(label: "Récord", value: "$_highScore"),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: GridView.builder(
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: _cards.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  return CardWidget(
                    card: _cards[index],
                    onTap: () => _onCardTap(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
