/// Este archivo define el módulo para consumir la PokeAPI.
/// Permite obtener información de Pokémon, tipos, especies y habilidades en español.
/// Implementa cache local y reintentos para mejorar la eficiencia y robustez.

import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http show get;

class PokeAPI {
  /// Mapa para almacenar una caché local para URLs ya consultadas (reduce llamadas repetidas).
  ///
  /// Esto es debido a que muchas URLs asociadas a diferentes campos de información por cada
  /// Pokémon se repiten, por lo que evita congestionar la API de solicitudes innecesarias.
  ///
  /// ¿Por qué no una sola URL para cada Pokémon?
  /// La información regresada por la endpoint de cada Pokemón dentro de la PokéAPI regresa
  /// la información más básica de cada Pokemón, además de que los datos están en inglés, a lo
  /// cual para los objetivos de este ejercicio se requiere traducir al español para mantener
  /// la consistencia de idioma dentro de la aplicación. Para ello, se necesitan realizar varias
  /// consultas por cada tipo, especie y habilidad.
  ///
  /// Además, la descripción de cada Pokemón solo están en las especies a las que se les asocia.
  final Map<String, dynamic> _cache = {};

  /// Obtiene el campo en español de una lista de objetos (por ejemplo, nombres).
  /// Si `last` es true, busca el último; si no, el primero.
  ///
  /// ¿Tiene algo que ver que se busque el último elemento en lugar del primero?
  /// No realmente. Por fines estéticos, se prefiere mostrar la versión más reciente de la
  /// descripción de cada Pokémon, ya que es la que aparece en los juegos más recientes de
  /// esta franquicia.
  ///
  /// [items] es la lista de objetos de los cuales se desea obtener el campo en español.
  /// [field] es el nombre del campo que se desea obtener.
  /// [last] indica si se debe buscar el último elemento en lugar del primero.
  String? getTraduccion(List items, String field, {bool last = false}) {
    final finder = last ? items.lastWhere : items.firstWhere;

    /// Busca el campo en español dentro de la lista de objetos.
    return finder(
      (item) => item['language']['name'] == 'es',
      orElse: () => null,
    )?[field];
  }

  /// Consulta una URL con cache y hasta 3 reintentos en caso de error.
  ///
  /// [url] es la URL a consultar.
  Future<dynamic> fetchUrl(String url) async {
    // Si la URL ya está en cache, retorna el valor cacheado.
    if (_cache.containsKey(url)) {
      return _cache[url];
    }
    // Si la URL no está en cache, realiza la consulta.

    int retries = 0;
    while (true) {
      try {
        final res = await http.get(Uri.parse(url));
        if (res.statusCode != 200) throw Exception('Error al consultar $url');
        // Decodifica la respuesta JSON.
        final data = jsonDecode(res.body);
        _cache[url] = data;
        // Retorna los datos obtenidos.
        return data;
      } catch (e) {
        retries++;
        // Si ocurre un error, espera 500 ms antes de reintentar.
        if (retries > 3) rethrow;
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  /// Obtiene la lista de los primeros 150 Pokémones con sus datos en español.
  ///
  /// Este proceso inicia solicitando la información básica de cada Pokémon por medio de
  /// un endpoint que proporciona la API por ID. Posteriormente, se realizan múltiples consultas
  /// para obtener información adicional, como tipos, habilidades y descripciones en español,
  /// ya que los datos retornados originalmente están en inglés.
  Future<List<Map<String, dynamic>>> fetchPokemonList() async {
    // Lista de futuros para los Pokémon
    final pokemones = <Future<Map<String, dynamic>>>[];
    int index = 0;
    // Genera 150 requests en paralelo, con reintentos y cache.
    while (index < 150) {
      try {
        final id = index + 1;
        final urlPokemon = "https://pokeapi.co/api/v2/pokemon/$id";
        final pokemon = await fetchUrl(urlPokemon) as Map<String, dynamic>;

        // Convierte altura y peso a unidades más fáciles de interpretar.
        pokemon["height"] /= 10; // dm → m
        pokemon["weight"] /= 10; // hg → kg

        final pokemonTypes = pokemon["types"] as List;
        final speciesUrl = pokemon["species"]["url"];
        final abilities = pokemon["abilities"] as List;

        // Peticiones de tipos, especie y habilidades en paralelo.
        final futures = [
          // Tipos
          ...pokemonTypes.map((typeEntry) async {
            final typeUrl = typeEntry["type"]["url"];
            final data = await fetchUrl(typeUrl) as Map<String, dynamic>;
            return getTraduccion(data["names"], "name") ?? data["name"];
          }),
          // Especie
          () async {
            final data = await fetchUrl(speciesUrl) as Map<String, dynamic>;
            return {
              "name": getTraduccion(data["names"], "name"),
              "flavor": getTraduccion(
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
            return getTraduccion(data["names"], "name") ?? data["name"];
          }),
        ];

        // Espera a que todas las peticiones se completen.
        final results = await Future.wait(futures);

        // Extrae datos de especie, tipos y habilidades
        final speciesData =
            results[pokemonTypes.length] as Map<String, dynamic>;
        final typeNames = results.sublist(0, pokemonTypes.length);
        final abilitiesNames = results.sublist(
          pokemonTypes.length + 1,
          results.length,
        );

        // Asigna los datos en español al objeto Pokémon
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
    // Retorna la lista final de Pokémones en español.
    return await Future.wait(pokemones);
  }
}
