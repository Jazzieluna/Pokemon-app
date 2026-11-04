import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/pokedex_viewmodel.dart';
import '../widgets/caja_pixel.dart';
import '../widgets/tarjeta_pokemon.dart';
import 'detalle_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_alHacerScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // al pasar el 80% del recorrido pedimos la siguiente pagina
  void _alHacerScroll() {
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.8) {
      context.read<PokedexViewModel>().cargarMas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PokedexViewModel>();

    if (vm.estado == EstadoPantalla.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.estado == EstadoPantalla.error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.errorMsg ?? 'ERROR',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              BotonPixel(texto: 'REINTENTAR', onPressed: vm.cargarInicial),
            ],
          ),
        ),
      );
    }

    final lista = vm.pokemon;
    return Scaffold(
      appBar: AppBar(
        title: const Text('POKEDEX'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${lista.length}',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              // el builder solo crea las tarjetas que estan visibles
              delegate: SliverChildBuilderDelegate(
                (context, i) => TarjetaPokemon(
                  pokemon: lista[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleScreen(resumen: lista[i]),
                    ),
                  ),
                ),
                childCount: lista.length,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _pie(vm)),
        ],
      ),
    );
  }

  // lo que se ve al final de la lista: cargador, reintentar o nada
  Widget _pie(PokedexViewModel vm) {
    if (vm.errorAlCargarMas) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: BotonPixel(
            texto: 'REINTENTAR',
            onPressed: vm.reintentarCargarMas,
          ),
        ),
      );
    }
    if (vm.cargandoMas) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox(height: 16);
  }
}
