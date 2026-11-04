import '../models/paso_evolucion.dart';
import '../models/pokemon_detalle.dart';
import '../models/pokemon_resumen.dart';
import '../services/poke_api_service.dart';

class PokemonRepository {
  final PokeApiService _api;

  // Atributos unificados en la parte superior
  Map<int, List<String>> _indiceTipos = {};
  Map<int, PokemonResumen> _basePorId = {};
  Map<int, int> _generaciones = {};

  Future<void>? _cargaIndice;
  Future<void>? _cargaBase;
  Future<void>? _cargaGeneraciones;

  final Map<int, PokemonDetalle> _cacheDetalles = {};
  final Map<String, List<PasoEvolucion>> _cacheEvoluciones = {};

  PokemonRepository(this._api);

  bool get indiceListo => _indiceTipos.isNotEmpty;
  int get totalEspecies => _indiceTipos.length;

  Future<void> cargarIndice() => _cargaIndice ??= _pedirIndice();

  Future<void> _pedirIndice() async {
    try {
      _indiceTipos = await _api.traerIndiceTipos();
    } catch (e) {
      _cargaIndice = null;
      rethrow;
    }
  }

  Future<void> cargarBase() => _cargaBase ??= _pedirBase();

  Future<void> _pedirBase() async {
    try {
      final lista = await _api.traerListadoBase();
      _basePorId = {for (final p in lista) p.id: p};
    } catch (e) {
      _cargaBase = null;
      rethrow;
    }
  }

  Future<void> cargarGeneraciones() =>
      _cargaGeneraciones ??= _pedirGeneraciones();

  Future<void> _pedirGeneraciones() async {
    try {
      _generaciones = await _api.traerIndiceGeneraciones();
    } catch (e) {
      _cargaGeneraciones = null;
      rethrow;
    }
  }

  Future<List<PokemonResumen>> traerPagina(int offset, int limit) async {
    await cargarIndice();
    final base = await _api.traerPagina(offset, limit);
    return base.map((p) => p.conTipos(_indiceTipos[p.id] ?? const [])).toList();
  }

  Future<PokemonDetalle> traerDetalle(int id) async {
    final guardado = _cacheDetalles[id];
    if (guardado != null) return guardado;

    final detalle = await _api.traerDetalle(id);
    _cacheDetalles[id] = detalle;
    return detalle;
  }

  Future<List<PasoEvolucion>> traerEvolucion(String url) async {
    final guardado = _cacheEvoluciones[url];
    if (guardado != null) return guardado;

    final pasos = await _api.traerEvolucion(url);
    _cacheEvoluciones[url] = pasos;
    return pasos;
  }

  PokemonResumen resumenPorId(int id, String nombre) => PokemonResumen(
    id: id,
    nombre: nombre,
    tipos: _indiceTipos[id] ?? const [],
  );

  // Refactorizados a asíncronos para garantizar la carga de bases de datos antes de devolver valores
  List<PokemonResumen> resumenesDeIds(Iterable<int> ids) {
    final lista = <PokemonResumen>[];
    for (final id in ids) {
      final base = _basePorId[id];
      if (base != null) {
        lista.add(base.conTipos(_indiceTipos[id] ?? const []));
      }
    }
    return lista;
  }

  Future<List<PokemonResumen>> catalogoCompleto() async {
    await cargarBase();
    await cargarIndice();
    final ids = _basePorId.keys.toList()..sort();
    return resumenesDeIds(ids);
  }

  int? generacionDe(int id) => _generaciones[id];

  List<int> get generacionesDisponibles =>
      _generaciones.values.toSet().toList()..sort();
}
