import 'pokemon_resumen.dart';

// un paso de la cadena: "desde" evoluciona a "hacia" bajo cierta condicion
class PasoEvolucion {
  final int idDesde;
  final String nombreDesde;
  final int idHacia;
  final String nombreHacia;
  final String condicion;

  const PasoEvolucion({
    required this.idDesde,
    required this.nombreDesde,
    required this.idHacia,
    required this.nombreHacia,
    required this.condicion,
  });

  // convierte el arbol anidado de la api en una lista plana de pasos
  static List<PasoEvolucion> desdeJson(Map<String, dynamic> json) {
    final pasos = <PasoEvolucion>[];

    // funcion recursiva: cada nodo se recorre y luego sus hijos
    void recorrer(Map<String, dynamic> nodo) {
      final desde = nodo['species'] as Map<String, dynamic>;
      for (final hijo in nodo['evolves_to'] as List) {
        final hacia = hijo['species'] as Map<String, dynamic>;
        pasos.add(
          PasoEvolucion(
            idDesde: PokemonResumen.idDesdeUrl(desde['url'] as String),
            nombreDesde: desde['name'] as String,
            idHacia: PokemonResumen.idDesdeUrl(hacia['url'] as String),
            nombreHacia: hacia['name'] as String,
            condicion: _condicion(hijo['evolution_details'] as List),
          ),
        );
        recorrer(hijo as Map<String, dynamic>);
      }
    }

    recorrer(json['chain'] as Map<String, dynamic>);
    return pasos;
  }

  // arma un texto corto con la primera condicion que aparezca
  static String _condicion(List detalles) {
    if (detalles.isEmpty) return '';
    final d = detalles.first as Map<String, dynamic>;
    final partes = <String>[];

    if (d['min_level'] != null) partes.add('NIV ${d['min_level']}');
    if (d['item'] != null) {
      partes.add((d['item']['name'] as String).replaceAll('-', ' '));
    }
    if (d['min_happiness'] != null) partes.add('AMISTAD');
    if (d['trigger']?['name'] == 'trade') partes.add('INTERCAMBIO');

    // si no encaja en nada de lo anterior, mostramos el nombre del disparador
    if (partes.isEmpty && d['trigger'] != null) {
      partes.add((d['trigger']['name'] as String).replaceAll('-', ' '));
    }
    return partes.join(' + ').toUpperCase();
  }
}
