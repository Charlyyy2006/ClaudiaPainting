// ══════════════════════════════════════════════════════════
//  Textos de la página en inglés y español
//
//  Para cambiar un texto, búsquelo aquí en los dos idiomas.
//  Las fotos y sus títulos NO están aquí: se administran desde
//  el panel (claudiapainting.com/admin).
// ══════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idioma actual: 'en' o 'es'. Al cambiarlo se redibuja la página.
final idioma = ValueNotifier<String>('en');

bool get enEspanol => idioma.value == 'es';

/// Avisa a toda la página cuando cambia el idioma. Sin esto, al tocar
/// EN / ES el idioma cambiaba por dentro pero la pantalla no se
/// volvía a dibujar y se quedaba en el idioma con el que abrió.
class IdiomaScope extends InheritedNotifier<ValueNotifier<String>> {
  IdiomaScope({super.key, required super.child}) : super(notifier: idioma);
}

extension IdiomaCtx on BuildContext {
  /// Hace que el widget que lo llama se redibuje al cambiar de idioma.
  void escucharIdioma() => dependOnInheritedWidgetOfExactType<IdiomaScope>();
}

/// Devuelve el texto de [clave] en el idioma actual.
String tx(String clave) => (enEspanol ? _es[clave] : null) ?? _en[clave] ?? clave;

/// Elige el idioma al abrir: el que la persona escogió la última
/// vez, o si no, el del teléfono / navegador.
Future<void> cargarIdioma() async {
  String? guardado;
  try {
    guardado = (await SharedPreferences.getInstance()).getString('cp-lang');
  } catch (_) {}
  final delSistema = PlatformDispatcher.instance.locale.languageCode;
  cambiarIdioma(guardado ?? (delSistema == 'es' ? 'es' : 'en'), guardar: false);
}

void cambiarIdioma(String nuevo, {bool guardar = true}) {
  idioma.value = nuevo == 'es' ? 'es' : 'en';
  SystemChrome.setApplicationSwitcherDescription(
    ApplicationSwitcherDescription(label: tx('doc_title'), primaryColor: 0xFF0F1115),
  );
  if (guardar) {
    SharedPreferences.getInstance()
        .then((p) => p.setString('cp-lang', idioma.value))
        .catchError((_) => false);
  }
}

const telefono1 = '+1 (504) 339-2155';
const telefono2 = '+1 (629) 207-2652';
const wa1 = '15043392155';
const wa2 = '16292072652';

/// Enlace de WhatsApp con un mensaje ya escrito en el idioma actual.
Uri enlaceWhatsApp([String numero = wa1]) => Uri.https('wa.me', '/$numero', {
      'text': enEspanol
          ? '¡Hola Claudia Painting! Me gustaría una cotización gratis.'
          : "Hi Claudia Painting! I'd like a free estimate.",
    });

