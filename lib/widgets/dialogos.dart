import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/colores.dart';

const RoundedRectangleBorder _forma = RoundedRectangleBorder(
  side: BorderSide(color: Colores.rojo, width: 3),
);

// devuelve el nombre escrito, o null si el usuario cancelo
Future<String?> pedirNombre(
  BuildContext context, {
  String titulo = 'NOMBRE DEL EQUIPO',
  String inicial = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _DialogoNombre(titulo: titulo, inicial: inicial),
  );
}

Future<bool> confirmar(BuildContext context, String mensaje) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colores.fondo,
      shape: _forma,
      content: Text(
        mensaje,
        style: GoogleFonts.vt323(fontSize: 24, color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            'NO',
            style: GoogleFonts.pressStart2p(fontSize: 9, color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            'SI',
            style: GoogleFonts.pressStart2p(fontSize: 9, color: Colores.rojo),
          ),
        ),
      ],
    ),
  );
  return respuesta ?? false;
}

class _DialogoNombre extends StatefulWidget {
  final String titulo;
  final String inicial;
  const _DialogoNombre({required this.titulo, required this.inicial});

  @override
  State<_DialogoNombre> createState() => _DialogoNombreState();
}

class _DialogoNombreState extends State<_DialogoNombre> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.inicial,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final texto = _ctrl.text.trim();
    if (texto.isNotEmpty) Navigator.pop(context, texto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colores.fondo,
      shape: _forma,
      title: Text(
        widget.titulo,
        style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white),
      ),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        maxLength: 20,
        textCapitalization: TextCapitalization.characters,
        cursorColor: Colores.rojo,
        style: GoogleFonts.vt323(fontSize: 26, color: Colors.white),
        onSubmitted: (_) => _guardar(),
        decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colores.rojo, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCELAR',
            style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: _guardar,
          child: Text(
            'GUARDAR',
            style: GoogleFonts.pressStart2p(fontSize: 8, color: Colores.rojo),
          ),
        ),
      ],
    );
  }
}
