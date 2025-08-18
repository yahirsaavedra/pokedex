/// Este archivo contiene la pantalla principal para gestionar los equipos de Pokémon.

import 'package:flutter/material.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'package:pokedexapp/screens/team_view_screen.dart';
import 'package:pokedexapp/widgets/team_card.dart';

/// Pantalla de Mis equipos
class MisEquiposScreen extends StatelessWidget {
  const MisEquiposScreen({super.key});

  // Mapa para asociar cada creador con un color
  static final Map<String, Color> _creadorColores = {};

  // Genera un color pastel aleatorio pero consistente para cada creador
  Color _colorParaCreador(String creador) {
    if (_creadorColores.containsKey(creador)) {
      return _creadorColores[creador]!;
    }
    final hash = creador.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);
    // Colores base suaves
    final baseColor = Color.fromARGB(255, r % 256, g % 256, b % 256);
    
    // Mezcla con blanco para obtener un color pastel.
    int pastelizar(int c) => ((c + 255) ~/ 2);
    final pastelColor = Color.fromARGB(
      255,
      pastelizar((baseColor.r * 255.0).round() & 0xff),
      pastelizar((baseColor.g * 255.0).round() & 0xff),
      pastelizar((baseColor.b * 255.0).round() & 0xff),
    );
    _creadorColores[creador] = pastelColor;
    return pastelColor;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: 230,
                  height: 50,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TeamScreen(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'CenturyGothic',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      child: const Text("Crear nuevo equipo"),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List>(
                future: BaseDatos.instance.buscarTodo("equipos"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final equipos = snapshot.data ?? [];
                  if (equipos.isEmpty) {
                    return const Center(child: Text("No hay equipos creados."));
                  }
                  return OrientationBuilder(
                    builder: (context, orientation) {
                      final crossAxisCount = orientation == Orientation.portrait
                          ? 2
                          : 3;
                      final aspectRatio = orientation == Orientation.portrait
                          ? 0.75
                          : 1.0; // Más largo
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: equipos.length,
                        itemBuilder: (context, index) {
                          final equipo = equipos[index] as Map<String, dynamic>;
                          final id = equipo["id"];
                          final creador = equipo["creador"] ?? "";
                          return EquipoCard(
                            equipo: equipo,
                            colorCreador: _colorParaCreador(creador),
                            onTap: () async {
                              final pokemonesEquipo = await BaseDatos.instance
                                  .buscarTodo("pokemones");
                              final seleccionados = pokemonesEquipo
                                  .where((p) => p["equipo"] == id)
                                  .map((p) => p["id"] as int)
                                  .toList();

                              if (!context.mounted) {
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamScreen(
                                    equipo: equipo,
                                    pokemonesSeleccionados: seleccionados,
                                    modoEdicion: true,
                                  ),
                                ),
                              );
                            },
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
}