const _en = <String, String>{
  'doc_title': 'Claudia Painting LLC — Residential Interior & Exterior Painting',
  'nav_services': 'Services', 'nav_process': 'Process', 'nav_work': 'Gallery',
  'nav_ba': 'Before & After', 'nav_about': 'About', 'nav_faq': 'FAQ', 'nav_contact': 'Contact',
  'nav_quote': 'Free estimate',

  'hero_tag': 'Free estimates · Se habla español',
  'hero_h1a': 'Your home deserves',
  'hero_h1b': 'a fresh start.',
  'hero_sub': 'Residential painting done the way it should be — walls prepped, floors covered, price agreed before the first brushstroke.',
  'hero_cta1': 'Message us on WhatsApp',
  'hero_cta2': 'See our work',
  'trust1': 'Price agreed up front', 'trust2': 'We clean up after ourselves', 'trust3': 'Fast replies on WhatsApp',

  'why_eyebrow': 'Why us', 'why_title': 'Painting is the easy part.',
  'why_lede': "Showing up, protecting your home and sticking to the price — that's what people remember.",
  'p1_t': 'Clean, careful work', 'p1_b': 'We protect your furniture, floors and trim before we touch a wall. When we leave, your home is clean — and painted.',
  'p2_t': 'Inside and outside', 'p2_b': 'A single bedroom or the whole exterior — one crew handles both.',
  'p3_t': 'Always reachable', 'p3_b': 'Message us on WhatsApp any time. No waiting on hold.',
  'p4_t': 'No surprises', 'p4_b': 'What we quote is what you pay — nothing added after the fact.',

  'svc_eyebrow': 'Services', 'svc_title': 'Residential painting, inside and out.',
  'svc1_t': 'Interior', 'svc1_b': 'Bedrooms, living rooms, kitchens, hallways. We prep the walls, protect your belongings and leave a smooth, even finish.',
  'svc1_l1': 'Walls, ceilings, trim and doors', 'svc1_l2': 'Patching and surface prep', 'svc1_l3': 'Furniture and floors covered every day',
  'svc2_t': 'Exterior', 'svc2_b': 'The outside of your home is the first thing people see. Full repaints or touch-ups, houses of any size.',
  'svc2_l1': 'Siding, soffits, porches and columns', 'svc2_l2': 'Windows, shutters, doors and railings', 'svc2_l3': 'Plants, walkways and driveways masked off',
  'both': 'Need both? Doing interior and exterior together usually saves you time — and a bit of money.',

  'proc_eyebrow': 'Process', 'proc_title': 'Four steps, no guesswork.',
  's1_t': 'You reach out', 's1_b': 'Send a WhatsApp message or fill out the form. Photos help, but aren\'t required.',
  's2_t': 'Free estimate', 's2_b': 'We look at the space, talk colors and finishes, and give you a clear price.',
  's3_t': 'We paint', 's3_b': 'We cover everything, prep the surfaces and work on the days we agreed.',
  's4_t': 'You walk through', 's4_b': 'Room by room, together. Anything you don\'t like, we fix before we pack up.',

  'gal_eyebrow': 'Gallery', 'gal_title': 'Real homes we painted.',
  'gal_lede': 'Tap any photo to see it full size.',
  'gal_more': 'More projects added as we finish them.',
  'cat_all': 'All', 'cat_interior': 'Interiors', 'cat_exterior': 'Exteriors', 'cat_proceso': 'Prep & process',

  'ba_eyebrow': 'Before & after', 'ba_title': 'Same room. New life.',
  'ba_lede': 'Drag the handle to compare before and after.',
  'tag_before': 'Before', 'tag_after': 'After',

  'ab_eyebrow': 'About', 'ab_title': 'We take your home seriously.',
  'ab_body': "Claudia Painting LLC started because we kept hearing the same complaints — painters who didn't show up, left a mess, or charged more than agreed. So we built the opposite: we show up, we do the work right, and we leave your home better than we found it.",
  'quote': 'We Paint. You Love. We Care.',

  'faq_eyebrow': 'FAQ', 'faq_title': 'Good to know.',
  'q1': 'Is the estimate really free?', 'a1': "Yes. We come look at the space, talk about what you want, and give you a price — with no obligation to hire us.",
  'q2': 'Do I need to move my furniture?', 'a2': "No. We move what needs moving, cover everything, and put it back when we're finished.",
  'q3': 'Do you help pick the colors?', 'a3': "Happily. Tell us the feeling you're going for and we'll suggest colors and finishes that work for that room and that light.",
  'q4': 'Who buys the paint?', 'a4': "Either way works. We can supply everything, or paint with what you've already bought.",
  'q5': 'How long does a job take?', 'a5': 'A single room is usually a day or two. A full interior or exterior depends on prep work and weather — we give you a realistic window with the estimate.',
  'q6': '¿Hablan español?', 'a6': 'Sí, por supuesto. Escríbanos por WhatsApp o llene el formulario en español.',

  'ct_eyebrow': 'Contact', 'ct_title': "Let's talk about your project.",
  'ct_lede': "Tell us what you need and we'll get back to you as soon as we can.",
  'ct_phone': 'WhatsApp / Phone', 'ct_both': 'Both numbers take WhatsApp messages and calls.',
  'tel_wa': 'WhatsApp', 'tel_call': 'Call',
  'ct_hours': 'Hours', 'ct_hours_v': 'Monday – Saturday · 8:00 AM – 6:00 PM',
  'ct_lang': 'Languages', 'ct_lang_v': 'English & Español',

  'fm_title': 'Request a free estimate',
  'fm_fn': 'First name', 'fm_ln': 'Last name', 'fm_ph': 'Phone number', 'fm_em': 'Email (optional)',
  'fm_sv': 'What do you need?', 'fm_sv1': 'Interior painting', 'fm_sv2': 'Exterior painting',
  'fm_sv3': 'Interior & exterior', 'fm_sv4': 'Not sure yet',
  'fm_ms': 'Tell us about your project',
  'fm_ms_ph': 'What rooms or areas? Any colors in mind?',
  'fm_send': 'Send message', 'fm_sending': 'Sending…',
  'fm_ok': "Message sent! We'll get back to you soon.",
  'fm_err': "Couldn't send that. Try again, or message us on WhatsApp.",
  'fm_req': 'Please add your name and phone number.',

  'f_about': 'Residential interior and exterior painting. Clean, careful work and honest prices.',
  'f_rights': 'All rights reserved', 'f_explore': 'Explore',
  'lb_of': 'of', 'close': 'Close', 'prev': 'Previous photo', 'next': 'Next photo', 'menu': 'Menu',
};

