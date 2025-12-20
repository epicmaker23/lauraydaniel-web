import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_plugins/url_strategy.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const _supabaseAnon = String.fromEnvironment('SUPABASE_ANON', defaultValue: '');
bool _supabaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  if (_supabaseUrl.isNotEmpty && _supabaseAnon.isNotEmpty) {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnon);
    _supabaseReady = true;
  }
  runApp(const BodaApp());
}

class BodaApp extends StatelessWidget {
  const BodaApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laura & Daniel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFD4AF37),
        scaffoldBackgroundColor: Colors.black,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFF3B3B3B),
          displayColor: const Color(0xFF3B3B3B),
        ),
      ),
      routes: {
        '/': (_) => const HomePage(),
        '/formulario': (_) => const PreinscriptionPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/formulario' || settings.name == 'formulario') {
          return MaterialPageRoute(builder: (_) => const PreinscriptionPage());
        }
        return null;
      },
      onGenerateInitialRoutes: (String initialRouteName) {
        final path = Uri.base.path;
        if (path == '/formulario' || path == 'formulario' || path == '/formulario/') {
          return [MaterialPageRoute(builder: (_) => const PreinscriptionPage())];
        }
        return [MaterialPageRoute(builder: (_) => const HomePage())];
      },
      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/imagenPrincipal.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.35)),
          const _HomeContent(),
          const _CookieBar(),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        shrinkWrap: true,
        children: [
          const _HeroCard(),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                _InfoCard(
                  icon: Icons.event_available,
                  title: 'Fecha',
                  subtitle: 'Sábado',
                  detail: '25 de Abril\n2026',
                  onTap: () => _mostrarRecordatorios(context),
                ),
                _InfoCard(
                  icon: Icons.church,
                  title: 'Ceremonia',
                  subtitle: 'Convento de San Francisco de El Soto',
                  detail: 'Soto‑Iruz\n12:30h',
                  onTap: () => _abrirMapa('Convento de San Francisco de El Soto, Soto‑Iruz, Cantabria, España'),
                ),
                _InfoCard(
                  icon: Icons.celebration,
                  title: 'Celebración',
                  subtitle: 'Finca La Real Labranza de Villasevil',
                  detail: 'Villasevil\n14:00h',
                  onTap: () => _abrirMapa('Finca La Real Labranza de Villasevil, Villasevil, Cantabria, España'),
                ),
                _InfoCard(
                  icon: Icons.directions_bus,
                  title: 'Transporte',
                  subtitle: 'Servicio de autobús disponible',
                  detail: 'Horarios y paradas',
                  onTap: () => _mostrarTransporte(context),
                ),
                _InfoCard(
                  icon: Icons.hotel,
                  title: 'Alojamiento',
                  subtitle: 'Hoteles recomendados',
                  detail: 'Reserva con antelación',
                  onTap: () => _mostrarAlojamiento(context),
                ),
                _InfoCard(
                  icon: Icons.card_giftcard,
                  title: 'Regalos',
                  subtitle: 'Vuestra presencia es suficiente',
                  detail: 'IBAN disponible',
                  onTap: () => _mostrarRegalos(context),
                ),
                _InfoCard(
                  icon: Icons.local_parking,
                  title: 'Parking',
                  subtitle: 'Aparcamiento disponible',
                  detail: 'En ceremonia y finca',
                  onTap: () => _mostrarParking(context),
                ),
                _InfoCard(
                  icon: Icons.photo_camera,
                  title: 'Subir Fotos',
                  subtitle: 'Álbum colaborativo',
                  detail: 'Comparte tus momentos',
                  onTap: () => _mostrarSubirFotos(context),
                ),
                _InfoCard(
                  icon: Icons.movie,
                  title: 'Fotomatón',
                  subtitle: 'Disponible tras la boda',
                  detail: 'Descarga de fotos',
                  onTap: () => _mostrarFotomaton(context),
                ),
              ];
              final width = constraints.maxWidth.clamp(0, 1200);
              final cross = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);
              final aspect = cross == 3 ? 1.15 : (cross == 2 ? 1.1 : 1.0);
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: aspect,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (_, i) => cards[i],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();
  
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gold, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  child: SizedBox(
                    width: 240,
                    height: 240,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 480,
                        height: 480,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(gold, BlendMode.srcIn),
                          child: Image.asset(
                            'assets/images/logoNuevo2.png',
                            width: 480,
                            height: 480,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) => Text(
                              'L&D',
                              style: GoogleFonts.allura(
                                fontSize: 240,
                                color: gold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                Text(
                  'Laura & Daniel',
                  style: GoogleFonts.allura(
                    fontSize: 48,
                    color: gold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  '25 de Abril de 2026',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const _Countdown(target: '2026-04-25 12:30:00'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Countdown extends StatefulWidget {
  final String target;
  const _Countdown({required this.target});
  
  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining = _calcRemaining());
    });
  }

  Duration _calcRemaining() {
    final target = DateTime.parse(widget.target.replaceFirst(' ', 'T'));
    final now = DateTime.now();
    return target.difference(now).isNegative ? Duration.zero : target.difference(now);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final mins = _remaining.inMinutes % 60;
    final secs = _remaining.inSeconds % 60;
    
    Widget tile(String value, String label) {
      const gold = Color(0xFFD4AF37);
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: gold,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        tile('$days', 'DÍAS'),
        const SizedBox(width: 8),
        tile('$hours', 'HORAS'),
        const SizedBox(width: 8),
        tile('$mins', 'MIN'),
        const SizedBox(width: 8),
        tile('$secs', 'SEG'),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;
  final VoidCallback? onTap;
  
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFD4AF37);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final double padding = (w * 0.08).clamp(12, 16).toDouble();
            final double iconSize = (w * 0.12).clamp(26, 34).toDouble();
            final double titleSize = (w * 0.12).clamp(22, 28).toDouble();
            final double subSize = (w * 0.05).clamp(12, 14).toDouble();
            final double detailSize = (w * 0.055).clamp(12, 14).toDouble();
            final double borderW = (w * 0.008).clamp(1.5, 2.0).toDouble();

            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.28),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: borderW),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(icon, size: iconSize, color: borderColor),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: GoogleFonts.allura(
                          fontSize: titleSize,
                          color: borderColor,
                          shadows: const [Shadow(color: Colors.black54, blurRadius: 2)],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: subSize),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        detail,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: detailSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CookieBar extends StatefulWidget {
  const _CookieBar();
  
  @override
  State<_CookieBar> createState() => _CookieBarState();
}

class _CookieBarState extends State<_CookieBar> {
  bool _visible = true;
  
  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          border: const Border(top: BorderSide(color: Colors.white24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Esta web utiliza cookies técnicas propias imprescindibles para su funcionamiento.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _visible = false),
                child: const Text('Rechazar', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => setState(() => _visible = false),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _abrirMapa(String direccion) async {
  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(direccion)}');
  await launchUrl(url, mode: LaunchMode.externalApplication);
}

void _dialogoSimple(BuildContext context, String titulo, String contenido) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: GoogleFonts.allura(
                  fontSize: 36,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 12),
              Text(contenido),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _mostrarRecordatorios(BuildContext context) {
  _dialogoSimple(
    context,
    'Recordatorios',
    'Se crearán 2 recordatorios: 1 semana antes (18/04/2026 10:00) y 3 horas antes (25/04/2026 09:30).',
  );
}

Widget _BusIcon({double size = 32}) {
  return SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _BusPainter(),
    ),
  );
}

class _BusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.grey.shade400;

    // Cuerpo del autobús (teal/azul claro)
    paint.color = const Color(0xFF4ECDC4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6),
        const Radius.circular(4),
      ),
      paint,
    );

    // Ventanas (azul claro)
    paint.color = const Color(0xFF87CEEB);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.25, size.height * 0.2),
        const Radius.circular(2),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.3, size.width * 0.25, size.height * 0.2),
        const Radius.circular(2),
      ),
      paint,
    );

    // Ruedas (gris)
    paint.color = Colors.grey.shade600;
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.85), size.height * 0.1, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.85), size.height * 0.1, paint);

    // Detalle naranja en el frente
    paint.color = Colors.orange.shade400;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.25, size.width * 0.15, size.height * 0.1),
      paint,
    );

    // Detalle rojo en la parte trasera
    paint.color = Colors.red.shade400;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.75, size.height * 0.25, size.width * 0.15, size.height * 0.1),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _MegaphoneIcon({double size = 20}) {
  return SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _MegaphonePainter(),
    ),
  );
}

