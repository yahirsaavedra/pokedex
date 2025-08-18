/// Este archivo contiene el widget que muestra la información
/// de un equipo en la interfaz.

import 'package:flutter/material.dart';

// Widget para mostrar la carta de un equipo.
class EquipoCard extends StatelessWidget {
  final Map<String, dynamic> equipo;
  final Color colorCreador;
  final VoidCallback onTap;

  /// Constructor de la carta de equipo.
  ///
  /// [equipo] es el mapa con los datos del equipo.
  /// [colorCreador] es el color del chip del creador.
  /// [onTap] es el callback al tocar la carta.
  const EquipoCard({
    super.key,
    required this.equipo,
    required this.colorCreador,
    required this.onTap,
  });

  @override
  /// Construye la interfaz de la carta de equipo.
  ///
  /// [context] es el contexto de construcción.
  Widget build(BuildContext context) {
    final nombre = equipo["nombre"] ?? "";
    final descripcion = equipo["descripcion"] ?? "";
    final creador = equipo["creador"] ?? "";

    return GestureDetector( // Detecta toques en la carta.
      onTap: onTap, // Navega a la pantalla de edición al tocar la carta.
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del equipo
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
              // Descripción del equipo (máx. 3 líneas)
              Flexible(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final descripcionParrafos = descripcion.split('\n');
                    List<Widget> parrafos = [];
                    int mostrar = descripcionParrafos.length > 3
                        ? 3
                        : descripcionParrafos.length;
                    for (int i = 0; i < mostrar; i++) {
                      parrafos.add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
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
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: parrafos,
                    );
                  },
                ),
              ),
              const Spacer(),
              // Chip con el nombre del creador
              Flexible(
                flex: 0,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: double.infinity,
                  child: Chip(
                    backgroundColor: colorCreador,
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
                      borderRadius: BorderRadius.circular(24),
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
  }
}