const _es = <String, String>{
  'doc_title': 'Claudia Painting LLC — Pintura residencial interior y exterior',
  'nav_services': 'Servicios', 'nav_process': 'Proceso', 'nav_work': 'Galería',
  'nav_ba': 'Antes y después', 'nav_about': 'Nosotros', 'nav_faq': 'Preguntas', 'nav_contact': 'Contacto',
  'nav_quote': 'Cotización gratis',

  'hero_tag': 'Cotización gratis · Se habla español',
  'hero_h1a': 'Su casa merece',
  'hero_h1b': 'un nuevo comienzo.',
  'hero_sub': 'Pintura residencial hecha como debe ser: paredes preparadas, pisos cubiertos y el precio acordado antes de la primera brochada.',
  'hero_cta1': 'Escríbanos por WhatsApp',
  'hero_cta2': 'Ver nuestros trabajos',
  'trust1': 'Precio acordado desde el inicio', 'trust2': 'Dejamos todo limpio', 'trust3': 'Respuesta rápida por WhatsApp',

  'why_eyebrow': 'Por qué nosotros', 'why_title': 'Pintar es la parte fácil.',
  'why_lede': 'Llegar puntual, cuidar su casa y respetar el precio: eso es lo que la gente recuerda.',
  'p1_t': 'Trabajo limpio y cuidadoso', 'p1_b': 'Protegemos sus muebles, pisos y molduras antes de tocar una pared. Cuando nos vamos, su casa queda limpia — y pintada.',
  'p2_t': 'Por dentro y por fuera', 'p2_b': 'Una sola habitación o el exterior completo: un mismo equipo hace ambos.',
  'p3_t': 'Siempre disponibles', 'p3_b': 'Escríbanos por WhatsApp cuando quiera. Sin esperas en el teléfono.',
  'p4_t': 'Sin sorpresas', 'p4_b': 'Lo que cotizamos es lo que paga — no agregamos cosas después.',

  'svc_eyebrow': 'Servicios', 'svc_title': 'Pintura residencial, por dentro y por fuera.',
  'svc1_t': 'Interiores', 'svc1_b': 'Recámaras, salas, cocinas, pasillos. Preparamos las paredes, protegemos sus cosas y dejamos un acabado parejo y liso.',
  'svc1_l1': 'Paredes, techos, molduras y puertas', 'svc1_l2': 'Resane y preparación antes de pintar', 'svc1_l3': 'Muebles y pisos cubiertos todos los días',
  'svc2_t': 'Exteriores', 'svc2_b': 'El exterior de su casa es lo primero que la gente ve. Repintado completo o retoques, casas de cualquier tamaño.',
  'svc2_l1': 'Fachada, aleros, porches y columnas', 'svc2_l2': 'Ventanas, persianas, puertas y barandales', 'svc2_l3': 'Plantas, banquetas y cocheras protegidas',
  'both': '¿Necesita ambos? Hacer interior y exterior juntos casi siempre le ahorra tiempo — y algo de dinero.',

  'proc_eyebrow': 'Proceso', 'proc_title': 'Cuatro pasos, sin adivinanzas.',
  's1_t': 'Usted nos escribe', 's1_b': 'Mándenos un WhatsApp o llene el formulario. Las fotos ayudan, pero no son obligatorias.',
  's2_t': 'Cotización gratis', 's2_b': 'Revisamos el espacio, hablamos de colores y acabados, y le damos un precio claro.',
  's3_t': 'Pintamos', 's3_b': 'Cubrimos todo, preparamos las superficies y trabajamos en los días acordados.',
  's4_t': 'Revisamos juntos', 's4_b': 'Cuarto por cuarto. Lo que no le guste, lo corregimos antes de recoger.',

  'gal_eyebrow': 'Galería', 'gal_title': 'Casas reales que pintamos.',
  'gal_lede': 'Toque cualquier foto para verla completa.',
  'gal_more': 'Vamos agregando proyectos conforme los terminamos.',
  'cat_all': 'Todos', 'cat_interior': 'Interiores', 'cat_exterior': 'Exteriores', 'cat_proceso': 'Proceso',

  'ba_eyebrow': 'Antes y después', 'ba_title': 'El mismo cuarto. Otra vida.',
  'ba_lede': 'Deslice la barra para comparar el antes y el después.',
  'tag_before': 'Antes', 'tag_after': 'Después',

  'ab_eyebrow': 'Nosotros', 'ab_title': 'Su casa nos importa de verdad.',
  'ab_body': 'Claudia Painting LLC nació porque escuchábamos siempre las mismas quejas: pintores que no llegaban, que dejaban un desastre o que cobraban más de lo acordado. Así que hicimos lo contrario: llegamos, hacemos el trabajo bien y dejamos su casa mejor de como la encontramos.',
  'quote': 'Pintamos. Usted ama. Nos importa.',

  'faq_eyebrow': 'Preguntas', 'faq_title': 'Bueno saberlo.',
  'q1': '¿La cotización realmente es gratis?', 'a1': 'Sí. Vamos a ver el espacio, hablamos de lo que quiere y le damos un precio — sin compromiso de contratarnos.',
  'q2': '¿Tengo que mover mis muebles?', 'a2': 'No. Nosotros movemos lo necesario, cubrimos todo y lo regresamos a su lugar al terminar.',
  'q3': '¿Nos ayudan a escoger los colores?', 'a3': 'Con gusto. Díganos qué ambiente busca y le sugerimos colores y acabados que funcionen para ese cuarto y esa luz.',
  'q4': '¿Quién compra la pintura?', 'a4': 'Como usted prefiera. Podemos poner todo el material, o pintar con lo que usted ya compró.',
  'q5': '¿Cuánto tarda el trabajo?', 'a5': 'Un cuarto normalmente toma uno o dos días. Un interior o exterior completo depende de la preparación y del clima — le damos un tiempo realista con la cotización.',
  'q6': '¿Hablan español?', 'a6': 'Sí, por supuesto. Escríbanos por WhatsApp o llene el formulario en español.',

  'ct_eyebrow': 'Contacto', 'ct_title': 'Hablemos de su proyecto.',
  'ct_lede': 'Cuéntenos qué necesita y le respondemos lo antes posible.',
  'ct_phone': 'WhatsApp / Teléfono', 'ct_both': 'A los dos números puede escribirles por WhatsApp o llamarles.',
  'tel_wa': 'WhatsApp', 'tel_call': 'Llamar',
  'ct_hours': 'Horario', 'ct_hours_v': 'Lunes a sábado · 8:00 AM – 6:00 PM',
  'ct_lang': 'Idiomas', 'ct_lang_v': 'Español e inglés',

  'fm_title': 'Solicite su cotización gratis',
  'fm_fn': 'Nombre', 'fm_ln': 'Apellido', 'fm_ph': 'Teléfono', 'fm_em': 'Correo (opcional)',
  'fm_sv': '¿Qué necesita?', 'fm_sv1': 'Pintura de interiores', 'fm_sv2': 'Pintura de exteriores',
  'fm_sv3': 'Interior y exterior', 'fm_sv4': 'Todavía no estoy seguro',
  'fm_ms': 'Cuéntenos sobre su proyecto',
  'fm_ms_ph': '¿Qué cuartos o áreas? ¿Algún color en mente?',
  'fm_send': 'Enviar mensaje', 'fm_sending': 'Enviando…',
  'fm_ok': '¡Mensaje enviado! Le respondemos pronto.',
  'fm_err': 'No se pudo enviar. Intente de nuevo o escríbanos por WhatsApp.',
  'fm_req': 'Por favor complete su nombre y su teléfono.',

  'f_about': 'Pintura residencial interior y exterior. Trabajo limpio y cuidadoso, y precios honestos.',
  'f_rights': 'Todos los derechos reservados', 'f_explore': 'Explorar',
  'lb_of': 'de', 'close': 'Cerrar', 'prev': 'Foto anterior', 'next': 'Foto siguiente', 'menu': 'Menú',
};
