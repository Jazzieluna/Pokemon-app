import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/colores.dart';

class BarraNavegacion extends StatelessWidget {
  final int actual;
  final ValueChanged<int> alCambiar;

  const BarraNavegacion({
    super.key,
    required this.actual,
    required this.alCambiar,
  });

  static const _items = [
    (icono: Icons.catching_pokemon, texto: 'POKEDEX'),
    (icono: Icons.search, texto: 'BUSCAR'),
    (icono: Icons.groups, texto: 'EQUIPOS'),
    (icono: Icons.person, texto: 'PERFIL'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colores.fondo,
        border: Border(top: BorderSide(color: Colores.rojo, width: 3)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => alCambiar(i),
                  child: Container(
                    color: i == actual ? Colores.rojo : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _items[i].icono,
                          color: i == actual ? Colors.white : Colors.white54,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].texto,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: i == actual ? Colors.white : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
