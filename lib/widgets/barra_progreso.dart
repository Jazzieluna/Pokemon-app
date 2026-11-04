import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BarraProgreso extends StatelessWidget {
  final String etiqueta;
  final int valor;
  final int total;
  final Color color;

  const BarraProgreso({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.total,
    required this.color,
  });

  static const int _segmentos = 30;

  @override
  Widget build(BuildContext context) {
    // si hay al menos uno, siempre se pinta un bloque (si no, 3 de 1025 no se verian)
    var llenos = 0;
    if (total > 0 && valor > 0) {
      llenos = (valor * _segmentos / total).ceil().clamp(1, _segmentos).toInt();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              etiqueta,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: Colors.white70,
              ),
            ),
            Text(
              '$valor / $total',
              style: GoogleFonts.vt323(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < _segmentos; i++)
              Expanded(
                child: Container(
                  height: 12,
                  margin: const EdgeInsets.only(right: 2),
                  color: i < llenos ? color : Colors.white12,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
