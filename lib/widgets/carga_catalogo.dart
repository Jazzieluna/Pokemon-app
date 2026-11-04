import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/pokemon_repository.dart';
import 'caja_pixel.dart';

// espera a que el catalogo (nombres + tipos) este listo y luego dibuja el builder
class CargaCatalogo extends StatefulWidget {
  final WidgetBuilder builder;
  const CargaCatalogo({super.key, required this.builder});

  @override
  State<CargaCatalogo> createState() => _CargaCatalogoState();
}

class _CargaCatalogoState extends State<CargaCatalogo> {
  late Future<void> _carga;

  @override
  void initState() {
    super.initState();
    _carga = _preparar();
  }

  Future<void> _preparar() async {
    final repo = context.read<PokemonRepository>();
    await Future.wait([repo.cargarBase(), repo.cargarIndice()]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
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
        return widget.builder(context);
      },
    );
  }
}
