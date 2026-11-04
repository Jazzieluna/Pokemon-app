import 'package:dio/dio.dart';

import '../models/pokemon_resumen.dart';
import '../models/pokemon_detalle.dart';
import '../models/paso_evolucion.dart';

class PokeApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://pokeapi.co/api/v2/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  static const List<String> _tipos = [
    'normal', 'fighting', 'flying', 'poison', 'ground', 'rock', 
    'bug', 'ghost', 'steel', 'fire', 'water', 'grass', 
    'electric', 'psychic', 'ice', 'dragon', 'dark', 'fairy',
  ];

  List<PokemonResumen> _aResumenes(List resultados) {
    final lista = <PokemonResumen>[];
    for (final item in resultados) {
      final id = PokemonResumen.idDesdeUrl(item['url'] as String);
      if (id >= 10000) continue;
      lista.add(PokemonResumen(id: id, nombre: item['name'] as String));
    }
    return lista;
  }

  Future<List<PokemonResumen>> traerListadoBase() async {
    final resp = await _dio.get('pokemon', queryParameters: {'limit': 2000});
    return _aResumenes(resp.data['results'] as List);
  }

  Future<List<PokemonResumen>> traerPagina(int offset, int limit) async {
    final resp = await _dio.get(
      'pokemon',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return _aResumenes(resp.data['results'] as List);
  }

  Future<Map<int, List<String>>> traerIndiceTipos() async {
    final Map<int, Map<int, String>> porSlot = {};

    // Los tipos son independientes: descargarlos en paralelo evita bloquear
    // la primera página con una larga secuencia de peticiones.
    final respuestas = await Future.wait(
      _tipos.map((tipo) => _dio.get('type/$tipo')),
    );
    for (var i = 0; i < _tipos.length; i++) {
      final resp = respuestas[i];
      final lista = resp.data['pokemon'] as List;
      
      for (final item in lista) {
        final id = PokemonResumen.idDesdeUrl(item['pokemon']['url'] as String);
        if (id >= 10000) continue;
        final slot = item['slot'] as int;
        porSlot.putIfAbsent(id, () => {})[slot] = _tipos[i];
      }
    }

    return porSlot.map((id, slots) {
      final orden = slots.keys.toList()..sort();
      return MapEntry(id, [for (final s in orden) slots[s]!]);
    });
  }

  Future<PokemonDetalle> traerDetalle(int id) async {
    final r = await Future.wait([
      _dio.get('pokemon/$id'),
      _dio.get('pokemon-species/$id'),
    ]);
    return PokemonDetalle.desdeJson(
      r[0].data as Map<String, dynamic>,
      r[1].data as Map<String, dynamic>,
    );
  }

  Future<List<PasoEvolucion>> traerEvolucion(String url) async {
    final resp = await _dio.get(url);
    return PasoEvolucion.desdeJson(resp.data as Map<String, dynamic>);
  }

  Future<Map<int, int>> traerIndiceGeneraciones() async {
    final lista = await _dio.get('generation');
    final urls = (lista.data['results'] as List)
        .map((g) => g['url'] as String)
        .toList();

    final Map<int, int> indice = {};
    
    // Peticiones secuenciales
    for (final url in urls) {
      final r = await _dio.get(url);
      final numero = r.data['id'] as int;
      for (final especie in r.data['pokemon_species'] as List) {
        final id = PokemonResumen.idDesdeUrl(especie['url'] as String);
        indice[id] = numero;
      }
    }
    return indice;
  }
}
