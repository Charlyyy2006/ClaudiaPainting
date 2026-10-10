// ══════════════════════════════════════════════════════════
//  Galería y antes/después
//  Las dos se llenan con lo que se sube desde el panel.
// ══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

import '../datos.dart';
import '../tema.dart';
import '../textos.dart';
import '../visor.dart';
import '../widgets.dart';

class Galeria extends StatefulWidget {
  const Galeria({super.key});

  @override
  State<Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<Galeria> {
  String _filtro = 'all';

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    return ValueListenableBuilder(
      valueListenable: galeria,
      builder: (context, fotos, _) {
        int cuantas(String c) => c == 'all' ? fotos.length : fotos.where((f) => f.categorias.contains(c)).length;
        final filtros = ['all', ...categoriasValidas.where((c) => cuantas(c) > 0)];
        if (!filtros.contains(_filtro)) _filtro = 'all';
        final visibles = _filtro == 'all' ? fotos : fotos.where((f) => f.categorias.contains(_filtro)).toList();

        return Seccion(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Encabezado(numero: '04', eyebrow: tx('gal_eyebrow'), titulo: tx('gal_title'), entrada: tx('gal_lede')),
            SizedBox(height: m.movil ? 36 : 56),

            // filtros
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final f in filtros)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Filtro(
                      texto_: tx('cat_$f'),
                      cuantas: cuantas(f),
                      activo: _filtro == f,
                      alTocar: () => setState(() => _filtro = f),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 28),

            // al cambiar de filtro, las fotos se desvanecen suavemente
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (actual, anteriores) => Stack(
                alignment: Alignment.topCenter,
                children: [...anteriores, ?actual],
              ),
              transitionBuilder: (hijo, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, .015), end: Offset.zero).animate(anim),
                  child: hijo,
                ),
              ),
              child: _Mosaico(
                key: ValueKey(_filtro),
                fotos: visibles,
                columnas: m.escritorio ? 3 : 2,
                espacio: m.movil ? 12 : 24,
              ),
            ),

            const SizedBox(height: 32),
            Text(tx('gal_more'), style: texto(14, color: C.grisClaro), textAlign: TextAlign.center),
          ]),
        );
      },
    );
  }
}

class _Filtro extends StatelessWidget {
  final String texto_;
  final int cuantas;
  final bool activo;
  final VoidCallback alTocar;
  const _Filtro({required this.texto_, required this.cuantas, required this.activo, required this.alTocar});

  @override
  Widget build(BuildContext context) => Semantics(
        selected: activo,
        button: true,
        child: TextButton(
          onPressed: alTocar,
          style: TextButton.styleFrom(
            backgroundColor: activo ? C.tinta : Colors.transparent,
            foregroundColor: activo ? Colors.white : C.tinta,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(color: activo ? C.tinta : C.linea),
            ),
          ),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: texto_, style: texto(14, color: activo ? Colors.white : C.tinta, peso: FontWeight.w500, alto: 1)),
            TextSpan(text: '  $cuantas', style: texto(12, color: activo ? Colors.white54 : C.grisClaro, alto: 1)),
          ])),
        ),
      );
}

/// Columnas de distinta altura, como un muro de fotos: cada foto
/// va a la columna que lleve menos altura acumulada.
class _Mosaico extends StatelessWidget {
  final List<FotoGaleria> fotos;
  final int columnas;
  final double espacio;
  const _Mosaico({super.key, required this.fotos, required this.columnas, required this.espacio});

  @override
  Widget build(BuildContext context) {
    final visor = [for (final f in fotos) FotoVisor(f.ruta, f.titulo.actual, f.descripcion.actual)];
    final cols = List.generate(columnas, (_) => <Widget>[]);
    final altos = List.filled(columnas, 0.0);

    for (var i = 0; i < fotos.length; i++) {
      var c = 0;
      for (var k = 1; k < columnas; k++) {
        if (altos[k] < altos[c] - 0.01) c = k;
      }
      altos[c] += 1 / fotos[i].proporcion + 0.25; // 0.25 ≈ el pie de foto
      cols[c].add(Padding(
        padding: EdgeInsets.only(bottom: espacio * 1.4),
        child: _Tarjeta(foto: fotos[i], alTocar: (desde) => abrirVisor(desde, visor, i)),
      ));
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var c = 0; c < columnas; c++) ...[
        if (c > 0) SizedBox(width: espacio),
        Expanded(child: Column(children: cols[c])),
      ],
    ]);
  }
}

class _Tarjeta extends StatefulWidget {
  final FotoGaleria foto;
  final ValueChanged<BuildContext> alTocar; // recibe el context de la tarjeta tocada
  const _Tarjeta({required this.foto, required this.alTocar});

  @override
  State<_Tarjeta> createState() => _TarjetaState();
}

class _TarjetaState extends State<_Tarjeta> {
  bool _sobre = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.foto;
    final movil = context.m.movil;
    final etiquetaCat = f.categorias.contains('proceso') ? 'proceso' : f.categorias.first;

