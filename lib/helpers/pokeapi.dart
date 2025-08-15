import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http show get;

class PokeAPI {
  Future<List<Map<String, dynamic>>> fetchPokemonList() async {
    // Función auxiliar para buscar un valor en español en una lista de nombres
    String? _getSpanishName(List items) {
      return items.firstWhere(
        (item) => item['language']['name'] == 'es',
        orElse: () => null,
      )?['name'];
    }

    String? _getSpanishFlavor(List items) {
      return items.lastWhere(
        (item) => item['language']['name'] == 'es',
        orElse: () => null,
      )?['flavor_text'];
    }

    String? _getSpanishAbility(List items) {
      return items.firstWhere(
        (item) => item['language']['name'] == 'es',
        orElse: () => null,
      )?['name'];
    }

    // Generar 150 requests en paralelo
    final pokemones = List.generate(150, (index) async {
      final id = index + 1;
      final urlPokemon = "https://pokeapi.co/api/v2/pokemon/$id";

      final responsePokemon = await http.get(Uri.parse(urlPokemon));
      if (responsePokemon.statusCode != 200) {
        throw Exception('Error al obtener el Pokémon $id');
      }

      final pokemon = jsonDecode(responsePokemon.body) as Map<String, dynamic>;

      pokemon["height"] /= 10; // dm → m
      pokemon["weight"] /= 10; // hg → kg

      final pokemonTypes = pokemon["types"] as List;
      final speciesUrl = pokemon["species"]["url"];
      final abilities = pokemon["abilities"] as List;

      // Peticiones de tipos y especies en paralelo
      final futures = [
        // Tipos
        ...pokemonTypes.map((typeEntry) async {
          final typeUrl = typeEntry["type"]["url"];
          final res = await http.get(Uri.parse(typeUrl));
          if (res.statusCode != 200) {
            throw Exception('Error al obtener tipo de Pokémon $id');
          }
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          return _getSpanishName(data["names"]) ?? data["name"];
        }),
        // Especie
        () async {
          final res = await http.get(Uri.parse(speciesUrl));
          if (res.statusCode != 200) {
            throw Exception('Error al obtener especie de Pokémon $id');
          }
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          return {
            "name": _getSpanishName(data["names"]),
            "flavor": _getSpanishFlavor(data["flavor_text_entries"]),
          };
        }(),
        // Habilidades
        ...abilities.map((abilityEntry) async {
          final abilityUrl = abilityEntry["ability"]["url"];
          final res = await http.get(Uri.parse(abilityUrl));
          if (res.statusCode != 200) {
            throw Exception('Error al obtener habilidad de Pokémon $id');
          }
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          return _getSpanishAbility(data["names"]) ?? data["name"];
        }),
      ];

      final results = await Future.wait(futures);

      // Los últimos resultados son la especie
      final speciesData = results[pokemonTypes.length] as Map<String, dynamic>;
      final typeNames = results.sublist(0, pokemonTypes.length);
      final abilitiesNames = results.sublist(
        pokemonTypes.length + 1,
        results.length,
      );

      pokemon["type"] = typeNames.first;
      pokemon["name"] = speciesData["name"];
      pokemon["description"] =
          speciesData["flavor"].replaceAll("\n", " ") ?? "???";
      pokemon["ability"] = abilitiesNames.first;

      return pokemon;
    });

    return await Future.wait(pokemones);
  }
}
