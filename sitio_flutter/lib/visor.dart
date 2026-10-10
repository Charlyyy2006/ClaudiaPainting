// ══════════════════════════════════════════════════════════
//  Visor de fotos a pantalla completa
//  Deslizar o flechas para cambiar, pellizcar para acercar,
//  Esc o la X para cerrar.
// ══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tema.dart';
import 'textos.dart';
import 'widgets.dart';

class FotoVisor {
  final String ruta, titulo, subtitulo;
  const FotoVisor(this.ruta, this.titulo, [this.subtitulo = '']);
}

/// [context] debe ser el de la foto que se tocó: el visor crece
/// desde ese punto de la pantalla y al cerrar se encoge hacia él.
void abrirVisor(BuildContext context, List<FotoVisor> fotos, int inicio) {
  var desde = Alignment.center;
  var escala = .85;
  final caja = context.findRenderObject();
  if (caja is RenderBox && caja.hasSize) {
    final pantalla = MediaQuery.sizeOf(context);
    final centro = caja.localToGlobal(caja.size.center(Offset.zero));
    desde = Alignment(
      (centro.dx / pantalla.width * 2 - 1).clamp(-1.0, 1.0),
      (centro.dy / pantalla.height * 2 - 1).clamp(-1.0, 1.0),
    );
    escala = (caja.size.width / pantalla.width).clamp(.25, .9);
  }

  showGeneralDialog(
    context: context,
    barrierColor: const Color(0xF20A0B0D),
    barrierDismissible: true,
    barrierLabel: tx('close'),
    transitionDuration: const Duration(milliseconds: 420),
    pageBuilder: (_, _, _) => _Visor(fotos: fotos, inicio: inicio),
    transitionBuilder: (_, anim, _, child) {
      final curva = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curva,
        child: ScaleTransition(
          scale: Tween(begin: escala, end: 1.0).animate(curva),
          alignment: desde,
          child: child,
        ),
      );
    },
  );
}

class _Visor extends StatefulWidget {
  final List<FotoVisor> fotos;
  final int inicio;
  const _Visor({required this.fotos, required this.inicio});

  @override
  State<_Visor> createState() => _VisorState();
}

class _VisorState extends State<_Visor> {
  late final PageController _pagina = PageController(
    initialPage: widget.inicio,
  );
  late int _actual = widget.inicio;

  void _ir(int dir) {
    final n = widget.fotos.length;
    if (n < 2) return;
    _pagina.animateToPage(
      (_actual + dir + n) % n,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pagina.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final foto = widget.fotos[_actual];
    final varias = widget.fotos.length > 1;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _ir(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _ir(1),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Stack(
              children: [
                // fotos
                Positioned.fill(
                  bottom: 96,
                  top: 56,
                  child: PageView.builder(
                    controller: _pagina,
                    itemCount: widget.fotos.length,
                    onPageChanged: (i) => setState(() => _actual = i),
                    itemBuilder: (_, i) => InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: m.movil ? 8 : 88,
                        ),
                        child: Foto(
                          widget.fotos[i].ruta,
                          fit: BoxFit.contain,
                          descripcion: widget.fotos[i].titulo,
                          fondo: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),

                // cerrar
                Positioned(
                  top: 8,
                  right: 8,
                  child: _BotonRedondo(
                    icono: Icons.close,
                    etiqueta: tx('close'),
                    alTocar: () => Navigator.of(context).pop(),
                  ),
                ),

                // flechas (en el celular basta con deslizar)
                if (varias && !m.movil) ...[
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 96,
                    child: Center(
                      child: _BotonRedondo(
                        icono: Icons.arrow_back,
                        etiqueta: tx('prev'),
                        alTocar: () => _ir(-1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 96,
                    child: Center(
                      child: _BotonRedondo(
                        icono: Icons.arrow_forward,
                        etiqueta: tx('next'),
                        alTocar: () => _ir(1),
                      ),
                    ),
                  ),
                ],

                // pie de foto
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  // al cambiar de foto, el texto se desvanece y sube un poco
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (hijo, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, .25),
                          end: Offset.zero,
                        ).animate(anim),
                        child: hijo,
                      ),
                    ),
                    child: Column(
                      key: ValueKey(_actual),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          foto.titulo,
                          textAlign: TextAlign.center,
                          style: texto(
                            15,
                            color: Colors.white,
                            peso: FontWeight.w500,
                          ),
                        ),
                        if (foto.subtitulo.isNotEmpty)
                          Text(
                            foto.subtitulo,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: texto(13, color: Colors.white54, alto: 1.5),
                          ),
                        if (varias) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${_actual + 1} ${tx('lb_of')} ${widget.fotos.length}',
                            style: etiqueta(color: Colors.white38),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonRedondo extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback alTocar;
  const _BotonRedondo({
    required this.icono,
    required this.etiqueta,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: alTocar,
    tooltip: etiqueta,
    icon: Icon(icono, color: Colors.white),
    style: IconButton.styleFrom(
      backgroundColor: Colors.white.withValues(alpha: .08),
      fixedSize: const Size(48, 48),
      side: const BorderSide(color: Colors.white24),
    ),
  );
}
