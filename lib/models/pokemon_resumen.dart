class PokemonResumen {
  final int id;
  final String nombre;
  final List<String> tipos;

  const PokemonResumen({
    required this.id,
    required this.nombre,
    this.tipos = const [],
  });

  // el id viene al final de la url: .../pokemon/25/
  static int idDesdeUrl(String url) {
    final partes = url.split('/').where((p) => p.isNotEmpty).toList();
    return int.parse(partes.last);
  }

  // urls predecibles de imagenes, sin pedir nada a la api
  static const String _base =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon';

  String get spriteUrl => '$_base/$id.png';
  String get spriteShinyUrl => '$_base/shiny/$id.png';
  String get artworkUrl => '$_base/other/official-artwork/$id.png';

  // copia con los tipos ya conocidos (la clase es inmutable)
  PokemonResumen conTipos(List<String> nuevosTipos) =>
      PokemonResumen(id: id, nombre: nombre, tipos: nuevosTipos);
}