class _MegaphonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Mango blanco
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.4, size.width * 0.15, size.height * 0.3),
        const Radius.circular(2),
      ),
      paint,
    );

    // Cuerpo rojo del megáfono
    paint.color = Colors.red.shade600;
    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.3);
    path.lineTo(size.width * 0.9, size.height * 0.1);
    path.lineTo(size.width * 0.9, size.height * 0.9);
    path.lineTo(size.width * 0.25, size.height * 0.7);
    path.close();
    canvas.drawPath(path, paint);

    // Cono blanco exterior
    paint.color = Colors.white;
    final conePath = Path();
    conePath.moveTo(size.width * 0.3, size.height * 0.35);
    conePath.lineTo(size.width * 0.85, size.height * 0.15);
    conePath.lineTo(size.width * 0.85, size.height * 0.85);
    conePath.lineTo(size.width * 0.3, size.height * 0.65);
    conePath.close();
    canvas.drawPath(conePath, paint);

    // Altavoz azul vibrante (interior del cono)
    paint.color = const Color(0xFF1E90FF);
    final speakerPath = Path();
    speakerPath.moveTo(size.width * 0.35, size.height * 0.4);
    speakerPath.lineTo(size.width * 0.8, size.height * 0.2);
    speakerPath.lineTo(size.width * 0.8, size.height * 0.8);
    speakerPath.lineTo(size.width * 0.35, size.height * 0.6);
    speakerPath.close();
    canvas.drawPath(speakerPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _mostrarTransporte(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_bus, color: Colors.blue.shade300, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Transporte',
                      style: GoogleFonts.allura(
                        fontSize: 36,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _seccionTransporte(
                  icon: Icons.airport_shuttle,
                  iconColor: Colors.green.shade400,
                  titulo: 'SERVICIO DE AUTOBÚS GRATUITO PARA INVITADOS',
                  contenido: 'Ponemos a disposición de nuestros invitados un servicio de autobús gratuito que facilitará el desplazamiento hasta la celebración.',
                ),
                const SizedBox(height: 20),
                _seccionTransporte(
                  icon: Icons.route,
                  iconColor: Colors.blue.shade300,
                  titulo: 'RUTA:',
                  contenido: 'Los autobuses realizarán la ruta Santander - Villasevil y viceversa.',
                ),
                const SizedBox(height: 20),
                _seccionTransporte(
                  icon: Icons.location_on,
                  iconColor: Colors.red,
                  titulo: 'PARADAS:',
                  contenido: 'Se realizarán paradas tanto a la ida como a la vuelta en Santander, Torrelavega y Puente Viesgo para facilitar el acceso a todos los invitados.\n\nLos puntos exactos de paradas en estas localidades se facilitarán más adelante en la web.',
                ),
                const SizedBox(height: 20),
                _seccionTransporte(
                  icon: Icons.access_time,
                  iconColor: Colors.red,
                  titulo: 'HORARIOS:',
                  contenido: 'Los horarios exactos se facilitarán más adelante en la web. No obstante, informamos que habrá dos horarios de vuelta disponibles:\n\n• Primer horario: 21:30 horas\n• Segundo horario: 00:30 horas',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.campaign, color: const Color(0xFFD4AF37), size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Os mantendremos informados de cualquier actualización a través de esta web.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(color: const Color(0xFFD4AF37)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _seccionTransporte({
  required IconData icon,
  required Color iconColor,
  required String titulo,
  required String contenido,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: iconColor, size: 24),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contenido,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _HotelIcon({double size = 32}) {
  return SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _HotelPainter(),
    ),
  );
}

class _HotelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Base del edificio (marrón claro)
    paint.color = const Color(0xFFD2B48C);
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.65),
      const Radius.circular(2),
    );
    canvas.drawRRect(baseRect, paint);

    // Techo curvo
    paint.color = const Color(0xFFD2B48C);
    final roofPath = Path();
    roofPath.moveTo(size.width * 0.1, size.height * 0.2);
    roofPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.05,
      size.width * 0.9,
      size.height * 0.2,
    );
    roofPath.lineTo(size.width * 0.9, size.height * 0.25);
    roofPath.lineTo(size.width * 0.1, size.height * 0.25);
    roofPath.close();
    canvas.drawPath(roofPath, paint);

    // Letra "H" grande en marrón oscuro
    paint.color = const Color(0xFF8B4513);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'H',
        style: TextStyle(
          color: Color(0xFF8B4513),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.5 - textPainter.width / 2, size.height * 0.35),
    );

    // Banda roja horizontal debajo de la "H"
    paint.color = Colors.red.shade600;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.55, size.width * 0.6, size.height * 0.08),
      paint,
    );

    // Ventanas azules a los lados
    paint.color = const Color(0xFF87CEEB);
    // Ventana izquierda
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.3, size.width * 0.12, size.height * 0.15),
      paint,
    );
    // Ventana derecha
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.73, size.height * 0.3, size.width * 0.12, size.height * 0.15),
      paint,
    );

    // Base marrón claro
    paint.color = const Color(0xFFDEB887);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.05, size.height * 0.85, size.width * 0.9, size.height * 0.1),
      paint,
    );

    // Plantas verdes en la base
    paint.color = Colors.green.shade600;
    // Planta izquierda
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.88, size.width * 0.15, size.height * 0.08),
      paint,
    );
    // Planta derecha
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.75, size.height * 0.88, size.width * 0.15, size.height * 0.08),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _mostrarAlojamiento(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.hotel, color: Colors.blue.shade300, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Alojamiento',
                      style: GoogleFonts.allura(
                        fontSize: 36,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _hotel(
                  'Gran Hotel Balneario de Puente Viesgo (4*)',
                  'Puente Viesgo (8 km de la ceremonia)',
                  'Spa, Balneario, Templo del Agua, Piscinas',
                  'https://balneariodepuenteviesgo.com',
                ),
                const SizedBox(height: 12),
                _hotel(
                  'Posada La Anjana (3*)',
                  'Puente Viesgo (8 km de la ceremonia)',
                  'Vistas al río Pas, Jardín, Parking gratuito',
                  'https://posadalaanjana.es/',
                ),
                const SizedBox(height: 12),
                _hotel(
                  'Posada Rincón del Pas (3*)',
                  'Puente Viesgo centro',
                  'Terraza, Bar, Jardín, WiFi',
                  'https://www.booking.com/hotel/es/posada-rincon-del-pas.html',
                ),
                const SizedBox(height: 12),
                _hotel(
                  'Hotel Torresport (4*)',
                  'Torrelavega (20 min de la ceremonia)',
                  'Spa, Piscina climatizada, Gimnasio, Parking, WiFi',
                  'https://www.hoteltorresport.com',
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _hotel(String nombre, String ubicacion, String servicios, String url) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text('Ubicación: $ubicacion', style: const TextStyle(fontSize: 14))),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.star, color: const Color(0xFFD4AF37), size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text('Servicios: $servicios', style: const TextStyle(fontSize: 14))),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.link, color: Colors.blue, size: 18),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
              child: const Text('Abrir web', style: TextStyle(color: Colors.blue, fontSize: 14)),
            ),
          ],
        ),
      ],
    ),
  );
}

