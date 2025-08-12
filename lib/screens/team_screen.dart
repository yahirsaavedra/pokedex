import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const TeamScreen());

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.sizeOf(context);
    var screenWidth = screen.width;
    var screenHeight = screen.height;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(''),
          shadowColor: Colors.black,
          elevation: 1,
        ),
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.keyboard_arrow_left),
                    label: const Text("Regresar"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Crear nuevo equipo",
                      style: const TextStyle(fontSize: 25),
                    ),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        minimumSize: Size(
                          screenWidth * 0.2,
                          screenHeight * 0.07,
                        ),
                        padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                        textStyle: TextStyle(fontSize: 18),
                        backgroundColor: Colors.red[400],
                      ),
                      child: const Text("¡Crear!"),
                    ),
                  ],
                ),
                const Divider(
                  height: 30,
                  thickness: 0.5,
                  indent: 20,
                  endIndent: null,
                  color: Colors.grey,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: screenWidth * 0.4,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  validator: (value) {
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Nombre del Equipo',
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  validator: (value) {
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Creador del Equipo',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              return null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Descripción',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // TODO: POKEMONES EN VISTA DE GRID
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _fetchPokemonList() async {
    final url = "https://pokeapi.co/api/v2/pokemon/"; // Sample API
    final response = await http.get(Uri.parse(url)); // Send GET request

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON
      var data = jsonDecode(response.body); // Decode the response body
      print(data);
      return data; // Just printing the data for now
    } else {
      // If the request failed, throw an error
      throw Exception('Ocurrió un error con la API');
    }
  }
}
