import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  final String label;
  final String value;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  static const _labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.indigo,
    fontSize: 12,
  );

  static const _valueStyle = TextStyle(
    fontSize: 16,
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: _labelStyle,
          ),

          // Espacio pequeño entre texto y valor
          const SizedBox(height: 2),

          // AnimatedSwitcher animará cuando el "value" cambie
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              // combinación de fade + scale (suave)
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },

            // IMPORTANTE: la key permite que Flutter
            // note que el valor cambió y dispare la animación
            child: Text(
              value,
              key: ValueKey<String>(value),
              style: _valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}
