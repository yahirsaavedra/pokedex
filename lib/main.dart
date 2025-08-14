import 'package:flutter/material.dart';
// import 'package:pokedexapp/screens/home_screen.dart';
import 'package:pokedexapp/screens/team_screen.dart'; // Pantalla de gestión de equipos

// Función principal de la app
void main() {
  runApp(const Pokedex()); // Inicia el widget raíz de la aplicación
}

// Widget principal de la app
class Pokedex extends StatelessWidget {
  const Pokedex({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp es el contenedor de toda la app: tema, rutas, título, etc.
    return MaterialApp(
      title: "Pokédex",
      debugShowCheckedModeBanner: false, // Quita la etiqueta "DEBUG"
      home:
          const TeamScreen(), // Pantalla inicial (puede cambiarse en el futuro)
    );
  }
}
