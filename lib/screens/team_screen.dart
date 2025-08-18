import 'package:flutter/material.dart';
import 'package:pokedexapp/screens/home_screen.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'package:pokedexapp/widgets/pokemon_card.dart';

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
        label: const Text(
          "Regresar",
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'CenturyGothic',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
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
        style: const TextStyle(
          fontFamily: 'CenturyGothic',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      "boton": Builder(
        builder: (context) {
          final orientation = MediaQuery.of(context).orientation;
          final double btnHeight = orientation == Orientation.portrait
              ? _screen.height * 0.07
              : 44;
          final double btnWidth = orientation == Orientation.portrait
              ? _screen.width * 0.4
              : 180;
          return SizedBox(
            height: btnHeight,
            width: btnWidth,
            child: FilledButton(
              onPressed: () async {
                try {
                  _validarFormulario();
                  _validarLista();

                  if (_nuevoEquipo) {
                    // Crear equipo nuevo
                    final idEquipo = await BaseDatos.instance
                        .insertar("equipos", {
                          "nombre": _nombreController.text.trim(),
                          "creador": _creadorController.text.trim(),
                          "descripcion": _descripcionController.text.trim(),
                        });

                    // Asignar los Pokémon seleccionados al equipo
                    for (final idPokemon in _seleccionados) {
                      await BaseDatos.instance.actualizar(
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
                    await BaseDatos.instance.actualizar(
                      "pokemones",
                      {"equipo": null},
                      "equipo = ?",
                      [idEquipo],
                    );
                    // Luego, asigna los seleccionados
                    for (final idPokemon in _seleccionados) {
                      await BaseDatos.instance.actualizar(
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
                minimumSize: Size(btnWidth, btnHeight),
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.red,
              ),
              child: Text(
                _nuevoEquipo ? "¡Crear!" : "Guardar cambios",
                style: const TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    };

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return Scaffold(
          appBar: AppBar(shadowColor: Colors.black, elevation: 1),
          backgroundColor: Colors.grey.shade200,
          body: SafeArea(
            // <-- Agrega este widget
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      botonRegresar,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                _nuevoEquipo
                                    ? "Crear nuevo equipo"
                                    : "Modificar Equipo",
                                style: const TextStyle(
                                  fontFamily: 'CenturyGothic',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: SizedBox(
                              height: 44,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: header["boton"],
                              ),
                            ),
                          ),
                        ],
                      ),
                      divisor,
                      formularioEquipo(orientation),
                      SizedBox(height: 16),
                      SizedBox(
                        height: orientation == Orientation.portrait
                            ? MediaQuery.of(context).size.height * 0.45
                            : MediaQuery.of(context).size.height * 0.55,
                        child: FutureBuilder<List>(
                          future: BaseDatos.instance.buscarTodo("pokemones"),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text("Error: ${snapshot.error}"),
                              );
                            }
                            final data = snapshot.data!;
                            return GridView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        orientation == Orientation.portrait
                                        ? 2
                                        : 4,
                                    mainAxisSpacing: 24,
                                    crossAxisSpacing: 24,
                                    childAspectRatio:
                                        orientation == Orientation.portrait
                                        ? 0.6
                                        : 0.5,
                                  ),
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final pokemon =
                                    data[index] as Map<String, dynamic>;
                                final nombre = pokemon["nombre"];
                                final imagen = pokemon["imagen"];
                                final tipo = pokemon["tipo"];
                                final idPokemon = pokemon["id"];
                                final isSelected = _seleccionados.contains(
                                  idPokemon,
                                );

                                return PokemonCard(
                                  nombre: nombre,
                                  imagen: imagen,
                                  tipo: tipo,
                                  isSelected: isSelected,
                                  chipColor: _tipoColor(
                                    tipo,
                                  ), // Pasa el color al widget
                                  extra: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        if (isSelected) {
                                          _seleccionados.remove(idPokemon);
                                        } else {
                                          if (_seleccionados.length < 10) {
                                            _seleccionados.add(idPokemon);
                                          }
                                        }
                                      });
                                    },
                                    child: Text(
                                      isSelected ? "Eliminar" : "Añadir",
                                      style: TextStyle(
                                        fontFamily: 'CenturyGothic',
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.red
                                            : Color(0xFF7AC74C),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
    return FutureBuilder<List>(
      future: BaseDatos.instance.buscarTodo("pokemones"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final data = snapshot.data!;
        return PokemonGrid(
          pokemones: data,
          seleccionados: _seleccionados,
          onSelect: (idPokemon, selected) {
            setState(() {
              if (selected) {
                try {
                  if (_seleccionados.isNotEmpty) {
                    _validarLista();
                  }
                  _seleccionados.add(idPokemon);
                } catch (e) {
                  desplegarError(e);
                }
              } else {
                _seleccionados.remove(idPokemon);
              }
            });
          },
        );
      },
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

  Color _tipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'planta':
        return const Color(0xFF7AC74C);
      case 'agua':
        return const Color(0xFF6390F0);
      case 'fuego':
        return const Color(0xFFEE8130);
      case 'trueno':
        return const Color(0xFFF7D02C);
      case 'tierra':
        return const Color(0xFFE2BF65);
      case 'normal':
        return const Color(0xFFA8A77A);
      default:
        return Colors.grey;
    }
  }
}

// Nuevo widget para el grid, mantiene el scroll y solo actualiza los cards necesarios
class PokemonGrid extends StatefulWidget {
  final List pokemones;
  final Set<int> seleccionados;
  final void Function(int idPokemon, bool selected) onSelect;

  const PokemonGrid({
    super.key,
    required this.pokemones,
    required this.seleccionados,
    required this.onSelect,
  });

  @override
  State<PokemonGrid> createState() => _PokemonGridState();
}

class _PokemonGridState extends State<PokemonGrid> {
  late Set<int> seleccionados;

  @override
  void initState() {
    super.initState();
    seleccionados = Set<int>.from(widget.seleccionados);
  }

  @override
  void didUpdateWidget(covariant PokemonGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seleccionados != widget.seleccionados) {
      seleccionados = Set<int>.from(widget.seleccionados);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return GridView.builder(
      padding: const EdgeInsets.only(top: 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (orientation == Orientation.portrait ? 2 : 3),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: (orientation == Orientation.portrait ? 0.6 : 0.75),
      ),
      itemCount: widget.pokemones.length,
      itemBuilder: (context, index) {
        final pokemon = widget.pokemones[index] as Map<String, dynamic>;
        final nombre = pokemon["nombre"];
        final imagen = pokemon["imagen"];
        final tipo = pokemon["tipo"];
        final idPokemon = pokemon["id"];
        final isSelected = seleccionados.contains(idPokemon);

        return PokemonCard(
          nombre: nombre,
          imagen: imagen,
          tipo: tipo,
          isSelected: isSelected,
          extra: TextButton(
            onPressed: () {
              setState(() {
                widget.onSelect(idPokemon, !isSelected);
                if (isSelected) {
                  seleccionados.remove(idPokemon);
                } else {
                  seleccionados.add(idPokemon);
                }
              });
            },
            child: Text(isSelected ? "Eliminar" : "Añadir"),
          ),
        );
      },
    );
  }
}
