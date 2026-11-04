import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../repositories/pokemon_repository.dart';
import '../theme/colores.dart';
import '../viewmodels/coleccion_viewmodel.dart';
import '../widgets/barra_progreso.dart';
import '../widgets/caja_pixel.dart';
import '../widgets/tarjeta_pokemon.dart';
import 'detalle_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Future<void> _carga;

  @override
  void initState() {
    super.initState();
    _carga = _preparar();
  }

  // necesitamos los nombres (listado base) y los tipos (indice) para dibujar tarjetas
  Future<void> _preparar() async {
    final repo = context.read<PokemonRepository>();
    await Future.wait([repo.cargarBase(), repo.cargarIndice()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PERFIL')),
      body: FutureBuilder<void>(
        future: _carga,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: BotonPixel(
                texto: 'REINTENTAR',
                onPressed: () => setState(() => _carga = _preparar()),
              ),
            );
          }
          return const _ContenidoPerfil();
        },
      ),
    );
  }
}

class _ContenidoPerfil extends StatelessWidget {
  const _ContenidoPerfil();

  @override
  Widget build(BuildContext context) {
    final col = context.watch<ColeccionViewModel>();
    final total = context.read<PokemonRepository>().totalEspecies;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CajaPixel(
              color: Colores.fondo,
              colorBorde: Colores.rojo,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  BarraProgreso(
                    etiqueta: 'VISTOS',
                    valor: col.totalVistos,
                    total: total,
                    color: Colors.lightBlueAccent,
                  ),
                  const SizedBox(height: 14),
                  BarraProgreso(
                    etiqueta: 'CAPTURADOS',
                    valor: col.totalCapturados,
                    total: total,
                    color: Colores.rojo,
                  ),
                ],
              ),
            ),
          ),
          TabBar(
            indicatorColor: Colores.rojo,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            labelStyle: GoogleFonts.pressStart2p(fontSize: 8),
            tabs: const [
              Tab(text: 'FAVORITOS'),
              Tab(text: 'VISTOS'),
              Tab(text: 'CAPTURADOS'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _GridIds(ids: col.idsFavoritos, vacio: 'SIN FAVORITOS AUN'),
                _GridIds(ids: col.idsVistos, vacio: 'NADA VISTO AUN'),
                _GridIds(ids: col.idsCapturados, vacio: 'NADA CAPTURADO AUN'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridIds extends StatelessWidget {
  final List<int> ids;
  final String vacio;
  const _GridIds({required this.ids, required this.vacio});

  @override
  Widget build(BuildContext context) {
    // estado vacio
    if (ids.isEmpty) {
      return Center(
        child: Text(
          vacio,
          style: GoogleFonts.pressStart2p(fontSize: 9, color: Colors.white54),
        ),
      );
    }

    final lista = context.read<PokemonRepository>().resumenesDeIds(ids);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: lista.length,
      itemBuilder: (context, i) => TarjetaPokemon(
        pokemon: lista[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetalleScreen(resumen: lista[i])),
        ),
      ),
    );
  }
}
