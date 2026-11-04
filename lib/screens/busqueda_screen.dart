import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../repositories/pokemon_repository.dart';
import '../theme/colores.dart';
import '../viewmodels/busqueda_viewmodel.dart';
import '../viewmodels/pokedex_viewmodel.dart';
import '../widgets/caja_pixel.dart';
import '../widgets/chip_filtro.dart';
import '../widgets/tarjeta_pokemon.dart';
import 'detalle_screen.dart';

const List<String> _romanos = [
  'I',
  'II',
  'III',
  'IV',
  'V',
  'VI',
  'VII',
  'VIII',
  'IX',
  'X',
  'XI',
  'XII',
];
String _romano(int n) =>
    (n >= 1 && n <= _romanos.length) ? _romanos[n - 1] : '$n';

class BusquedaScreen extends StatelessWidget {
  const BusquedaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          BusquedaViewModel(ctx.read<PokemonRepository>())..cargar(),
      child: const _BusquedaVista(),
    );
  }
}

class _BusquedaVista extends StatefulWidget {
  const _BusquedaVista();

  @override
  State<_BusquedaVista> createState() => _BusquedaVistaState();
}

class _BusquedaVistaState extends State<_BusquedaVista> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusquedaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('BUSCAR')),
      body: _cuerpo(vm),
    );
  }

  Widget _cuerpo(BusquedaViewModel vm) {
    switch (vm.estado) {
      case EstadoPantalla.cargando:
        return const Center(child: CircularProgressIndicator());
      case EstadoPantalla.error:
        return Center(
          child: BotonPixel(texto: 'REINTENTAR', onPressed: vm.cargar),
        );
      case EstadoPantalla.exito:
        return Column(
          children: [
            _campoBusqueda(vm),
            _filtros(vm),
            _encabezado(vm),
            Expanded(child: _resultados(vm)),
          ],
        );
    }
  }

  Widget _campoBusqueda(BusquedaViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: CajaPixel(
        color: Colores.fondo,
        colorBorde: Colores.rojo,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white54),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ctrl,
                onChanged: vm.cambiarTexto,
                cursorColor: Colores.rojo,
                style: GoogleFonts.vt323(fontSize: 24, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'NOMBRE O NUMERO',
                  hintStyle: GoogleFonts.vt323(
                    fontSize: 24,
                    color: Colors.white30,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            // el boton de borrar solo depende del controlador, no del viewmodel
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _ctrl,
              builder: (_, valor, _) => valor.text.isEmpty
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () {
                        _ctrl.clear();
                        vm.cambiarTexto('');
                      },
                      child: const Icon(Icons.close, color: Colors.white54),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtros(BusquedaViewModel vm) {
    final repo = context.read<PokemonRepository>();

    return Column(
      children: [
        _FilaFiltro(
          etiqueta: 'TIPO',
          chips: [
            for (final t in Colores.tipos.keys)
              ChipFiltro(
                texto: Colores.nombresTipo[t] ?? t,
                color: Colores.deTipo(t),
                activo: vm.tipo == t,
                onTap: () => vm.elegirTipo(t),
              ),
          ],
        ),
        _FilaFiltro(
          etiqueta: 'GEN',
          chips: [
            for (final g in repo.generacionesDisponibles)
              ChipFiltro(
                texto: _romano(g),
                color: Colors.blueGrey,
                activo: vm.generacion == g,
                onTap: () => vm.elegirGeneracion(g),
              ),
          ],
        ),
      ],
    );
  }

  Widget _encabezado(BusquedaViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${vm.resultados.length} RESULTADOS',
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: Colors.white70,
              ),
            ),
          ),
          if (vm.hayFiltros)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                vm.limpiar();
              },
              child: Text(
                'LIMPIAR',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: Colores.rojo,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _resultados(BusquedaViewModel vm) {
    // estado vacio
    if (vm.resultados.isEmpty) {
      return Center(
        child: Text(
          'SIN RESULTADOS',
          style: GoogleFonts.pressStart2p(fontSize: 9, color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      // al arrastrar la lista se cierra el teclado
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemCount: vm.resultados.length,
      itemBuilder: (context, i) {
        final p = vm.resultados[i];
        return TarjetaPokemon(
          // la key le dice a flutter que esta tarjeta es "la del pokemon X",
          // aunque cambie su posicion al filtrar
          key: ValueKey(p.id),
          pokemon: p,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetalleScreen(resumen: p)),
          ),
        );
      },
    );
  }
}

class _FilaFiltro extends StatelessWidget {
  final String etiqueta;
  final List<Widget> chips;
  const _FilaFiltro({required this.etiqueta, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: SizedBox(
              width: 32,
              child: Text(
                etiqueta,
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in chips)
                    Padding(padding: const EdgeInsets.only(right: 6), child: c),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
