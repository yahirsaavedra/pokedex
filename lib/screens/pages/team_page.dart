import 'package:flutter/material.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'package:pokedexapp/screens/team_screen.dart';
import 'dart:math' as math;

class MisEquiposScreen extends StatelessWidget {
  const MisEquiposScreen({super.key});

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
                FilledButton(
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
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text("Crear nuevo equipo"),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List>(
                future: BaseDatos.instance.queryAll("equipos"),
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
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: orientation == Orientation.portrait
                              ? 2
                              : 3,
                          mainAxisSpacing: 32,
                          crossAxisSpacing: 32,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: equipos.length,
                        itemBuilder: (context, index) {
                          final equipo = equipos[index] as Map<String, dynamic>;
                          final nombre = equipo["nombre"] ?? "";
                          final descripcion = equipo["descripcion"] ?? "";
                          final creador = equipo["creador"] ?? "";
                          final id = equipo["id"];

                          return GestureDetector(
                            onTap: () async {
                              // Obtén los pokemones del equipo
                              final pokemonesEquipo = await BaseDatos.instance
                                  .queryAll("pokemones");
                              final seleccionados = pokemonesEquipo
                                  .where((p) => p["equipo"] == id)
                                  .map((p) => p["id"] as int)
                                  .toList();

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
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      descripcion,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Spacer(),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(
                                            (math.Random().nextDouble() *
                                                    0xFFFFFF)
                                                .toInt(),
                                          ).withAlpha(255),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          creador,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
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
}
