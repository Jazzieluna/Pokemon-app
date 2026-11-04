import 'package:flutter/material.dart';

import '../widgets/barra_navegacion.dart';
import 'perfil_screen.dart';
import 'pokedex_screen.dart';
import 'equipos_screen.dart';
import 'busqueda_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _actual = 0;

  final List<Widget> _pantallas = const [
    PokedexScreen(),
    BusquedaScreen(),
    EquiposScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mantiene todas las pestañas vivas: al volver a la pokedex
      // sigues en el mismo lugar del scroll
      body: IndexedStack(
        index: _actual,
        children: [
          for (var i = 0; i < _pantallas.length; i++)
            // las pestañas ocultas desactivan sus Hero; si no, un mismo pokemon
            // en dos pestañas repetiria el tag y Flutter lanzaria un error
            HeroMode(enabled: i == _actual, child: _pantallas[i]),
        ],
      ),
      bottomNavigationBar: BarraNavegacion(
        actual: _actual,
        alCambiar: (i) => setState(() => _actual = i),
      ),
    );
  }
}
