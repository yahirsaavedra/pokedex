import 'package:flutter/material.dart';
import 'package:pokedexapp/screens/home_screen.dart';
import 'package:pokedexapp/helpers/database.dart';

// Función principal de la app
void main() {
  runApp(const Pokedex());
}

// Widget principal de la app
class Pokedex extends StatelessWidget {
  const Pokedex({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp es el contenedor de toda la app: tema, rutas, título, etc.
    return MaterialApp(
      theme: ThemeData(fontFamily: 'CenturyGothic'),
      title: "Pokédex",
      debugShowCheckedModeBanner: false, // Quita la etiqueta "DEBUG"
      home: FutureBuilder(
        future: BaseDatos.instance.database,
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
