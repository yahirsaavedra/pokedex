import 'package:flutter/material.dart';
import 'package:pokedexapp/screens/home_screen.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'dart:math' as math;

// Pantalla donde se crea o modifica un equipo de Pokémon
class TeamScreen extends StatefulWidget {
  final Map<String, dynamic>? equipo;
  final List<int>? pokemonesSeleccionados;
  final bool modoEdicion;

  const TeamScreen({
    super.key,
    this.equipo,
    this.pokemonesSeleccionados,
    this.modoEdicion = false,
  });

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late Size _screen;

  final SizedBox _separadorV = const SizedBox(width: 8); // Separador horizontal

  // Controladores de texto para el formulario
  final _nombreController = TextEditingController();
  final _creadorController = TextEditingController();
  final _descripcionController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Clave para validar el formulario

  late bool _nuevoEquipo;
  final Set<int> _seleccionados = {};

  @override
  void initState() {
    super.initState();
    _nuevoEquipo = !(widget.modoEdicion);

    if (widget.equipo != null) {
      _nombreController.text = widget.equipo!["nombre"] ?? "";
      _creadorController.text = widget.equipo!["creador"] ?? "";
      _descripcionController.text = widget.equipo!["descripcion"] ?? "";
    }

    if (widget.pokemonesSeleccionados != null) {
      _seleccionados.addAll(widget.pokemonesSeleccionados!);
    }
  }

  @override
  void dispose() {
    // Liberar memoria de los controladores
    _nombreController.dispose();
    _creadorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screen = MediaQuery.sizeOf(context); // Obtiene tamaño de pantalla

    // Botón de regresar (a implementar funcionalidad)
    Widget botonRegresar = Align(
      alignment: Alignment.topLeft,
      child: TextButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        icon: const Icon(Icons.keyboard_arrow_left),
        label: const Text("Regresar"),
      ),
    );

    // Línea divisoria
    Widget divisor = const Divider(
      height: 30,
      thickness: 0.5,
      indent: 20,
      color: Colors.grey,
    );

    // Encabezado con título y botón
    Map<String, dynamic> header = {
      "titulo": Text(
        _nuevoEquipo ? "Crear nuevo equipo" : "Modificar Equipo",
        style: const TextStyle(fontSize: 25),
      ),
      "boton": FilledButton(
        onPressed: () async {
          try {
            _validarFormulario();
            _validarLista();

            if (_nuevoEquipo) {
              // Crear equipo nuevo
              final idEquipo = await BaseDatos.instance.insert("equipos", {
                "nombre": _nombreController.text.trim(),
                "creador": _creadorController.text.trim(),
                "descripcion": _descripcionController.text.trim(),
              });

              // Asignar los Pokémon seleccionados al equipo
              for (final idPokemon in _seleccionados) {
                await BaseDatos.instance.update(
                  "pokemones",
                  {"equipo": idEquipo},
                  "id = ?",
                  [idPokemon],
                );
              }
            } else {
              // Editar equipo existente: actualizar pokemones
              final idEquipo = widget.equipo!["id"];
              // Primero, desasigna todos los pokemones de este equipo
              await BaseDatos.instance.update(
                "pokemones",
                {"equipo": null},
                "equipo = ?",
                [idEquipo],
              );
              // Luego, asigna los seleccionados
              for (final idPokemon in _seleccionados) {
                await BaseDatos.instance.update(
                  "pokemones",
                  {"equipo": idEquipo},
                  "id = ?",
                  [idPokemon], // Usa el ID real, no el índice ni -1
                );
              }
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } catch (e) {
            desplegarError(e);
          }
        },

        style: FilledButton.styleFrom(
          minimumSize: Size(
            _screen.width * 0.2,
            _screen.width * 0.07,
          ), // PENDIENTE CAMBIAR UN WIDTH POR HEIGHT, OOPS!
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
          appBar: AppBar(shadowColor: Colors.black, elevation: 1),
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
                  formularioEquipo(orientation), // Campos de texto
                  listaPokemones(), // Lista de Pokémon en Grid
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Crea un campo de texto con validación y opción de solo lectura
  Expanded campo(String texto, TextEditingController controller) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        readOnly: !_nuevoEquipo, // Si no es nuevo, no se puede editar
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: texto,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return ""; // Error si está vacío
          }
          return null;
        },
      ),
    );
  }

  // Crea el formulario del equipo (adaptado a orientación vertical u horizontal)
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

  // Valida que todos los campos del formulario estén llenos
  void _validarFormulario() {
    if (!_formKey.currentState!.validate()) {
      throw Exception("Por favor, completa todos los campos.");
    }
  }

  // Valida que haya entre 1 y 10 Pokémon seleccionados
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
        future: BaseDatos.instance.queryAll(
          "pokemones",
        ), // Espera la lista de Pokémon
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // Cargando...
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
                      ? 0.65
                      : 0.95),
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final pokemon = data[index] as Map<String, dynamic>;
                  final nombre = pokemon["nombre"];
                  final imagen = pokemon["imagen"];
                  final tipo = pokemon["tipo"];

                  final idPokemon = pokemon["id"];
                  bool isSelected = _seleccionados.contains(idPokemon);

                  return Card(
                    elevation: 1,
                    color: isSelected
                        ? Colors.lightGreen.shade200
                        : Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(image: NetworkImage(imagen)),
                        Text(nombre, style: const TextStyle(fontSize: 16)),
                        Chip(
                          label: Text(tipo),
                          backgroundColor: Color(
                            (math.Random().nextDouble() * 0xFFFFFF).toInt(),
                          ).withAlpha(255),
                        ),
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
                                _seleccionados.remove(idPokemon);
                              } else {
                                try {
                                  if (_seleccionados.isNotEmpty) {
                                    _validarLista();
                                  }
                                  _seleccionados.add(idPokemon);
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

  // Muestra errores en un SnackBar rojo
  void desplegarError(error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().split(": ")[1]),
        backgroundColor: Colors.red,
      ),
    );
  }
}
