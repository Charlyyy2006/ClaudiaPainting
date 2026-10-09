# Claudia Painting — sitio en Flutter

La página de claudiapainting.com, hecha en Flutter para web.

## Qué se edita dónde

| Quiero cambiar…                         | Archivo                        |
|-----------------------------------------|--------------------------------|
| Un texto (inglés o español)             | `lib/textos.dart`              |
| Colores, letras, tamaños                | `lib/tema.dart`                |
| Una sección de la página                | `lib/secciones/`               |
| Título y descripción para Google        | `web/index.html`               |
| Fotos de la galería / antes y después   | **El panel**: claudiapainting.com/admin (no hace falta compilar) |

## Probar en la computadora

```powershell
flutter run -d chrome
```

Las fotos se leen de `../fotos` y `../datos`, así que para verlas
igual que en internet conviene probar la versión compilada con un
servidor que sirva la carpeta de Netlify (`publicar/`).

## Publicar un cambio de código

```powershell
.\compilar.ps1
```

Eso deja la página compilada en `../sitio`. Luego se hace commit y
push de `sitio/` (y del código) y Netlify la publica solo.
