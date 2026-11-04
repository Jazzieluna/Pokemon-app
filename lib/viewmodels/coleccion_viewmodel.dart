import 'package:flutter/foundation.dart';

import '../repositories/coleccion_repository.dart';

class ColeccionViewModel extends ChangeNotifier {
  final ColeccionRepository _repo;

  late final Set<int> _favoritos;
  late final Set<int> _vistos;
  late final Set<int> _capturados;

  ColeccionViewModel(this._repo) {
    // lo guardado se lee una sola vez al crear el viewmodel
    _favoritos = _repo.leerFavoritos();
    _vistos = _repo.leerVistos();
    _capturados = _repo.leerCapturados();
  }

  bool esFavorito(int id) => _favoritos.contains(id);
  bool esVisto(int id) => _vistos.contains(id);
  bool esCapturado(int id) => _capturados.contains(id);

  int get totalVistos => _vistos.length;
  int get totalCapturados => _capturados.length;

  // listas ordenadas por numero de pokedex
  List<int> get idsFavoritos => _favoritos.toList()..sort();
  List<int> get idsVistos => _vistos.toList()..sort();
  List<int> get idsCapturados => _capturados.toList()..sort();

  void alternarFavorito(int id) {
    // remove devuelve false si no estaba: entonces lo agregamos
    if (!_favoritos.remove(id)) _favoritos.add(id);
    _repo.guardarFavoritos(_favoritos);
    notifyListeners();
  }

  void alternarCapturado(int id) {
    if (!_capturados.remove(id)) {
      _capturados.add(id);
      // capturar implica haberlo visto
      if (_vistos.add(id)) _repo.guardarVistos(_vistos);
    }
    _repo.guardarCapturados(_capturados);
    notifyListeners();
  }

  void marcarVisto(int id) {
    // add devuelve true solo si no estaba; si ya estaba, no hay nada que hacer
    if (_vistos.add(id)) {
      _repo.guardarVistos(_vistos);
      notifyListeners();
    }
  }
}
