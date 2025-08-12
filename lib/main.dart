import 'package:flutter/material.dart';
import 'package:pokedexapp/screens/team_screen.dart';

void main() {
  runApp(const Pokedex());
}

class Pokedex extends StatelessWidget {
  const Pokedex({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pokédex",
      debugShowCheckedModeBanner: false,
      //theme: ThemeData(fontFamily: "Century Gothic"),
      home: const TeamScreen(),
    );
  }
}
