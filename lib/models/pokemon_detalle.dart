class StatBase {
  final String nombre; // clave de la api: hp, attack, defense...
  final int valor;
  const StatBase(this.nombre, this.valor);
}

class PokemonDetalle {
  final int id;
  final String nombre;
  final List<String> tipos;
  final double alturaM;
  final double pesoKg;
  final List<String> habilidades;
  final List<StatBase> stats;
  final String? gritoUrl;
  final String descripcion;
  final String categoria;
  final String? urlCadenaEvolutiva;

  const PokemonDetalle({
    required this.id,
    required this.nombre,
    required this.tipos,
    required this.alturaM,
    required this.pesoKg,
    required this.habilidades,
    required this.stats,
    required this.gritoUrl,
    required this.descripcion,
    required this.categoria,
    required this.urlCadenaEvolutiva,
  });

  // p = json de /pokemon/id, esp = json de /pokemon-species/id
  factory PokemonDetalle.desdeJson(
    Map<String, dynamic> p,
    Map<String, dynamic> esp,
  ) {
    return PokemonDetalle(
      id: p['id'] as int,
      nombre: p['name'] as String,
      tipos: (p['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      // la api da la altura en decimetros y el peso en hectogramos
      alturaM: (p['height'] as int) / 10,
      pesoKg: (p['weight'] as int) / 10,
      habilidades: (p['abilities'] as List).map((a) {
        final nombre = (a['ability']['name'] as String).replaceAll('-', ' ');
        return (a['is_hidden'] as bool) ? '$nombre (oculta)' : nombre;
      }).toList(),
      stats: (p['stats'] as List)
          .map(
            (s) => StatBase(s['stat']['name'] as String, s['base_stat'] as int),
          )
          .toList(),
      gritoUrl: p['cries']?['latest'] as String?,
      descripcion: _descripcion(esp['flavor_text_entries'] as List),
      categoria: _categoria(esp['genera'] as List),
      urlCadenaEvolutiva: esp['evolution_chain']?['url'] as String?,
    );
  }

  // busca el texto en español (el ultimo es el mas reciente), si no hay usa ingles
  static String _descripcion(List entradas) {
    String? es;
    String? en;
    for (final e in entradas) {
      final idioma = e['language']['name'];
      // la api trae saltos de linea y caracteres raros dentro del texto
      final texto = (e['flavor_text'] as String).replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      if (idioma == 'es') es = texto;
      if (idioma == 'en') en = texto;
    }
    return es ?? en ?? 'sin descripcion';
  }

  static String _categoria(List genera) {
    for (final g in genera) {
      if (g['language']['name'] == 'es') return g['genus'] as String;
    }
    return '';
  }
}
