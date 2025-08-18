import 'package:flutter/material.dart';
import 'package:pokedexapp/helpers/database.dart';

class PokemonModal extends StatelessWidget {
  final int pokemonId;
  const PokemonModal({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final widthFactor = isLandscape ? 0.6 : 0.92;
    final maxHeight = isLandscape
        ? MediaQuery.of(context).size.height * 0.8
        : MediaQuery.of(context).size.height * 0.95;

    return Center(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SafeArea(
            child: FutureBuilder<List>(
              future: BaseDatos.instance.buscar("pokemones", pokemonId),
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

                return Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Encabezado rojo con botón de cerrar
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 24,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF26D6D),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(28),
                                topRight: Radius.circular(28),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    "Información",
                                    style: const TextStyle(
                                      fontFamily: 'CenturyGothic',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Image.network(
                              imagen,
                              height:
                                  MediaQuery.of(context).size.height *
                                  (isLandscape ? 0.13 : 0.16),
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(
                            nombre,
                            style: const TextStyle(
                              fontFamily: 'CenturyGothic',
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(
                              tipo,
                              style: const TextStyle(
                                fontFamily: 'CenturyGothic',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: _tipoColor(tipo),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: _datoPokemon(
                                    "${altura ?? "?"} m",
                                    "Altura",
                                  ),
                                ),
                                Flexible(
                                  child: _datoPokemon(
                                    "${peso ?? "?"} kg",
                                    "Peso",
                                  ),
                                ),
                                Flexible(
                                  child: _datoPokemon(
                                    habilidad ?? "?",
                                    "Habilidad",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              descripcion ?? "",
                              style: const TextStyle(
                                fontFamily: 'CenturyGothic',
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _datoPokemon(String valor, String etiqueta) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontFamily: 'CenturyGothic',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: const TextStyle(
            fontFamily: 'CenturyGothic',
            fontWeight: FontWeight.normal,
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

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
