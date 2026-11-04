import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pokemon_resumen.dart';
import '../theme/colores.dart';
import 'caja_pixel.dart';

import 'package:provider/provider.dart';

import '../viewmodels/coleccion_viewmodel.dart';

class TarjetaPokemon extends StatelessWidget {
  final PokemonResumen pokemon;
  final VoidCallback? onTap;

  const TarjetaPokemon({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    // select: esta tarjeta solo se redibuja si cambia SU favorito o SU capturado,
    // no cuando cambia cualquier otro pokemon de la coleccion
    final esFavorito = context.select<ColeccionViewModel, bool>(
      (c) => c.esFavorito(pokemon.id),
    );
    final esCapturado = context.select<ColeccionViewModel, bool>(
      (c) => c.esCapturado(pokemon.id),
    );
    // el color de la tarjeta sale del tipo primario
    final tipoPrimario = pokemon.tipos.isNotEmpty
        ? pokemon.tipos.first
        : 'normal';
    final colorTipo = Colores.deTipo(tipoPrimario);
    // mezclamos con negro para un fondo oscuro del mismo tono
    final colorFondo = Color.lerp(colorTipo, Colors.black, 0.45)!;

    final numero = '#${pokemon.id.toString().padLeft(4, '0')}';
    final nombre = pokemon.nombre.replaceAll('-', ' ').toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: CajaPixel(
        color: colorFondo,
        colorBorde: colorTipo,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // numero en la esquina
            Row(
              children: [
                if (esFavorito)
                  const Icon(Icons.favorite, size: 12, color: Colors.redAccent),
                if (esCapturado)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.catching_pokemon,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                const Spacer(),
                Text(
                  numero,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            // imagen grande, escalada sin suavizado para ver los pixeles
            Expanded(
              child: Hero(
                tag: 'sprite-${pokemon.id}',
                child: CachedNetworkImage(
                  imageUrl: pokemon.spriteUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  placeholder: (_, _) => const SizedBox(),
                  errorWidget: (_, _, _) =>
                      const Icon(Icons.broken_image, color: Colors.white38),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // scaleDown encoge el texto si el nombre es muy largo
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                nombre,
                style: GoogleFonts.pressStart2p(
                  fontSize: 9,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [for (final t in pokemon.tipos) ChipTipo(tipo: t)],
            ),
          ],
        ),
      ),
    );
  }
}

class ChipTipo extends StatelessWidget {
  final String tipo;
  const ChipTipo({super.key, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final color = Colores.deTipo(tipo);
    // texto blanco sobre colores oscuros y negro sobre colores claros
    final textoOscuro =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        Colores.nombresTipo[tipo] ?? tipo.toUpperCase(),
        style: GoogleFonts.vt323(
          fontSize: 15,
          color: textoOscuro ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
