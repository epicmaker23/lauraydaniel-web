import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_plugins/url_strategy.dart';

// Helper functions for responsive design
class ResponsiveHelper {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;
  
  static int getGridCrossAxisCount(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
  
  static double getResponsiveValue(BuildContext context, {required double mobile, double? tablet, required double desktop}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return desktop;
  }
  
  static EdgeInsets getResponsivePadding(BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    required EdgeInsets desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return desktop;
  }
  
  static double getFontSize(BuildContext context, {required double mobile, double? tablet, required double desktop}) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return desktop;
  }
}

// Firebase configuration
const firebaseConfig = {
  'apiKey': 'AIzaSyB-S08g6wd15r5Uko5LYj-jlwl-D5-nnBE',
  'authDomain': 'lauraydaniel-boda-e81d9.firebaseapp.com',
  'projectId': 'lauraydaniel-boda-e81d9',
  'storageBucket': 'lauraydaniel-boda-e81d9.firebasestorage.app',
  'messagingSenderId': '451517226012',
  'appId': '1:451517226012:web:237110b6a8d5bc26ae93d9',
  'measurementId': 'G-4086827BKM',
};

// Collections
const String _rsvpCollection = 'rsvps';
const String _galleryCollection = 'gallery_photos';
const String _galleryPath = 'gallery';

