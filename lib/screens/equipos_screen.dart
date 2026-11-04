import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/equipo.dart';
import '../models/pokemon_resumen.dart';
import '../theme/colores.dart';
import '../viewmodels/equipos_viewmodel.dart';
import '../widgets/caja_pixel.dart';
import '../widgets/dialogos.dart';
import 'equipo_detalle_screen.dart';

class EquiposScreen extends StatelessWidget {
  const EquiposScreen({super.key});

  Future<void> _nuevo(BuildContext context) async {
    final nombre = await pedirNombre(context);
    if (nombre == null || !context.mounted) return;
    context.read<EquiposViewModel>().crear(nombre);
  }

  @override
  Widget build(BuildContext context) {
    final equipos = context.watch<EquiposViewModel>().equipos;

    return Scaffold(
      appBar: AppBar(title: const Text('EQUIPOS')),
      floatingActionButton: GestureDetector(
        onTap: () => _nuevo(context),
        child: CajaPixel(
          color: Colores.rojo,
          colorBorde: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'NUEVO',
                style: GoogleFonts.pressStart2p(
                  fontSize: 9,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: equipos.isEmpty
          // estado vacio
          ? Center(
              child: Text(
                'NO TIENES EQUIPOS\n\nCREA UNO CON EL BOTON',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 9,
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: equipos.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _TarjetaEquipo(equipo: equipos[i]),
              ),
            ),
    );
  }
}

class _TarjetaEquipo extends StatelessWidget {
  final Equipo equipo;
  const _TarjetaEquipo({required this.equipo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EquipoDetalleScreen(equipoId: equipo.id),
        ),
      ),
      child: CajaPixel(
        color: Colores.fondo,
        colorBorde: Colores.rojo,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    equipo.nombre,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${equipo.ids.length}/${Equipo.maximo}',
                  style: GoogleFonts.vt323(fontSize: 22, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // siempre 6 ranuras: las que no tienen pokemon se ven vacias
            Row(
              children: [
                for (var i = 0; i < Equipo.maximo; i++)
                  Expanded(
                    child: _Ranura(
                      id: i < equipo.ids.length ? equipo.ids[i] : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Ranura extends StatelessWidget {
  final int? id;
  const _Ranura({this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: id == null
            ? const Icon(Icons.catching_pokemon, color: Colors.white12)
            : CachedNetworkImage(
                imageUrl: PokemonResumen(id: id!, nombre: '').spriteUrl,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                placeholder: (_, _) => const SizedBox(),
              ),
      ),
    );
  }
}
