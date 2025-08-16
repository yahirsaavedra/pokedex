import 'package:flutter/material.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'package:pokedexapp/widgets/pokemon_card.dart';

class PokemonModal extends StatelessWidget {
  final int pokemonId;
  const PokemonModal({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List>(
        future: BaseDatos.instance.query("pokemones", pokemonId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final data = snapshot.data!;
          final pokemon = data.first as Map<String, dynamic>;
          final nombre = pokemon["nombre"];
          final imagen = pokemon["imagen"];
          final tipo = pokemon["tipo"];
          final altura = pokemon["altura"];
          final peso = pokemon["peso"];
          final habilidad = pokemon["habilidad"];
          final descripcion = pokemon["descripcion"];

          return Card(
            elevation: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PokemonCard(nombre: nombre, imagen: imagen, tipo: tipo),
                Table(
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        TableCell(
                          child: Column(
                            children: [Text("$altura m"), Text("Altura")],
                          ),
                        ),
                        TableCell(
                          child: Column(
                            children: [Text("$peso kg"), Text("Peso")],
                          ),
                        ),
                        TableCell(
                          child: Column(
                            children: [Text(habilidad), Text("Habilidad")],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(descripcion),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
