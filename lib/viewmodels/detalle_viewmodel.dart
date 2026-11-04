import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/paso_evolucion.dart';
import '../models/pokemon_detalle.dart';
import '../repositories/pokemon_repository.dart';
import 'pokedex_viewmodel.dart'; // para reutilizar EstadoPantalla

class DetalleViewModel extends ChangeNotifier {
  final PokemonRepository _repo;
  DetalleViewModel(this._repo);

  final AudioPlayer _player = AudioPlayer();

  EstadoPantalla estado = EstadoPantalla.cargando;
  PokemonDetalle? detalle;
  int? _id;
  bool _cerrado = false;

  // la cadena evolutiva se carga aparte, despues del detalle
  List<PasoEvolucion> pasos = [];
  bool cargandoEvo = false;
  bool errorEvo = false;

  Future<void> cargar(int id) async {
    _id = id;
    estado = EstadoPantalla.cargando;
    _avisar();
    try {
      detalle = await _repo.traerDetalle(id);
      estado = EstadoPantalla.exito;
    } catch (e) {
      estado = EstadoPantalla.error;
    }
    _avisar();

    // si el detalle llego bien, pedimos la evolucion sin bloquear la pantalla
    if (estado == EstadoPantalla.exito) await cargarEvolucion();
  }

  Future<void> cargarEvolucion() async {
    final url = detalle?.urlCadenaEvolutiva;
    if (url == null) return; // algunos pokemon no tienen cadena

    cargandoEvo = true;
    errorEvo = false;
    _avisar();
    try {
      pasos = await _repo.traerEvolucion(url);
    } catch (e) {
      errorEvo = true;
    }
    cargandoEvo = false;
    _avisar();
  }

  Future<void> reintentar() => cargar(_id!);

  Future<void> reproducirGrito() async {
    final url = detalle?.gritoUrl;
    if (url == null) return;
    try {
      await _player.stop(); // si ya estaba sonando, reinicia
      await _player.play(UrlSource(url));
    } catch (e) {
      // si el audio falla, la pantalla sigue funcionando
      debugPrint('error de audio: $e');
    }
  }

  @override
  void dispose() {
    _cerrado = true;
    _player.dispose(); // libera el reproductor al salir de la pantalla
    super.dispose();
  }

  void _avisar() {
    if (!_cerrado) notifyListeners();
  }
}
