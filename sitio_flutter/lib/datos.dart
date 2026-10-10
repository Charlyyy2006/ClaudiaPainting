// ══════════════════════════════════════════════════════════
//  Fotos de la galería y del antes/después
//
//  Viven en datos/galeria.json y datos/antes-despues.json y se
//  administran desde el panel: claudiapainting.com/admin
//  La app las lee al abrir, así que una foto nueva aparece sin
//  tener que volver a compilar nada.
//
//  Las listas de abajo son solo el RESPALDO: se muestran si el
//  archivo no se puede leer o viene mal escrito, para que la
//  galería nunca aparezca vacía.
// ══════════════════════════════════════════════════════════
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'textos.dart';

/// Un texto en los dos idiomas.
class Doble {
  final String en, es;
  const Doble(this.en, this.es);
  String get actual => enEspanol ? es : en;
}

class FotoGaleria {
  final String ruta;
  final List<String> categorias;
  final double proporcion; // ancho / alto
  final Doble titulo, descripcion;
  const FotoGaleria(
    this.ruta,
    this.categorias,
    this.proporcion,
    this.titulo,
    this.descripcion,
  );
}

class Proyecto {
  final String antes, despues;
  final Doble titulo, descripcion;
  final List<String> etiquetasEn, etiquetasEs;
  const Proyecto(
    this.antes,
    this.despues,
    this.titulo,
    this.descripcion,
    this.etiquetasEn,
    this.etiquetasEs,
  );
  List<String> get etiquetas => enEspanol ? etiquetasEs : etiquetasEn;
}

const categoriasValidas = ['interior', 'exterior', 'proceso'];

// ── Respaldo ────────────────────────────────────────────────
const _galeriaRespaldo = [
  FotoGaleria(
    'fotos/exterior.jpg',
    ['exterior'],
    3 / 4,
    Doble('Porch, columns & soffits', 'Porche, columnas y aleros'),
    Doble(
      'Exterior · Crisp white on brick',
      'Exterior · Blanco puro sobre ladrillo',
    ),
  ),
  FotoGaleria(
    'fotos/despues1.jpg',
    ['interior'],
    3 / 4,
    Doble('Charcoal bedroom', 'Recámara en carbón'),
    Doble(
      'Interior · Walls + shiplap ceiling',
      'Interior · Paredes y techo de madera',
    ),
  ),
  FotoGaleria(
    'fotos/interior.jpg',
    ['interior'],
    4 / 5,
    Doble('Vaulted living room', 'Sala con techo alto'),
    Doble(
      'Interior · Warm greige, ceiling included',
      'Interior · Gris cálido, techo incluido',
    ),
  ),
  FotoGaleria(
    'fotos/despues3.jpg',
    ['interior'],
    1,
    Doble('Kitchen ceiling & moulding', 'Techo de cocina y molduras'),
    Doble(
      'Interior · Smooth, seamless finish',
      'Interior · Acabado liso y parejo',
    ),
  ),
  FotoGaleria(
    'fotos/antes2.jpg',
    ['exterior', 'proceso'],
    4 / 5,
    Doble('Masked and ready', 'Todo cubierto y listo'),
    Doble(
      'Prep · Brick, steps and plants covered',
      'Preparación · Ladrillo, escalones y plantas',
    ),
  ),
  FotoGaleria(
    'fotos/antes1.jpg',
    ['interior', 'proceso'],
    1,
    Doble('Bare pine panelling', 'Madera de pino sin tratar'),
    Doble(
      'Prep · Before the first coat',
      'Preparación · Antes de la primera mano',
    ),
  ),
];

const _proyectosRespaldo = [
  Proyecto(
    'fotos/antes1.jpg',
    'fotos/despues1.jpg',
    Doble('Bedroom & wood ceiling', 'Recámara y techo de madera'),
    Doble(
      'Bare pine panelling turned into a deep, even charcoal — walls, ceiling boards and trim, all sealed and finished in the same tone.',
      'Madera de pino sin tratar convertida en un carbón profundo y parejo — paredes, tablas del techo y molduras, todo sellado y terminado en el mismo tono.',
    ),
    ['Interior', 'Full repaint', 'Ceiling included'],
    ['Interior', 'Repintado completo', 'Techo incluido'],
  ),
  Proyecto(
    'fotos/antes2.jpg',
    'fotos/despues2.jpg',
    Doble('Front porch & trim', 'Porche y molduras'),
    Doble(
      'Brick, steps and plants all masked off first, then columns, soffits and railings brought back to a clean, even white.',
      'Ladrillo, escalones y plantas cubiertos primero; luego columnas, aleros y barandales devueltos a un blanco limpio y parejo.',
    ),
    ['Exterior', 'Prep + repaint', 'Fully masked'],
    ['Exterior', 'Preparación + pintura', 'Todo enmascarado'],
  ),
  Proyecto(
    'fotos/antes3.jpg',
    'fotos/despues3.jpg',
    Doble('Kitchen ceiling & trim', 'Techo de cocina y molduras'),
    Doble(
      'From an opened-up ceiling with exposed joists to a flat, seamless finish — mouldings and trim cut in by hand.',
      'De un techo abierto con las vigas a la vista a un acabado plano y sin uniones — molduras y remates cortados a mano.',
    ),
    ['Interior', 'Ceilings', 'Mouldings'],
    ['Interior', 'Techos', 'Molduras'],
  ),
];

