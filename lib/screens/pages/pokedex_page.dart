import 'package:flutter/material.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'package:pokedexapp/modals/pokemon_modal.dart';

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List>(
                future: BaseDatos.instance.buscarTodo("pokemones"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final data = snapshot.data!;
                  return OrientationBuilder(
                    builder: (context, orientation) {
                      final crossAxisCount = orientation == Orientation.portrait
                          ? 2
                          : 4;
                      final aspectRatio = orientation == Orientation.portrait
                          ? 0.8
                          : 1.0;
                      return GridView.builder(
                        padding: const EdgeInsets.only(top: 12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final pokemon = data[index] as Map<String, dynamic>;
                          final nombre = pokemon["nombre"];
                          final imagen = pokemon["imagen"];
                          final tipo = pokemon["tipo"];
                          return InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.4),
                                builder: (context) =>
                                    PokemonModal(pokemonId: pokemon["id"]),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Image(
                                            image: NetworkImage(imagen),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
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
                                          backgroundColor: _tipoColor(
                                            tipo,
                                          ), // Usa la función consistente
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 0,
                                          ),
                                        ),
                                      ],
                                    ),
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
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Color por tipo (puedes ajustar los colores según tu preferencia)
  Color _tipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'planta':
        return const Color(0xFF7AC74C);
      case 'agua':
        return const Color(0xFF6390F0);
      case 'fuego':
        return const Color(0xFFEE8130);
      case 'trueno':
        return const Color(0xFFF7D02C);
      case 'tierra':
        return const Color(0xFFE2BF65);
      case 'normal':
        return const Color(0xFFA8A77A);
      default:
        return Colors.grey;
    }
  }
}
