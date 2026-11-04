import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/equipo.dart';
import '../repositories/equipos_repository.dart';

enum ResultadoAgregar { ok, lleno, repetido, noExiste }

class EquiposViewModel extends ChangeNotifier {
  final EquiposRepository _repo;
  late final List<Equipo> _equipos;

  EquiposViewModel(this._repo) {
    _equipos = _repo.leer();
  }

  UnmodifiableListView<Equipo> get equipos => UnmodifiableListView(_equipos);

  Equipo? porId(String id) {
    for (final e in _equipos) {
      if (e.id == id) return e;
    }
    return null;
  }

  Equipo crear(String nombre) {
    final nuevo = Equipo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: nombre,
    );
    _equipos.add(nuevo);
    _guardar();
    return nuevo;
  }

  void renombrar(String id, String nombre) {
    _reemplazar(id, (e) => e.copiarCon(nombre: nombre));
  }

  void eliminar(String id) {
    _equipos.removeWhere((e) => e.id == id);
    _guardar();
  }

  ResultadoAgregar agregar(String equipoId, int pokemonId) {
    final e = porId(equipoId);
    if (e == null) return ResultadoAgregar.noExiste;
    if (e.ids.contains(pokemonId)) return ResultadoAgregar.repetido;
    if (e.lleno) return ResultadoAgregar.lleno;

    // [...lista, x] crea una lista nueva con x al final
    _reemplazar(equipoId, (x) => x.copiarCon(ids: [...x.ids, pokemonId]));
    return ResultadoAgregar.ok;
  }

  void quitar(String equipoId, int pokemonId) {
    _reemplazar(
      equipoId,
      (x) => x.copiarCon(ids: x.ids.where((i) => i != pokemonId).toList()),
    );
  }

  // busca el equipo, aplica el cambio y guarda
  void _reemplazar(String id, Equipo Function(Equipo) cambio) {
    final i = _equipos.indexWhere((e) => e.id == id);
    if (i == -1) return;
    _equipos[i] = cambio(_equipos[i]);
    _guardar();
  }

  void _guardar() {
    _repo.guardar(_equipos);
    notifyListeners();
  }
}
