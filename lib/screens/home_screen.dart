import 'package:flutter/material.dart';
import 'package:pokedexapp/screens/pages/pokedex_page.dart';
import 'package:pokedexapp/screens/pages/team_page.dart';

// Pantalla principal con tabs ("Mis equipos" y "Pokedex")
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Lista estática de pestañas
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Mis equipos'),
    Tab(text: 'Pokedex'),
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return TabControllerExample(tabs: HomeScreen.tabs);
  }
}

// Widget que controla las pestañas usando DefaultTabController
class TabControllerExample extends StatelessWidget {
  const TabControllerExample({required this.tabs, super.key});

  final List<Tab> tabs; // Pestañas recibidas como parámetro

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length, // Número de pestañas
      child: DefaultTabControllerListener(
        onTabChanged: (int index) {
          // Aquí podrías reaccionar cuando se cambia de pestaña
        },
        child: SafeArea(
          // <-- Envuelve el Scaffold con SafeArea
          child: Scaffold(
            backgroundColor: Colors.white.withOpacity(
              0.95,
            ), // Fondo blanco opaco
            appBar: AppBar(
              automaticallyImplyLeading: false, // No mostrar botón de volver
              backgroundColor: Colors.white.withOpacity(0.95),
              elevation: 0,
              bottom: TabBar(
                tabs: tabs,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Color(0xFFB3E5FC), // Azul claro
                    width: 8,
                  ),
                ),
                labelPadding: EdgeInsets.only(
                  bottom: 12,
                ), // Espaciado debajo del texto
                labelStyle: TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'CenturyGothic',
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black,
              ),
            ),

            body: TabBarView(
              children: const [
                MisEquiposScreen(), // Archivo nuevo 1
                PokedexScreen(), // Archivo nuevo 2
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Este widget escucha cambios en el tab activo
class DefaultTabControllerListener extends StatefulWidget {
  const DefaultTabControllerListener({
    required this.onTabChanged, // Función que se ejecuta al cambiar de tab
    required this.child,
    super.key,
  });

  final ValueChanged<int> onTabChanged;
  final Widget child;

  @override
  State<DefaultTabControllerListener> createState() =>
      _DefaultTabControllerListenerState();
}

class _DefaultTabControllerListenerState
    extends State<DefaultTabControllerListener> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtiene el controlador de pestañas
    final TabController? defaultTabController = DefaultTabController.maybeOf(
      context,
    );

    // Si no hay DefaultTabController, lanza un error
    assert(() {
      if (defaultTabController == null) {
        throw FlutterError(
          'No DefaultTabController para ${widget.runtimeType}.\n'
          'Debes envolver este widget en un DefaultTabController.',
        );
      }
      return true;
    }());

    // Si el controlador cambia, actualizamos el listener
    if (defaultTabController != _controller) {
      _controller?.removeListener(_listener);
      _controller = defaultTabController;
      _controller?.addListener(_listener);
    }
  }

  // Listener que se ejecuta cuando cambia de pestaña
  void _listener() {
    final TabController? controller = _controller;

    // Si el cambio de tab aún está en transición, no hacer nada
    if (controller == null || controller.indexIsChanging) {
      return;
    }

    widget.onTabChanged(controller.index); // Ejecuta callback
  }

  @override
  void dispose() {
    _controller?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; // Devuelve el widget hijo
  }
}
