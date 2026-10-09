// ══════════════════════════════════════════════════════════
//  Piezas que se repiten en toda la página
// ══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import 'tema.dart';

// ── Fotos ───────────────────────────────────────────────────
// En el celular, una foto de 4000 px gasta memoria de más y es
// justo lo que hacía que algunas no aparecieran. Por eso cada
// foto se pide al tamaño en que se va a ver:
//  · ya publicado, el CDN de imágenes de Netlify la reduce y la
//    convierte a WebP antes de mandarla
//  · siempre, se decodifica al ancho que ocupa en pantalla

bool get _esLocal {
  final h = Uri.base.host;
  return h.isEmpty || h == 'localhost' || h == '127.0.0.1' || h.endsWith('.localhost');
}

const _anchos = [400, 800, 1200, 1600];

int _anchoPara(double px) => _anchos.firstWhere((a) => a >= px, orElse: () => _anchos.last);

String urlOriginal(String ruta) => Uri.base.resolve('/$ruta').toString();

String urlFoto(String ruta, int ancho) {
  if (_esLocal) return urlOriginal(ruta);
  return Uri.base.resolve('/.netlify/images').replace(queryParameters: {
    'url': '/$ruta', 'w': '$ancho', 'q': '78', 'fm': 'webp',
  }).toString();
}

class Foto extends StatelessWidget {
  final String ruta;
  final BoxFit fit;
  final Alignment alineacion;
  final String? descripcion;
  final Color fondo; // lo que se ve mientras carga

  const Foto(this.ruta, {super.key, this.fit = BoxFit.cover, this.alineacion = Alignment.center, this.descripcion, this.fondo = C.fondo2});

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(builder: (context, c) {
      final visible = c.maxWidth.isFinite ? c.maxWidth : 1200.0;
      final ancho = _anchoPara(visible * dpr);
      final relleno = ColoredBox(color: fondo);

      Widget imagen(String url, {required bool conRespaldo}) => Image.network(
            url,
            fit: fit,
            alignment: alineacion,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: ancho,
            semanticLabel: descripcion,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, sincrona) {
              if (sincrona) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: child,
              );
            },
            // si el CDN falla por cualquier motivo, se pide la original
            errorBuilder: (context, _, _) =>
                conRespaldo ? imagen(urlOriginal(ruta), conRespaldo: false) : relleno,
          );

      return Stack(fit: StackFit.expand, children: [
        relleno,
        imagen(urlFoto(ruta, ancho), conRespaldo: !_esLocal),
      ]);
    });
  }
}

// ── Contenedor de sección ───────────────────────────────────

class Seccion extends StatelessWidget {
  final Widget child;
  final Color color;
  final double? arriba, abajo;
  const Seccion({super.key, required this.child, this.color = C.fondo, this.arriba, this.abajo});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    return Container(
      color: color,
      padding: EdgeInsets.fromLTRB(m.margen, arriba ?? m.seccion, m.margen, abajo ?? m.seccion),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: child,
      ),
    );
  }
}

/// Número + nombre de la sección, título grande y una entrada
/// opcional. En pantalla ancha la etiqueta va a la izquierda.
class Encabezado extends StatelessWidget {
  final String numero, eyebrow, titulo;
  final String? entrada;
  final bool oscuro;
  const Encabezado({super.key, required this.numero, required this.eyebrow, required this.titulo, this.entrada, this.oscuro = false});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final colorTitulo = oscuro ? Colors.white : C.tinta;
    final colorTexto = oscuro ? Colors.white60 : C.gris;

    final marca = Row(mainAxisSize: MainAxisSize.min, children: [
      Text(numero, style: etiqueta(color: oscuro ? Colors.white : C.tinta)),
      const SizedBox(width: 10),
      Container(width: 24, height: 1, color: oscuro ? Colors.white30 : C.linea),
      const SizedBox(width: 10),
      Text(eyebrow.toUpperCase(), style: etiqueta(color: colorTexto)),
    ]);

    final cuerpo = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: tituloSeccion(m, color: colorTitulo)),
      if (entrada != null) ...[
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(entrada!, style: texto(m.movil ? 16 : 17, color: colorTexto)),
        ),
      ],
    ]);

    if (!m.escritorio) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        marca, const SizedBox(height: 22), cuerpo,
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 280, child: Padding(padding: const EdgeInsets.only(top: 14), child: marca)),
      Expanded(child: cuerpo),
    ]);
  }
}

