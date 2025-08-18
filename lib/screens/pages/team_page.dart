import 'package:flutter/material.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'package:pokedexapp/screens/team_screen.dart';

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
                SizedBox(
                  width: 230, // Un poco más ancho para el texto
                  height: 50,
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
                          final nombre = equipo["nombre"] ?? "";
                          final descripcion = equipo["descripcion"] ?? "";
                          final creador = equipo["creador"] ?? "";
                          final id = equipo["id"];

                          return GestureDetector(
                            onTap: () async {
                              final pokemonesEquipo = await BaseDatos.instance
                                  .buscarTodo("pokemones");
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
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      flex: 0,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          nombre,
                                          style: const TextStyle(
                                            fontFamily: 'CenturyGothic',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Flexible(
                                      flex: 2,
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final descripcionParrafos =
                                              descripcion.split('\n');
                                          List<Widget> parrafos = [];
                                          int mostrar =
                                              descripcionParrafos.length > 3
                                              ? 3
                                              : descripcionParrafos.length;
                                          for (int i = 0; i < mostrar; i++) {
                                            parrafos.add(
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 2,
                                                ),
                                                child: Text(
                                                  descripcionParrafos[i],
                                                  style: const TextStyle(
                                                    fontFamily: 'CenturyGothic',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                  softWrap: true,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            );
                                          }
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: parrafos,
                                          );
                                        },
                                      ),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                      flex: 0,
                                      child: Container(
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        width: double.infinity,
                                        child: Chip(
                                          backgroundColor: const Color(
                                            0xFFB3E5FC,
                                          ),
                                          label: Text(
                                            creador,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: 'CenturyGothic',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
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
