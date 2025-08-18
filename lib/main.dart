/// Este archivo contiene el punto de entrada principal de la aplicación Pokédex.
/// Define el widget raíz y la configuración global del tema, rutas y pantalla inicial.

import 'package:flutter/material.dart';
import 'package:pokedexapp/screens/home_screen.dart';
import 'package:pokedexapp/helpers/database.dart';

/// Función principal de la app. Inicializa y ejecuta el widget raíz.
void main() {
  runApp(const Pokedex());
}

/// Este es un widget sin estado que construye la interfaz de usuario de la aplicación.
///
/// Configura el tema, título, y muestra la pantalla inicial cuando la base de datos está lista.
class Pokedex extends StatelessWidget {
  const Pokedex({super.key});

  @override
  /// Construye la interfaz de usuario de la aplicación.
  ///
  /// [context] es el contexto de construcción.
  Widget build(BuildContext context) {
    // MaterialApp es el contenedor de toda la app: tema, rutas, título, etc.
    return MaterialApp(
      theme: ThemeData(fontFamily: 'CenturyGothic'), // Fuente global
      title: "Pokédex",
      debugShowCheckedModeBanner: false, // Quita la etiqueta "DEBUG"
      home: FutureBuilder(
        future: BaseDatos
            .instance
            .database, // Espera la inicialización de la base de datos
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // Muestra icono de carga mientras la base se inicializa
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Cuando la base está lista, muestra la pantalla principal
          return const HomeScreen();
        },
      ),
    );
  }
}
