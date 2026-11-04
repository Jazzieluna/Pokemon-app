class Equipo {
  final String id;
  final String nombre;
  final List<int> ids;

  static const int maximo = 6;

  const Equipo({required this.id, required this.nombre, this.ids = const []});

  bool get lleno => ids.length >= maximo;

  // la clase es inmutable: para "modificar" se crea una copia con el cambio
  Equipo copiarCon({String? nombre, List<int>? ids}) {
    return Equipo(id: id, nombre: nombre ?? this.nombre, ids: ids ?? this.ids);
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'ids': ids};

  factory Equipo.desdeJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      ids: (json['ids'] as List).map((e) => e as int).toList(),
    );
  }
}
