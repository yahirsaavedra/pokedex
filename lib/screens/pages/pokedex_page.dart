import 'package:flutter/material.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'package:pokedexapp/modals/pokemon_modal.dart';
import 'dart:math' as math;

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pokedex",
                style: const TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List>(
                  future: BaseDatos.instance.queryAll("pokemones"),
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
                        final crossAxisCount =
                            orientation == Orientation.portrait ? 2 : 4;
                        final aspectRatio = orientation == Orientation.portrait
                            ? 0.8
                            : 1.0;
                        return GridView.builder(
                          padding: const EdgeInsets.only(top: 12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                showModalBottomSheet(
                                  context: context,
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
                                              fontSize: 18,
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
                                                fontWeight: FontWeight.normal,
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: _tipoColor(tipo),
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
      ),
    );
  }

  // Color por tipo (puedes ajustar los colores según tu preferencia)
  Color _tipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'planta':
        return Color(0xFF8BC34A);
      case 'agua':
        return Color(0xFF4FC3F7);
      case 'tierra':
        return Color(0xFFE57373);
      case 'trueno':
        return Color(0xFFFFD600);
      case 'normal':
        return Color(0xFFBA68C8);
      default:
        return Colors.grey;
    }
  }
}
