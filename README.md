# Pokédex Pixel

Aplicación Flutter para explorar Pokémon, consultar sus datos y formar equipos. Consume la [PokéAPI](https://pokeapi.co/api/v2/) y guarda la colección personal y los equipos en el dispositivo.

## Funciones

- Pokédex en cuadrícula con imagen, número, nombre y tipos.
- Detalle con sprite, artwork oficial, descripción, altura, peso, habilidades, estadísticas, grito y cadena evolutiva.
- Búsqueda por nombre o número, con filtros por tipo y generación.
- Equipos con creación, renombrado, eliminación y hasta seis integrantes; se conservan al cerrar la app.
- Favoritos y registro de Pokémon vistos y capturados.
- Navegación inferior entre Pokédex, búsqueda, equipos y perfil.

## Ejecutar

Requiere Flutter y Dart compatibles con las versiones declaradas en `pubspec.yaml`.

```bash
flutter pub get
flutter run
```

Para ejecutar en web, selecciona Chrome como dispositivo en Flutter o usa `flutter run -d chrome`.

## Decisiones técnicas

La aplicación separa presentación, estado y acceso a datos: `screens` y `widgets` dibujan la interfaz, `viewmodels` coordinan sus estados y `repositories` gestionan API, caché en memoria y persistencia local. Provider comparte estos servicios y modelos de vista.

### Carga del catálogo

La PokéAPI devuelve páginas con nombre y URL, mientras que los tipos se consultan por separado. La app pide páginas de 20 Pokémon con `limit` y `offset`, y resuelve el índice de tipos en peticiones concurrentes, sin solicitar el detalle completo de cada Pokémon para dibujar una tarjeta. Los sprites usan URLs predecibles; el artwork oficial se reserva para el detalle.

La lista usa `CustomScrollView` y constructores perezosos para crear solo las tarjetas necesarias. Al llegar aproximadamente al 80 % del contenido disponible, el viewmodel solicita la siguiente página. Un indicador evita peticiones simultáneas, y un error al paginar conserva los resultados existentes y muestra una opción para reintentar. `cached_network_image` reutiliza imágenes descargadas; los detalles y evoluciones consultados también se mantienen en caché durante la sesión.

### Persistencia

Los equipos se guardan como JSON en `SharedPreferences`, incluyendo solo IDs de Pokémon. Favoritos, vistos y capturados se guardan como listas de IDs. Así se evita duplicar en almacenamiento local datos que la API puede volver a proporcionar.

## Organización

- `lib/services`: comunicación HTTP con PokéAPI.
- `lib/repositories`: carga, caché y persistencia.
- `lib/models`: Pokémon, equipos y evolución.
- `lib/viewmodels`: paginación, búsqueda, colección y equipos.
- `lib/screens` y `lib/widgets`: pantallas y componentes reutilizables.
- `lib/theme`: colores por tipo y tema de la aplicación.

## Ideas adicionales incluidas

La app implementa favoritos y una Pokédex personal con progreso de vistos y capturados. También incorpora gritos de Pokémon, filtros por generación y equipos persistentes.
