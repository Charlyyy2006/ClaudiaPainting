// ══════════════════════════════════════════════════════════
//  Nosotros, preguntas, contacto y pie de página
// ══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../tema.dart';
import '../textos.dart';
import '../widgets.dart';
import 'inicio.dart';

class Nosotros extends StatelessWidget {
  const Nosotros({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final cita = Container(
      padding: EdgeInsets.all(m.movil ? 28 : 44),
      color: C.fondo2,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(width: 48, child: LineaPincel(alto: 4)),
        const SizedBox(height: 28),
        Text('“${tx('quote')}”', style: titulo(m.movil ? 28 : 36, estilo: FontStyle.italic, peso: FontWeight.w400)),
        const SizedBox(height: 22),
        Text('CLAUDIA PAINTING LLC', style: etiqueta()),
      ]),
    );

    return Seccion(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Encabezado(numero: '06', eyebrow: tx('ab_eyebrow'), titulo: tx('ab_title')),
        SizedBox(height: m.movil ? 32 : 56),
        if (m.escritorio)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(width: 280),
            Expanded(child: Text(tx('ab_body'), style: texto(17))),
            const SizedBox(width: 56),
            Expanded(child: cita),
          ])
        else ...[
          Text(tx('ab_body'), style: texto(16)),
          const SizedBox(height: 36),
          cita,
        ],
      ]),
    );
  }
}

class Preguntas extends StatelessWidget {
  const Preguntas({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final lista = Column(children: [
      for (var i = 1; i <= 6; i++) _Pregunta(pregunta: tx('q$i'), respuesta: tx('a$i')),
      Container(height: 1, color: C.linea),
    ]);
    return Seccion(
      color: C.blanco,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Encabezado(numero: '07', eyebrow: tx('faq_eyebrow'), titulo: tx('faq_title')),
        SizedBox(height: m.movil ? 32 : 56),
        if (m.escritorio)
          Row(children: [const SizedBox(width: 280), Expanded(child: lista)])
        else
          lista,
      ]),
    );
  }
}

class _Pregunta extends StatefulWidget {
  final String pregunta, respuesta;
  const _Pregunta({required this.pregunta, required this.respuesta});

  @override
  State<_Pregunta> createState() => _PreguntaState();
}

/// Al abrir: la respuesta se despliega hacia abajo y aparece
/// desvaneciéndose, la pregunta se pinta de verde y el "+" gira
/// hasta volverse una "×". Al cerrar, lo mismo al revés.
class _PreguntaState extends State<_Pregunta> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
    reverseDuration: const Duration(milliseconds: 320),
  );
  late final _despliegue = CurvedAnimation(parent: _anim, curve: Curves.easeInOutCubic);
  late final _aparece = CurvedAnimation(
    parent: _anim,
    curve: const Interval(.25, 1, curve: Curves.easeOut), // el texto entra cuando ya hay espacio
    reverseCurve: const Interval(0, .6, curve: Curves.easeIn),
  );
  bool _sobre = false;

  bool get _abierta => _anim.status == AnimationStatus.forward || _anim.status == AnimationStatus.completed;

  void _alternar() => setState(() => _abierta ? _anim.reverse() : _anim.forward());

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resaltada = _abierta || _sobre;
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.linea))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Semantics(
          button: true,
          expanded: _abierta,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _sobre = true),
            onExit: (_) => setState(() => _sobre = false),
            child: GestureDetector(
              onTap: _alternar,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Row(children: [
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: texto(17, color: resaltada ? C.acento : C.tinta, peso: FontWeight.w500, alto: 1.4),
                      child: Text(widget.pregunta),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // círculo que se rellena al abrir, con el + girando
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _abierta ? C.acento : Colors.transparent,
                      border: Border.all(color: resaltada ? C.acento : C.linea),
                    ),
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: .125).animate(_despliegue),
                      child: Icon(Icons.add, size: 20, color: _abierta ? Colors.white : C.tinta),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _despliegue,
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: _aparece,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, -.15), end: Offset.zero).animate(_aparece),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 26, right: 52),
                child: Text(widget.respuesta, style: texto(16)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class Contacto extends StatelessWidget {
  const Contacto({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.m;

    Widget dato(String titulo_, Widget contenido) => Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.linea))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo_.toUpperCase(), style: etiqueta()),
            const SizedBox(height: 10),
            contenido,
          ]),
        );

    Widget telefono(String numero, String wa) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 16, runSpacing: 4, children: [
            Text(numero, style: texto(18, color: C.tinta, peso: FontWeight.w600, alto: 1.3)),
            TextoEnlace(tx('tel_wa'), estilo: texto(14.5, color: C.acento, peso: FontWeight.w600), enlace: enlaceWhatsApp(wa)),
            TextoEnlace(tx('tel_call'), estilo: texto(14.5, color: C.tinta, peso: FontWeight.w600), enlace: Uri.parse('tel:+$wa')),
          ]),
        );

    final info = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      dato(tx('ct_phone'), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tx('ct_both'), style: texto(14)),
        const SizedBox(height: 6),
        telefono(telefono1, wa1),
        telefono(telefono2, wa2),
      ])),
      dato(tx('ct_hours'), Text(tx('ct_hours_v'), style: texto(16, color: C.tinta))),
      dato(tx('ct_lang'), Text(tx('ct_lang_v'), style: texto(16, color: C.tinta))),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: Boton(tx('hero_cta1'), tipo: TipoBoton.whatsapp, icono: Icons.chat_rounded, enlace: enlaceWhatsApp(), ancho: m.movil),
      ),
    ]);

    return Seccion(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Encabezado(numero: '08', eyebrow: tx('ct_eyebrow'), titulo: tx('ct_title'), entrada: tx('ct_lede')),
        SizedBox(height: m.movil ? 40 : 64),
        if (m.escritorio)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 5, child: info),
            const SizedBox(width: 64),
            const Expanded(flex: 6, child: _Formulario()),
          ])
        else ...[
          info,
          const SizedBox(height: 48),
          const _Formulario(),
        ],
      ]),
    );
  }
}

