# Pokédex Pixel

Aplicación Flutter con estética de videojuego pixelado para explorar Pokémon, consultar sus datos y formar equipos. Consume la [PokéAPI](https://pokeapi.co/api/v2/) y guarda la colección personal y los equipos en el dispositivo.

Práctica 7 de *Programación de dispositivos móviles* — UPIIT, Instituto Politécnico Nacional.

**Autor:** Jassiel Luna Cantu

## Entregables

| Entregable | Enlace |
|---|---|
| APK para Android | [agregar enlace] |
| Video: cómo resolví el infinite scrolling (2 min) | [agregar enlace] |
| Video: demo funcional en móvil y web (máx. 5 min) | [agregar enlace] |

## Funciones

**Obligatorias**

- Pokédex en cuadrícula de dos columnas con imagen, número, nombre y tipos, con infinite scrolling.
- Detalle con sprite, artwork oficial, descripción, categoría, altura, peso, habilidades, estadísticas base con barras de bloques, grito (*cry*) y cadena evolutiva.
- Equipos: crear, renombrar, eliminar y editar; máximo seis integrantes; se conservan al cerrar la app; vista del equipo con resumen de integrantes y tipos.
- Búsqueda por nombre o número, con filtros por tipo y generación que se combinan entre sí.

**Sugeridas (elegidas)**

- **Favoritos:** marca Pokémon con un corazón; se ven en la tarjeta y en una pestaña del perfil.
- **Pokédex personal:** registra *vistos* (automático al abrir el detalle) y *capturados* (botón manual), con barras de progreso sobre el total de especies.

**Extras**

- Navegación inferior entre Pokédex, Buscar, Equipos y Perfil, que conserva la posición del scroll al cambiar de pestaña.
- Transición *hero* entre la tarjeta y el detalle.
- Feedback háptico al agregar a un equipo y al marcar favorito o capturado.
- Salto entre Pokémon desde la cadena evolutiva.

## Estilo visual

Interfaz inspirada en los menús de los juegos clásicos:

- Rojo Pokédex `#DC0A2D` como color de marca y fondo oscuro `#1D1D1D`.
- Un color por tipo, usado como acento en tarjetas, chips, estadísticas y detalle.
- Cero esquinas redondeadas, bordes gruesos y sombras duras sin desenfoque (`blurRadius: 0`). Todo panel y botón parte de un único widget, `CajaPixel`, para que el estilo viva en un solo lugar.
- Tipografías *Press Start 2P* (títulos y etiquetas) y *VT323* (datos y textos largos), vía `google_fonts`.
- Sprites escalados con `FilterQuality.none` para conservar los píxeles nítidos.

## Ejecutar

Desarrollada con Flutter 3.47.7 (canal stable). Requiere un SDK compatible con las versiones declaradas en `pubspec.yaml`.

```bash
flutter pub get
flutter run
```

Para elegir dispositivo:

```bash
flutter devices
flutter run -d <id-del-dispositivo>   # por ejemplo, un celular Android con depuración USB
flutter run -d chrome                 # web
```

En web, el navegador guarda los datos locales por puerto, y `flutter run` elige uno distinto en cada ejecución. Para comprobar que los equipos y favoritos persisten, fija el puerto:

```bash
flutter run -d chrome --web-port=8080
```

### Generar el APK

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

La compilación *release* necesita el permiso de internet declarado en `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>` y antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

En modo *debug* Flutter lo agrega por su cuenta; en *release* no, y sin él la app abre pero no descarga nada.

Probada en un teléfono Android (Android 15) y en Chrome.

## Arquitectura

La aplicación separa presentación, estado y acceso a datos. El flujo va siempre en una sola dirección:

```
Pantalla  →  ViewModel  →  Repositorio  →  Servicio  →  PokéAPI
(dibuja)     (estado y     (de dónde sale   (HTTP)
              lógica)       el dato: red,
                            caché o disco)
```

- `screens` y `widgets` dibujan la interfaz y nunca hablan con la API.
- `viewmodels` guardan el estado de cada pantalla y avisan con `notifyListeners()`.
- `repositories` deciden si un dato viene de la red, de la caché en memoria o del almacenamiento local.
- `services` es la única capa que conoce HTTP.
- **Provider** inyecta los repositorios y viewmodels. `context.watch` suscribe una pantalla a los cambios y `context.read` solo da una orden sin redibujar.

Se eligió MVVM con `ChangeNotifier` por ser el patrón más directo que cumple la separación UI / lógica / datos que pide la práctica, sin la ceremonia adicional de BLoC o Redux.

### Organización

```
lib/
├── models/         Pokémon (resumen y detalle), equipo, paso de evolución
├── services/       comunicación HTTP con la PokéAPI
├── repositories/   PokeAPI + caché, colección y equipos (persistencia)
├── viewmodels/     paginación, detalle, búsqueda, colección y equipos
├── screens/        pantallas completas
├── widgets/        componentes reutilizables (CajaPixel, TarjetaPokemon, ...)
└── theme/          colores por tipo y tema de la aplicación
```

### Estados de pantalla

Cada pantalla que depende de datos maneja explícitamente sus estados:

| Pantalla | Cargando | Éxito | Vacío | Error |
|---|---|---|---|---|
| Pokédex | indicador central | cuadrícula | — | botón de reintentar; si falla una página, la lista se conserva y el botón aparece al final |
| Detalle | indicador (la cabecera aparece al instante) | pestañas | evolución: "NO EVOLUCIONA" | botón de reintentar; la evolución tiene el suyo |
| Búsqueda | indicador | resultados | "SIN RESULTADOS" | botón de reintentar |
| Equipos | — | lista de equipos | "NO TIENES EQUIPOS" | — |
| Perfil | indicador | progreso y listas | cada pestaña tiene su mensaje | botón de reintentar |

## Infinite scrolling sin trabar la app

La PokéAPI entrega, en el listado, solo el nombre y la URL de cada Pokémon: ni imagen ni tipos. Y el detalle completo de un Pokémon es muy pesado (el arreglo de movimientos y los sprites de decenas de juegos ocupan casi todo el JSON). Pedir 20 detalles por página para dibujar 20 tarjetas habría sido lento y excesivo.

### Solución

1. **Imagen sin pedir detalle.** El número del Pokémon está al final de su URL (`.../pokemon/25/`) y las imágenes siguen un patrón predecible en el repositorio de sprites, así que la URL del sprite se arma directamente con el número.
2. **Tipos con un índice.** El endpoint `/type/<nombre>` lista todos los Pokémon de ese tipo. Con **18 peticiones en paralelo** (`Future.wait`), una sola vez por sesión, se construye un mapa `id → tipos` de todo el catálogo. El orden de los tipos (primario y secundario) se respeta con el campo `slot`. Con ese índice cada tarjeta se completa sin ninguna petición adicional.
3. **Paginación con `limit` y `offset`.** Se piden páginas de 20 nombres. El `offset` es la cantidad de Pokémon ya cargados, y esa cantidad solo crece cuando una página **llegó completa**; por eso, si una petición falla, el reintento pide exactamente la misma página sin duplicar ni saltarse ninguno.
4. **Precarga anticipada.** Al pasar el 80 % del recorrido de la lista se pide la siguiente página, antes de que el usuario llegue al final.
5. **Sin peticiones duplicadas.** Un indicador de carga (`cargandoMas`) hace que un scroll rápido no dispare la misma página varias veces. Lo mismo ocurre con el índice de tipos: el repositorio guarda el `Future` en curso, de modo que dos pantallas que lo necesitan a la vez comparten una sola petición.
6. **Lista virtualizada.** `CustomScrollView` con `SliverChildBuilderDelegate` crea únicamente las tarjetas visibles.
7. **Imágenes y respuestas en caché.** `cached_network_image` reutiliza los sprites descargados; los detalles y cadenas evolutivas consultados se guardan en memoria durante la sesión.
8. **Imágenes proporcionadas al contexto.** La lista usa el sprite pequeño; el artwork oficial, más pesado, solo se descarga en el detalle, con indicador mientras carga.
9. **Errores sin perder lo cargado.** Si falla la red al paginar, las tarjetas ya mostradas permanecen y aparece un botón de reintentar al final de la lista.

### Cobertura de las pistas de la práctica

| Pista | Cómo se resolvió |
|---|---|
| 1. No cargar todo de golpe | Páginas de 20 con `limit` y `offset` |
| 2. Peticiones en paralelo | `Future.wait` para el índice de tipos y para el detalle (Pokémon + especie) |
| 3. URLs predecibles de sprites | La tarjeta no pide el detalle |
| 4. Precarga anticipada | Disparo al 80 % del recorrido |
| 5. Evitar peticiones duplicadas | Indicador `cargandoMas` y `Future` compartido en el repositorio |
| 6. Virtualizar la lista | Delegados constructores perezosos |
| 7. Cachear imágenes y respuestas | `cached_network_image` y cachés en memoria en el repositorio |
| 8. Imágenes optimizadas | Sprite chico en lista, artwork grande solo en detalle |
| 9. Manejo de errores | Reintento al final de la lista sin perder lo cargado |
| 10. Hilo principal libre | Parcial: los modelos solo extraen los campos necesarios del JSON y no hay procesamiento pesado en la interfaz. No se usaron isolates propios (ver *Limitaciones*) |

### Otras ideas consideradas

- **Pedir el detalle completo de cada tarjeta en paralelo.** Resuelve los tipos, pero descarga el JSON pesado 20 veces por página. Se descartó a favor del índice de tipos.
- **Paginación por cursor frente a `offset`.** La propia respuesta de la API incluye un campo `next` con la URL de la página siguiente, que equivale a un cursor. Se optó por `offset` porque es explícito, fácil de razonar y compatible con reintentos idempotentes.
- **Listado base completo en memoria.** Una sola petición (`limit=2000`) trae los ~1300 nombres y sirve para la búsqueda instantánea. La pantalla de búsqueda trabaja sobre él, sin peticiones por cada tecla.
- **Debounce en la búsqueda.** El filtrado espera 300 ms de pausa al escribir, para no filtrar con cada tecla.

## Búsqueda y filtros

La búsqueda se hace en memoria sobre el catálogo completo (formas alternativas excluidas: solo ids menores a 10000).

- Un número (`25`, `#025`) busca ese número exacto; un texto busca los nombres que lo contienen.
- Los filtros de tipo y generación son de selección única (tocar el activo lo quita) y se combinan entre sí y con el texto.
- La generación de cada Pokémon se obtiene de `/generation`: una petición al listado y otra por generación, en paralelo, y se construye un índice `id → generación`.

## Equipos y persistencia

**Modelo de datos del equipo.** Un equipo guarda `id`, `nombre` y la lista de **ids** de sus integrantes, no los Pokémon completos. Es pequeño, nunca se desactualiza y los datos se reconstruyen desde el catálogo cuando hacen falta. El mismo criterio se aplica a favoritos, vistos y capturados.

**Reglas.** Máximo seis integrantes y sin repetidos. Agregar devuelve un resultado explícito (`ok`, `lleno`, `repetido`, `noExiste`) y la interfaz solo lo traduce a un mensaje, de modo que las reglas viven en un único lugar.

**Almacenamiento.**

| Dato | Formato en `SharedPreferences` |
|---|---|
| Equipos | un único JSON con la lista de equipos |
| Favoritos, vistos, capturados | listas de ids como texto |

Se usó `SharedPreferences` (clave-valor) por funcionar tanto en móvil como en web, a diferencia de SQLite, que en web requiere configuración adicional. Si los datos guardados estuvieran dañados, la lectura de equipos devuelve una lista vacía en lugar de cerrar la app.

Los modelos son inmutables y "modificar" un equipo crea una copia (`copiarCon`), para que ninguna parte de la app vea un objeto a medio cambiar.

## Detalles de rendimiento e interfaz

- `context.select` en las tarjetas: al marcar un favorito solo se redibuja la tarjeta afectada, no todas las del catálogo.
- `ValueKey` por Pokémon en los resultados de búsqueda, para que Flutter asocie cada tarjeta a su Pokémon aunque cambie de posición al filtrar.
- `IndexedStack` conserva las pestañas vivas y `HeroMode` desactiva las animaciones *hero* de las ocultas, evitando etiquetas duplicadas.
- Los ViewModels y pantallas liberan lo que crean: temporizador del debounce, controladores de texto y reproductor de audio. También evitan notificar después de destruirse si el usuario sale antes de que llegue una respuesta.
- La cadena evolutiva se carga después del detalle y con su propio indicador, para que el resto de la pantalla no espere esa petición.

## Tecnologías

| Paquete | Uso |
|---|---|
| `provider` | inyección de dependencias y estado |
| `dio` | peticiones HTTP con tiempos de espera |
| `cached_network_image` | caché de imágenes y marcadores de posición |
| `audioplayers` | reproducción de los gritos |
| `shared_preferences` | persistencia local |
| `google_fonts` | tipografías pixel |

## Limitaciones conocidas

- Los nombres de Pokémon, habilidades y objetos de evolución provienen de la API en inglés; traducirlos exigiría peticiones adicionales por cada uno. Las descripciones y categorías sí se muestran en español cuando existen.
- De cada evolución se muestra solo la primera condición; algunas tienen varias alternativas.
- El índice de tipos y el de generaciones se descargan en cada inicio y viven en memoria: la app necesita conexión al arrancar y no incluye modo offline.
- Las fuentes se descargan por internet la primera vez que se usan.
- En equipos, los Pokémon se agregan con el botón del detalle; no se implementó arrastrar y soltar.
- El audio depende de que el navegador acepte los archivos de grito, por lo que en web puede variar entre navegadores. En Android funciona.
- No se usaron isolates propios para transformar datos; el procesamiento por respuesta es ligero, pero sería una mejora posible para el índice completo.

## Créditos

- Datos: [PokéAPI](https://pokeapi.co/).
- Sprites y gritos: repositorios [PokeAPI/sprites](https://github.com/PokeAPI/sprites) y [PokeAPI/cries](https://github.com/PokeAPI/cries).
- Pokémon y sus nombres son marcas de Nintendo, Game Freak y Creatures Inc. Este proyecto es un trabajo académico sin fines comerciales.
