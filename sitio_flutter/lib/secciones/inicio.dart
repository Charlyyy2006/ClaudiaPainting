// ══════════════════════════════════════════════════════════
//  Barra de arriba, menú del celular y portada
// ══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

import '../tema.dart';
import '../textos.dart';
import '../widgets.dart';

/// Las secciones a las que lleva el menú, en orden.
const menuSecciones = ['services', 'process', 'gallery', 'before-after', 'about', 'faq', 'contact'];

String nombreSeccion(String id) => tx(switch (id) {
      'services' => 'nav_services',
      'process' => 'nav_process',
      'gallery' => 'nav_work',
      'before-after' => 'nav_ba',
      'about' => 'nav_about',
      'faq' => 'nav_faq',
      _ => 'nav_contact',
    });

class BarraSuperior extends StatelessWidget {
  final bool solida; // blanca después de bajar un poco
  final void Function(String id) irA;
  final VoidCallback abrirMenu;
  const BarraSuperior({super.key, required this.solida, required this.irA, required this.abrirMenu});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final frente = solida ? C.tinta : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: solida ? C.fondo.withValues(alpha: .97) : Colors.transparent,
        border: Border(bottom: BorderSide(color: solida ? C.linea : Colors.transparent)),
      ),
      padding: EdgeInsets.symmetric(horizontal: m.margen),
      height: 68,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => irA('home'),
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: 'Claudia Painting', style: titulo(21, color: frente, estilo: FontStyle.italic)),
                    TextSpan(text: '  LLC', style: etiqueta(color: solida ? C.grisClaro : Colors.white54).copyWith(fontSize: 9.5)),
                  ]),
                  semanticsLabel: 'Claudia Painting LLC',
                ),
              ),
            ),
            const Spacer(),
            if (m.escritorio)
              for (final id in menuSecciones.take(6))
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: TextoEnlace(nombreSeccion(id),
                      estilo: texto(13.5, color: frente, peso: FontWeight.w500), alTocar: () => irA(id)),
                ),
            SizedBox(width: m.escritorio ? 28 : 12),
            _SelectorIdioma(color: frente),
            if (m.escritorio) ...[
              const SizedBox(width: 20),
              SizedBox(
                height: 42,
                child: TextButton(
                  onPressed: () => irA('contact'),
                  style: TextButton.styleFrom(
                    backgroundColor: solida ? C.tinta : Colors.white,
                    foregroundColor: solida ? Colors.white : C.tinta,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    textStyle: texto(13.5, peso: FontWeight.w600, alto: 1),
                  ),
                  child: Text(tx('nav_quote')),
                ),
              ),
            ] else
              IconButton(
                onPressed: abrirMenu,
                tooltip: tx('menu'),
                icon: Icon(Icons.menu, color: frente),
              ),
          ]),
        ),
      ),
    );
  }
}

class _SelectorIdioma extends StatelessWidget {
  final Color color;
  const _SelectorIdioma({required this.color});

  @override
  Widget build(BuildContext context) {
    context.escucharIdioma();
    Widget opcion(String codigo) {
      final activo = idioma.value == codigo;
      return Semantics(
        button: true,
        selected: activo,
        label: codigo == 'en' ? 'English' : 'Español',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => cambiarIdioma(codigo),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              child: Text(codigo.toUpperCase(),
                  style: etiqueta(color: activo ? color : color.withValues(alpha: .4)).copyWith(letterSpacing: 1.4)),
            ),
          ),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      opcion('en'),
      Text('/', style: etiqueta(color: color.withValues(alpha: .3))),
      opcion('es'),
    ]);
  }
}

/// Menú a pantalla completa para celular y tableta.
class MenuMovil extends StatelessWidget {
  final void Function(String id) irA;
  const MenuMovil({super.key, required this.irA});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width,
      backgroundColor: C.oscuro,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.m.margen),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: 68,
              child: Row(children: [
                const _SelectorIdioma(color: Colors.white),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: tx('close'),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ]),
            ),
            Expanded(
              child: ListView(children: [
                for (final id in menuSecciones)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      irA(id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
                      child: Text(nombreSeccion(id), style: titulo(28, color: Colors.white)),
                    ),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 12),
              child: Boton(tx('hero_cta1'), tipo: TipoBoton.whatsapp, icono: Icons.chat_rounded,
                  enlace: enlaceWhatsApp(), ancho: true),
            ),
          ]),
        ),
      ),
    );
  }
}

class Portada extends StatelessWidget {
  final void Function(String id) irA;
  const Portada({super.key, required this.irA});

  @override
  Widget build(BuildContext context) {
    final m = context.m;

    final textoPortada = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Image.asset('assets/logo.png', width: m.movil ? 210 : 260, height: (m.movil ? 210 : 260) * 432 / 760, semanticLabel: 'Claudia Painting LLC — We Paint. You Love. We Care.'),
      SizedBox(height: m.movil ? 28 : 36),
      Text(tx('hero_tag').toUpperCase(), style: etiqueta(color: Colors.white60)),
      const SizedBox(height: 20),
      Text.rich(
        TextSpan(children: [
          TextSpan(text: '${tx('hero_h1a')}\n'),
          TextSpan(text: tx('hero_h1b'), style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFB9D8BF))),
        ]),
        style: titulo(m.movil ? 40 : (m.tableta ? 56 : 68), color: Colors.white, peso: FontWeight.w400),
      ),
      const SizedBox(height: 24),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Text(tx('hero_sub'), style: texto(m.movil ? 16 : 17.5, color: Colors.white60)),
      ),
      const SizedBox(height: 36),
      Wrap(spacing: 12, runSpacing: 12, children: [
        Boton(tx('hero_cta1'), tipo: TipoBoton.whatsapp, icono: Icons.chat_rounded, enlace: enlaceWhatsApp(), ancho: m.movil),
        Boton(tx('hero_cta2'), tipo: TipoBoton.claro, alTocar: () => irA('gallery'), ancho: m.movil),
      ]),
      const SizedBox(height: 40),
      Wrap(spacing: 28, runSpacing: 10, children: [
        for (final k in ['trust1', 'trust2', 'trust3'])
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check, size: 16, color: Color(0xFF7FB98C)),
            const SizedBox(width: 8),
            Text(tx(k), style: texto(13.5, color: Colors.white70, alto: 1.3)),
          ]),
      ]),
    ]);

    final foto = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AspectRatio(
        aspectRatio: m.escritorio ? 4 / 5 : 4 / 3,
        child: const Foto('fotos/exterior.jpg', descripcion: 'Freshly painted home exterior — porch columns, soffits and trim'),
      ),
    );

    return Container(
      color: C.oscuro,
      child: Column(children: [
        Seccion(
          color: Colors.transparent,
          arriba: m.movil ? 108 : 150,
          abajo: m.movil ? 56 : 110,
          child: m.escritorio
              ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(flex: 11, child: textoPortada),
                  const SizedBox(width: 72),
                  Expanded(flex: 9, child: foto),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  textoPortada,
                  SizedBox(height: m.movil ? 48 : 64),
                  foto,
                ]),
        ),
        const LineaPincel(),
      ]),
    );
  }
}
