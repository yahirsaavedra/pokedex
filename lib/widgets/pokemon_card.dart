import 'package:flutter/material.dart';
import 'dart:math' as math;

class PokemonCard extends StatelessWidget {
  final String nombre;
  final String imagen;
  final String tipo;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? extra; // Para añadir widgets extra como botones

  const PokemonCard({
    super.key,
    required this.nombre,
    required this.imagen,
    required this.tipo,
    this.isSelected = false,
    this.onTap,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: isSelected ? Colors.lightGreen.shade200 : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: NetworkImage(imagen)),
          Text(nombre, style: const TextStyle(fontSize: 16)),
          Chip(
            label: Text(tipo),
            backgroundColor: Color(
              (math.Random().nextDouble() * 0xFFFFFF).toInt(),
            ).withAlpha(255),
          ),
          const Divider(
            height: 30,
            thickness: 0.5,
            indent: 20,
            color: Colors.grey,
          ),
          if (extra != null) extra!,
        ],
      ),
    );
  }
}