/// Lo que se está mostrando ahora. Empieza con el respaldo y se
/// reemplaza en cuanto llegan los archivos del panel.
final galeria = ValueNotifier<List<FotoGaleria>>(_galeriaRespaldo);
final proyectos = ValueNotifier<List<Proyecto>>(_proyectosRespaldo);

// ── Revisión de lo que llega del panel ──────────────────────
// Aunque el contenido lo escriben personas de confianza, un error
// de dedo no debe romper la página: lo que no pasa la revisión se
// descarta en silencio.

String _texto(Object? v, [int max = 160]) {
  if (v is! String) return '';
  final s = v.trim();
  return s.length > max ? s.substring(0, max) : s;
}

/// Solo rutas dentro del propio sitio y con extensión de imagen.
String _ruta(Object? v) {
  if (v is! String) return '';
  final s = v.trim().replaceFirst(RegExp(r'^/+'), '');
  if (s.contains('..') || s.contains(':')) return '';
  if (!RegExp(
    r'^[A-Za-z0-9._\-/]+\.(jpe?g|png|webp|avif|gif)$',
    caseSensitive: false,
  ).hasMatch(s))
    return '';
  return s;
}

List<String> _lista(Object? v, int max) => (v is List ? v : const [])
    .map((e) => _texto(e, 40))
    .where((e) => e.isNotEmpty)
    .take(max)
    .toList();

const _formas = {'3/4': 3 / 4, '4/5': 4 / 5, '1/1': 1.0};

FotoGaleria? _foto(Object? fila) {
  if (fila is! Map) return null;
  final ruta = _ruta(fila['imagen']);
  if (ruta.isEmpty) return null;
  final tEs = _texto(fila['titulo_es']), tEn = _texto(fila['titulo_en']);
  if (tEs.isEmpty && tEn.isEmpty) return null;
  final dEs = _texto(fila['descripcion_es']),
      dEn = _texto(fila['descripcion_en']);
  var cats =
      (fila['categorias'] is List ? fila['categorias'] as List : const [])
          .map((c) => '$c'.toLowerCase().trim())
          .where(categoriasValidas.contains)
          .toList();
  if (cats.isEmpty) cats = ['interior'];
  return FotoGaleria(
    ruta,
    cats,
    _formas[fila['forma']] ?? 3 / 4,
    Doble(tEn.isEmpty ? tEs : tEn, tEs.isEmpty ? tEn : tEs),
    Doble(dEn.isEmpty ? dEs : dEn, dEs.isEmpty ? dEn : dEs),
  );
}

Proyecto? _proyecto(Object? fila) {
  if (fila is! Map) return null;
  final a = _ruta(fila['imagen_antes']), d = _ruta(fila['imagen_despues']);
  if (a.isEmpty || d.isEmpty) return null; // hacen falta las dos
  final tEs = _texto(fila['titulo_es']), tEn = _texto(fila['titulo_en']);
  if (tEs.isEmpty && tEn.isEmpty) return null;
  final dEs = _texto(fila['descripcion_es'], 600),
      dEn = _texto(fila['descripcion_en'], 600);
  final cEs = _lista(fila['etiquetas_es'], 3),
      cEn = _lista(fila['etiquetas_en'], 3);
  return Proyecto(
    a,
    d,
    Doble(tEn.isEmpty ? tEs : tEn, tEs.isEmpty ? tEn : tEs),
    Doble(dEn.isEmpty ? dEs : dEn, dEs.isEmpty ? dEn : dEs),
    cEn.isEmpty ? cEs : cEn,
    cEs.isEmpty ? cEn : cEs,
  );
}

Future<List<Object?>?> _leer(String archivo, String clave) async {
  try {
    // el número al final evita que el navegador muestre una copia vieja
    final url = Uri.base.resolve(
      '$archivo?v=${DateTime.now().millisecondsSinceEpoch}',
    );
    final res = await http.get(url);
    if (res.statusCode != 200) return null;
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    final filas = data is List ? data : (data is Map ? data[clave] : null);
    return filas is List ? filas : null;
  } catch (_) {
    return null; // se queda el respaldo
  }
}

/// Pide los dos archivos a la vez y reemplaza el respaldo con lo
/// que pase la revisión.
Future<void> cargarDatos() async {
  final r = await Future.wait([
    _leer('datos/galeria.json', 'fotos'),
    _leer('datos/antes-despues.json', 'proyectos'),
  ]);

  final limpias =
      r[0]?.map(_foto).whereType<FotoGaleria>().toList() ?? const [];
  if (limpias.isNotEmpty) galeria.value = limpias;

  final validos =
      r[1]?.map(_proyecto).whereType<Proyecto>().toList() ?? const [];
  if (validos.isNotEmpty) proyectos.value = validos;
}
