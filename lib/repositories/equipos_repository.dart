import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/equipo.dart';

class EquiposRepository {
  final SharedPreferences _prefs;
  EquiposRepository(this._prefs);

  static const String _clave = 'equipos';

  List<Equipo> leer() {
    final texto = _prefs.getString(_clave);
    if (texto == null) return [];
    try {
      final lista = jsonDecode(texto) as List;
      return lista
          .map((e) => Equipo.desdeJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // si los datos guardados estan danados, empezamos de cero y no truena la app
      return [];
    }
  }

  Future<void> guardar(List<Equipo> equipos) {
    final texto = jsonEncode(equipos.map((e) => e.toJson()).toList());
    return _prefs.setString(_clave, texto);
  }
}
