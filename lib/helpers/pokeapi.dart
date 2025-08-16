import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http show get;

class PokeAPI {
  // Cache para URLs ya consultadas
  final Map<String, dynamic> _cache = {};

  // Método unificado para obtener un campo en español
  String? getSpanishField(List items, String field, {bool last = false}) {
    final finder = last ? items.lastWhere : items.firstWhere;
    return finder(
      (item) => item['language']['name'] == 'es',
      orElse: () => null,
    )?[field];
  }

  // Consulta una URL con cache y reintentos
  Future<dynamic> fetchUrl(String url) async {
    if (_cache.containsKey(url)) {
      return _cache[url];
    }
    int retries = 0;
    while (true) {
      try {
        final res = await http.get(Uri.parse(url));
        if (res.statusCode != 200) throw Exception('Error al consultar $url');
        final data = jsonDecode(res.body);
        _cache[url] = data;
        return data;
      } catch (e) {
        retries++;
        if (retries > 3) rethrow; // Reintenta hasta 3 veces
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchPokemonList() async {
    // Generar 150 requests en paralelo, con reintentos y cache
    final pokemones = <Future<Map<String, dynamic>>>[];
    int index = 0;
    while (index < 150) {
      try {
        final id = index + 1;
        final urlPokemon = "https://pokeapi.co/api/v2/pokemon/$id";
        final pokemon = await fetchUrl(urlPokemon) as Map<String, dynamic>;

        pokemon["height"] /= 10; // dm → m
        pokemon["weight"] /= 10; // hg → kg

        final pokemonTypes = pokemon["types"] as List;
        final speciesUrl = pokemon["species"]["url"];
        final abilities = pokemon["abilities"] as List;

        // Peticiones de tipos y especies en paralelo, usando cache
        final futures = [
          // Tipos
          ...pokemonTypes.map((typeEntry) async {
            final typeUrl = typeEntry["type"]["url"];
            final data = await fetchUrl(typeUrl) as Map<String, dynamic>;
            return getSpanishField(data["names"], "name") ?? data["name"];
          }),
          // Especie
          () async {
            final data = await fetchUrl(speciesUrl) as Map<String, dynamic>;
            return {
              "name": getSpanishField(data["names"], "name"),
              "flavor": getSpanishField(
                data["flavor_text_entries"],
                "flavor_text",
                last: true,
              ),
            };
          }(),
          // Habilidades
          ...abilities.map((abilityEntry) async {
            final abilityUrl = abilityEntry["ability"]["url"];
            final data = await fetchUrl(abilityUrl) as Map<String, dynamic>;
            return getSpanishField(data["names"], "name") ?? data["name"];
          }),
        ];

        final results = await Future.wait(futures);

        final speciesData =
            results[pokemonTypes.length] as Map<String, dynamic>;
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

        pokemones.add(Future.value(pokemon));
        index++;
      } catch (e) {
        // Si ocurre error, reintenta desde el índice actual
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return await Future.wait(pokemones);
  }
}
