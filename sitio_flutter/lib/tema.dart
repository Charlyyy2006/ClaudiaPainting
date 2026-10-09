// ══════════════════════════════════════════════════════════
//  Sistema de diseño — minimalista
//  Mucho blanco, una sola tinta y un solo color de acento
//  (el verde del logo). Los colores del arcoíris del logo solo
//  aparecen como una línea fina, para no recargar la página.
// ══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

class C {
  static const fondo = Color(0xFFFAFAF7);
  static const fondo2 = Color(0xFFF2F0EA);
  static const blanco = Color(0xFFFFFFFF);
  static const tinta = Color(0xFF111418);
  static const gris = Color(0xFF5F6670);
  static const grisClaro = Color(0xFF9AA0A8);
  static const linea = Color(0xFFE4E1D9);
  static const oscuro = Color(0xFF0F1115);
  static const acento = Color(0xFF3F7A4D);
  static const acento2 = Color(0xFF2F6039);
  static const wa = Color(0xFF25D366);

  /// los seis colores del logo, en orden
  static const pincel = [
    Color(0xFF2F6FD0), Color(0xFF3C8FA0), Color(0xFF4F8A45),
    Color(0xFFD6A63A), Color(0xFFD2762F), Color(0xFFC1543A),
  ];
}

/// Medidas que cambian según el ancho de la pantalla.
class Medidas {
  final double ancho;
  const Medidas(this.ancho);

  bool get movil => ancho < 720;
  bool get tableta => ancho >= 720 && ancho < 1040;
  bool get escritorio => ancho >= 1040;

  /// margen a los lados del contenido
  double get margen => movil ? 20 : (tableta ? 40 : 56);

  /// espacio vertical entre secciones
  double get seccion => movil ? 72 : (tableta ? 104 : 136);
}

extension MedidasCtx on BuildContext {
  Medidas get m => Medidas(MediaQuery.sizeOf(this).width);
}

// ── Tipografía ──────────────────────────────────────────────
// Fraunces (con serifa) para títulos, Inter para todo lo demás.
// Las dos van dentro del sitio, en assets/fonts.

TextStyle titulo(double size, {Color color = C.tinta, FontStyle? estilo, FontWeight peso = FontWeight.w500}) =>
    TextStyle(
      fontFamily: 'Fraunces', fontSize: size, height: 1.08, letterSpacing: -size * 0.025,
      color: color, fontWeight: peso, fontStyle: estilo,
    );

TextStyle texto(double size, {Color color = C.gris, FontWeight peso = FontWeight.w400, double alto = 1.7}) =>
    TextStyle(fontFamily: 'Inter', fontSize: size, height: alto, color: color, fontWeight: peso);

TextStyle etiqueta({Color color = C.gris}) => TextStyle(
      fontFamily: 'Inter', fontSize: 11.5, letterSpacing: 2.2, fontWeight: FontWeight.w600, color: color,
    );

ThemeData temaApp() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(seedColor: C.acento, surface: C.fondo),
    scaffoldBackgroundColor: C.fondo,
    splashFactory: NoSplash.splashFactory,
    textSelectionTheme: const TextSelectionThemeData(selectionColor: Color(0x403F7A4D)),
  );
}

/// Título grande de cada sección.
TextStyle tituloSeccion(Medidas m, {Color color = C.tinta}) =>
    titulo(m.movil ? 34 : (m.tableta ? 44 : 54), color: color);
