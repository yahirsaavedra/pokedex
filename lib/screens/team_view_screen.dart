/// Este archivo contiene la pantalla de visualización y
/// edición/creación de un equipo de Pokémon.

import 'package:flutter/material.dart';
import 'package:pokedexapp/screens/home_screen.dart';
import 'package:pokedexapp/helpers/database.dart';
import 'package:pokedexapp/widgets/team_view_pokemon_card.dart';

/// Pantalla donde se crea o modifica un equipo de Pokémon.
class TeamScreen extends StatefulWidget {
  final Map<String, dynamic>? equipo;
  final List<int>? pokemonesSeleccionados;
  final bool modoEdicion;

  /// Constructor para la pantalla de equipo.
  /// [equipo] es la información del equipo a modificar en caso de existir.
  /// [pokemonesSeleccionados] es la lista de Pokémones correspondientes a dicho equipo.
  /// [modoEdicion] indica si se está editando un equipo existente.
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

  // Separador horizontal para los campos del formulario.
  final SizedBox _separadorV = const SizedBox(width: 8);

  // Controladores de texto para los campos del formulario.
  final _nombreController = TextEditingController();
  final _creadorController = TextEditingController();
  final _descripcionController = TextEditingController();

  // Clave para validar el formulario.
  final _formKey = GlobalKey<FormState>();

  late bool _nuevoEquipo;
  final Set<int> _seleccionados = {};

  @override
  void initState() {
    super.initState();
    // Determina si se está creando un equipo nuevo o editando uno existente.
    _nuevoEquipo = !(widget.modoEdicion);

    // Si existe un equipo, carga los datos en los controladores.
    if (widget.equipo != null) {
      _nombreController.text = widget.equipo!["nombre"] ?? "";
      _creadorController.text = widget.equipo!["creador"] ?? "";
      _descripcionController.text = widget.equipo!["descripcion"] ?? "";
    }

    // Si hay Pokémones seleccionados, los agrega al set.
    if (widget.pokemonesSeleccionados != null) {
      _seleccionados.addAll(widget.pokemonesSeleccionados!);
    }
  }

