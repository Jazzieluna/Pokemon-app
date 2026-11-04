import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/pokemon_detalle.dart';
import '../models/pokemon_resumen.dart';
import '../repositories/pokemon_repository.dart';
import '../theme/colores.dart';
import '../viewmodels/detalle_viewmodel.dart';
import '../viewmodels/pokedex_viewmodel.dart';
import '../widgets/caja_pixel.dart';
import '../widgets/tarjeta_pokemon.dart';
import '../models/paso_evolucion.dart';

import 'package:flutter/services.dart';

import '../viewmodels/coleccion_viewmodel.dart';
import '../widgets/selector_equipo.dart';

class DetalleScreen extends StatefulWidget {
  final PokemonResumen resumen;
  const DetalleScreen({super.key, required this.resumen});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  @override
  void initState() {
    super.initState();
    // se marca como visto despues del primer frame: notifyListeners no puede
    // llamarse mientras Flutter esta construyendo la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ColeccionViewModel>().marcarVisto(widget.resumen.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          DetalleViewModel(ctx.read<PokemonRepository>())
            ..cargar(widget.resumen.id),
      child: _DetalleVista(resumen: widget.resumen),
    );
  }
}

class _DetalleVista extends StatelessWidget {
  final PokemonResumen resumen;
  const _DetalleVista({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleViewModel>();

    final tipoPrimario = resumen.tipos.isNotEmpty
        ? resumen.tipos.first
        : 'normal';
    final colorTipo = Colores.deTipo(tipoPrimario);
    final colorFondo = Color.lerp(colorTipo, Colors.black, 0.45)!;

    // el boton de sonido solo aparece cuando el detalle ya cargo y hay grito
    final hayGrito =
        vm.estado == EstadoPantalla.exito && vm.detalle?.gritoUrl != null;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colores.fondo,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BotonFlotante(
              icono: Icons.group_add,
              color: Colores.rojo,
              onTap: () => mostrarSelectorEquipo(
                context,
                pokemonId: resumen.id,
                nombre: resumen.nombre,
              ),
            ),
            if (hayGrito) ...[
              const SizedBox(height: 12),
              _BotonFlotante(
                icono: Icons.volume_up,
                color: colorTipo,
                onTap: vm.reproducirGrito,
              ),
            ],
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // la cabecera usa el resumen, asi aparece al instante
              _Cabecera(resumen: resumen, colorFondo: colorFondo),
              TabBar(
                indicatorColor: colorTipo,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                labelStyle: GoogleFonts.pressStart2p(fontSize: 9),
                tabs: const [
                  Tab(text: 'ACERCA DE'),
                  Tab(text: 'STATS'),
                  Tab(text: 'EVOLUCION'),
                ],
              ),
              Expanded(child: _cuerpo(context, vm, colorTipo)),
            ],
          ),
        ),
      ),
    );
  }

  // los 3 estados de la pantalla: cargando, error, exito
  Widget _cuerpo(BuildContext context, DetalleViewModel vm, Color colorTipo) {
    switch (vm.estado) {
      case EstadoPantalla.cargando:
        return const Center(child: CircularProgressIndicator());
      case EstadoPantalla.error:
        return Center(
          child: BotonPixel(texto: 'REINTENTAR', onPressed: vm.reintentar),
        );
      case EstadoPantalla.exito:
        final det = vm.detalle!;
        return TabBarView(
          children: [
            _TabAcerca(detalle: det, resumen: resumen, colorTipo: colorTipo),
            _TabStats(detalle: det, colorTipo: colorTipo),
            _TabEvolucion(idActual: resumen.id, colorTipo: colorTipo),
          ],
        );
    }
  }
}

class _Cabecera extends StatelessWidget {
  final PokemonResumen resumen;
  final Color colorFondo;
  const _Cabecera({required this.resumen, required this.colorFondo});

