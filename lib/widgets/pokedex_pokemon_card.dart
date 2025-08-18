import 'package:flutter/material.dart';
import 'package:pokedexapp/modals/pokemon_modal.dart';

// Widget para mostrar la carta de un Pokémon en la Pokedex
class PokedexPokemonCard extends StatelessWidget {
  final Map<String, dynamic> pokemon;
  final Color tipoColor;

  /// Constructor de la carta de Pokémon para la Pokedex.
  /// [pokemon] es el mapa con los datos del Pokémon.
  /// [tipoColor] es el color del chip de tipo.
  const PokedexPokemonCard({
    super.key,
    required this.pokemon,
    required this.tipoColor,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = pokemon["nombre"];
    final imagen = pokemon["imagen"];
    final tipo = pokemon["tipo"];
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        // Muestra el modal con la información del Pokémon
        showDialog(
          context: context,
          barrierColor: const Color.fromARGB(
            102,
            0,
            0,
            0,
          ), // Fondo semitransparente
          builder: (context) => PokemonModal(pokemonId: pokemon["id"]),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagen del Pokémon
                  Expanded(
                    child: Image(
                      image: NetworkImage(imagen),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Nombre del Pokémon
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontFamily: 'CenturyGothic',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: tipoColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 0,
                    ),
                  ),
                ],
              ),
              // Icono de información en la esquina superior derecha
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.info_outline,
                  color: Colors.grey[700],
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