  @override
  /// Libera la memoria de los controladores de texto.
  void dispose() {
    _nombreController.dispose();
    _creadorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  /// Construye el widget.
  ///
  /// [context] es el contexto de construcción.
  Widget build(BuildContext context) {
    /// Obtiene el tamaño de la pantalla.
    _screen = MediaQuery.sizeOf(context);

    // Botón para regresar a la pantalla principal.
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

    // Línea divisoria visual.
    Widget divisor = const Divider(
      height: 30,
      thickness: 0.5,
      indent: 20,
      color: Colors.grey,
    );

    // Título de la pantalla (crear o modificar).
    Widget titulo = Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(
          _nuevoEquipo ? "Crear nuevo equipo" : "Modificar Equipo",
          style: const TextStyle(
            fontFamily: 'CenturyGothic',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    // Botón para crear o guardar cambios en el equipo.
    Widget boton = Padding(
      padding: const EdgeInsets.only(left: 12),
      child: SizedBox(
        height: 44,
        child: FittedBox(
          // Escala el contenido para que quepa en el botón.
          fit: BoxFit.scaleDown,
          child: Builder(
            // Crea un nuevo contexto para obtener la orientación de la pantalla.
            builder: (context) {
              final orientation = MediaQuery.of(context).orientation;
              final double btnHeight = orientation == Orientation.portrait
                  ? _screen.height * 0.07
                  : 44;
              final double btnWidth = orientation == Orientation.portrait
                  ? _screen.width * 0.4
                  : 250;
              return SizedBox(
                // Define el tamaño del botón.
                height: btnHeight,
                width: btnWidth,
                child: FilledButton(
                  // Botón para crear o guardar cambios en el equipo.
                  onPressed: () async {
                    try {
                      // Valida los campos del formulario y la selección de Pokémones.
                      _validarFormulario();
                      _validarLista();

                      if (_nuevoEquipo) {
                        // Crea un nuevo equipo en la base de datos.
                        final idEquipo = await BaseDatos.instance
                            .insertar("equipos", {
                              "nombre": _nombreController.text.trim(),
                              "creador": _creadorController.text.trim(),
                              "descripcion": _descripcionController.text.trim(),
                            });

                        // Asigna los Pokémones seleccionados al nuevo equipo.
                        for (final idPokemon in _seleccionados) {
                          await BaseDatos.instance.actualizar(
                            "pokemones",
                            {"equipo": idEquipo},
                            "id = ?",
                            [idPokemon],
                          );
                        }
                      } else {
                        // Edita el equipo existente y actualiza los Pokémones.
                        final idEquipo = widget.equipo!["id"];
                        // Desasigna todos los Pokémones del equipo.
                        await BaseDatos.instance.actualizar(
                          "pokemones",
                          {"equipo": null},
                          "equipo = ?",
                          [idEquipo],
                        );
                        // Asigna los Pokémones seleccionados al equipo.
                        for (final idPokemon in _seleccionados) {
                          await BaseDatos.instance.actualizar(
                            "pokemones",
                            {"equipo": idEquipo},
                            "id = ?",
                            [idPokemon],
                          );
                        }
                      }

                      // Verifica que el widget sigue montado antes de navegar.
                      if (!context.mounted) return;

                      // Regresa a la pantalla principal.
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    } catch (e) {
                      // Muestra el error en un SnackBar.
                      desplegarError(e);
                    }
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: Size(btnWidth, btnHeight),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 14),
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
        ),
      ),
    );

    // Construye la interfaz principal de la pantalla.
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        // Proporciona una base sólida de Material para construir el widget.
        return Scaffold(
          // Barra superior de la aplicación.
          appBar: AppBar(
            shadowColor: Colors.black,
            elevation: 1,
            automaticallyImplyLeading: false, // Quita la flecha de volver.
          ),
          // Color de fondo de la pantalla.
          backgroundColor: Colors.grey.shade200,
          /* Envuelve todo en un SafeArea para evitar conflictos con la barra de menú
          del sistema operativo en versiones recientes de Android. */
          body: SafeArea(
            child: SingleChildScrollView(
              /* Permite el desplazamiento en caso de que
            el contenido sea demasiado grande. */
              child: Padding(
                // Agrega un relleno alrededor del formulario.
                padding: const EdgeInsets.symmetric(
                  // Define el relleno del formulario.
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Form(
                  // Formulario para crear o editar un equipo.
                  key: _formKey,
                  child: Column(
                    // Columna que contiene los campos del formulario.
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      botonRegresar,
                      Row(
                        // Fila que contiene el título y el botón.
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [titulo, boton],
                      ),
                      divisor,
                      formularioEquipo(orientation),
                      SizedBox(height: 16),
                      // Muestra el grid de Pokémones para seleccionar.
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: FutureBuilder<List>(
                          // Carga la lista de Pokémones desde la base de datos.
                          future: BaseDatos.instance.buscarTodo("pokemones"),
                          builder: (context, snapshot) {
                            // Muestra un indicador de carga mientras se obtienen los datos.
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            // Maneja el caso de error al cargar los datos.
                            if (snapshot.hasError) {
                              return Center(
                                child: Text("Error: ${snapshot.error}"),
                              );
                            }
                            final data = snapshot.data!;
                            // Muestra los Pokémones en un grid
                            return GridView.builder(
                              // Constructor de un grid de Pokémones.
                              padding: const EdgeInsets.only(top: 8),
                              gridDelegate: // Define el diseño del grid.
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    orientation == Orientation.portrait ? 2 : 4,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio:
                                    orientation == Orientation.portrait
                                    ? 0.6
                                    : 0.5,
                              ),
                              itemCount:
                                  data.length, // Número total de Pokémones.
                              itemBuilder: (context, index) {
                                // Constructor de cada elemento del grid.
                                final pokemon =
                                    data[index] as Map<String, dynamic>;
                                final nombre = pokemon["nombre"];
                                final imagen = pokemon["imagen"];
                                final tipo = pokemon["tipo"];
                                final idPokemon = pokemon["id"];
                                final isSelected = _seleccionados.contains(
                                  idPokemon,
                                );

                                // Widget para mostrar la carta de cada Pokémon
                                return PokemonCard(
                                  nombre: nombre,
                                  imagen: imagen,
                                  tipo: tipo,
                                  isSelected: isSelected,
                                  chipColor: _tipoColor(tipo),
                                  extra: TextButton(
                                    // Botón para añadir o eliminar Pokémon del equipo.
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

  /// Crea un campo de texto con validación y opción de solo lectura.
  ///
  /// [texto] es el texto del campo.
  /// [controller] es el controlador del campo de texto.
  Expanded campo(String texto, TextEditingController controller) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        readOnly: !_nuevoEquipo, // Si no es nuevo, no se puede editar.
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: texto,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return ""; // Error si está vacío.
          }
          return null;
        },
      ),
    );
  }

  /// Crea el formulario del equipo (adaptado a orientación vertical u horizontal).
  ///
  /// [orientacion] es la orientación de la pantalla.
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

  /// Valida que todos los campos del formulario estén llenos.
  void _validarFormulario() {
    if (!_formKey.currentState!.validate()) {
      throw Exception("Por favor, completa todos los campos.");
    }
  }

  /// Valida que haya entre 1 y 10 Pokémon seleccionados.
  void _validarLista() {
    if (_seleccionados.isEmpty) {
      throw Exception("Selecciona al menos un pokémon.");
    }
    if (_seleccionados.length >= 10) {
      throw Exception("Solo puedes seleccionar hasta máximo 10 pokémones.");
    }
  }

  /// Muestra errores en un SnackBar rojo.
  ///
  /// [error] es el error a mostrar.
  void desplegarError(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().split(": ")[1]),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Devuelve el color correspondiente al tipo de Pokémon.
  ///
  /// [tipo] es el tipo de Pokémon.
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

/// Grid de Pokémones.
class PokemonGrid extends StatefulWidget {
  final List pokemones;
  final Set<int> seleccionados;
  final void Function(int idPokemon, bool selected) onSelect;

  /// Constructor para el grid de Pokémones.
  ///
  /// [pokemones] es la lista de Pokémones a mostrar.
  /// [seleccionados] es la lista de Pokémones seleccionados.
  /// [onSelect] es el evento que se dispara al seleccionar o deseleccionar un Pokémon.
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
  /// Inicializa el estado del widget.
  void initState() {
    super.initState();
    seleccionados = Set<int>.from(widget.seleccionados);
  }

  @override
  /// Actualiza el estado del widget cuando cambia.
  ///
  /// [oldWidget] es el widget anterior.
  void didUpdateWidget(covariant PokemonGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seleccionados != widget.seleccionados) {
      seleccionados = Set<int>.from(widget.seleccionados);
    }
  }

  @override
  /// Construye el widget.
  ///
  /// [context] es el contexto de construcción.
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