    return Semantics(
      button: true,
      label: f.titulo.actual,
      child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        onEnter: (_) => setState(() => _sobre = true),
        onExit: (_) => setState(() => _sobre = false),
        child: GestureDetector(
          onTap: () => widget.alTocar(context),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(
                aspectRatio: f.proporcion,
                child: AnimatedScale(
                  scale: _sobre ? 1.04 : 1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  child: Foto(f.ruta, descripcion: '${f.titulo.actual} — ${f.descripcion.actual}'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(tx('cat_$etiquetaCat').toUpperCase(),
                style: etiqueta(color: etiquetaCat == 'proceso' ? const Color(0xFFA9792A) : C.acento).copyWith(fontSize: 10)),
            const SizedBox(height: 4),
            Text(f.titulo.actual, style: texto(movil ? 14.5 : 16, color: C.tinta, peso: FontWeight.w600, alto: 1.3)),
            if (f.descripcion.actual.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(f.descripcion.actual, style: texto(movil ? 13 : 14, alto: 1.45)),
            ],
          ]),
        ),
      ),
    );
  }
}

// ── Antes y después ─────────────────────────────────────────

class AntesDespues extends StatelessWidget {
  const AntesDespues({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    return ValueListenableBuilder(
      valueListenable: proyectos,
      builder: (context, lista, _) => Seccion(
        color: C.blanco,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Encabezado(numero: '05', eyebrow: tx('ba_eyebrow'), titulo: tx('ba_title'), entrada: tx('ba_lede')),
          SizedBox(height: m.movil ? 44 : 72),
          for (var i = 0; i < lista.length; i++) ...[
            if (i > 0) SizedBox(height: m.movil ? 56 : 88),
            _Proyecto(proyecto: lista[i], numero: i + 1, alReves: i.isOdd),
          ],
        ]),
      ),
    );
  }
}

class _Proyecto extends StatelessWidget {
  final Proyecto proyecto;
  final int numero;
  final bool alReves;
  const _Proyecto({required this.proyecto, required this.numero, required this.alReves});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final p = proyecto;

    final comparador = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: _Comparador(
        antes: p.antes,
        despues: p.despues,
        alAmpliar: (desde) => abrirVisor(desde, [
          FotoVisor(p.antes, '${tx('tag_before')} — ${p.titulo.actual}'),
          FotoVisor(p.despues, '${tx('tag_after')} — ${p.titulo.actual}'),
        ], 0),
      ),
    );

    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(numero.toString().padLeft(2, '0'), style: etiqueta(color: C.acento)),
      const SizedBox(height: 14),
      Text(p.titulo.actual, style: titulo(m.movil ? 26 : 32)),
      const SizedBox(height: 14),
      Text(p.descripcion.actual, style: texto(16)),
      if (p.etiquetas.isNotEmpty) ...[
        const SizedBox(height: 20),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in p.etiquetas)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: C.linea), borderRadius: BorderRadius.circular(999)),
              child: Text(e, style: texto(12.5, color: C.tinta, alto: 1.2)),
            ),
        ]),
      ],
    ]);

    if (!m.escritorio) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: comparador),
        const SizedBox(height: 28),
        info,
      ]);
    }
    final hijos = [
      Expanded(flex: 6, child: comparador),
      const SizedBox(width: 64),
      Expanded(flex: 5, child: info),
    ];
    return Row(children: alReves ? hijos.reversed.toList() : hijos);
  }
}

/// Las dos fotos encimadas con una barra que se arrastra: a la
/// izquierda se ve el antes y a la derecha el después.
class _Comparador extends StatefulWidget {
  final String antes, despues;
  final ValueChanged<BuildContext> alAmpliar;
  const _Comparador({required this.antes, required this.despues, required this.alAmpliar});

  @override
  State<_Comparador> createState() => _ComparadorState();
}

class _ComparadorState extends State<_Comparador> {
  double _pos = .5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          void mover(double x) => setState(() => _pos = (x / w).clamp(0.0, 1.0));

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) => mover(d.localPosition.dx),
            onTapUp: (d) => mover(d.localPosition.dx),
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Stack(fit: StackFit.expand, children: [
                Foto(widget.despues, alineacion: Alignment.topCenter, descripcion: tx('tag_after')),
                ClipRect(
                  clipper: _RecorteIzquierdo(_pos),
                  child: Foto(widget.antes, alineacion: Alignment.topCenter, descripcion: tx('tag_before')),
                ),
                // línea y manija
                Positioned(
                  left: w * _pos - 1, top: 0, bottom: 0,
                  child: Container(width: 2, color: Colors.white),
                ),
                Positioned(
                  left: w * _pos - 22,
                  top: 0, bottom: 0,
                  child: Center(
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4))],
                      ),
                      child: const Icon(Icons.code, size: 20, color: C.tinta),
                    ),
                  ),
                ),
                Positioned(left: 12, top: 12, child: _Marca(tx('tag_before'), oscura: true)),
                Positioned(right: 12, top: 12, child: _Marca(tx('tag_after'), oscura: false)),
                Positioned(
                  right: 10, bottom: 10,
                  child: IconButton(
                    onPressed: () => widget.alAmpliar(context),
                    tooltip: '${tx('tag_before')} / ${tx('tag_after')}',
                    icon: const Icon(Icons.open_in_full, size: 18, color: C.tinta),
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .92)),
                  ),
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

class _RecorteIzquierdo extends CustomClipper<Rect> {
  final double pos;
  _RecorteIzquierdo(this.pos);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * pos, size.height);

  @override
  bool shouldReclip(_RecorteIzquierdo old) => old.pos != pos;
}

class _Marca extends StatelessWidget {
  final String texto_;
  final bool oscura;
  const _Marca(this.texto_, {required this.oscura});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: oscura ? const Color(0xCC0F1115) : C.acento,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(texto_.toUpperCase(), style: etiqueta(color: Colors.white).copyWith(fontSize: 10)),
      );
}
