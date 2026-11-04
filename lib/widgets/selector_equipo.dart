import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/equipo.dart';
import '../theme/colores.dart';
import '../viewmodels/equipos_viewmodel.dart';
import 'caja_pixel.dart';
import 'dialogos.dart';

Future<void> mostrarSelectorEquipo(
  BuildContext context, {
  required int pokemonId,
  required String nombre,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colores.fondo,
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: Colores.rojo, width: 3),
    ),
    builder: (_) => _Selector(pokemonId: pokemonId, nombre: nombre),
  );
}

SnackBar _aviso(String texto) {
  return SnackBar(
    backgroundColor: Colores.rojo,
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: Colors.white, width: 2),
    ),
    content: Text(
      texto,
      style: GoogleFonts.vt323(fontSize: 20, color: Colors.white),
    ),
  );
}

class _Selector extends StatelessWidget {
  final int pokemonId;
  final String nombre;
  const _Selector({required this.pokemonId, required this.nombre});

  String _mensaje(ResultadoAgregar r, String equipo) {
    switch (r) {
      case ResultadoAgregar.ok:
        return '${nombre.toUpperCase()} AGREGADO A $equipo';
      case ResultadoAgregar.lleno:
        return 'EL EQUIPO YA TIENE ${Equipo.maximo}';
      case ResultadoAgregar.repetido:
        return 'YA ESTA EN $equipo';
      case ResultadoAgregar.noExiste:
        return 'EL EQUIPO YA NO EXISTE';
    }
  }

  void _agregar(BuildContext context, Equipo equipo) {
    final vm = context.read<EquiposViewModel>();
    // el messenger se toma antes de cerrar el panel, porque despues ya no hay contexto
    final mensajero = ScaffoldMessenger.of(context);

    final resultado = vm.agregar(equipo.id, pokemonId);
    Navigator.pop(context);

    if (resultado == ResultadoAgregar.ok) HapticFeedback.mediumImpact();
    mensajero.showSnackBar(_aviso(_mensaje(resultado, equipo.nombre)));
  }

  Future<void> _nuevo(BuildContext context) async {
    final nombreEquipo = await pedirNombre(context);
    // despues de un await hay que verificar que la pantalla siga viva
    if (nombreEquipo == null || !context.mounted) return;

    final vm = context.read<EquiposViewModel>();
    final mensajero = ScaffoldMessenger.of(context);

    final nuevo = vm.crear(nombreEquipo);
    vm.agregar(nuevo.id, pokemonId);
    Navigator.pop(context);

    HapticFeedback.mediumImpact();
    mensajero.showSnackBar(
      _aviso('${nombre.toUpperCase()} AGREGADO A $nombreEquipo'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final equipos = context.watch<EquiposViewModel>().equipos;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'AGREGAR A EQUIPO',
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (equipos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'AUN NO TIENES EQUIPOS',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: Colors.white54,
                  ),
                ),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final e in equipos)
                    _FilaEquipo(
                      equipo: e,
                      pokemonId: pokemonId,
                      onTap: () => _agregar(context, e),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: BotonPixel(
                texto: 'NUEVO EQUIPO',
                onPressed: () => _nuevo(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaEquipo extends StatelessWidget {
  final Equipo equipo;
  final int pokemonId;
  final VoidCallback onTap;
  const _FilaEquipo({
    required this.equipo,
    required this.pokemonId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final yaEsta = equipo.ids.contains(pokemonId);
    // se ve apagado si no se puede agregar, pero sigue siendo tocable para avisar por que
    final apagado = yaEsta || equipo.lleno;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: apagado ? 0.5 : 1,
          child: CajaPixel(
            color: Colores.fondo,
            colorBorde: Colors.white54,
            grosorBorde: 2,
            sombra: 3,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    equipo.nombre,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (yaEsta)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.greenAccent,
                    ),
                  ),
                Text(
                  '${equipo.ids.length}/${Equipo.maximo}',
                  style: GoogleFonts.vt323(fontSize: 22, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