bool _firebaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: firebaseConfig['apiKey']!,
        authDomain: firebaseConfig['authDomain']!,
        projectId: firebaseConfig['projectId']!,
        storageBucket: firebaseConfig['storageBucket']!,
        messagingSenderId: firebaseConfig['messagingSenderId']!,
        appId: firebaseConfig['appId']!,
        measurementId: firebaseConfig['measurementId'],
      ),
    );
    _firebaseReady = true;
  } catch (e) {
    debugPrint('Error inicializando Firebase: $e');
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
        '/upload': (_) => const UploadPage(),
        '/admin': (_) => const AdminPage(),
        '/galeria': (_) => const GaleriaPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/formulario' || settings.name == 'formulario') {
          return MaterialPageRoute(builder: (_) => const PreinscriptionPage());
        }
        if (settings.name == '/upload' || settings.name == 'upload') {
          return MaterialPageRoute(builder: (_) => const UploadPage());
        }
        if (settings.name == '/admin' || settings.name == 'admin') {
          return MaterialPageRoute(builder: (_) => const AdminPage());
        }
        if (settings.name == '/galeria' || settings.name == 'galeria') {
          return MaterialPageRoute(builder: (_) => const GaleriaPage());
        }
        return null;
      },
      onGenerateInitialRoutes: (String initialRouteName) {
        final path = Uri.base.path;
        if (path == '/formulario' || path == 'formulario' || path == '/formulario/') {
          return [MaterialPageRoute(builder: (_) => const PreinscriptionPage())];
        }
        if (path == '/upload' || path == 'upload' || path == '/upload/') {
          return [MaterialPageRoute(builder: (_) => const UploadPage())];
        }
        if (path == '/admin' || path == 'admin' || path == '/admin/') {
          return [MaterialPageRoute(builder: (_) => const AdminPage())];
        }
        if (path == '/galeria' || path == 'galeria' || path == '/galeria/') {
          return [MaterialPageRoute(builder: (_) => const GaleriaPage())];
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
        padding: ResponsiveHelper.getResponsivePadding(
          context,
          mobile: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          desktop: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        ),
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
                  onTap: () => Navigator.of(context).pushNamed('/galeria'),
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
              final screenWidth = MediaQuery.of(context).size.width;
              int cross;
              double aspect;
              
              if (screenWidth < 600) {
                // Móvil: 1 columna
                cross = 1;
                aspect = 1.2;
              } else if (screenWidth < 900) {
                // Tablet pequeña: 2 columnas
                cross = 2;
                aspect = 1.1;
              } else if (screenWidth < 1200) {
                // Tablet grande / Desktop pequeño: 2-3 columnas
                cross = width >= 1100 ? 3 : 2;
                aspect = cross == 3 ? 1.15 : 1.1;
              } else {
                // Desktop: 3 columnas
                cross = 3;
                aspect = 1.15;
              }
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
          color: Colors.black.withOpacity(0.95),
          border: const Border(top: BorderSide(color: Colors.white24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                      'Política de Cookies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => setState(() => _visible = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta web utiliza únicamente cookies técnicas propias que son estrictamente necesarias para el funcionamiento del sitio web. Estas cookies no recopilan información personal identificable y no se utilizan para fines de seguimiento o publicidad.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
              TextButton(
                onPressed: () => setState(() => _visible = false),
                    child: const Text(
                      'Rechazar',
                      style: TextStyle(color: Colors.white70),
                    ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => setState(() => _visible = false),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                    ),
                child: const Text('Aceptar'),
                  ),
                ],
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
  final isMobile = MediaQuery.of(context).size.width < 600;
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 520,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.allura(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      mobile: 28,
                      desktop: 36,
                    ),
                    color: const Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  contenido,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      mobile: 14,
                      desktop: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                  'Hotel Bahía de Santander (4*)',
                  'Santander',
                  'Ubicación céntrica, Parking, WiFi, Servicios completos',
                  'https://www.booking.com/searchresults.html?ss=Hotel+Bah%C3%ADa+de+Santander',
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
                'Lo más importante para nosotros es compartir este día especial con vosotros. No tendremos lista de bodas.',
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
      await _sendRsvpToFirebase(payload);
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

  Future<void> _sendRsvpToFirebase(Map<String, dynamic> payload) async {
    if (!_firebaseReady) {
      throw 'Backend no configurado. Firebase no está inicializado.';
    }
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection(_rsvpCollection).add(payload);
    } catch (e) {
      throw 'Error guardando RSVP: $e';
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
  if (!_firebaseReady) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backend no configurado. Firebase no está inicializado.'),
      ),
    );
    return;
  }

  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(content: Text('Subiendo ${result.files.length} archivo(s)...')),
  );

  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  final today = DateTime.now().toIso8601String().substring(0, 10);
  int successCount = 0;
  int failCount = 0;

  for (final file in result.files) {
    final bytes = file.bytes;
    if (bytes == null) {
      failCount++;
      scaffold.showSnackBar(
        SnackBar(content: Text('No pude leer datos de ${file.name}.')),
      );
      continue;
    }
    
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}-${file.name}';
      final path = '$_galleryPath/$today/$fileName';
      final ref = storage.ref(path);
      
      final metadata = SettableMetadata(
        contentType: _inferMime(file.extension),
      );
      
      await ref.putData(bytes, metadata);
      final downloadUrl = await ref.getDownloadURL();

      await firestore.collection(_galleryCollection).add({
        'url': downloadUrl,
        'approved': false,
        'created_at': FieldValue.serverTimestamp(),
        'filename': file.name,
      });
      
      successCount++;
    } catch (e) {
      failCount++;
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Error subiendo ${file.name}: $e'),
        ),
      );
    }
  }

  scaffold.clearSnackBars();
  if (successCount > 0) {
    scaffold.showSnackBar(
      SnackBar(
        content: Text('¡$successCount archivo(s) subido(s) correctamente!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  if (failCount > 0) {
    scaffold.showSnackBar(
      SnackBar(
        content: Text('$failCount archivo(s) fallaron al subir.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});
  
  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _uploading = false;
  int _uploadedCount = 0;
  int _totalFiles = 0;

  Future<void> _handleUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif', 'mp4', 'mov', 'avi', 'mkv'],
      withData: true,
    );
    
    if (result == null || result.files.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No seleccionaste archivos.')),
        );
      }
      return;
    }
    
    if (!_firebaseReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backend no configurado. Firebase no está inicializado.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _uploading = true;
      _uploadedCount = 0;
      _totalFiles = result.files.length;
    });

    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(content: Text('Subiendo ${result.files.length} archivo(s)...')),
    );

    final storage = FirebaseStorage.instance;
    final firestore = FirebaseFirestore.instance;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    int successCount = 0;
    int failCount = 0;

    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) {
        failCount++;
        if (mounted) {
          scaffold.showSnackBar(
            SnackBar(content: Text('No pude leer datos de ${file.name}.')),
          );
        }
        setState(() => _uploadedCount++);
        continue;
      }
      
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}-${file.name}';
        final path = '$_galleryPath/$today/$fileName';
        final ref = storage.ref(path);
        
        final metadata = SettableMetadata(
          contentType: _inferMime(file.extension),
        );
        
        await ref.putData(bytes, metadata);
        final downloadUrl = await ref.getDownloadURL();

        await firestore.collection(_galleryCollection).add({
          'url': downloadUrl,
          'approved': false,
          'created_at': FieldValue.serverTimestamp(),
          'filename': file.name,
        });
        
        successCount++;
      } catch (e) {
        failCount++;
        if (mounted) {
        scaffold.showSnackBar(
          SnackBar(
              content: Text('Error subiendo ${file.name}: $e'),
          ),
        );
      }
    }
      
      if (mounted) {
        setState(() => _uploadedCount++);
    }
  }

    setState(() => _uploading = false);

    if (mounted) {
  scaffold.clearSnackBars();
      if (successCount > 0) {
  scaffold.showSnackBar(
          SnackBar(
            content: Text('¡$successCount archivo(s) subido(s) correctamente!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      if (failCount > 0) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('$failCount archivo(s) fallaron al subir.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    
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
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(.35),
                        Colors.black.withOpacity(.55),
                      ],
                    ),
                    border: Border.all(color: gold),
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
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.photo_camera, color: gold, size: 32),
                            const SizedBox(width: 12),
                            Text(
                              'Subir Fotos y Videos',
                              style: GoogleFonts.allura(
                                fontSize: 36,
                                color: gold,
                                shadows: const [
                                  Shadow(color: Colors.black54, blurRadius: 3),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Comparte tus momentos especiales de la boda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Puedes subir múltiples fotos y videos a la vez. Los archivos se revisarán antes de publicarse en el álbum.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        if (_uploading) ...[
                          Column(
                            children: [
                              CircularProgressIndicator(
                                value: _totalFiles > 0 ? _uploadedCount / _totalFiles : null,
                                color: gold,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Subiendo $_uploadedCount de $_totalFiles archivos...',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                        FilledButton.icon(
                          onPressed: _uploading ? null : _handleUpload,
                          icon: const Icon(Icons.cloud_upload),
                          label: Text(_uploading ? 'Subiendo...' : 'Seleccionar y Subir Archivos'),
                          style: FilledButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                          icon: const Icon(Icons.home),
                          label: const Text('Volver a la Página Principal'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: gold,
                            side: const BorderSide(color: gold, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

// Login widget reutilizable
class _LoginDialog extends StatefulWidget {
  final String expectedUsername;
  final String expectedPassword;
  final VoidCallback onSuccess;
  
  const _LoginDialog({
    required this.expectedUsername,
    required this.expectedPassword,
    required this.onSuccess,
  });
  
  @override
  State<_LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<_LoginDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _handleLogin() async {
    if (_usernameController.text.trim() != widget.expectedUsername ||
        _passwordController.text != widget.expectedPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña incorrectos'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.of(context).pop();
      widget.onSuccess();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Iniciar Sesión',
              style: GoogleFonts.allura(
                fontSize: 32,
                color: gold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocusNode.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: gold.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: gold),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: gold.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: gold),
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: FilledButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

// Página de administración
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isAuthenticated = false;
  int _selectedTab = 0;
  
  void _showLogin() {
    showDialog(
      context: context,
      builder: (_) => _LoginDialog(
        expectedUsername: 'epicmaker',
        expectedPassword: '25deabril',
        onSuccess: () => setState(() => _isAuthenticated = true),
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showLogin());
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: const Color(0xFFD4AF37)),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Panel de Administración',
          style: GoogleFonts.allura(fontSize: 28, color: const Color(0xFFD4AF37)),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => setState(() => _isAuthenticated = false),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _selectedTab = 0),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedTab == 0
                          ? const Color(0xFFD4AF37).withOpacity(0.3)
                          : Colors.transparent,
                    ),
                    child: const Text('Confirmaciones', style: TextStyle(color: Colors.white)),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _selectedTab = 1),
                    style: TextButton.styleFrom(
                      backgroundColor: _selectedTab == 1
                          ? const Color(0xFFD4AF37).withOpacity(0.3)
                          : Colors.transparent,
                    ),
                    child: const Text('Aprobar Fotos', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? const _RsvpManagementTab()
                : const _PhotoApprovalTab(),
          ),
        ],
      ),
    );
  }
}

// Tab de gestión de RSVPs
class _RsvpManagementTab extends StatefulWidget {
  const _RsvpManagementTab();
  
  @override
  State<_RsvpManagementTab> createState() => _RsvpManagementTabState();
}

class _RsvpManagementTabState extends State<_RsvpManagementTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(_rsvpCollection)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay confirmaciones'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  data['name'] ?? 'Sin nombre',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${data['email'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                    Text('Teléfono: ${data['phone'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                    Text('Asistencia: ${data['asistencia'] == 'si' ? 'Sí' : 'No'}', style: const TextStyle(color: Colors.white70)),
                    if (data['asistencia'] == 'si') ...[
                      Text('Adultos: ${data['num_adultos'] ?? 0}', style: const TextStyle(color: Colors.white70)),
                      Text('12-18: ${data['num_12_18'] ?? 0}', style: const TextStyle(color: Colors.white70)),
                      Text('0-12: ${data['num_0_12'] ?? 0}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
                      onPressed: () => _editRsvp(context, doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRsvp(context, doc.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Future<void> _deleteRsvp(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta confirmación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection(_rsvpCollection).doc(id).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Confirmación eliminada'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
  
  Future<void> _editRsvp(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: data['name'] ?? '');
    final emailController = TextEditingController(text: data['email'] ?? '');
    
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Confirmación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await doc.reference.update({
                  'name': nameController.text,
                  'email': emailController.text,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Confirmación actualizada'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// Tab de aprobación de fotos
class _PhotoApprovalTab extends StatefulWidget {
  const _PhotoApprovalTab();
  
  @override
  State<_PhotoApprovalTab> createState() => _PhotoApprovalTabState();
}

class _PhotoApprovalTabState extends State<_PhotoApprovalTab> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(_galleryCollection)
          .where('approved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay fotos pendientes de aprobación'));
        }
        
        // Ordenar por fecha en el cliente
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aTime = a.data() as Map<String, dynamic>;
            final bTime = b.data() as Map<String, dynamic>;
            final aCreated = aTime['created_at'] as Timestamp?;
            final bCreated = bTime['created_at'] as Timestamp?;
            if (aCreated == null && bCreated == null) return 0;
            if (aCreated == null) return 1;
            if (bCreated == null) return -1;
            return bCreated.compareTo(aCreated); // Descendente
          });
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final url = data['url'] as String?;
            
            if (url == null) return const SizedBox.shrink();
            
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approvePhoto(doc.id),
                          tooltip: 'Aprobar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _rejectPhoto(doc.id),
                          tooltip: 'Rechazar',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _approvePhoto(String id) async {
    try {
      await FirebaseFirestore.instance.collection(_galleryCollection).doc(id).update({
        'approved': true,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto aprobada'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _rejectPhoto(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar rechazo'),
        content: const Text('¿Estás seguro de que quieres rechazar esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection(_galleryCollection).doc(id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto rechazada'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

// Página de galería
class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});
  
  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  bool _isAuthenticated = false;
  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  final Map<String, ImageProvider> _imageCache = {};
  
  void _showLogin() {
    showDialog(
      context: context,
      builder: (_) => _LoginDialog(
        expectedUsername: 'boda',
        expectedPassword: '25deabril',
        onSuccess: () => setState(() => _isAuthenticated = true),
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showLogin());
  }
  
  @override
  void dispose() {
    _imageCache.clear();
    super.dispose();
  }
  
  Widget _buildOptimizedImage(String url) {
    // Usar cache si está disponible
    if (_imageCache.containsKey(url)) {
      return Image(
        image: _imageCache[url]!,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: child,
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }
    
    // Cargar imagen con optimizaciones
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          // Cachear la imagen cuando se carga completamente
          final imageProvider = NetworkImage(url);
          _imageCache[url] = imageProvider;
          return child;
        }
        return Container(
          color: Colors.grey[900],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: const Color(0xFFD4AF37),
            ),
          ),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[800],
        child: const Icon(Icons.broken_image, color: Colors.white54),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: const Color(0xFFD4AF37)),
        ),
      );
    }
    
    const gold = Color(0xFFD4AF37);
    
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Galería de Fotos',
            style: GoogleFonts.allura(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                mobile: 22,
                desktop: 28,
              ),
              color: gold,
            ),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.black,
        actions: [
          Builder(
            builder: (context) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(_galleryCollection)
                    .where('approved', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final isMobile = MediaQuery.of(context).size.width < 600;
                  
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 2 : 4,
                        ),
                        child: FilledButton.icon(
                          onPressed: docs.isNotEmpty
                              ? () => _downloadAllImages(context, docs)
                              : null,
                          icon: const Icon(Icons.download, color: Colors.black, size: 18),
                          label: Text(
                            'Descargar todo',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 12,
                              vertical: isMobile ? 6 : 8,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 2 : 4,
                        ),
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed('/upload'),
                          icon: const Icon(Icons.upload, color: Colors.black, size: 18),
                          label: Text(
                            'Subir fotos / videos',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 12,
                              vertical: isMobile ? 6 : 8,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: gold),
                        onPressed: () => setState(() => _isAuthenticated = false),
                        tooltip: 'Cerrar sesión',
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(_galleryCollection)
            .where('approved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library, size: 64, color: Colors.white54),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay fotos aprobadas aún',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/upload'),
                    icon: const Icon(Icons.upload),
                    label: const Text('Subir fotos / videos'),
                    style: FilledButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }
          
          // Ordenar por fecha en el cliente
          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final aTime = a.data() as Map<String, dynamic>;
              final bTime = b.data() as Map<String, dynamic>;
              final aCreated = aTime['created_at'] as Timestamp?;
              final bCreated = bTime['created_at'] as Timestamp?;
              if (aCreated == null && bCreated == null) return 0;
              if (aCreated == null) return 1;
              if (bCreated == null) return -1;
              return bCreated.compareTo(aCreated); // Descendente
            });
          
          final totalPages = (docs.length / _itemsPerPage).ceil();
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage).clamp(0, docs.length);
          final paginatedDocs = docs.sublist(startIndex, endIndex);
          
          return Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    int crossAxisCount;
                    double spacing;
                    
                    if (screenWidth < 600) {
                      // Móvil: 2 columnas
                      crossAxisCount = 2;
                      spacing = 8;
                    } else if (screenWidth < 900) {
                      // Tablet: 3 columnas
                      crossAxisCount = 3;
                      spacing = 10;
                    } else if (screenWidth < 1400) {
                      // Desktop pequeño: 4 columnas
                      crossAxisCount = 4;
                      spacing = 12;
                    } else {
                      // Desktop grande: 5 columnas
                      crossAxisCount = 5;
                      spacing = 12;
                    }
                    
                    return GridView.builder(
                      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveValue(
                        context,
                        mobile: 8,
                        desktop: 16,
                      )),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: 1.0,
                      ),
                  itemCount: paginatedDocs.length,
                  itemBuilder: (context, index) {
                    final doc = paginatedDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final url = data['url'] as String?;
                    
                    if (url == null) return const SizedBox.shrink();
                    
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () => _showFullImage(context, url),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildOptimizedImage(url),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Material(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            child: IconButton(
                              icon: const Icon(Icons.download, color: Color(0xFFD4AF37), size: 28),
                              onPressed: () => _downloadImage(url, data['filename'] as String?),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              tooltip: 'Descargar',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                    );
                  },
                ),
              ),
              if (totalPages > 1)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border(top: BorderSide(color: gold.withOpacity(0.3))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Color(0xFFD4AF37)),
                        onPressed: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                      ),
                      Text(
                        'Página ${_currentPage + 1} de $totalPages',
                        style: const TextStyle(color: Color(0xFFD4AF37)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Color(0xFFD4AF37)),
                        onPressed: _currentPage < totalPages - 1
                            ? () => setState(() => _currentPage++)
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Future<void> _downloadImage(String url, String? filename) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _downloadAllImages(BuildContext context, List<QueryDocumentSnapshot> docs) async {
    if (docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay imágenes para descargar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando ${docs.length} archivo(s)...'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Descargar todas las imágenes una por una
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final url = data['url'] as String?;
      if (url != null) {
        try {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
          // Pequeña pausa entre descargas para evitar sobrecarga
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          // Continuar con las siguientes aunque falle una
          continue;
        }
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descargas iniciadas. Revisa tu carpeta de descargas.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    child: IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: () => _downloadImage(url, null),
                      tooltip: 'Descargar',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
