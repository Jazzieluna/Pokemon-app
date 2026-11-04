import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_pixel/models/equipo.dart';

void main() {
  test('un equipo conserva sus datos al serializarse', () {
    const original = Equipo(id: 'equipo-1', nombre: 'Kanto', ids: [1, 4, 7]);

    final recuperado = Equipo.desdeJson(original.toJson());

    expect(recuperado.id, original.id);
    expect(recuperado.nombre, original.nombre);
    expect(recuperado.ids, original.ids);
    expect(recuperado.lleno, isFalse);
  });
}
