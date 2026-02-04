import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const CardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
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
      ),
    );
  }
}
