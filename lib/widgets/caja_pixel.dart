import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/colores.dart';

class CajaPixel extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color colorBorde;
  final double grosorBorde;
  final double sombra;
  final EdgeInsetsGeometry padding;

  const CajaPixel({
    super.key,
    required this.child,
    required this.color,
    this.colorBorde = Colors.black,
    this.grosorBorde = 3,
    this.sombra = 4,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        // sin borderRadius: esquinas cuadradas
        border: Border.all(color: colorBorde, width: grosorBorde),
        // sombra dura: sin desenfoque, desplazada en diagonal
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(sombra, sombra),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class BotonPixel extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const BotonPixel({super.key, required this.texto, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CajaPixel(
        color: Colores.rojo,
        colorBorde: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          texto,
          style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}
