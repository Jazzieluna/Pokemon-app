import 'package:flutter/material.dart';

class Colores {
  static const Color rojo = Color(0xFFDC0A2D);
  static const Color fondo = Color(0xFF1D1D1D);

  // un color por tipo (la clave es el nombre del tipo en la api)
  static const Map<String, Color> tipos = {
    'normal': Color(0xFFA8A77A),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'electric': Color(0xFFF7D02C),
    'grass': Color(0xFF7AC74C),
    'ice': Color(0xFF96D9D6),
    'fighting': Color(0xFFC22E28),
    'poison': Color(0xFFA33EA1),
    'ground': Color(0xFFE2BF65),
    'flying': Color(0xFFA98FF3),
    'psychic': Color(0xFFF95587),
    'bug': Color(0xFFA6B91A),
    'rock': Color(0xFFB6A136),
    'ghost': Color(0xFF735797),
    'dragon': Color(0xFF6F35FC),
    'dark': Color(0xFF705746),
    'steel': Color(0xFFB7B7CE),
    'fairy': Color(0xFFD685AD),
  };

  // nombres en español para mostrar en pantalla
  static const Map<String, String> nombresTipo = {
    'normal': 'NORMAL',
    'fire': 'FUEGO',
    'water': 'AGUA',
    'electric': 'ELECTRICO',
    'grass': 'PLANTA',
    'ice': 'HIELO',
    'fighting': 'LUCHA',
    'poison': 'VENENO',
    'ground': 'TIERRA',
    'flying': 'VOLADOR',
    'psychic': 'PSIQUICO',
    'bug': 'BICHO',
    'rock': 'ROCA',
    'ghost': 'FANTASMA',
    'dragon': 'DRAGON',
    'dark': 'SINIESTRO',
    'steel': 'ACERO',
    'fairy': 'HADA',
  };

  // si el tipo no existe devuelve el color de normal
  static Color deTipo(String tipo) => tipos[tipo] ?? tipos['normal']!;
}
