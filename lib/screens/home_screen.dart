/// Este archivo contiene la pantalla principal de la aplicación,
/// que incluye las pestañas "Mis equipos" y "Pokedex".

import 'package:flutter/material.dart';
import 'package:pokedexapp/screens/tabs/pokedex_tab.dart';
import 'package:pokedexapp/screens/tabs/my_teams_tab.dart';

/// Pantalla principal con tabs ("Mis equipos" y "Pokedex").
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Lista estática de pestañas.
  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Mis equipos'),
    Tab(text: 'Pokedex'),
  ];

  @override
  // Implementa el estado de la pantalla principal.
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Estado de la pantalla principal.
class _HomeScreenState extends State<HomeScreen> {
  @override
  /// Implementa el método build para construir la interfaz.
  ///
  /// [context] es el contexto de construcción.
  Widget build(BuildContext context) {
    return ControladorTabs(tabs: HomeScreen.tabs);
  }
}

/// Widget que controla las pestañas usando DefaultTabController.
class ControladorTabs extends StatelessWidget {
  const ControladorTabs({required this.tabs, super.key});

  // Lista fija de pestañas.
  final List<Tab> tabs;

  /// Construye el widget de control de pestañas.
  ///
  /// [context] es el contexto de construcción.
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length, // Número de pestañas.
      /* Envuelve todo en un SafeArea para evitar conflictos con la barra de menú
      del sistema operativo en versiones recientes de Android. */
      child: SafeArea(
        // Proporciona una base sólida de Material para construir el widget.
        child: Scaffold(
          backgroundColor: const Color.fromARGB(242, 255, 255, 255),
          // Barra superior de la aplicación.
          appBar: AppBar(
            automaticallyImplyLeading: false, // No mostrar botón de Volver.
            backgroundColor: const Color.fromARGB(242, 255, 255, 255),
            elevation: 0, // Sombreado
            bottom: TabBar(
              tabs: tabs,
              indicator: UnderlineTabIndicator(
                // Indicador de pestaña.
                borderSide: BorderSide(
                  color: Color(0xFFB3E5FC), // Azul claro.
                  width: 8,
                ),
              ),
              labelPadding: EdgeInsets.only(
                bottom: 12,
              ), // Espaciado debajo del texto.
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
              labelColor: Colors.black, // Color del tab seleccionado.
              unselectedLabelColor:
                  Colors.black, // Color del tab no seleccionado.
            ),
          ),

          body: TabBarView(
            // Contenedor de las vistas de las pestañas.
            children: const [MisEquiposScreen(), PokedexScreen()],
          ),
        ),
      ),
    );
  }
}
