import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late Future<List> _pokemonFuture;
  late Size _screen;
  late bool _nuevoEquipo;

  final SizedBox _separadorV = const SizedBox(width: 8);

  final _nombreController = TextEditingController();
  final _creadorController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Set<int> _seleccionados = {};

  @override
  void initState() {
    _nuevoEquipo = true;
    super.initState();
    _pokemonFuture = _fetchPokemonList();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _creadorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screen = MediaQuery.sizeOf(context);

    Widget botonRegresar = Align(
      alignment: Alignment.topLeft,
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.keyboard_arrow_left),
        label: const Text("Regresar"),
      ),
    );

    Widget divisor = const Divider(
      height: 30,
      thickness: 0.5,
      indent: 20,
      color: Colors.grey,
    );

    Map<String, dynamic> header = {
      "titulo": Text(
        _nuevoEquipo ? "Crear nuevo equipo" : "Modificar Equipo",
        style: const TextStyle(fontSize: 25),
      ),
      "boton": FilledButton(
        onPressed: () {
          try {
            _validarFormulario();
            _validarLista();
          } catch (e) {
            desplegarError(e);
          }
        },
        style: FilledButton.styleFrom(
          minimumSize: Size(_screen.width * 0.2, _screen.width * 0.07),
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle: const TextStyle(fontSize: 18),
          backgroundColor: Colors.red,
        ),
        child: Text(_nuevoEquipo ? "¡Crear!" : "Guardar cambios"),
      ),
    };

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(''),
            shadowColor: Colors.black,
            elevation: 1,
          ),
          backgroundColor: Colors.grey.shade200,
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  botonRegresar,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [header["titulo"], header["boton"]],
                  ),
                  divisor,
                  formularioEquipo(orientation),
                  listaPokemones(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Expanded campo(String texto, TextEditingController controller) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        readOnly: !_nuevoEquipo,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: texto,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "";
          }
          return null;
        },
      ),
    );
  }

  Widget formularioEquipo(Orientation orientacion) {
    SizedBox separadorH = const SizedBox(height: 70);
    if (orientacion == Orientation.portrait) {
      return Wrap(
        children: [
          Row(
            children: [
              campo("Nombre del Equipo", _nombreController),
              _separadorV,
              campo("Creador del Equipo", _creadorController),
            ],
          ),
          separadorH,
          campo("Descripción", _descripcionController),
          separadorH,
        ],
      );
    } else {
      return Row(
        children: [
          SizedBox(
            width: _screen.width * 0.4,
            child: Row(
              children: [
                campo("Nombre del Equipo", _nombreController),
                _separadorV,
                campo("Creador del Equipo", _creadorController),
              ],
            ),
          ),
          _separadorV,
          campo("Descripción", _descripcionController),
        ],
      );
    }
  }

  void _validarFormulario() {
    if (!_formKey.currentState!.validate()) {
      throw Exception("Por favor, completa todos los campos.");
    }
  }

  void _validarLista() {
    if (_seleccionados.isEmpty) {
      throw Exception("Selecciona al menos un pokémon.");
    }
    if (_seleccionados.length >= 10) {
      throw Exception("Solo puedes seleccionar hasta máximo 10 pokémones.");
    }
  }

  Widget listaPokemones() {
    return Expanded(
      child: FutureBuilder<List>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;

          return OrientationBuilder(
            builder: (context, orientation) {
              return GridView.builder(
                padding: const EdgeInsets.only(top: 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (orientation == Orientation.portrait ? 2 : 3),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: (orientation == Orientation.portrait
                      ? 0.8
                      : 1.2),
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final pokemon = data[index] as Map<String, dynamic>;
                  String image = pokemon["sprites"]["front_default"];
                  String name = pokemon["name"] ?? "???";
                  name = "${name[0].toUpperCase()}${name.substring(1)}";

                  bool isSelected = _seleccionados.contains(index);

                  return Card(
                    elevation: 1,
                    color: isSelected
                        ? Colors.lightBlue.shade100
                        : Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(image: NetworkImage(image)),
                        Text(name, style: const TextStyle(fontSize: 16)),
                        const Divider(
                          height: 30,
                          thickness: 0.5,
                          indent: 20,
                          color: Colors.grey,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (isSelected) {
                                _seleccionados.remove(index);
                              } else {
                                try {
                                  if (_seleccionados.isNotEmpty) {
                                    _validarLista();
                                  }
                                  _seleccionados.add(index);
                                } catch (e) {
                                  desplegarError(e);
                                }
                              }
                            });
                          },
                          child: Text(isSelected ? "Eliminar" : "Añadir"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void desplegarError(error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().split(": ")[1]),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<List> _fetchPokemonList() async {
    final futures = List.generate(150, (i) async {
      final id = i + 1;
      final url = "https://pokeapi.co/api/v2/pokemon/$id";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error con el Pokémon $id');
      }
    });
    return await Future.wait(futures);
  }
}
