import 'package:flutter/material.dart';

// Widget para mostrar la carta de un Pokémon
class PokemonCard extends StatelessWidget {
  final String nombre;
  final String imagen;
  final String tipo;
  final bool isSelected;
  final Widget? extra;
  final Color? chipColor; // <-- Nuevo parámetro

  const PokemonCard({
    super.key,
    required this.nombre,
    required this.imagen,
    required this.tipo,
    required this.isSelected,
    this.extra,
    this.chipColor, // <-- Nuevo parámetro
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 6 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Image.network(imagen, fit: BoxFit.contain)),
            const SizedBox(height: 8),
            Text(
              nombre,
              style: const TextStyle(
                fontFamily: 'CenturyGothic',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                tipo,
                style: const TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              backgroundColor:
                  chipColor ?? Colors.grey, // <-- Usa el color recibido
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            if (extra != null) ...[const SizedBox(height: 8), extra!],
          ],
        ),
      ),
    );
  }
}
