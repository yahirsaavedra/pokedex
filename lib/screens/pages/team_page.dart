import 'package:flutter/material.dart';

class MisEquiposScreen extends StatelessWidget {
  const MisEquiposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size _screen = MediaQuery.sizeOf(context);

    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        minimumSize: Size(_screen.width * 0.2, _screen.height * 0.07),
        padding: const EdgeInsets.symmetric(vertical: 10),
        textStyle: const TextStyle(fontSize: 18),
        backgroundColor: Colors.red,
      ),
      child: Text("Crear nuevo equipo"),
    );
  }
}
