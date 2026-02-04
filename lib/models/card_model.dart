import 'package:flutter/material.dart';

/// Representa una carta en el juego de memoria.
///
/// Contiene un ID único y un ícono visual.
/// Los estados `isFlipped` e `isMatched` controlan
/// el comportamiento en el tablero.
class CardModel {
  final int id;
  final IconData icon;
  final bool isFlipped;
  final bool isMatched;

  const CardModel({
    required this.id,
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });

  /// Devuelve una copia de esta carta con
  /// cambios en las propiedades indicadas.
  CardModel copyWith({
    bool? isFlipped,
    bool? isMatched,
  }) {
    return CardModel(
      id: id,
      icon: icon,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