void _mostrarRegalos(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const _RegalosDialog(),
  );
}

class _RegalosDialog extends StatefulWidget {
  const _RegalosDialog();
  
  @override
  State<_RegalosDialog> createState() => _RegalosDialogState();
}

class _RegalosDialogState extends State<_RegalosDialog> {
  bool _ibanVisible = false;
  static const _iban = 'ES61 0081 2714 1500 0827 1440';
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.blue.shade300, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Regalos',
                    style: GoogleFonts.allura(
                      fontSize: 36,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Vuestra presencia es nuestro mejor regalo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'No tendremos lista de bodas. Lo más importante para nosotros es compartir este día especial con vosotros.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              const Text(
                'Si queréis tener un detalle con nosotros',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aquí os dejamos nuestro número de cuenta para que podáis hacernos un regalo si lo deseáis.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _ibanVisible ? _iban : '•••• •••• •••• •••• •••• ••••',
                        style: TextStyle(
                          color: const Color(0xFFD4AF37),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.copy,
                        color: _ibanVisible ? const Color(0xFFD4AF37) : Colors.grey.shade400,
                      ),
                      onPressed: _ibanVisible
                          ? () {
                              Clipboard.setData(const ClipboardData(text: _iban));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('IBAN copiado al portapapeles'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          : null,
                    ),
                    IconButton(
                      icon: Icon(
                        _ibanVisible ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() => _ibanVisible = !_ibanVisible);
                      },
                      tooltip: _ibanVisible ? 'Ocultar número de cuenta' : 'Mostrar número de cuenta',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mil gracias por acompañarnos en este día tan especial.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(color: const Color(0xFFD4AF37)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _mostrarParking(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.local_parking, color: Colors.blue.shade300, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Aparcamiento',
                    style: GoogleFonts.allura(
                      fontSize: 36,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _seccionParking(
                icon: Icons.church,
                iconColor: const Color(0xFFD4AF37),
                titulo: 'CEREMONIA:',
                contenido: 'Aparcamiento disponible en los alrededores del Convento de San Francisco de El Soto.',
                onVerUbicacion: () => launchUrl(
                  Uri.parse('https://maps.app.goo.gl/cZCa1bVXzQ5xjU9A7'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const SizedBox(height: 20),
              _seccionParking(
                icon: Icons.celebration,
                iconColor: Colors.orange,
                titulo: 'CELEBRACIÓN:',
                contenido: 'Se puede aparcar en los alrededores de la finca, en el pueblo. También hay un aparcamiento grande a 5 minutos andando de la finca, siguiendo la carretera nacional.',
                onVerUbicacion: () => launchUrl(
                  Uri.parse('https://maps.app.goo.gl/nZEFo6CF9Wm7JcFb7'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _seccionParking({
  required IconData icon,
  required Color iconColor,
  required String titulo,
  required String contenido,
  required VoidCallback onVerUbicacion,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        contenido,
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5E6D3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.7),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onVerUbicacion,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: const Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ver ubicación del aparcamiento',
                    style: TextStyle(
                      color: const Color(0xFFD4AF37),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

void _mostrarSubirFotos(BuildContext context) {
  _uploadViaRest(context);
}

void _mostrarFotomaton(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.camera_alt, color: Colors.blue.shade300, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    'Fotomatón',
                    style: GoogleFonts.allura(
                      fontSize: 36,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Descarga tus fotos divertidas del fotomatón. Disponible después de la boda.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(color: const Color(0xFFD4AF37)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class PreinscriptionPage extends StatefulWidget {
  const PreinscriptionPage({super.key});
  
  @override
  State<PreinscriptionPage> createState() => _PreinscriptionPageState();
}

class _PreinscriptionPageState extends State<PreinscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _allergies = TextEditingController();
  final TextEditingController _songs = TextEditingController();
  final TextEditingController _message = TextEditingController();

  String? _attendance;
  String _age = 'adulto';
  String? _companion;
  int _numCompanions = 1;
  List<_CompanionData> _companions = [];
  String? _needTransport;
  String? _ownCar;
  String? _albumDigital;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _companions = List.generate(_numCompanions, (_) => _CompanionData());
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _allergies.dispose();
    _songs.dispose();
    _message.dispose();
    super.dispose();
  }

  void _setCompanions(int n) {
    setState(() {
      _numCompanions = n.clamp(1, 9);
      if (_companions.length < _numCompanions) {
        _companions.addAll(
          List.generate(_numCompanions - _companions.length, (_) => _CompanionData()),
        );
      } else if (_companions.length > _numCompanions) {
        _companions = _companions.sublist(0, _numCompanions);
      }
    });
  }

  bool _isValidEmail(String v) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_attendance == 'si') {
      if (_companion == null || _needTransport == null || _ownCar == null || _albumDigital == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa los campos obligatorios.')),
        );
        return;
      }
      if (_companion == 'si') {
        for (var i = 0; i < _companions.length; i++) {
          if (_companions[i].name.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Nombre acompañante ${i + 1} obligatorio.')),
            );
            return;
          }
        }
      }
    }

    setState(() => _sending = true);
    try {
      final payload = _buildRsvpPayload();
      await _sendRsvpToSupabase(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Preinscripción enviada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error enviando: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Map<String, dynamic> _buildRsvpPayload() {
    int countAdult = 0, countTeen = 0, countKid = 0;
    if (_attendance == 'si') {
      if (_age == 'adulto') countAdult++;
      if (_age == '12-18') countTeen++;
      if (_age == '0-12') countKid++;
    }
    if (_companion == 'si') {
      for (final c in _companions) {
        if (c.age == 'adulto') countAdult++;
        if (c.age == '12-18') countTeen++;
        if (c.age == '0-12') countKid++;
      }
    }

    final Map<String, dynamic> data = {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'asistencia': _attendance,
      'edad_principal': _age,
      'alergias_principal': _allergies.text.trim().isEmpty ? null : _allergies.text.trim(),
      'acompanante': _companion,
      'num_acompanantes': _companion == 'si' ? _companions.length : 0,
      'num_adultos': countAdult,
      'num_12_18': countTeen,
      'num_0_12': countKid,
      'necesita_transporte': _needTransport,
      'coche_propio': _ownCar,
      'canciones': _songs.text.trim().isEmpty ? null : _songs.text.trim(),
      'album_digital': _albumDigital,
      'mensaje_novios': _message.text.trim().isEmpty ? null : _message.text.trim(),
      'created_at': DateTime.now().toIso8601String(),
      'origen_form': 'flutter_web',
    };
    if (_companion == 'si' && _companions.isNotEmpty) {
      data['acompanantes_json'] = _companions.map((c) => {
        'nombre': c.name.text.trim(),
        'edad': c.age,
        'alergias': c.allergies.text.trim().isEmpty ? null : c.allergies.text.trim(),
      }).toList();
    }
    return data;
  }

  Future<void> _sendRsvpToSupabase(Map<String, dynamic> payload) async {
    if (_supabaseUrl.isEmpty || _supabaseAnon.isEmpty) {
      throw 'Backend no configurado. Compila con SUPABASE_URL y SUPABASE_ANON.';
    }
    final headers = {
      'Authorization': 'Bearer $_supabaseAnon',
      'apikey': _supabaseAnon,
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    };
    var uri = Uri.parse('$_supabaseUrl/rest/v1/boda.rsvps');
    var resp = await http.post(uri, headers: headers, body: jsonEncode(payload));
    if (resp.statusCode >= 300) {
      uri = Uri.parse('$_supabaseUrl/rest/v1/rsvps');
      resp = await http.post(uri, headers: headers, body: jsonEncode(payload));
      if (resp.statusCode >= 300) {
        throw 'HTTP ${resp.statusCode}: ${resp.body}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/imagenPrincipal.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.45)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(.35),
                        Colors.black.withOpacity(.55),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 40,
                        color: Colors.black38,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            children: [
                              _LogoCircle(),
                              const SizedBox(height: 12),
                              Text(
                                'Laura & Daniel',
                                style: GoogleFonts.allura(
                                  fontSize: 36,
                                  color: const Color(0xFFD4AF37),
                                  shadows: const [
                                    Shadow(color: Colors.black54, blurRadius: 3),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Confirma tu asistencia',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                          const _EventDetailsSection(),
                          _Section(
                            title: 'Tus datos',
                            child: Column(
                              children: [
                                _TextField(
                                  controller: _name,
                                  label: 'Nombre y apellidos',
                                  validator: (v) => v!.trim().isEmpty ? 'Campo obligatorio' : null,
                                ),
                                _TextField(
                                  controller: _email,
                                  label: 'Correo electrónico',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v!.trim().isEmpty || _isValidEmail(v.trim())
                                      ? null
                                      : 'Email no válido',
                                ),
                                _TextField(
                                  controller: _phone,
                                  label: 'Teléfono',
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v!.trim().isEmpty ? 'Campo obligatorio' : null,
                                ),
                              ],
                            ),
                          ),
                          _Section(
                            title: 'Confirmación de asistencia',
                            child: _RadioGroup(
                              value: _attendance,
                              onChanged: (v) => setState(() => _attendance = v),
                              items: const [
                                ('si', 'Sí, asistiré'),
                                ('no', 'No podré asistir'),
                              ],
                            ),
                          ),
                          if (_attendance == 'si') ...[
                            _Section(
                              title: 'Información adicional',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Grupo de edad', style: TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  _RadioGroup(
                                    value: _age,
                                    onChanged: (v) => setState(() => _age = v ?? 'adulto'),
                                    items: const [
                                      ('adulto', 'Adulto (+18)'),
                                      ('12-18', '12-18 años'),
                                      ('0-12', 'Menor 12 años'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _TextField(
                                    controller: _allergies,
                                    label: 'Alergias o intolerancias',
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('¿Vendrás acompañado?', style: TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  _RadioGroup(
                                    value: _companion,
                                    onChanged: (v) => setState(() => _companion = v),
                                    items: const [('si', 'Sí'), ('no', 'No')],
                                  ),
                                ],
                              ),
                            ),
                            if (_companion == 'si')
                              _Section(
                                title: 'Acompañantes',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: _numCompanions > 1
                                              ? () => _setCompanions(_numCompanions - 1)
                                              : null,
                                          icon: const Icon(Icons.remove),
                                        ),
                                        Text('$_numCompanions', style: const TextStyle(color: Colors.white)),
                                        IconButton(
                                          onPressed: _numCompanions < 9
                                              ? () => _setCompanions(_numCompanions + 1)
                                              : null,
                                          icon: const Icon(Icons.add),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Mínimo 1 · Máximo 9',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    for (int i = 0; i < _companions.length; i++)
                                      _CompanionCard(
                                        index: i + 1,
                                        data: _companions[i],
                                      ),
                                  ],
                                ),
                              ),
                            _Section(
                              title: 'Transporte',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('¿Necesitas transporte?', style: TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  _RadioGroup(
                                    value: _needTransport,
                                    onChanged: (v) => setState(() => _needTransport = v),
                                    items: const [('si', 'Sí'), ('no', 'No')],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '¿Llevarás coche propio? (para organizar parking)',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  _RadioGroup(
                                    value: _ownCar,
                                    onChanged: (v) => setState(() => _ownCar = v),
                                    items: const [('si', 'Sí'), ('no', 'No')],
                                  ),
                                ],
                              ),
                            ),
                            _Section(
                              title: 'Entretenimiento',
                              child: _TextField(
                                controller: _songs,
                                label: '¿Qué canciones te gustaría escuchar?',
                                maxLines: 3,
                              ),
                            ),
                            _Section(
                              title: 'Comunicación',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '¿Te gustaría recibir el álbum digital?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  _RadioGroup(
                                    value: _albumDigital,
                                    onChanged: (v) => setState(() => _albumDigital = v),
                                    items: const [('si', 'Sí'), ('no', 'No')],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          _Section(
                            title: 'Mensaje especial',
                            child: _TextField(
                              controller: _message,
                              label: 'Mensaje para los novios',
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _sending ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(_sending ? 'Enviando...' : 'Enviar confirmación'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    return RepaintBoundary(
      child: Center(
        child: SizedBox(
          width: 280,
          height: 280,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 560,
              height: 560,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(goldColor, BlendMode.srcIn),
                child: Image.asset(
                  'assets/images/logoNuevo2.png',
                  width: 560,
                  height: 560,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Text(
                    'L&D',
                    style: GoogleFonts.allura(
                      fontSize: 252,
                      color: goldColor,
                      fontWeight: FontWeight.w600,
                      shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventDetailsSection extends StatelessWidget {
  const _EventDetailsSection();
  
  @override
  Widget build(BuildContext context) {
    final cardBorder = Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3));
    
    Widget detailCard({
      required String emoji,
      required String title,
      String? imageAsset,
      required List<String> lines,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          border: cardBorder,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              if (imageAsset != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imageAsset,
                    width: 228,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              for (final l in lines)
                Text(
                  l,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth;
          final cross = width >= 800 ? 3 : 1;
          final children = <Widget>[
            detailCard(
              emoji: '⛪',
              title: 'Ceremonia',
              imageAsset: 'assets/images/santuario.jpg',
              lines: const ['Convento de San Francisco de El Soto', 'Soto‑Iruz – 12:30h'],
            ),
            detailCard(
              emoji: '🥂',
              title: 'Celebración',
              imageAsset: 'assets/images/labranza.jpg',
              lines: const ['Finca La Real Labranza de Villasevil', '14:00h'],
            ),
            detailCard(
              emoji: '📅',
              title: 'Fecha',
              lines: const ['Sábado, 25 de Abril de 2026'],
            ),
          ];
          final mainExtent = cross == 3 ? 200.0 : (cross == 2 ? 210.0 : 220.0);
          return GridView.custom(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: mainExtent,
            ),
            childrenDelegate: SliverChildListDelegate(children),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  
  const _Section({required this.title, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.allura(
              fontSize: 28,
              color: const Color(0xFFD4AF37),
              shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  
  const _TextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: validator,
      ),
    );
  }
}

class _RadioGroup extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<(String, String)> items;
  
  const _RadioGroup({
    required this.value,
    required this.onChanged,
    required this.items,
  });
  
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    ButtonStyle style(bool selected) => OutlinedButton.styleFrom(
      foregroundColor: selected ? Colors.black : gold,
      backgroundColor: selected ? gold : Colors.black.withOpacity(0.18),
      side: const BorderSide(color: gold, width: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: items.map((e) {
        final selected = value == e.$1;
        return OutlinedButton(
          onPressed: () => onChanged(e.$1),
          style: style(selected),
          child: Text(e.$2),
        );
      }).toList(),
    );
  }
}

class _CompanionData {
  final TextEditingController name = TextEditingController();
  String age = 'adulto';
  final TextEditingController allergies = TextEditingController();
}

class _CompanionCard extends StatelessWidget {
  final int index;
  final _CompanionData data;
  
  const _CompanionCard({required this.index, required this.data});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border.all(color: const Color(0xFFD4AF37)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Acompañante $index', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: data.name,
            decoration: const InputDecoration(labelText: 'Nombre y apellidos'),
            validator: (v) => v!.trim().isEmpty ? 'Campo obligatorio' : null,
          ),
          const SizedBox(height: 8),
          const Text('Grupo de edad'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: const Text('Adulto (+18)'),
                selected: data.age == 'adulto',
                onSelected: (_) => data.age = 'adulto',
              ),
              ChoiceChip(
                label: const Text('12-18 años'),
                selected: data.age == '12-18',
                onSelected: (_) => data.age = '12-18',
              ),
              ChoiceChip(
                label: const Text('Menor 12 años'),
                selected: data.age == '0-12',
                onSelected: (_) => data.age = '0-12',
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: data.allergies,
            decoration: const InputDecoration(
              labelText: 'Alergias o intolerancias (opcional)',
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

String _inferMime(String? ext) {
  final e = (ext ?? '').toLowerCase();
  if (e == 'jpg' || e == 'jpeg') return 'image/jpeg';
  if (e == 'png') return 'image/png';
  if (e == 'webp') return 'image/webp';
  if (e == 'heic' || e == 'heif') return 'image/heic';
  if (e == 'mp4') return 'video/mp4';
  if (e == 'mov') return 'video/quicktime';
  if (e == 'avi') return 'video/x-msvideo';
  if (e == 'mkv') return 'video/x-matroska';
  return 'application/octet-stream';
}

Future<void> _uploadViaRest(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif', 'mp4', 'mov', 'avi', 'mkv'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No seleccionaste archivos.')),
    );
    return;
  }
  if (_supabaseUrl.isEmpty || _supabaseAnon.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backend no configurado (REST). Faltan SUPABASE_URL/ANON.'),
      ),
    );
    return;
  }

  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(content: Text('Subiendo (REST) ${result.files.length} archivo(s)...')),
  );

  final today = DateTime.now().toIso8601String().substring(0, 10);
  for (final file in result.files) {
    final bytes = file.bytes;
    if (bytes == null) {
      scaffold.showSnackBar(
        SnackBar(content: Text('No pude leer datos de ${file.name}.')),
      );
      continue;
    }
    final path = 'uploads/$today/${DateTime.now().millisecondsSinceEpoch}-${file.name}';
    final mime = _inferMime(file.extension);

    final uploadUri = Uri.parse('$_supabaseUrl/storage/v1/object/boda/$path');
    final uploadResp = await http.post(
      uploadUri,
      headers: {
        'Authorization': 'Bearer $_supabaseAnon',
        'apikey': _supabaseAnon,
        'Content-Type': mime,
        'x-upsert': 'true',
      },
      body: bytes,
    );
    if (uploadResp.statusCode >= 300) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Fallo storage ${file.name}: ${uploadResp.statusCode} ${uploadResp.body}'),
        ),
      );
      continue;
    }

    final publicUrl = '$_supabaseUrl/storage/v1/object/public/boda/$path';

    final restUri = Uri.parse('$_supabaseUrl/rest/v1/boda.gallery_photos');
    final insertResp = await http.post(
      restUri,
      headers: {
        'Authorization': 'Bearer $_supabaseAnon',
        'apikey': _supabaseAnon,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: '{"url":"$publicUrl","approved":false}',
    );
    if (insertResp.statusCode >= 300) {
      final restUri2 = Uri.parse('$_supabaseUrl/rest/v1/gallery_photos');
      final insertResp2 = await http.post(
        restUri2,
        headers: {
          'Authorization': 'Bearer $_supabaseAnon',
          'apikey': _supabaseAnon,
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
        body: '{"url":"$publicUrl","approved":false}',
      );
      if (insertResp2.statusCode >= 300) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Fallo insert ${file.name}: ${insertResp2.statusCode} ${insertResp2.body}'),
          ),
        );
      }
    }
  }

  scaffold.clearSnackBars();
  scaffold.showSnackBar(
    const SnackBar(content: Text('¡Archivos subidos (REST) correctamente!')),
  );
}
