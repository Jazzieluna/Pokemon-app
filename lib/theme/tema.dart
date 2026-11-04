import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colores.dart';

ThemeData crearTema() {
  final base = ThemeData.dark(useMaterial3: true);

  // solo tomamos el nombre de la fuente de datos (vt323)
  final fuenteDatos = GoogleFonts.vt323().fontFamily;

  return base.copyWith(
    scaffoldBackgroundColor: Colores.fondo,
    colorScheme: ColorScheme.dark(
      primary: Colores.rojo,
      surface: Colores.fondo,
    ),
    // flutter aplica la fuente a su propio textTheme
    textTheme: base.textTheme.apply(
      fontFamily: fuenteDatos,
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colores.rojo,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.pressStart2p(
        fontSize: 14,
        color: Colors.white,
      ),
    ),
  );
}