// ── Formulario (se envía por Formspree, igual que antes) ────

class _Formulario extends StatefulWidget {
  const _Formulario();

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  static final _destino = Uri.parse('https://formspree.io/f/mqevavbg');

  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _mensaje = TextEditingController();
  String? _servicio;
  bool _enviando = false;
  String? _aviso;
  bool _ok = false;

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _telefono, _correo, _mensaje]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_nombre.text.trim().isEmpty || _telefono.text.trim().isEmpty) {
      setState(() { _aviso = 'fm_req'; _ok = false; });
      return;
    }
    setState(() { _enviando = true; _aviso = null; });
    try {
      final res = await http.post(_destino, headers: {'Accept': 'application/json'}, body: {
        'first_name': _nombre.text.trim(),
        'last_name': _apellido.text.trim(),
        'phone': _telefono.text.trim(),
        'email': _correo.text.trim(),
        'service': _servicio == null ? '' : tx(_servicio!),
        'message': _mensaje.text.trim(),
        'page_language': idioma.value,
      });
      if (res.statusCode < 200 || res.statusCode >= 300) throw Exception('respuesta ${res.statusCode}');
      for (final c in [_nombre, _apellido, _telefono, _correo, _mensaje]) {
        c.clear();
      }
      setState(() { _servicio = null; _aviso = 'fm_ok'; _ok = true; });
    } catch (_) {
      setState(() { _aviso = 'fm_err'; _ok = false; });
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  InputDecoration _deco(String etiqueta_, {String? pista}) => InputDecoration(
        labelText: etiqueta_,
        hintText: pista,
        labelStyle: texto(14.5),
        floatingLabelStyle: texto(13, color: C.acento, peso: FontWeight.w600),
        hintStyle: texto(14.5, color: C.grisClaro),
        filled: true,
        fillColor: C.blanco,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: C.linea)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: C.acento, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final estilo = texto(15.5, color: C.tinta, alto: 1.4);
    const sep = SizedBox(height: 14, width: 14);

    Widget campo(TextEditingController c, String clave, {TextInputType? tipo, List<String>? auto, int lineas = 1, String? pista}) =>
        TextField(
          controller: c,
          keyboardType: tipo,
          autofillHints: auto,
          maxLines: lineas,
          minLines: lineas,
          style: estilo,
          textInputAction: lineas > 1 ? TextInputAction.newline : TextInputAction.next,
          decoration: _deco(tx(clave), pista: pista),
        );

    final nombre = campo(_nombre, 'fm_fn', auto: const [AutofillHints.givenName]);
    final apellido = campo(_apellido, 'fm_ln', auto: const [AutofillHints.familyName]);

    return AutofillGroup(
      child: Container(
        padding: EdgeInsets.all(m.movil ? 20 : 36),
        color: C.fondo2,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(tx('fm_title'), style: titulo(m.movil ? 24 : 28)),
          const SizedBox(height: 24),
          if (m.movil) ...[nombre, sep, apellido] else Row(children: [Expanded(child: nombre), sep, Expanded(child: apellido)]),
          sep,
          campo(_telefono, 'fm_ph', tipo: TextInputType.phone, auto: const [AutofillHints.telephoneNumber]),
          sep,
          campo(_correo, 'fm_em', tipo: TextInputType.emailAddress, auto: const [AutofillHints.email]),
          sep,
          DropdownButtonFormField<String>(
            initialValue: _servicio,
            key: ValueKey('servicio-${idioma.value}-$_servicio'),
            decoration: _deco(tx('fm_sv')),
            style: estilo,
            isExpanded: true,
            dropdownColor: C.blanco,
            items: [
              for (final k in ['fm_sv1', 'fm_sv2', 'fm_sv3', 'fm_sv4'])
                DropdownMenuItem(value: k, child: Text(tx(k))),
            ],
            onChanged: (v) => setState(() => _servicio = v),
          ),
          sep,
          campo(_mensaje, 'fm_ms', lineas: 4, pista: tx('fm_ms_ph')),
          const SizedBox(height: 20),
          Boton(_enviando ? tx('fm_sending') : tx('fm_send'), alTocar: _enviando ? null : _enviar, ancho: true),
          if (_aviso != null) ...[
            const SizedBox(height: 14),
            Semantics(
              liveRegion: true,
              child: Text(tx(_aviso!),
                  style: texto(14.5, color: _ok ? C.acento : const Color(0xFFB4442F), peso: FontWeight.w600, alto: 1.4)),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Pie de página ───────────────────────────────────────────

class Pie extends StatelessWidget {
  final void Function(String id) irA;
  const Pie({super.key, required this.irA});

  @override
  Widget build(BuildContext context) {
    final m = context.m;
    final enlaceEstilo = texto(14.5, color: Colors.white60, alto: 1.3);

    Widget columna(String titulo_, List<Widget> hijos) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo_.toUpperCase(), style: etiqueta(color: Colors.white)),
          const SizedBox(height: 14),
          ...hijos,
        ]);

    final marca = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Image.asset('assets/logo.png', width: 180, height: 180 * 432 / 760, semanticLabel: 'Claudia Painting LLC'),
      const SizedBox(height: 18),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Text(tx('f_about'), style: texto(14.5, color: Colors.white54)),
      ),
    ]);

    final explorar = columna(tx('f_explore'), [
      for (final id in menuSecciones.take(6))
        TextoEnlace(nombreSeccion(id), estilo: enlaceEstilo, alTocar: () => irA(id)),
    ]);

    final contacto = columna(tx('ct_eyebrow'), [
      TextoEnlace('WhatsApp $telefono1', estilo: enlaceEstilo, enlace: enlaceWhatsApp(wa1)),
      TextoEnlace('WhatsApp $telefono2', estilo: enlaceEstilo, enlace: enlaceWhatsApp(wa2)),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(tx('ct_hours_v'), style: enlaceEstilo),
      ),
    ]);

    return Container(
      color: C.oscuro,
      child: Column(children: [
        const LineaPincel(),
        Seccion(
          color: Colors.transparent,
          arriba: m.movil ? 56 : 80,
          abajo: 28,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (m.escritorio)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 2, child: marca),
                Expanded(child: explorar),
                Expanded(child: contacto),
              ])
            else ...[
              marca,
              const SizedBox(height: 40),
              Wrap(spacing: 48, runSpacing: 36, children: [explorar, contacto]),
            ],
            const SizedBox(height: 48),
            Container(height: 1, color: Colors.white12),
            const SizedBox(height: 22),
            Wrap(alignment: WrapAlignment.spaceBetween, spacing: 20, runSpacing: 8, children: [
              Text('© ${DateTime.now().year} Claudia Painting LLC · ${tx('f_rights')}',
                  style: texto(13, color: Colors.white38)),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('We Paint. You Love. We Care.', style: titulo(14.5, color: Colors.white54, estilo: FontStyle.italic)),
                const SizedBox(width: 8),
                // ícono y no el carácter ♥: así no se descarga una fuente de emojis entera
                const Icon(Icons.favorite, size: 13, color: Color(0xFF7FB98C)),
              ]),
            ]),
          ]),
        ),
      ]),
    );
  }
}
