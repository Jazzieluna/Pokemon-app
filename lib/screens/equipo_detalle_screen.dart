import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/equipo.dart';
import '../models/pokemon_resumen.dart';
import '../repositories/pokemon_repository.dart';
import '../theme/colores.dart';
import '../viewmodels/equipos_viewmodel.dart';
import '../widgets/caja_pixel.dart';
import '../widgets/carga_catalogo.dart';
import '../widgets/dialogos.dart';
import '../widgets/tarjeta_pokemon.dart';
import 'detalle_screen.dart';

class EquipoDetalleScreen extends StatelessWidget {
  final String equipoId;
  const EquipoDetalleScreen({super.key, required this.equipoId});

  Future<void> _renombrar(BuildContext context, Equipo equipo) async {
    final nombre = await pedirNombre(
      context,
      titulo: 'RENOMBRAR',
      inicial: equipo.nombre,
    );
    if (nombre == null || !context.mounted) return;
    context.read<EquiposViewModel>().renombrar(equipo.id, nombre);
  }

  Future<void> _eliminar(BuildContext context, Equipo equipo) async {
    final ok = await confirmar(context, 'ELIMINAR "${equipo.nombre}"?');
    if (!ok || !context.mounted) return;
    context.read<EquiposViewModel>().eliminar(equipo.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final equipo = context.watch<EquiposViewModel>().porId(equipoId);

    // si el equipo se acaba de eliminar, la pantalla se cierra en este mismo
    // instante: mientras tanto no hay nada que dibujar
    if (equipo == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(equipo.nombre, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _renombrar(context, equipo),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _eliminar(context, equipo),
          ),
        ],
      ),
      body: CargaCatalogo(builder: (_) => _Contenido(equipo: equipo)),
    );
  }
}

class _Contenido extends StatelessWidget {
  final Equipo equipo;
  const _Contenido({required this.equipo});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PokemonRepository>();
    final miembros = repo.resumenesDeIds(equipo.ids);

    // tipos distintos que tiene el equipo
    final tipos = <String>{};
    for (final m in miembros) {
      tipos.addAll(m.tipos);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: CajaPixel(
            color: Colores.fondo,
            colorBorde: Colores.rojo,
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTEGRANTES ${equipo.ids.length}/${Equipo.maximo}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (tipos.isEmpty)
                    Text(
                      'EQUIPO VACIO. AGREGA POKEMON DESDE SU DETALLE',
                      style: GoogleFonts.vt323(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final t in tipos) ChipTipo(tipo: t)],
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.68,
            ),
            itemCount: Equipo.maximo,
            itemBuilder: (context, i) => i < miembros.length
                ? _Integrante(equipoId: equipo.id, pokemon: miembros[i])
                : const _RanuraVacia(),
          ),
        ),
      ],
    );
  }
}

class _Integrante extends StatelessWidget {
  final String equipoId;
  final PokemonResumen pokemon;
  const _Integrante({required this.equipoId, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: TarjetaPokemon(
            pokemon: pokemon,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetalleScreen(resumen: pokemon),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () =>
              context.read<EquiposViewModel>().quitar(equipoId, pokemon.id),
          child: CajaPixel(
            color: Colors.black54,
            colorBorde: Colors.white54,
            grosorBorde: 2,
            sombra: 2,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                'QUITAR',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RanuraVacia extends StatelessWidget {
  const _RanuraVacia();

  @override
  Widget build(BuildContext context) {
    return CajaPixel(
      color: Colores.fondo,
      colorBorde: Colors.white24,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.catching_pokemon, size: 48, color: Colors.white12),
            const SizedBox(height: 8),
            Text(
              'VACIO',
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