/// Línea fina con los seis colores del logo.
class LineaPincel extends StatelessWidget {
  final double alto;
  const LineaPincel({super.key, this.alto = 3});

  @override
  Widget build(BuildContext context) => Container(
        height: alto,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: C.pincel)),
      );
}

// ── Botones ─────────────────────────────────────────────────

enum TipoBoton { primario, whatsapp, contorno, claro }

class Boton extends StatelessWidget {
  final String texto_;
  final TipoBoton tipo;
  final IconData? icono;
  final VoidCallback? alTocar;
  final Uri? enlace;
  final bool ancho;

  const Boton(this.texto_, {super.key, this.tipo = TipoBoton.primario, this.icono, this.alTocar, this.enlace, this.ancho = false});

  @override
  Widget build(BuildContext context) {
    final (fondo, frente, borde) = switch (tipo) {
      TipoBoton.primario => (C.tinta, Colors.white, C.tinta),
      TipoBoton.whatsapp => (C.wa, const Color(0xFF06301A), C.wa),
      TipoBoton.contorno => (Colors.transparent, C.tinta, C.tinta.withValues(alpha: .25)),
      TipoBoton.claro => (Colors.transparent, Colors.white, Colors.white38),
    };

    Widget boton(VoidCallback? accion) => TextButton(
          onPressed: accion,
          style: TextButton.styleFrom(
            backgroundColor: fondo,
            foregroundColor: frente,
            minimumSize: Size(ancho ? double.infinity : 0, 52),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: borde),
            ),
            textStyle: texto(15, peso: FontWeight.w600, alto: 1.2),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icono != null) ...[Icon(icono, size: 18), const SizedBox(width: 10)],
            Flexible(child: Text(texto_, textAlign: TextAlign.center)),
          ]),
        );

    if (enlace != null) {
      return Enlace(uri: enlace!, builder: (abrir) => boton(abrir));
    }
    return boton(alTocar);
  }
}

/// Enlace de verdad (<a> en el navegador): se puede abrir en otra
/// pestaña, copiar, y los buscadores lo ven.
class Enlace extends StatelessWidget {
  final Uri uri;
  final Widget Function(VoidCallback? abrir) builder;
  const Enlace({super.key, required this.uri, required this.builder});

  @override
  Widget build(BuildContext context) {
    final externo = uri.scheme == 'http' || uri.scheme == 'https';
    return Link(
      uri: uri,
      target: externo ? LinkTarget.blank : LinkTarget.self,
      builder: (context, abrir) => builder(abrir),
    );
  }
}

/// Texto que se subraya al pasar el mouse.
class TextoEnlace extends StatefulWidget {
  final String texto_;
  final TextStyle estilo;
  final VoidCallback? alTocar;
  final Uri? enlace;
  const TextoEnlace(this.texto_, {super.key, required this.estilo, this.alTocar, this.enlace});

  @override
  State<TextoEnlace> createState() => _TextoEnlaceState();
}

class _TextoEnlaceState extends State<TextoEnlace> {
  bool _sobre = false;

  @override
  Widget build(BuildContext context) {
    Widget hijo(VoidCallback? accion) => MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _sobre = true),
          onExit: (_) => setState(() => _sobre = false),
          child: GestureDetector(
            onTap: accion,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(widget.texto_,
                  style: widget.estilo.copyWith(
                    decoration: _sobre ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: widget.estilo.color,
                  )),
            ),
          ),
        );
    if (widget.enlace != null) return Enlace(uri: widget.enlace!, builder: hijo);
    return hijo(widget.alTocar);
  }
}

/// Reparte [hijos] en una cuadrícula de [columnas] con el mismo
/// ancho, sin que ninguno se estire de alto.
class Cuadricula extends StatelessWidget {
  final int columnas;
  final double espacio, espacioV;
  final List<Widget> hijos;
  const Cuadricula({super.key, required this.columnas, required this.hijos, this.espacio = 24, double? espacioV})
      : espacioV = espacioV ?? espacio;

  @override
  Widget build(BuildContext context) {
    final filas = <Widget>[];
    for (var i = 0; i < hijos.length; i += columnas) {
      final fila = <Widget>[];
      for (var j = 0; j < columnas; j++) {
        if (j > 0) fila.add(SizedBox(width: espacio));
        fila.add(Expanded(child: i + j < hijos.length ? hijos[i + j] : const SizedBox()));
      }
      if (filas.isNotEmpty) filas.add(SizedBox(height: espacioV));
      filas.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: fila)));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: filas);
  }
}
