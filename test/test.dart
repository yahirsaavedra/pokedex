import 'package:pokedexapp/helpers/pokeapi.dart';

void main() async {
  var pokemon = await PokeAPI().fetchPokemonList();
  final id = pokemon[0]["id"];
  final nombre = pokemon[0]["name"];
  final tipo = pokemon[0]["type"];
  final altura = pokemon[0]["height"];
  final peso = pokemon[0]["weight"];
  final imagen = pokemon[0]["sprites"]["front_default"];
  final descripcion = pokemon[0]["description"];
  print(id);
  print(nombre);
  print(tipo);
  print(altura);
  print(peso);
  print(imagen);
  print(descripcion);
}
