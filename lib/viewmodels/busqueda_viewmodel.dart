import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/pokemon_resumen.dart';
import '../repositories/pokemon_repository.dart';
import 'pokedex_viewmodel.dart'; // para reutilizar EstadoPantalla

class BusquedaViewModel extends ChangeNotifier {
  final PokemonRepository _repo;
  BusquedaViewModel(this._repo);

  EstadoPantalla estado = EstadoPantalla.cargando;

  List<PokemonResumen> _todos = [];
  List<PokemonResumen> resultados = [];

  // filtros actuales
  String texto = '';
  String? tipo;
  int? generacion;

  Timer? _debounce;
  bool _cerrado = false;

  bool get hayFiltros => texto.isNotEmpty || tipo != null || generacion != null;

  Future<void> cargar() async {
    estado = EstadoPantalla.cargando;
    _avisar();
    try {
      // las tres cargas son independientes: van en paralelo
      await Future.wait([
        _repo.cargarBase(),
        _repo.cargarIndice(),
        _repo.cargarGeneraciones(),
      ]);
      _todos = await _repo.catalogoCompleto();
      _filtrar();
      estado = EstadoPantalla.exito;
    } catch (e) {
      estado = EstadoPantalla.error;
    }
    _avisar();
  }

  // se llama en cada tecla, pero el filtrado espera 300 ms de pausa
  void cambiarTexto(String nuevo) {
    _debounce?.cancel(); // si el usuario siguio escribiendo, descartamos la espera anterior
    _debounce = Timer(const Duration(milliseconds: 300), () {
      texto = nuevo.trim().toLowerCase();
      _filtrar();
      _avisar();
    });
  }

  // tocar el filtro activo lo quita
  void elegirTipo(String t) {
    tipo = (tipo == t) ? null : t;
    _filtrar();
    _avisar();
  }

  void elegirGeneracion(int g) {
    generacion = (generacion == g) ? null : g;
    _filtrar();
    _avisar();
  }

  void limpiar() {
    _debounce?.cancel();
    texto = '';
    tipo = null;
    generacion = null;
    _filtrar();
    _avisar();
  }

  void _filtrar() {
    // "#025", "25" y "025" son el mismo numero
    final numero = int.tryParse(texto.replaceAll('#', ''));

    resultados = _todos.where((p) {
      if (tipo != null && !p.tipos.contains(tipo)) return false;
      if (generacion != null && _repo.generacionDe(p.id) != generacion) {
        return false;
      }
      if (texto.isEmpty) return true;
      if (numero != null) return p.id == numero;
      return p.nombre.contains(texto);
    }).toList();
  }

  @override
  void dispose() {
    _cerrado = true;
    _debounce?.cancel(); // un Timer vivo despues del dispose llamaria a un objeto muerto
    super.dispose();
  }

  void _avisar() {
    if (!_cerrado) notifyListeners();
  }
}
