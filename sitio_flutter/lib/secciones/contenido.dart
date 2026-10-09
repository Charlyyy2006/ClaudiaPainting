// ══════════════════════════════════════════════════════════
//  Por qué nosotros, servicios y proceso
// ══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

import '../tema.dart';
import '../textos.dart';
import '../visor.dart';
import '../widgets.dart';

class PorQue extends StatelessWidget {
  const PorQue({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final items = [
      for (var i = 1; i <= 4; i++)
        _Punto(numero: '0$i', titulo: tx('p${i}_t'), cuerpo: tx('p${i}_b')),
    ];
    return Seccion(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Encabezado(numero: '01', eyebrow: tx('why_eyebrow'), titulo: tx('why_title'), entrada: tx('why_lede')),
        SizedBox(height: m.movil ? 44 : 72),
        Cuadricula(columnas: m.escritorio ? 4 : (m.movil ? 1 : 2), espacio: 32, espacioV: m.movil ? 28 : 40, hijos: items),
      ]),
    );
  }
}

class _Punto extends StatelessWidget {
  final String numero, titulo, cuerpo;
  const _Punto({required this.numero, required this.titulo, required this.cuerpo});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: 22),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.tinta))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(numero, style: etiqueta(color: C.acento)),
          const SizedBox(height: 14),
          Text(titulo, style: texto(17, color: C.tinta, peso: FontWeight.w600, alto: 1.35)),
          const SizedBox(height: 8),
          Text(cuerpo, style: texto(15)),
        ]),
      );
}

class Servicios extends StatelessWidget {
  final void Function(String id) irA;
  const Servicios({super.key, required this.irA});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final fotos = [
      FotoVisor('fotos/interior.jpg', tx('svc1_t'), tx('svc1_l1')),
      FotoVisor('fotos/despues2.jpg', tx('svc2_t'), tx('svc2_l1')),
    ];

    Widget servicio(int i) {
      final n = i + 1;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: GestureDetector(
            onTap: () => abrirVisor(context, fotos, i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(aspectRatio: 4 / 5, child: Foto(fotos[i].ruta, descripcion: fotos[i].titulo)),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(tx('svc${n}_t'), style: titulo(m.movil ? 28 : 34)),
        const SizedBox(height: 12),
        Text(tx('svc${n}_b'), style: texto(16)),
        const SizedBox(height: 20),
        for (var l = 1; l <= 3; l++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.linea))),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.acento, shape: BoxShape.circle)),
              const SizedBox(width: 14),
              Expanded(child: Text(tx('svc${n}_l$l'), style: texto(15, color: C.tinta, alto: 1.4))),
            ]),
          ),
      ]);
    }

    return Seccion(
      color: C.blanco,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Encabezado(numero: '02', eyebrow: tx('svc_eyebrow'), titulo: tx('svc_title')),
        SizedBox(height: m.movil ? 44 : 72),
        if (m.movil) ...[
          servicio(0),
          const SizedBox(height: 56),
          servicio(1),
        ] else
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: servicio(0)),
            SizedBox(width: m.escritorio ? 56 : 32),
            Expanded(child: servicio(1)),
          ]),
        SizedBox(height: m.movil ? 48 : 72),
        Container(
          padding: EdgeInsets.all(m.movil ? 22 : 32),
          color: C.fondo2,
          child: m.movil
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tx('both'), style: texto(16, color: C.tinta, alto: 1.55)),
                  const SizedBox(height: 20),
                  Boton(tx('nav_quote'), alTocar: () => irA('contact'), ancho: true),
                ])
              : Row(children: [
                  Expanded(child: Text(tx('both'), style: texto(16, color: C.tinta, alto: 1.55))),
                  const SizedBox(width: 24),
                  Boton(tx('nav_quote'), alTocar: () => irA('contact')),
                ]),
        ),
      ]),
    );
  }
}

class Proceso extends StatelessWidget {
  const Proceso({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    Widget paso(int i) => Container(
          padding: const EdgeInsets.only(top: 22),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white24))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('0$i', style: titulo(40, color: Colors.white, peso: FontWeight.w300)),
            const SizedBox(height: 18),
            Text(tx('s${i}_t'), style: texto(17, color: Colors.white, peso: FontWeight.w600, alto: 1.35)),
            const SizedBox(height: 8),
            Text(tx('s${i}_b'), style: texto(15, color: Colors.white60)),
          ]),
        );

    return Seccion(
      color: C.oscuro,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Encabezado(numero: '03', eyebrow: tx('proc_eyebrow'), titulo: tx('proc_title'), oscuro: true),
        SizedBox(height: m.movil ? 44 : 72),
        Cuadricula(
          columnas: m.escritorio ? 4 : (m.movil ? 1 : 2),
          espacio: 32,
          espacioV: m.movil ? 32 : 48,
          hijos: [for (var i = 1; i <= 4; i++) paso(i)],
        ),
      ]),
    );
  }
}
