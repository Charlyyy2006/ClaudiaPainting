// ══════════════════════════════════════════════════════════
//  CLAUDIA PAINTING LLC — sitio web en Flutter
//
//  Cómo está armado:
//   · tema.dart      colores, letras y medidas
//   · textos.dart    todos los textos en inglés y español
//   · datos.dart     fotos del panel (galería y antes/después)
//   · widgets.dart   piezas reutilizables (fotos, botones…)
//   · visor.dart     fotos a pantalla completa
//   · secciones/     cada parte de la página
// ══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

import 'datos.dart';
import 'secciones/contacto.dart';
import 'secciones/contenido.dart';
import 'secciones/galeria.dart';
import 'secciones/inicio.dart';
import 'tema.dart';
import 'textos.dart';
import 'widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdioma();
  cargarDatos(); // no se espera: la página abre con el respaldo
  runApp(const ClaudiaPainting());
}

class ClaudiaPainting extends StatelessWidget {
  const ClaudiaPainting({super.key});

  @override
  Widget build(BuildContext context) {
    return IdiomaScope(
      child: ValueListenableBuilder(
        valueListenable: idioma,
        builder: (context, lang, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (_) => tx('doc_title'),
          theme: temaApp(),
          locale: Locale(lang),
          home: const Pagina(),
        ),
      ),
    );
  }
}

class Pagina extends StatefulWidget {
  const Pagina({super.key});

  @override
  State<Pagina> createState() => _PaginaState();
}

class _PaginaState extends State<Pagina> {
  final _scroll = ScrollController();
  final _scaffold = GlobalKey<ScaffoldState>();
  final _solida = ValueNotifier(false);
  final _subir = ValueNotifier(false);

  /// una llave por sección, para poder bajar hasta ella
  final _llaves = {
    for (final id in ['home', ...menuSecciones]) id: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final y = _scroll.offset;
      _solida.value = y > 40;
      _subir.value = y > 900;
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _solida.dispose();
    _subir.dispose();
    super.dispose();
  }

  void _irA(String id) {
    if (id == 'home') {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
      return;
    }
    final ctx = _llaves[id]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _marcada(String id, Widget hijo) =>
      KeyedSubtree(key: _llaves[id], child: hijo);

  @override
  Widget build(BuildContext context) {
    final m = context.m;

    return Scaffold(
      key: _scaffold,
      endDrawer: m.escritorio ? null : MenuMovil(irA: _irA),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scroll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _marcada('home', Portada(irA: _irA)),
                  const PorQue(),
                  _marcada('services', Servicios(irA: _irA)),
                  _marcada('process', const Proceso()),
                  _marcada('gallery', const Galeria()),
                  _marcada('before-after', const AntesDespues()),
                  _marcada('about', const Nosotros()),
                  _marcada('faq', const Preguntas()),
                  _marcada('contact', const Contacto()),
                  Pie(irA: _irA),
                ],
              ),
            ),
          ),

          // barra de arriba
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder(
              valueListenable: _solida,
              builder: (_, solida, _) => BarraSuperior(
                solida: solida,
                irA: _irA,
                abrirMenu: () => _scaffold.currentState?.openEndDrawer(),
              ),
            ),
          ),

          // botones flotantes
          Positioned(
            right: m.movil ? 16 : 24,
            bottom: m.movil ? 16 : 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ValueListenableBuilder(
                  valueListenable: _subir,
                  builder: (_, visible, _) => AnimatedOpacity(
                    opacity: visible ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: !visible,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IconButton(
                          onPressed: () => _irA('home'),
                          tooltip: 'Top',
                          icon: const Icon(
                            Icons.arrow_upward,
                            color: C.tinta,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: C.blanco,
                            fixedSize: const Size(48, 48),
                            side: const BorderSide(color: C.linea),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Enlace(
                  uri: enlaceWhatsApp(),
                  builder: (abrir) => Material(
                    color: C.wa,
                    shape: const StadiumBorder(),
                    elevation: 6,
                    shadowColor: const Color(0x6625D366),
                    child: InkWell(
                      onTap: abrir,
                      customBorder: const StadiumBorder(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: m.movil ? 16 : 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chat_rounded,
                              color: Color(0xFF06301A),
                              size: 22,
                            ),
                            if (!m.movil) ...[
                              const SizedBox(width: 10),
                              Text(
                                'WhatsApp',
                                style: texto(
                                  15,
                                  color: const Color(0xFF06301A),
                                  peso: FontWeight.w600,
                                  alto: 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
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
