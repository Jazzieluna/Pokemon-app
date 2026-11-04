import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChipFiltro extends StatelessWidget {
  final String texto;
  final Color color;
  final bool activo;
  final VoidCallback onTap;

  const ChipFiltro({
    super.key,
    required this.texto,
    required this.color,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fondoClaro =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        // los inactivos se ven apagados; el activo se ve completo y con borde blanco
        opacity: activo ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: activo ? Colors.white : Colors.black,
              width: 2,
            ),
          ),
          child: Text(
            texto,
            style: GoogleFonts.vt323(
              fontSize: 18,
              color: fondoClaro ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
