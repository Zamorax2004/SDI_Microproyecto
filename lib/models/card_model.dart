import 'package:flutter/material.dart';

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
