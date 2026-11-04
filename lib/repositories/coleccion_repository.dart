import 'package:shared_preferences/shared_preferences.dart';

// esta clase es la unica que sabe como se guardan los datos en el telefono
class ColeccionRepository {
  final SharedPreferences _prefs;
  ColeccionRepository(this._prefs);

  static const String _kFavoritos = 'favoritos';
  static const String _kVistos = 'vistos';
  static const String _kCapturados = 'capturados';

  Set<int> leerFavoritos() => _leer(_kFavoritos);
  Set<int> leerVistos() => _leer(_kVistos);
  Set<int> leerCapturados() => _leer(_kCapturados);

  Future<void> guardarFavoritos(Set<int> ids) => _guardar(_kFavoritos, ids);
  Future<void> guardarVistos(Set<int> ids) => _guardar(_kVistos, ids);
  Future<void> guardarCapturados(Set<int> ids) => _guardar(_kCapturados, ids);

  Set<int> _leer(String clave) {
    final lista = _prefs.getStringList(clave) ?? [];
    return lista.map(int.parse).toSet();
  }

  Future<void> _guardar(String clave, Set<int> ids) {
    return _prefs.setStringList(clave, ids.map((i) => '$i').toList());
  }
}
