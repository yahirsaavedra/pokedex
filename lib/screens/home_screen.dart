import 'package:flutter/material.dart';

// TODO: ESTE ES SOLAMENTE CODIGO DE PRUEBA, CAMBIAR POR UN DISEÑO MAS IMPLEMENTADO

void main() => runApp(const HomeScreen());

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    return const MaterialApp(home: TabControllerExample(tabs: HomeScreen.tabs));
  }
}

class TabControllerExample extends StatelessWidget {
  const TabControllerExample({required this.tabs, super.key});

  final List<Tab> tabs;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: DefaultTabControllerListener(
        onTabChanged: (int index) {
          //debugPrint('tab changed: $index');
        },
        child: Scaffold(
          appBar: AppBar(bottom: TabBar(tabs: tabs)),
          body: TabBarView(
            children: tabs.map((Tab tab) {
              return Center(
                child: Text(
                  '${tab.text!} Tab',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class DefaultTabControllerListener extends StatefulWidget {
  const DefaultTabControllerListener({
    required this.onTabChanged,
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

    final TabController? defaultTabController = DefaultTabController.maybeOf(
      context,
    );

    assert(() {
      if (defaultTabController == null) {
        // Cambiar por algo más creativo
        throw FlutterError(
          'No DefaultTabController for ${widget.runtimeType}.\n'
          'When creating a ${widget.runtimeType}, you must ensure that there '
          'is a DefaultTabController above the ${widget.runtimeType}.',
        );
      }
      return true;
    }());

    if (defaultTabController != _controller) {
      _controller?.removeListener(_listener);
      _controller = defaultTabController;
      _controller?.addListener(_listener);
    }
  }

  void _listener() {
    final TabController? controller = _controller;

    if (controller == null || controller.indexIsChanging) {
      return;
    }

    widget.onTabChanged(controller.index);
  }

  @override
  void dispose() {
    _controller?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
