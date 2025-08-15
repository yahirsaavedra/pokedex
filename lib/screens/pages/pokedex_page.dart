import 'package:flutter/material.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'package:pokedexapp/modals/pokemon_modal.dart';
import 'dart:math' as math;

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List>(
        future: BaseDatos.instance.queryAll(
          "pokemones",
        ), // Espera la lista de Pokémon
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Cargando...
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;

          return OrientationBuilder(
            builder: (context, orientation) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (orientation == Orientation.portrait
                        ? 3
                        : 4),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: (orientation == Orientation.portrait
                        ? 0.6
                        : 1),
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final pokemon = data[index] as Map<String, dynamic>;
                    final nombre = pokemon["nombre"];
                    final imagen = pokemon["imagen"];
                    final tipo = pokemon["tipo"];

                    return Card(
                      elevation: 1,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                PokemonModal(pokemonId: pokemon["id"]),
                          );
                        },
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
