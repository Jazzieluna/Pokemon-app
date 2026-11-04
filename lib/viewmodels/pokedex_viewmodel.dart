import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/pokemon_resumen.dart';
import '../repositories/pokemon_repository.dart';

enum EstadoPantalla { cargando, exito, error }

class PokedexViewModel extends ChangeNotifier {
  final PokemonRepository _repo;
  PokedexViewModel(this._repo);

  static const int tamPagina = 20;

  final List<PokemonResumen> _pokemon = [];
  // vista de solo lectura, sin copiar la lista en cada build
  UnmodifiableListView<PokemonResumen> get pokemon =>
      UnmodifiableListView(_pokemon);

  EstadoPantalla estado = EstadoPantalla.cargando;
  bool cargandoMas = false;
  bool hayMas = true;
  bool errorAlCargarMas = false;
  String? errorMsg;

  // primera carga: indice de tipos + pagina 1
  Future<void> cargarInicial() async {
    estado = EstadoPantalla.cargando;
    errorMsg = null;
    notifyListeners();
    try {
      await _cargarPagina();
      estado = EstadoPantalla.exito;
    } catch (e) {
      estado = EstadoPantalla.error;
      errorMsg = 'no se pudo cargar la pokedex';
    }
    notifyListeners();
  }

  // paginas siguientes, las dispara el scroll
  Future<void> cargarMas() async {
    // el flag: si ya hay una carga en curso, no hacemos nada
    if (cargandoMas || !hayMas || errorAlCargarMas) return;
    if (estado != EstadoPantalla.exito) return;

    cargandoMas = true;
    notifyListeners();
    try {
      await _cargarPagina();
    } catch (e) {
      errorAlCargarMas = true; // la lista que ya teniamos no se toca
    }
    cargandoMas = false;
    notifyListeners();
  }

  // solo el boton de reintentar quita el error y vuelve a pedir
  Future<void> reintentarCargarMas() async {
    errorAlCargarMas = false;
    await cargarMas();
  }

  Future<void> _cargarPagina() async {
    // el offset es cuantos llevamos: solo avanza si la pagina llego bien
    final pagina = await _repo.traerPagina(_pokemon.length, tamPagina);
    _pokemon.addAll(pagina);
    hayMas = _pokemon.length < _repo.totalEspecies;
  }
}
