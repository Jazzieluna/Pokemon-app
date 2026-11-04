import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/coleccion_repository.dart';
import 'repositories/equipos_repository.dart';
import 'repositories/pokemon_repository.dart';
import 'screens/home_screen.dart';
import 'services/poke_api_service.dart';
import 'theme/tema.dart';
import 'viewmodels/coleccion_viewmodel.dart';
import 'viewmodels/equipos_viewmodel.dart';
import 'viewmodels/pokedex_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(PokedexApp(prefs: prefs));
}

class PokedexApp extends StatelessWidget {
  final SharedPreferences prefs;
  const PokedexApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PokemonRepository>(
          create: (_) => PokemonRepository(PokeApiService()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              PokedexViewModel(ctx.read<PokemonRepository>())..cargarInicial(),
        ),
        ChangeNotifierProvider(
          create: (_) => ColeccionViewModel(ColeccionRepository(prefs)),
        ),
        ChangeNotifierProvider(
          create: (_) => EquiposViewModel(EquiposRepository(prefs)),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: crearTema(),
        home: const HomeScreen(),
      ),
    );
  }
}
