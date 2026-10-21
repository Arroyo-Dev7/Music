/// Interruptores de rendimiento. Cámbialos y compara con DevTools en
/// `flutter run --profile` para decidir qué conservar en tu TECNO CM7.

/// Vidrio con desenfoque (BackdropFilter) en la barra inferior.
/// `false` = panel casi opaco sin desenfoque (más barato en GPU).
/// Aunque esté en true, el desenfoque se apaga solo mientras hay scroll.
const bool kGlassBlur = true;

/// Intensidad del desenfoque del vidrio. Antes: 24.
const double kGlassSigma = 14;

/// Miniatura de la lista de canciones (px). 128 se ve nítida a ~56 dp y
/// se decodifica mucho más rápido que 192/256.
const int kListArtworkPx = 128;

/// Fondo de la pantalla de reproducción.
/// `false` (por defecto) = carátula diminuta (64 px) ampliada con filtro
///   bicúbico: parecido al desenfoque, pero sin coste de GPU por fotograma.
/// `true`  = el ImageFiltered con sigma 50 original (caro en gama media).
const bool kRichAmbientBlur = false;