  @override
  Widget build(BuildContext context) {
    final col = context.watch<ColeccionViewModel>();
    final numero = '#${resumen.id.toString().padLeft(4, '0')}';
    final nombre = resumen.nombre.replaceAll('-', ' ').toUpperCase();

    return Container(
      color: colorFondo,
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nombre,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Text(
                numero,
                style: GoogleFonts.pressStart2p(
                  fontSize: 9,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                Positioned.fill(
                  // mismo tag que en la tarjeta: flutter anima el vuelo entre las dos
                  child: Hero(
                    tag: 'sprite-${resumen.id}',
                    child: CachedNetworkImage(
                      imageUrl: resumen.spriteUrl,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      placeholder: (_, _) => const SizedBox(),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Column(
                    children: [
                      _BotonToggle(
                        icono: Icons.favorite,
                        activo: col.esFavorito(resumen.id),
                        colorActivo: Colors.redAccent,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          col.alternarFavorito(resumen.id);
                        },
                      ),
                      const SizedBox(height: 10),
                      _BotonToggle(
                        icono: Icons.catching_pokemon,
                        activo: col.esCapturado(resumen.id),
                        colorActivo: Colores.rojo,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          col.alternarCapturado(resumen.id);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [for (final t in resumen.tipos) ChipTipo(tipo: t)],
          ),
        ],
      ),
    );
  }
}

class _BotonToggle extends StatelessWidget {
  final IconData icono;
  final bool activo;
  final Color colorActivo;
  final VoidCallback onTap;
  const _BotonToggle({
    required this.icono,
    required this.activo,
    required this.colorActivo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CajaPixel(
        color: activo ? colorActivo : Colors.black54,
        colorBorde: Colors.white,
        grosorBorde: 2,
        sombra: 3,
        padding: const EdgeInsets.all(6),
        child: Icon(icono, size: 20, color: Colors.white),
      ),
    );
  }
}

class _TabAcerca extends StatelessWidget {
  final PokemonDetalle detalle;
  final PokemonResumen resumen;
  final Color colorTipo;
  const _TabAcerca({
    required this.detalle,
    required this.resumen,
    required this.colorTipo,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Text(
          detalle.descripcion,
          style: GoogleFonts.vt323(fontSize: 22, color: Colors.white),
        ),
        const SizedBox(height: 16),
        CajaPixel(
          color: Colores.fondo,
          colorBorde: colorTipo,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (detalle.categoria.isNotEmpty)
                _Fila('CATEGORIA', detalle.categoria),
              _Fila('ALTURA', '${detalle.alturaM.toStringAsFixed(1)} M'),
              _Fila('PESO', '${detalle.pesoKg.toStringAsFixed(1)} KG'),
              _Fila('HABILIDADES', detalle.habilidades.join(', ')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'ARTWORK OFICIAL',
          style: GoogleFonts.pressStart2p(fontSize: 9, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        CajaPixel(
          color: Color.lerp(colorTipo, Colors.black, 0.6)!,
          colorBorde: colorTipo,
          child: SizedBox(
            height: 220,
            child: CachedNetworkImage(
              imageUrl: resumen.artworkUrl,
              fit: BoxFit.contain,
              placeholder: (_, _) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, _, _) =>
                  const Icon(Icons.broken_image, color: Colors.white38),
            ),
          ),
        ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _Fila(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              etiqueta,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: Colors.white54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor.toUpperCase(),
              style: GoogleFonts.vt323(fontSize: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

const Map<String, String> _etiquetasStat = {
  'hp': 'PS',
  'attack': 'ATQ',
  'defense': 'DEF',
  'special-attack': 'ATQ.E',
  'special-defense': 'DEF.E',
  'speed': 'VEL',
};

class _TabStats extends StatelessWidget {
  final PokemonDetalle detalle;
  final Color colorTipo;
  const _TabStats({required this.detalle, required this.colorTipo});

  @override
  Widget build(BuildContext context) {
    var total = 0;
    for (final s in detalle.stats) {
      total += s.valor;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        for (final s in detalle.stats)
          _BarraStat(
            etiqueta: _etiquetasStat[s.nombre] ?? s.nombre,
            valor: s.valor,
            color: colorTipo,
          ),
        const SizedBox(height: 12),
        _Fila('TOTAL', '$total'),
      ],
    );
  }
}

// barra hecha de bloques cuadrados, no de una barra lisa
class _BarraStat extends StatelessWidget {
  final String etiqueta;
  final int valor;
  final Color color;
  const _BarraStat({
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  static const int _segmentos = 20;
  static const int _statMaximo = 200; // escala de la barra

  @override
  Widget build(BuildContext context) {
    final llenos = (valor * _segmentos / _statMaximo)
        .round()
        .clamp(0, _segmentos)
        .toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              etiqueta,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: Colors.white70,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$valor',
              style: GoogleFonts.vt323(fontSize: 20, color: Colors.white),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < _segmentos; i++)
                  Expanded(
                    child: Container(
                      height: 14,
                      margin: const EdgeInsets.only(right: 2),
                      color: i < llenos ? color : Colors.white12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabEvolucion extends StatelessWidget {
  final int idActual;
  final Color colorTipo;
  const _TabEvolucion({required this.idActual, required this.colorTipo});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleViewModel>();

    if (vm.cargandoEvo) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorEvo) {
      return Center(
        child: BotonPixel(texto: 'REINTENTAR', onPressed: vm.cargarEvolucion),
      );
    }
    // estado vacio: algunos pokemon no evolucionan
    if (vm.pasos.isEmpty) {
      return Center(
        child: Text(
          'NO EVOLUCIONA',
          style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white54),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        for (final paso in vm.pasos)
          _FilaEvolucion(paso: paso, colorTipo: colorTipo, idActual: idActual),
      ],
    );
  }
}

class _FilaEvolucion extends StatelessWidget {
  final PasoEvolucion paso;
  final Color colorTipo;
  final int idActual;
  const _FilaEvolucion({
    required this.paso,
    required this.colorTipo,
    required this.idActual,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CajaPixel(
        color: Colores.fondo,
        colorBorde: colorTipo,
        child: Row(
          children: [
            Expanded(
              child: _MiniPokemon(
                id: paso.idDesde,
                nombre: paso.nombreDesde,
                idActual: idActual,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_forward, color: colorTipo),
                  const SizedBox(height: 4),
                  Text(
                    paso.condicion,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.vt323(fontSize: 17, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _MiniPokemon(
                id: paso.idHacia,
                nombre: paso.nombreHacia,
                idActual: idActual,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniPokemon extends StatelessWidget {
  final int id;
  final String nombre;
  final int idActual;
  const _MiniPokemon({
    required this.id,
    required this.nombre,
    required this.idActual,
  });

  @override
  Widget build(BuildContext context) {
    final resumen = PokemonResumen(id: id, nombre: nombre);

    return GestureDetector(
      onTap: () {
        // si es el mismo que ya estamos viendo, no hacemos nada
        if (id == idActual) return;
        final completo = context.read<PokemonRepository>().resumenPorId(
          id,
          nombre,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetalleScreen(resumen: completo)),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CachedNetworkImage(
              imageUrl: resumen.spriteUrl,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              placeholder: (_, _) => const SizedBox(),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              nombre.replaceAll('-', ' ').toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: id == idActual ? Colors.white : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonFlotante extends StatelessWidget {
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  const _BotonFlotante({
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // icono negro sobre colores claros y blanco sobre oscuros
    final fondoClaro =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: CajaPixel(
        color: color,
        colorBorde: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Icon(icono, color: fondoClaro ? Colors.black : Colors.white),
      ),
    );
  }
}
