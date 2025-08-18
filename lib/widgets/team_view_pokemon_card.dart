import 'package:flutter/material.dart';

// Widget para mostrar la carta de un Pokémon en el equipo
class PokemonCard extends StatelessWidget {
  final String nombre;
  final String imagen;
  final String tipo;
  final bool isSelected;
  final Widget? extra;
  final Color? chipColor;

  /// Constructor de la carta de Pokémon.
  ///
  /// [nombre] es el nombre del Pokémon.
  /// [imagen] es la URL de la imagen.
  /// [tipo] es el tipo del Pokémon.
  /// [isSelected] indica si está seleccionado.
  /// [extra] es un widget adicional (botón de añadir/eliminar).
  /// [chipColor] es el color del chip de tipo.
  const PokemonCard({
    super.key,
    required this.nombre,
    required this.imagen,
    required this.tipo,
    required this.isSelected,
    this.extra,
    this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    // Usa LayoutBuilder para adaptar el diseño al espacio disponible.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: isSelected ? 6 : 2, // Resalta si está seleccionado.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Imagen del Pokémon
                      Expanded(
                        child: Image.network(imagen, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 8),
                      // Nombre del Pokémon
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
                      // Chip con el tipo del Pokémon
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
                        backgroundColor: chipColor ?? Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                      ),
                      // Widget extra (botón de añadir/eliminar)
                      if (extra != null) ...[const SizedBox(height: 8), extra!],
                    ],
                  ),
                ),
              ),
            ),
            // Icono de selección si el Pokémon está seleccionado
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF7AC74C),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(26, 0, 0, 0), // Sombra suave
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.check, color: Colors.white, size: 28),
                ),
              ),
          ],
        );
      },
    );
  }
}
