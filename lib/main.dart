import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

// Widget para reproducir videos en web
class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  
  const _VideoPlayerWidget({required this.videoUrl});
  
  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  @override
  void initState() {
    super.initState();
    _createVideoElement();
  }
  
  void _createVideoElement() {
    final videoElement = html.VideoElement()
      ..src = widget.videoUrl
      ..controls = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..autoplay = false;
    
    // Registrar el elemento HTML
    final viewId = 'video-player-${widget.videoUrl.hashCode}';
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => videoElement,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final viewId = 'video-player-${widget.videoUrl.hashCode}';
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: viewId),
    );
  }
}

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
                  title: 'Fotos / Videos',
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
                      Icon(
                        icon,
                        size: iconSize,
                        color: const Color(0xFFD4AF37), // Dorado explícito para todos los iconos
                      ),
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
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.event_available, color: const Color(0xFFD4AF37), size: 32),
                  const SizedBox(width: 12),
                  Text(
    'Recordatorios',
                    style: GoogleFonts.allura(
                      fontSize: 36,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Añade recordatorios a tu calendario para no perderte nuestra boda.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Puedes crear dos recordatorios:',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              // Botones de recordatorios
              _RecordatorioButton(
                text: 'Recordatorio 1 semana antes',
                onTap: () {
                  // Crear recordatorio 1 semana antes (18/04/2026 10:00)
                  final fecha = DateTime(2026, 4, 18, 10, 0);
                  _crearRecordatorioCalendario(context, fecha, 'Recordatorio boda Laura & Daniel - 1 semana antes');
                },
              ),
              const SizedBox(height: 12),
              _RecordatorioButton(
                text: 'Recordatorio 3 horas antes',
                onTap: () {
                  // Crear recordatorio 3 horas antes (25/04/2026 09:30)
                  final fecha = DateTime(2026, 4, 25, 9, 30);
                  _crearRecordatorioCalendario(context, fecha, 'Recordatorio boda Laura & Daniel - 3 horas antes');
                },
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

class _RecordatorioButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _RecordatorioButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD4AF37), // dorado
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

Future<void> _crearRecordatorioCalendario(BuildContext context, DateTime fecha, String titulo) async {
  // Formato para Google Calendar
  final fechaInicio = fecha.toUtc();
  final fechaFin = fechaInicio.add(const Duration(hours: 1));
  
  final fechaInicioStr = '${fechaInicio.year}${fechaInicio.month.toString().padLeft(2, '0')}${fechaInicio.day.toString().padLeft(2, '0')}T${fechaInicio.hour.toString().padLeft(2, '0')}${fechaInicio.minute.toString().padLeft(2, '0')}00Z';
  final fechaFinStr = '${fechaFin.year}${fechaFin.month.toString().padLeft(2, '0')}${fechaFin.day.toString().padLeft(2, '0')}T${fechaFin.hour.toString().padLeft(2, '0')}${fechaFin.minute.toString().padLeft(2, '0')}00Z';
  
  final detalles = 'Boda de Laura & Daniel\n\nCeremonia: Convento de San Francisco de El Soto, Soto-Iruz - 12:30h\nCelebración: Finca La Real Labranza de Villasevil - 14:00h';
  final ubicacion = 'Cantabria, España';
  
  final url = Uri.parse(
    'https://calendar.google.com/calendar/render?action=TEMPLATE'
    '&text=${Uri.encodeComponent(titulo)}'
    '&dates=$fechaInicioStr/$fechaFinStr'
    '&details=${Uri.encodeComponent(detalles)}'
    '&location=${Uri.encodeComponent(ubicacion)}'
  );
  
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio añadido a tu calendario')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el calendario: $e')),
      );
    }
  }
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
                    Icon(Icons.directions_bus, color: const Color(0xFFD4AF37), size: 32),
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
                    Icon(Icons.hotel, color: const Color(0xFFD4AF37), size: 32),
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
                  Icon(Icons.card_giftcard, color: const Color(0xFFD4AF37), size: 32),
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
                  Icon(Icons.local_parking, color: const Color(0xFFD4AF37), size: 32),
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
                  Icon(Icons.camera_alt, color: const Color(0xFFD4AF37), size: 32),
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
  String? _busStop; // 'santander' | 'torrelavega' | 'puente_viesgo'
  String? _ownCar;
  String? _albumDigital;
  String? _needTrona; // 'si' | 'no' (solo para menores de 12 años)
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
      if (_companion == null || _needTransport == null || _albumDigital == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa los campos obligatorios.')),
        );
        return;
      }
      // Validar parada de autobús si usa el autobús
      if (_needTransport == 'si' && _busStop == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar desde dónde cogerás el autobús.')),
        );
        return;
      }
      // Validar trona para invitado principal si es menor de 12 años
      if (_age == '0-12' && _needTrona == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes indicar si necesitarás una trona.')),
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
          if (_companions[i].needTransport == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Debes indicar si el acompañante ${i + 1} usará el autobús.')),
            );
            return;
          }
          // Validar parada de autobús si usa el autobús
          if (_companions[i].needTransport == 'si' && _companions[i].busStop == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Debes seleccionar desde dónde cogerá el autobús el acompañante ${i + 1}.')),
            );
            return;
          }
          // Validar trona para acompañantes menores de 12 años
          if (_companions[i].age == '0-12' && _companions[i].needTrona == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Debes indicar si el acompañante ${i + 1} necesitará una trona.')),
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
          const SnackBar(
            content: Text(
              '¡Confirmación enviada!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Redirigir a la portada después de un breve delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        });
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
      'name': _name.text.trim().toUpperCase(),
      'email': _email.text.trim().toUpperCase(),
      'phone': _phone.text.trim().toUpperCase(),
      'asistencia': _attendance?.toUpperCase(),
      'edad_principal': _age.toUpperCase(),
      'alergias_principal': _allergies.text.trim().isEmpty ? null : _allergies.text.trim().toUpperCase(),
      'acompanante': _companion?.toUpperCase(),
      'num_acompanantes': _companion == 'si' ? _companions.length : 0,
      'num_adultos': countAdult,
      'num_12_18': countTeen,
      'num_0_12': countKid,
      'necesita_transporte': _needTransport?.toUpperCase(),
      'parada_autobus': _busStop?.toUpperCase(), // 'SANTANDER' | 'TORRELAVEGA' | 'PUENTE_VIESGO'
      'coche_propio': _ownCar?.toUpperCase(),
      'necesita_trona': _needTrona?.toUpperCase(), // solo para menores de 12 años
      'canciones': _songs.text.trim().isEmpty ? null : _songs.text.trim().toUpperCase(),
      'album_digital': _albumDigital?.toUpperCase(),
      'mensaje_novios': _message.text.trim().isEmpty ? null : _message.text.trim().toUpperCase(),
      'created_at': DateTime.now().toIso8601String(),
      'origen_form': 'flutter_web',
    };
    if (_companion == 'si' && _companions.isNotEmpty) {
      data['acompanantes_json'] = _companions.map((c) => {
        'nombre': c.name.text.trim().toUpperCase(),
        'edad': c.age.toUpperCase(),
        'alergias': c.allergies.text.trim().isEmpty ? null : c.allergies.text.trim().toUpperCase(),
        'necesita_transporte': c.needTransport?.toUpperCase() ?? '',
        'parada_autobus': c.busStop?.toUpperCase() ?? '', // 'SANTANDER' | 'TORRELAVEGA' | 'PUENTE_VIESGO'
        'necesita_trona': c.needTrona?.toUpperCase() ?? '', // solo para menores de 12 años
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]')),
                                  ],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Campo obligatorio';
                                    }
                                    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$').hasMatch(v.trim())) {
                                      return 'Solo se permiten letras';
                                    }
                                    return null;
                                  },
                                ),
                                _TextField(
                                  controller: _email,
                                  label: 'Correo electrónico',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Campo obligatorio';
                                    }
                                    if (!_isValidEmail(v.trim())) {
                                      return 'Email no válido';
                                    }
                                    return null;
                                  },
                                ),
                                _TextField(
                                  controller: _phone,
                                  label: 'Teléfono',
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(9),
                                  ],
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Campo obligatorio';
                                    }
                                    if (!RegExp(r'^\d{9}$').hasMatch(v.trim())) {
                                      return 'Debe tener exactamente 9 dígitos';
                                    }
                                    return null;
                                  },
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
                                  if (_age == '0-12') ...[
                                    const SizedBox(height: 8),
                                    const Text('¿Necesitarás una trona?', style: TextStyle(color: Colors.white)),
                                    const SizedBox(height: 8),
                                    _RadioGroup(
                                      value: _needTrona,
                                      onChanged: (v) => setState(() => _needTrona = v),
                                      items: const [('si', 'Sí'), ('no', 'No')],
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  const Text('¿Usarás el autobús?', style: TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  _RadioGroup(
                                    value: _needTransport,
                                    onChanged: (v) => setState(() {
                                      _needTransport = v;
                                      if (v == 'no') _busStop = null; // Limpiar parada si no usa autobús
                                    }),
                                    items: const [('si', 'Sí'), ('no', 'No')],
                                  ),
                                  if (_needTransport == 'si') ...[
                                    const SizedBox(height: 12),
                                    const Text('¿Desde dónde cogerás el autobús?', style: TextStyle(color: Colors.white)),
                                    const SizedBox(height: 8),
                                    _RadioGroup(
                                      value: _busStop,
                                      onChanged: (v) => setState(() => _busStop = v),
                                      items: const [
                                        ('santander', 'Santander'),
                                        ('torrelavega', 'Torrelavega'),
                                        ('puente_viesgo', 'Puente Viesgo'),
                                      ],
                                    ),
                                  ],
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
                                        onTransportChanged: (value) => setState(() {
                                          _companions[i].needTransport = value;
                                          if (value == 'no') _companions[i].busStop = null; // Limpiar parada si no usa autobús
                                        }),
                                        onAgeChanged: (value) => setState(() => _companions[i].age = value),
                                        onTronaChanged: (value) => setState(() => _companions[i].needTrona = value),
                                        onBusStopChanged: (value) => setState(() => _companions[i].busStop = value),
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
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                              minimumSize: const Size(double.infinity, 56),
                            ),
                            child: Text(
                              _sending ? 'Enviando...' : 'Enviar confirmación',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
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
      IconData? icon,
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
              icon != null
                  ? Icon(icon, size: 24, color: const Color(0xFFD4AF37))
                  : Text(emoji, style: const TextStyle(fontSize: 24)),
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
              icon: Icons.church,
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
  final List<TextInputFormatter>? inputFormatters;
  
  const _TextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
      foregroundColor: selected ? Colors.white : gold,
      backgroundColor: selected ? gold : Colors.white.withOpacity(0.1),
      side: BorderSide(
        color: gold,
        width: selected ? 2.0 : 1.5,
      ),
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
  String? needTransport; // 'si' | 'no'
  String? busStop; // 'santander' | 'torrelavega' | 'puente_viesgo'
  String? needTrona; // 'si' | 'no' (solo para menores de 12 años)
}

class _CompanionCard extends StatelessWidget {
  final int index;
  final _CompanionData data;
  final ValueChanged<String?> onTransportChanged;
  final ValueChanged<String> onAgeChanged;
  final ValueChanged<String?> onTronaChanged;
  final ValueChanged<String?> onBusStopChanged;
  
  const _CompanionCard({
    required this.index,
    required this.data,
    required this.onTransportChanged,
    required this.onAgeChanged,
    required this.onTronaChanged,
    required this.onBusStopChanged,
  });
  
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]')),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Campo obligatorio';
              }
              if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$').hasMatch(v.trim())) {
                return 'Solo se permiten letras';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          const Text('Grupo de edad', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _RadioGroup(
            value: data.age,
            onChanged: (v) => onAgeChanged(v ?? 'adulto'),
            items: const [
              ('adulto', 'Adulto (+18)'),
              ('12-18', '12-18 años'),
              ('0-12', 'Menor 12 años'),
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
          const SizedBox(height: 12),
          const Text('¿Usarás el autobús?', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _RadioGroup(
            value: data.needTransport,
            onChanged: onTransportChanged,
            items: const [('si', 'Sí'), ('no', 'No')],
          ),
          if (data.needTransport == 'si') ...[
            const SizedBox(height: 12),
            const Text('¿Desde dónde cogerá el autobús?', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _RadioGroup(
              value: data.busStop,
              onChanged: onBusStopChanged,
              items: const [
                ('santander', 'Santander'),
                ('torrelavega', 'Torrelavega'),
                ('puente_viesgo', 'Puente Viesgo'),
              ],
            ),
          ],
          if (data.age == '0-12') ...[
            const SizedBox(height: 12),
            const Text('¿Necesitará una trona?', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _RadioGroup(
              value: data.needTrona,
              onChanged: onTronaChanged,
              items: const [('si', 'Sí'), ('no', 'No')],
            ),
          ],
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

class _FileUploadProgress {
  final String fileName;
  final int fileSize;
  double progress;
  int bytesTransferred;
  String? status;
  String? timeRemaining;
  DateTime? startTime;
  bool isComplete;
  bool hasError;
  String? errorMessage;

  _FileUploadProgress({
    required this.fileName,
    required this.fileSize,
    this.progress = 0.0,
    this.bytesTransferred = 0,
    this.status,
    this.timeRemaining,
    this.startTime,
    this.isComplete = false,
    this.hasError = false,
    this.errorMessage,
  });
}

class _UploadPageState extends State<UploadPage> {
  bool _uploading = false;
  final Map<String, _FileUploadProgress> _uploadProgress = {};

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatTime(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    }
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Future<void> _handleUpload() async {
    print('_handleUpload: Iniciando selección de archivos...');
    try {
      // En Flutter web, usar input HTML directamente es más confiable
      final completer = Completer<List<html.File>>();
      final input = html.FileUploadInputElement()
        ..accept = '.jpg,.jpeg,.png,.webp,.heic,.heif,.mp4,.mov,.avi,.mkv'
        ..multiple = true;
      
      input.onChange.listen((e) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          completer.complete(files);
        } else {
          completer.complete([]);
        }
        input.remove();
      });
      
      input.click();
      
      print('_handleUpload: Esperando selección de archivos...');
      final htmlFiles = await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          input.remove();
          return <html.File>[];
        },
      );
      
      if (htmlFiles.isEmpty) {
        print('_handleUpload: No se seleccionaron archivos');
        return;
      }
      
      print('_handleUpload: Archivos seleccionados: ${htmlFiles.length}');

      // Verificar Firebase ANTES de establecer el estado de subida
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
      
      // Inicializar el estado de subida INMEDIATAMENTE para que el usuario vea el progreso
      if (!mounted) return;
      
      final progressMap = <String, _FileUploadProgress>{};
      
      // Inicializar progreso para TODOS los archivos seleccionados usando htmlFiles
      for (final htmlFile in htmlFiles) {
        progressMap[htmlFile.name] = _FileUploadProgress(
          fileName: htmlFile.name,
          fileSize: htmlFile.size,
          status: 'Leyendo...',
        );
      }
      
      print('_handleUpload: Estableciendo estado de subida...');
      setState(() {
        _uploading = true;
        _uploadProgress.clear();
        _uploadProgress.addAll(progressMap);
      });
      print('_handleUpload: Estado establecido. _uploading: $_uploading, archivos: ${_uploadProgress.length}');
      
      // Pequeño delay para asegurar que el setState se complete y la UI se actualice
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (!mounted) return;
      
      // Leer los archivos HTML y convertirlos a bytes en paralelo
      final validFiles = <PlatformFile>[];
      
      // Leer todos los archivos en paralelo para mayor velocidad
      final readFutures = htmlFiles.map((htmlFile) async {
        try {
          // Leer el archivo usando FileReader
          final reader = html.FileReader();
          final completer = Completer<Uint8List>();
          
          reader.onLoadEnd.listen((e) {
            final result = reader.result;
            if (result is Uint8List) {
              completer.complete(result);
            } else {
              completer.completeError('No se pudo leer el archivo');
            }
          });
          
          reader.onError.listen((e) {
            completer.completeError('Error al leer el archivo');
          });
          
          reader.readAsArrayBuffer(htmlFile);
          
          final bytes = await completer.future;
          
          if (mounted) {
            setState(() {
              _uploadProgress[htmlFile.name] = _FileUploadProgress(
                fileName: htmlFile.name,
                fileSize: bytes.length,
                status: 'Pendiente',
              );
            });
          }
          
          return PlatformFile(
            name: htmlFile.name,
            size: bytes.length,
            bytes: bytes,
            path: null,
          );
        } catch (e) {
          print('_handleUpload: Error al leer archivo ${htmlFile.name}: $e');
          if (mounted) {
            setState(() {
              _uploadProgress[htmlFile.name] = _FileUploadProgress(
                fileName: htmlFile.name,
                fileSize: htmlFile.size,
                status: 'Error',
                hasError: true,
                errorMessage: 'Error al leer el archivo: $e',
              );
            });
          }
          return null;
        }
      }).toList();
      
      // Esperar a que todos los archivos se lean
      final results = await Future.wait(readFutures);
      validFiles.addAll(results.whereType<PlatformFile>());
      
      // Si no hay archivos válidos, mostrar error pero mantener el modal visible
      if (validFiles.isEmpty) {
        // Esperar un momento para que el usuario vea el error, luego cerrar
        await Future.delayed(const Duration(seconds: 3));
        
        if (mounted) {
          setState(() => _uploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Los archivos seleccionados no pudieron ser leídos. Por favor, intenta con archivos más pequeños o menos archivos a la vez.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      if (!mounted) return;
      
      // Actualizar el estado de los archivos válidos a "Pendiente"
      for (final file in validFiles) {
        if (mounted) {
          setState(() {
            _uploadProgress[file.name] = _FileUploadProgress(
              fileName: file.name,
              fileSize: file.bytes!.length,
              status: 'Pendiente',
            );
          });
        }
      }

      final scaffold = ScaffoldMessenger.of(context);
      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      int successCount = 0;
      int failCount = 0;

      // Subir archivos en paralelo con seguimiento de progreso
    final uploadFutures = validFiles.map((file) async {
    final bytes = file.bytes;
    if (bytes == null) {
        failCount++;
        if (mounted) {
          setState(() {
            _uploadProgress[file.name] = _FileUploadProgress(
              fileName: file.name,
              fileSize: 0,
              hasError: true,
              errorMessage: 'No se pudieron leer los datos del archivo',
              status: 'Error',
            );
          });
        }
        return;
      }

      final fileKey = file.name;
      final startTime = DateTime.now();

      if (mounted) {
        setState(() {
          _uploadProgress[fileKey] = _FileUploadProgress(
            fileName: file.name,
            fileSize: bytes.length,
            startTime: startTime,
            status: 'Subiendo...',
          );
        });
      }

      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}-${file.name}';
        final path = '$_galleryPath/$today/$fileName';
        final ref = storage.ref(path);
        
        final metadata = SettableMetadata(
          contentType: _inferMime(file.extension),
        );
        
        // Usar UploadTask para rastrear el progreso
        final uploadTask = ref.putData(bytes, metadata);
        
        // Escuchar el progreso
        uploadTask.snapshotEvents.listen((taskSnapshot) {
          if (!mounted) return;
          
          final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          final bytesTransferred = taskSnapshot.bytesTransferred;
          final elapsed = DateTime.now().difference(startTime);
          
          // Calcular velocidad y tiempo restante
          String? timeRemaining;
          if (progress > 0 && elapsed.inMilliseconds > 0) {
            final speed = bytesTransferred / elapsed.inMilliseconds; // bytes por milisegundo
            final remainingBytes = taskSnapshot.totalBytes - bytesTransferred;
            final remainingMs = (remainingBytes / speed).round();
            if (remainingMs > 0 && speed > 0) {
              timeRemaining = _formatTime(Duration(milliseconds: remainingMs));
            }
          }

          setState(() {
            _uploadProgress[fileKey] = _FileUploadProgress(
              fileName: file.name,
              fileSize: taskSnapshot.totalBytes,
              progress: progress,
              bytesTransferred: bytesTransferred,
              startTime: startTime,
              status: 'Subiendo...',
              timeRemaining: timeRemaining,
            );
          });
        });

        // Esperar a que termine la subida
        final taskSnapshot = await uploadTask;
        final downloadUrl = await ref.getDownloadURL();

        await firestore.collection(_galleryCollection).add({
          'url': downloadUrl,
          'approved': false,
          'created_at': FieldValue.serverTimestamp(),
          'filename': file.name,
        });

        successCount++;
        
        if (mounted) {
          setState(() {
            _uploadProgress[fileKey] = _FileUploadProgress(
              fileName: file.name,
              fileSize: taskSnapshot.totalBytes,
              progress: 1.0,
              bytesTransferred: taskSnapshot.totalBytes,
              startTime: startTime,
              status: 'Completado',
              isComplete: true,
            );
          });
        }
      } catch (e) {
        failCount++;
        if (mounted) {
          setState(() {
            _uploadProgress[fileKey] = _FileUploadProgress(
              fileName: file.name,
              fileSize: bytes.length,
              hasError: true,
              errorMessage: e.toString(),
              status: 'Error',
            );
          });
        }
      }
    }).toList();

    // Esperar a que todos los archivos terminen
    await Future.wait(uploadFutures);

    if (mounted) {
      setState(() => _uploading = false);
    }

    if (mounted) {
      // Mostrar resumen final
      if (successCount > 0 || failCount > 0) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              failCount > 0
                  ? 'Completado: $successCount exitoso(s), $failCount error(es)'
                  : '¡$successCount archivo(s) subido(s) correctamente!',
            ),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar archivos: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      // Log del error para debugging
      print('Error en _handleUpload: $e');
      print('Stack trace: $stackTrace');
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
                constraints: const BoxConstraints(maxWidth: 450),
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
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      mobile: const EdgeInsets.all(16),
                      desktop: const EdgeInsets.all(32),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              color: gold,
                              size: ResponsiveHelper.getResponsiveValue(
                                context,
                                mobile: 24,
                                desktop: 32,
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveHelper.getResponsiveValue(
                                context,
                                mobile: 8,
                                desktop: 12,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Subir Fotos / Videos',
                                style: GoogleFonts.allura(
                                  fontSize: ResponsiveHelper.getFontSize(
                                    context,
                                    mobile: 24,
                                    desktop: 36,
                                  ),
                                  color: gold,
                                  shadows: const [
                                    Shadow(color: Colors.black54, blurRadius: 3),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: gold.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.cloud_upload, color: gold, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Subiendo archivos',
                                      style: TextStyle(
                                        color: gold,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_uploadProgress.isEmpty) ...[
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(color: Color(0xFFD4AF37)),
                                          SizedBox(height: 12),
                                          Text(
                                            'Preparando archivos...',
                                            style: TextStyle(color: Colors.white70, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  ..._uploadProgress.values.map((progress) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900]?.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: progress.hasError
                                            ? Colors.red
                                            : progress.isComplete
                                                ? Colors.green
                                                : gold.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                progress.fileName,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (progress.isComplete)
                                              Icon(Icons.check_circle, color: Colors.green, size: 18)
                                            else if (progress.hasError)
                                              Icon(Icons.error, color: Colors.red, size: 18)
                                            else
                                              SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  value: progress.progress,
                                                  color: gold,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress.progress,
                                            minHeight: 6,
                                            backgroundColor: Colors.grey[800],
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              progress.hasError
                                                  ? Colors.red
                                                  : progress.isComplete
                                                      ? Colors.green
                                                      : gold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              progress.hasError
                                                  ? 'Error: ${progress.errorMessage ?? "Error desconocido"}'
                                                  : progress.isComplete
                                                      ? 'Completado'
                                                      : progress.status ?? 'Subiendo...',
                                              style: TextStyle(
                                                color: progress.hasError
                                                    ? Colors.red[300]
                                                    : progress.isComplete
                                                        ? Colors.green[300]
                                                        : Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                            if (!progress.hasError && !progress.isComplete && progress.timeRemaining != null)
                                              Text(
                                                '${(progress.progress * 100).toStringAsFixed(0)}% • ${_formatBytes(progress.bytesTransferred)} / ${_formatBytes(progress.fileSize)} • ${progress.timeRemaining} restantes',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11,
                                                ),
                                              )
                                            else if (!progress.hasError)
                                              Text(
                                                '${_formatBytes(progress.fileSize)}',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                        FilledButton(
                          onPressed: _uploading ? null : _handleUpload,
                          style: FilledButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getResponsiveValue(
                                context,
                                mobile: 20,
                                desktop: 32,
                              ),
                              horizontal: ResponsiveHelper.getResponsiveValue(
                                context,
                                mobile: 16,
                                desktop: 24,
                              ),
                            ),
                            minimumSize: const Size(double.infinity, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: ResponsiveHelper.getResponsiveValue(
                                  context,
                                  mobile: 24,
                                  desktop: 32,
                                ),
                              ),
                              SizedBox(
                                width: ResponsiveHelper.getResponsiveValue(
                                  context,
                                  mobile: 8,
                                  desktop: 12,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  _uploading ? 'Subiendo...' : 'Seleccionar y Subir Archivos',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      mobile: 16,
                                      desktop: 20,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: gold,
                            side: const BorderSide(color: gold, width: 1.5),
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getResponsiveValue(
                                context,
                                mobile: 14,
                                desktop: 16,
                              ),
                              horizontal: ResponsiveHelper.getResponsiveValue(
                                context,
                                mobile: 12,
                                desktop: 16,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.home,
                                size: ResponsiveHelper.getResponsiveValue(
                                  context,
                                  mobile: 20,
                                  desktop: 24,
                                ),
                              ),
                              SizedBox(
                                width: ResponsiveHelper.getResponsiveValue(
                                  context,
                                  mobile: 8,
                                  desktop: 10,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  'Volver a la Página Principal',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      mobile: 14,
                                      desktop: 16,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
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

// Función para exportar datos a Excel
Future<void> _exportToExcel(BuildContext context) async {
  try {
    // Mostrar indicador de carga
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generando Excel...'), duration: Duration(seconds: 2)),
      );
    }

    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection(_rsvpCollection).get();

    // Crear archivo Excel
    final excel = excel_lib.Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Confirmaciones'];

    // Encabezados
    final headers = [
      'ID',
      'Tipo',
      'Nombre',
      'Email',
      'Teléfono',
      'Asistencia',
      'Edad',
      'Alergias',
      'Usa Autobús',
      'Parada Autobús',
      'Necesita Trona',
      'Canciones Favoritas',
      'Álbum Digital',
      'Mensaje Novios',
      'Fecha Creación',
    ];
    
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = excel_lib.TextCellValue(headers[i]);
    }

    int rowIndex = 1;

    // Procesar cada documento
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final docId = doc.id;
      final createdAt = data['created_at']?.toString() ?? '';

      // Fila para el invitado principal
      final asistenciaStr = (data['asistencia']?.toString().toUpperCase() ?? '');
      final principalRow = [
        docId,
        'INVITADO PRINCIPAL',
        data['name']?.toString() ?? '',
        data['email']?.toString() ?? '',
        data['phone']?.toString() ?? '',
        asistenciaStr == 'SI' ? 'SÍ' : 'NO',
        _formatAgeForExcel(data['edad_principal']),
        data['alergias_principal']?.toString() ?? '',
        (data['necesita_transporte']?.toString().toUpperCase() ?? '') == 'SI' ? 'SÍ' : 'NO',
        _formatBusStopForExcel(data['parada_autobus']),
        (data['necesita_trona']?.toString().toUpperCase() ?? '') == 'SI' ? 'SÍ' : 'NO',
        data['canciones']?.toString() ?? '',
        (data['album_digital']?.toString().toUpperCase() ?? '') == 'SI' ? 'SÍ' : 'NO',
        data['mensaje_novios']?.toString() ?? '',
        createdAt,
      ];

      for (int i = 0; i < principalRow.length; i++) {
        sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).value = excel_lib.TextCellValue(principalRow[i].toString());
      }
      rowIndex++;

      // Filas para acompañantes
      if (data['acompanantes_json'] != null) {
        final companions = data['acompanantes_json'] as List;
        for (final companion in companions) {
          final companionMap = companion as Map<String, dynamic>;
          final companionRow = [
            docId,
            'ACOMPAÑANTE',
            companionMap['nombre']?.toString() ?? '',
            '', // Email vacío para acompañantes
            '', // Teléfono vacío para acompañantes
            asistenciaStr == 'SI' ? 'SÍ' : 'NO',
            _formatAgeForExcel(companionMap['edad']),
            companionMap['alergias']?.toString() ?? '',
            (companionMap['necesita_transporte']?.toString().toUpperCase() ?? '') == 'SI' ? 'SÍ' : 'NO',
            _formatBusStopForExcel(companionMap['parada_autobus']),
            (companionMap['necesita_trona']?.toString().toUpperCase() ?? '') == 'SI' ? 'SÍ' : 'NO',
            '', // Canciones vacío para acompañantes
            '', // Álbum digital vacío para acompañantes
            '', // Mensaje vacío para acompañantes
            createdAt,
          ];

          for (int i = 0; i < companionRow.length; i++) {
            sheet.cell(excel_lib.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex)).value = excel_lib.TextCellValue(companionRow[i].toString());
          }
          rowIndex++;
        }
      }
    }

    // Convertir a bytes
    final excelBytes = excel.save();
    if (excelBytes == null) {
      throw Exception('Error al generar el archivo Excel');
    }

    // Descargar archivo
    final blob = html.Blob([excelBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'confirmaciones_boda_${DateTime.now().toString().split(' ')[0]}.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excel exportado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

String _formatAgeForExcel(dynamic value) {
  if (value == null || value.toString().isEmpty) return '';
  final str = value.toString().toUpperCase();
  if (str == 'ADULTO' || str == 'ADULTO (+18)') return 'ADULTO (+18)';
  if (str == '12-18' || str == '12-18 AÑOS') return '12-18 AÑOS';
  if (str == '0-12' || str == 'MENOR 12 AÑOS') return 'MENOR 12 AÑOS';
  return str;
}

String _formatBusStopForExcel(dynamic value) {
  if (value == null || value.toString().isEmpty) return '';
  final str = value.toString().toUpperCase();
  if (str == 'SANTANDER') return 'SANTANDER';
  if (str == 'TORRELAVEGA') return 'TORRELAVEGA';
  if (str == 'PUENTE_VIESGO' || str == 'PUENTE VIESGO') return 'PUENTE VIESGO';
  return str;
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
            icon: const Icon(Icons.download, color: Color(0xFFD4AF37)),
            onPressed: () => _exportToExcel(context),
            tooltip: 'Exportar a Excel',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD4AF37)),
            onPressed: () {
              setState(() => _isAuthenticated = false);
              Navigator.of(context).pushReplacementNamed('/');
            },
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
                  child: FilledButton(
                    onPressed: () => setState(() => _selectedTab = 0),
                    style: FilledButton.styleFrom(
                      backgroundColor: _selectedTab == 0
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFD4AF37).withOpacity(0.5),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Confirmaciones',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: _selectedTab == 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => setState(() => _selectedTab = 1),
                    style: FilledButton.styleFrom(
                      backgroundColor: _selectedTab == 1
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFD4AF37).withOpacity(0.5),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Aprobar Fotos',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: _selectedTab == 1 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => setState(() => _selectedTab = 2),
                    style: FilledButton.styleFrom(
                      backgroundColor: _selectedTab == 2
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFD4AF37).withOpacity(0.5),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Borrar Fotos',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: _selectedTab == 2 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? const _RsvpManagementTab()
                : _selectedTab == 1
                    ? const _PhotoApprovalTab()
                    : const _DeletePhotosTab(),
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
                onTap: () => _viewRsvpDetails(context, doc),
                title: Text(
                  data['name'] ?? 'Sin nombre',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${data['email'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                    Text('Teléfono: ${data['phone'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                    Text('Asistencia: ${(data['asistencia']?.toString().toUpperCase() ?? '') == 'SI' ? 'SÍ' : 'NO'}', style: const TextStyle(color: Colors.white70)),
                    if ((data['asistencia']?.toString().toUpperCase() ?? '') == 'SI') ...[
                      Text('Adultos: ${data['num_adultos'] ?? 0}', style: const TextStyle(color: Colors.white70)),
                      Text('12-18: ${data['num_12_18'] ?? 0}', style: const TextStyle(color: Colors.white70)),
                      Text('0-12: ${data['num_0_12'] ?? 0}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ],
                ),
                leading: Icon(
                  (data['asistencia']?.toString().toUpperCase() ?? '') == 'SI' ? Icons.check_circle : Icons.cancel,
                  color: (data['asistencia']?.toString().toUpperCase() ?? '') == 'SI' ? Colors.green : Colors.red,
                  size: 28,
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
  
  Future<void> _viewRsvpDetails(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final gold = const Color(0xFFD4AF37);
    
    // Cargar acompañantes
    List<Map<String, dynamic>> companionsData = [];
    if (data['acompanantes_json'] != null) {
      companionsData = List<Map<String, dynamic>>.from(data['acompanantes_json']);
    }
    
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border(bottom: BorderSide(color: gold.withOpacity(0.3))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: gold, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Detalles de la Confirmación',
                        style: GoogleFonts.allura(
                          fontSize: 28,
                          color: gold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Información Principal', [
                        _buildDetailRow('Nombre', data['name'] ?? 'N/A'),
                        _buildDetailRow('Email', data['email'] ?? 'N/A'),
                        _buildDetailRow('Teléfono', data['phone'] ?? 'N/A'),
                        _buildDetailRow('Asistencia', (data['asistencia']?.toString().toUpperCase() ?? '') == 'SI' ? 'SÍ' : 'NO'),
                      ]),
                      if ((data['asistencia']?.toString().toUpperCase() ?? '') == 'SI') ...[
                        const SizedBox(height: 16),
                        _buildDetailSection('Información del Invitado Principal', [
                          _buildDetailRow('Edad', _formatAge(data['edad_principal'])),
                          if (data['alergias_principal'] != null && data['alergias_principal'].toString().isNotEmpty)
                            _buildDetailRow('Alergias', data['alergias_principal'] ?? 'Ninguna'),
                          if ((data['edad_principal']?.toString().toUpperCase() ?? '') == '0-12' && data['necesita_trona'] != null)
                            _buildDetailRow('¿Necesita trona?', _formatYesNo(data['necesita_trona'])),
                          if (data['necesita_transporte'] != null)
                            _buildDetailRow('¿Usa el autobús?', _formatYesNo(data['necesita_transporte'])),
                          if ((data['necesita_transporte']?.toString().toUpperCase() ?? '') == 'SI' && data['parada_autobus'] != null)
                            _buildDetailRow('Parada autobús', _formatBusStop(data['parada_autobus'])),
                        ]),
                        const SizedBox(height: 16),
                        _buildDetailSection('Acompañantes', [
                          _buildDetailRow('Viene acompañado', ((data['acompanante'] ?? data['companion'])?.toString().toUpperCase() ?? '') == 'SI' ? 'SÍ' : 'NO'),
                          if (data['num_adultos'] != null || data['num_12_18'] != null || data['num_0_12'] != null) ...[
                            const SizedBox(height: 8),
                            _buildDetailRow('Total adultos', '${data['num_adultos'] ?? 0}', indent: 0),
                            _buildDetailRow('Total 12-18 años', '${data['num_12_18'] ?? 0}', indent: 0),
                            _buildDetailRow('Total menores 12 años', '${data['num_0_12'] ?? 0}', indent: 0),
                          ],
                          if (((data['acompanante'] ?? data['companion'])?.toString().toUpperCase() ?? '') == 'SI' && companionsData.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...companionsData.asMap().entries.map((entry) {
                              final index = entry.key;
                              final companion = entry.value;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: gold.withOpacity(0.3), width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline, color: gold, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Acompañante ${index + 1}',
                                          style: TextStyle(
                                            color: gold,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow('Nombre', companion['nombre'] ?? 'N/A', indent: 0),
                                    _buildDetailRow('Edad', _formatAge(companion['edad']), indent: 0),
                                    if (companion['alergias'] != null && companion['alergias'].toString().isNotEmpty)
                                      _buildDetailRow('Alergias', companion['alergias'] ?? 'Ninguna', indent: 0),
                                    if (companion['necesita_transporte'] != null)
                                      _buildDetailRow('¿Usa autobús?', _formatYesNo(companion['necesita_transporte']), indent: 0),
                                    if ((companion['necesita_transporte']?.toString().toUpperCase() ?? '') == 'SI' && companion['parada_autobus'] != null)
                                      _buildDetailRow('Parada autobús', _formatBusStop(companion['parada_autobus']), indent: 0),
                                    if ((companion['edad']?.toString().toUpperCase() ?? '') == '0-12' && companion['necesita_trona'] != null)
                                      _buildDetailRow('¿Necesita trona?', _formatYesNo(companion['necesita_trona']), indent: 0),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ]),
                        const SizedBox(height: 16),
                        _buildDetailSection('Información Adicional', [
                          if (data['canciones'] != null && data['canciones'].toString().isNotEmpty)
                            _buildDetailRow('Canciones favoritas', data['canciones'] ?? 'N/A'),
                          _buildDetailRow('¿Desea álbum digital?', _formatYesNo(data['album_digital'])),
                          if (data['mensaje_novios'] != null && data['mensaje_novios'].toString().isNotEmpty)
                            _buildDetailRow('Mensaje para los novios', data['mensaje_novios'] ?? 'N/A'),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border(top: BorderSide(color: gold.withOpacity(0.3))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _editRsvp(context, doc);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: gold,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Editar',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailSection(String title, List<Widget> children) {
    const gold = Color(0xFFD4AF37);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {double indent = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: indent, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatYesNo(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'NO ESPECIFICADO';
    final str = value.toString().toUpperCase();
    if (str == 'SI' || str == 'SÍ' || str == 'YES') return 'SÍ';
    if (str == 'NO') return 'NO';
    return str;
  }
  
  String _formatAge(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'N/A';
    final str = value.toString().toUpperCase();
    if (str == 'ADULTO' || str == 'ADULTO (+18)') return 'ADULTO (+18)';
    if (str == '12-18' || str == '12-18 AÑOS') return '12-18 AÑOS';
    if (str == '0-12' || str == 'MENOR 12 AÑOS') return 'MENOR 12 AÑOS';
    return str;
  }
  
  String _formatBusStop(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'N/A';
    final str = value.toString().toUpperCase();
    if (str == 'SANTANDER') return 'SANTANDER';
    if (str == 'TORRELAVEGA') return 'TORRELAVEGA';
    if (str == 'PUENTE_VIESGO' || str == 'PUENTE VIESGO') return 'PUENTE VIESGO';
    return str;
  }
  
  Future<void> _editRsvp(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final gold = const Color(0xFFD4AF37);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    // Función auxiliar para normalizar valores de sí/no
    String? normalizeYesNo(String? value) {
      if (value == null || value.isEmpty || value.trim().isEmpty) return null;
      final normalized = value.trim().toLowerCase();
      if (normalized == 'si' || normalized == 'sí' || normalized == 'yes') return 'si';
      if (normalized == 'no') return 'no';
      return null;
    }
    
    // Controllers para datos principales
    final nameController = TextEditingController(text: data['name'] ?? '');
    final emailController = TextEditingController(text: data['email'] ?? '');
    final phoneController = TextEditingController(text: data['phone'] ?? '');
    final songsController = TextEditingController(text: data['canciones'] ?? '');
    final messageController = TextEditingController(text: data['mensaje_novios'] ?? '');
    
    // Estado para asistencia y acompañante - normalizar valores
    String asistencia = (data['asistencia']?.toString().trim().toLowerCase() ?? 'no');
    if (asistencia != 'si' && asistencia != 'no') asistencia = 'no';
    
    String companion = ((data['acompanante'] ?? data['companion'])?.toString().trim().toLowerCase() ?? 'no');
    if (companion != 'si' && companion != 'no') companion = 'no';
    
    String? needTransportNormalized = normalizeYesNo(data['necesita_transporte']?.toString());
    String needTransport = needTransportNormalized ?? '';
    
    String? albumDigitalNormalized = normalizeYesNo(data['album_digital']?.toString());
    String albumDigital = albumDigitalNormalized ?? '';
    
    // Edad del invitado principal
    String edadPrincipal = (data['edad_principal']?.toString().trim().toLowerCase() ?? 'adulto');
    if (edadPrincipal != 'adulto' && edadPrincipal != '12-18' && edadPrincipal != '0-12') {
      edadPrincipal = 'adulto';
    }
    
    // Alergias del invitado principal
    final allergiesPrincipalController = TextEditingController(text: data['alergias_principal']?.toString().trim() ?? '');
    
    // Trona del invitado principal
    String? needTronaPrincipalNormalized = normalizeYesNo(data['necesita_trona']?.toString());
    String needTronaPrincipal = needTronaPrincipalNormalized ?? '';
    
    // Parada de autobús del invitado principal
    String? busStopPrincipal = data['parada_autobus']?.toString().trim();
    if (busStopPrincipal != null && busStopPrincipal.isNotEmpty) {
      busStopPrincipal = busStopPrincipal.toLowerCase();
      if (busStopPrincipal != 'santander' && busStopPrincipal != 'torrelavega' && busStopPrincipal != 'puente_viesgo') {
        busStopPrincipal = null;
      }
    } else {
      busStopPrincipal = null;
    }
    
    // Cargar acompañantes
    List<Map<String, dynamic>> companionsData = [];
    if (data['acompanantes_json'] != null) {
      companionsData = List<Map<String, dynamic>>.from(data['acompanantes_json']);
    }
    
    // Controllers para acompañantes - normalizar valores de edad
    final companionControllers = companionsData.map((c) {
      String age = (c['edad']?.toString().trim() ?? 'adulto');
      // Validar que la edad sea uno de los valores permitidos
      if (age != 'adulto' && age != '12-18' && age != '0-12') {
        age = 'adulto';
      }
      return {
        'name': TextEditingController(text: c['nombre']?.toString().trim() ?? ''),
        'age': age,
        'allergies': TextEditingController(text: c['alergias']?.toString().trim() ?? ''),
        'needTransport': c['necesita_transporte']?.toString(),
        'busStop': c['parada_autobus']?.toString(),
        'needTrona': c['necesita_trona']?.toString(),
      };
    }).toList();
    
    int numCompanions = companionControllers.length;
    
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 700,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border(bottom: BorderSide(color: gold.withOpacity(0.3))),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: gold, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Editar Confirmación',
                          style: GoogleFonts.allura(
                            fontSize: 28,
                            color: gold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Información principal
                        _buildSectionTitle('Información Principal'),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 24),
                        
                        // Información del invitado principal
                        if (asistencia == 'si') ...[
                          _buildSectionTitle('Información del Invitado Principal'),
                          DropdownButtonFormField<String>(
                            value: edadPrincipal,
                            decoration: InputDecoration(
                              labelText: 'Edad',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: gold),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black),
                            items: const [
                              DropdownMenuItem(value: 'adulto', child: Text('Adulto', style: TextStyle(color: Colors.black))),
                              DropdownMenuItem(value: '12-18', child: Text('12-18 años', style: TextStyle(color: Colors.black))),
                              DropdownMenuItem(value: '0-12', child: Text('0-12 años', style: TextStyle(color: Colors.black))),
                            ],
                            onChanged: (value) {
                              setState(() {
                                edadPrincipal = value ?? 'adulto';
                                if (edadPrincipal != '0-12') {
                                  needTronaPrincipal = '';
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: allergiesPrincipalController,
                            decoration: InputDecoration(
                              labelText: 'Alergias (opcional)',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: gold),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                          if (edadPrincipal == '0-12') ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: needTronaPrincipal.isEmpty ? null : (needTronaPrincipal == 'si' || needTronaPrincipal == 'no' ? needTronaPrincipal : null),
                              decoration: InputDecoration(
                                labelText: '¿Necesita trona?',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: gold),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: null, child: Text('No especificado', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'si', child: Text('Sí', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'no', child: Text('No', style: TextStyle(color: Colors.black))),
                              ],
                              onChanged: (value) => setState(() => needTronaPrincipal = value ?? ''),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                        
                        // Asistencia
                        _buildSectionTitle('Asistencia'),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'si', label: Text('Sí')),
                            ButtonSegment(value: 'no', label: Text('No')),
                          ],
                          selected: {asistencia},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() => asistencia = newSelection.first);
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Acompañantes
                        if (asistencia == 'si') ...[
                          _buildSectionTitle('Acompañantes'),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'si', label: Text('Sí')),
                              ButtonSegment(value: 'no', label: Text('No')),
                            ],
                            selected: {companion},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                companion = newSelection.first;
                                if (companion == 'no') {
                                  numCompanions = 0;
                                  companionControllers.clear();
                                } else if (companionControllers.isEmpty) {
                                  numCompanions = 1;
                                  companionControllers.add({
                                    'name': TextEditingController(),
                                    'age': 'adulto',
                                    'allergies': TextEditingController(),
                                    'needTransport': null,
                                    'busStop': null,
                                    'needTrona': null,
                                  });
                                }
                              });
                            },
                          ),
                          if (companion == 'si') ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: gold.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: gold.withOpacity(0.5), width: 2),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Número de acompañantes:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    onPressed: numCompanions > 0
                                        ? () {
                                            setState(() {
                                              numCompanions--;
                                              companionControllers.removeLast();
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.remove, color: Colors.black87),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$numCompanions',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: numCompanions < 9
                                        ? () {
                                            setState(() {
                                              numCompanions++;
                                              companionControllers.add({
                                                'name': TextEditingController(),
                                                'age': 'adulto',
                                                'allergies': TextEditingController(),
                                                'needTransport': null,
                                                'busStop': null,
                                                'needTrona': null,
                                              });
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.add, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            ...companionControllers.asMap().entries.map((entry) {
                              final index = entry.key;
                              final controllers = entry.value;
                              return Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: gold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: gold, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gold.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: gold,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Acompañante ${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: controllers['name'] as TextEditingController,
                                      decoration: InputDecoration(
                                        labelText: 'Nombre',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: gold),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: controllers['age'] as String,
                                      decoration: InputDecoration(
                                        labelText: 'Edad',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: gold),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      dropdownColor: Colors.white,
                                      style: const TextStyle(color: Colors.black),
                                      items: const [
                                        DropdownMenuItem(value: 'adulto', child: Text('Adulto', style: TextStyle(color: Colors.black))),
                                        DropdownMenuItem(value: '12-18', child: Text('12-18 años', style: TextStyle(color: Colors.black))),
                                        DropdownMenuItem(value: '0-12', child: Text('0-12 años', style: TextStyle(color: Colors.black))),
                                      ],
                                      onChanged: (value) {
                                        setState(() => controllers['age'] = value ?? 'adulto');
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: controllers['allergies'] as TextEditingController,
                                      decoration: InputDecoration(
                                        labelText: 'Alergias (opcional)',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: gold),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: (controllers['needTransport']?.toString() ?? '').isEmpty 
                                          ? null 
                                          : ((controllers['needTransport']?.toString() == 'si' || controllers['needTransport']?.toString() == 'no') 
                                              ? controllers['needTransport']?.toString() 
                                              : null),
                                      decoration: InputDecoration(
                                        labelText: '¿Usará el autobús?',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: gold),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      dropdownColor: Colors.white,
                                      style: const TextStyle(color: Colors.black),
                                      items: const [
                                        DropdownMenuItem(value: null, child: Text('No especificado', style: TextStyle(color: Colors.black))),
                                        DropdownMenuItem(value: 'si', child: Text('Sí', style: TextStyle(color: Colors.black))),
                                        DropdownMenuItem(value: 'no', child: Text('No', style: TextStyle(color: Colors.black))),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          controllers['needTransport'] = value ?? '';
                                          if (value == 'no') {
                                            controllers['busStop'] = null;
                                          }
                                        });
                                      },
                                    ),
                                    if ((controllers['needTransport']?.toString() ?? '') == 'si') ...[
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: controllers['busStop']?.toString(),
                                        decoration: InputDecoration(
                                          labelText: 'Desde dónde cogerá el autobús?',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: gold),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: Colors.black),
                                        items: const [
                                          DropdownMenuItem(value: null, child: Text('Seleccionar', style: TextStyle(color: Colors.black))),
                                          DropdownMenuItem(value: 'santander', child: Text('Santander', style: TextStyle(color: Colors.black))),
                                          DropdownMenuItem(value: 'torrelavega', child: Text('Torrelavega', style: TextStyle(color: Colors.black))),
                                          DropdownMenuItem(value: 'puente_viesgo', child: Text('Puente Viesgo', style: TextStyle(color: Colors.black))),
                                        ],
                                        onChanged: (value) => setState(() => controllers['busStop'] = value),
                                      ),
                                    ],
                                    if ((controllers['age'] as String) == '0-12') ...[
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: (controllers['needTrona']?.toString() ?? '').isEmpty 
                                            ? null 
                                            : ((controllers['needTrona']?.toString() == 'si' || controllers['needTrona']?.toString() == 'no') 
                                                ? controllers['needTrona']?.toString() 
                                                : null),
                                        decoration: InputDecoration(
                                          labelText: '¿Necesitará una trona?',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: gold),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        dropdownColor: Colors.white,
                                        style: const TextStyle(color: Colors.black),
                                        items: const [
                                          DropdownMenuItem(value: null, child: Text('No especificado', style: TextStyle(color: Colors.black))),
                                          DropdownMenuItem(value: 'si', child: Text('Sí', style: TextStyle(color: Colors.black))),
                                          DropdownMenuItem(value: 'no', child: Text('No', style: TextStyle(color: Colors.black))),
                                        ],
                                        onChanged: (value) => setState(() => controllers['needTrona'] = value ?? ''),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                          ],
                          const SizedBox(height: 24),
                          
                          // Transporte del invitado principal
                          _buildSectionTitle('Transporte del Invitado Principal'),
                          DropdownButtonFormField<String>(
                            value: needTransport.isEmpty ? null : (needTransport == 'si' || needTransport == 'no' ? needTransport : null),
                            decoration: InputDecoration(
                              labelText: '¿Usa el autobús?',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: gold),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black),
                            items: const [
                              DropdownMenuItem(value: null, child: Text('No especificado', style: TextStyle(color: Colors.black))),
                              DropdownMenuItem(value: 'si', child: Text('Sí', style: TextStyle(color: Colors.black))),
                              DropdownMenuItem(value: 'no', child: Text('No', style: TextStyle(color: Colors.black))),
                            ],
                            onChanged: (value) {
                              setState(() {
                                needTransport = value ?? '';
                                if (needTransport == 'no') {
                                  busStopPrincipal = null;
                                }
                              });
                            },
                          ),
                          if (needTransport == 'si') ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: busStopPrincipal,
                              decoration: InputDecoration(
                                labelText: 'Desde dónde cogerá el autobús?',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: gold.withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: gold),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              dropdownColor: Colors.white,
                              style: const TextStyle(color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Seleccionar', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'santander', child: Text('Santander', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'torrelavega', child: Text('Torrelavega', style: TextStyle(color: Colors.black))),
                                DropdownMenuItem(value: 'puente_viesgo', child: Text('Puente Viesgo', style: TextStyle(color: Colors.black))),
                              ],
                              onChanged: (value) => setState(() => busStopPrincipal = value),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                        
                        // Canciones y mensaje
                        _buildSectionTitle('Información Adicional'),
                        TextField(
                          controller: songsController,
                          decoration: InputDecoration(
                            labelText: 'Canciones favoritas (opcional)',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 2,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: albumDigital.isEmpty ? null : (albumDigital == 'si' || albumDigital == 'no' ? albumDigital : null),
                          decoration: InputDecoration(
                            labelText: '¿Desea álbum digital?',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('No especificado')),
                            DropdownMenuItem(value: 'si', child: Text('Sí')),
                            DropdownMenuItem(value: 'no', child: Text('No')),
                          ],
                          onChanged: (value) => setState(() => albumDigital = value ?? ''),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            labelText: 'Mensaje para los novios (opcional)',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: gold),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 3,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border(top: BorderSide(color: gold.withOpacity(0.3))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () async {
                          try {
                            // Calcular conteos (solo acompañantes, el principal se suma después)
                            int countAdult = 0, countTeen = 0, countKid = 0;
                            if (companion == 'si' && companionControllers.isNotEmpty) {
                              for (final c in companionControllers) {
                                final age = c['age'] as String;
                                if (age == 'adulto') countAdult++;
                                if (age == '12-18') countTeen++;
                                if (age == '0-12') countKid++;
                              }
                            }
                            
                            // Preparar datos de acompañantes
                            List<Map<String, dynamic>> acompanantesJson = [];
                            if (companion == 'si' && companionControllers.isNotEmpty) {
                              acompanantesJson = companionControllers.map((c) {
                                final nameCtrl = c['name'] as TextEditingController;
                                final allergiesCtrl = c['allergies'] as TextEditingController;
                                final needTransport = c['needTransport']?.toString() ?? '';
                                final busStop = c['busStop']?.toString() ?? '';
                                final needTrona = c['needTrona']?.toString() ?? '';
                                return {
                                  'nombre': nameCtrl.text.trim().toUpperCase(),
                                  'edad': (c['age'] as String).toUpperCase(),
                                  'alergias': allergiesCtrl.text.trim().isEmpty ? null : allergiesCtrl.text.trim().toUpperCase(),
                                  'necesita_transporte': needTransport.isEmpty ? null : needTransport.toUpperCase(),
                                  'parada_autobus': busStop.isEmpty ? null : busStop.toUpperCase(),
                                  'necesita_trona': needTrona.isEmpty ? null : needTrona.toUpperCase(),
                                };
                              }).toList();
                            }
                            
                            // Calcular conteos incluyendo el invitado principal
                            if (asistencia == 'si') {
                              if (edadPrincipal == 'adulto') countAdult++;
                              if (edadPrincipal == '12-18') countTeen++;
                              if (edadPrincipal == '0-12') countKid++;
                            }
                            
                            // Actualizar documento
                            await doc.reference.update({
                              'name': nameController.text.trim().toUpperCase(),
                              'email': emailController.text.trim().toUpperCase(),
                              'phone': phoneController.text.trim().toUpperCase(),
                              'asistencia': asistencia.toUpperCase(),
                              'edad_principal': edadPrincipal.toUpperCase(),
                              'alergias_principal': allergiesPrincipalController.text.trim().isEmpty ? null : allergiesPrincipalController.text.trim().toUpperCase(),
                              'necesita_trona': needTronaPrincipal.isEmpty ? null : needTronaPrincipal.toUpperCase(),
                              'companion': companion.toUpperCase(),
                              'num_acompanantes': companion == 'si' ? companionControllers.length : 0,
                              'num_adultos': countAdult,
                              'num_12_18': countTeen,
                              'num_0_12': countKid,
                              'necesita_transporte': needTransport.isEmpty ? null : needTransport.toUpperCase(),
                              'parada_autobus': busStopPrincipal?.toUpperCase(),
                              'canciones': songsController.text.trim().isEmpty ? null : songsController.text.trim().toUpperCase(),
                              'album_digital': albumDigital.isEmpty ? null : albumDigital.toUpperCase(),
                              'mensaje_novios': messageController.text.trim().isEmpty ? null : messageController.text.trim().toUpperCase(),
                              'acompanantes_json': acompanantesJson,
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
                        style: FilledButton.styleFrom(backgroundColor: gold),
                        child: const Text('Guardar', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    // Limpiar controllers al cerrar
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    allergiesPrincipalController.dispose();
    songsController.dispose();
    messageController.dispose();
    for (final c in companionControllers) {
      (c['name'] as TextEditingController).dispose();
      (c['allergies'] as TextEditingController).dispose();
    }
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  final Map<String, bool> _loadingStates = {};
  
  bool _isVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') || 
           lowerUrl.contains('.mov') || 
           lowerUrl.contains('.webm') ||
           lowerUrl.contains('video') ||
           lowerUrl.contains('video/');
  }
  
  void _showVideoPlayer(BuildContext context, String url, String docId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(bottom: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Reproductor de Video',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: _VideoPlayerWidget(videoUrl: url),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _approvePhoto(docId);
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Aprobar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _rejectPhoto(docId);
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Rechazar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMediaWidget(String url, {String? docId}) {
    if (_isVideo(url)) {
      return GestureDetector(
        onTap: docId != null ? () => _showVideoPlayer(context, url, docId) : null,
        child: Container(
          color: Colors.grey[900],
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam, color: Color(0xFFD4AF37), size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'Video',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    if (docId != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Toca para reproducir',
                          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10),
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
    
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          _loadingStates[url] = false;
          return child;
        }
        _loadingStates[url] = true;
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
      errorBuilder: (context, error, stackTrace) {
        _loadingStates[url] = false;
        return Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        if (frame == null) {
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
                strokeWidth: 2,
              ),
            ),
          );
        }
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    
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
        
        // Ordenar por fecha en el cliente (más recientes primero)
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aCreated = aData['created_at'] as Timestamp?;
            final bCreated = bData['created_at'] as Timestamp?;
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
                    crossAxisCount = 2;
                    spacing = 8;
                  } else if (screenWidth < 900) {
                    crossAxisCount = 3;
                    spacing = 10;
                  } else if (screenWidth < 1400) {
                    crossAxisCount = 4;
                    spacing = 12;
                  } else {
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildMediaWidget(url, docId: doc.id),
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
                      icon: const Icon(Icons.chevron_left, color: gold),
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                    Text(
                      'Página ${_currentPage + 1} de $totalPages',
                      style: const TextStyle(color: gold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: gold),
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

// Tab de borrar fotos
class _DeletePhotosTab extends StatefulWidget {
  const _DeletePhotosTab();
  
  @override
  State<_DeletePhotosTab> createState() => _DeletePhotosTabState();
}

class _DeletePhotosTabState extends State<_DeletePhotosTab> {
  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  final Map<String, bool> _loadingStates = {};
  
  bool _isVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') || 
           lowerUrl.contains('.mov') || 
           lowerUrl.contains('.webm') ||
           lowerUrl.contains('video') ||
           lowerUrl.contains('video/');
  }
  
  void _showVideoPlayer(BuildContext context, String url, String docId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(bottom: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Reproductor de Video',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: _VideoPlayerWidget(videoUrl: url),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(top: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deletePhoto(docId, url);
                      },
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('Eliminar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMediaWidget(String url, {String? docId}) {
    if (_isVideo(url)) {
      return GestureDetector(
        onTap: docId != null ? () => _showVideoPlayer(context, url, docId) : null,
        child: Container(
          color: Colors.grey[900],
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam, color: Color(0xFFD4AF37), size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'Video',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    if (docId != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Toca para reproducir',
                          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10),
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
    
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          _loadingStates[url] = false;
          return child;
        }
        _loadingStates[url] = true;
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
      errorBuilder: (context, error, stackTrace) {
        _loadingStates[url] = false;
        return Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        if (frame == null) {
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
                strokeWidth: 2,
              ),
            ),
          );
        }
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
    );
  }
  
  Future<void> _deletePhoto(String id, String? url) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta foto? Esta acción no se puede deshacer.'),
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
        // Eliminar de Firestore
        await FirebaseFirestore.instance.collection(_galleryCollection).doc(id).delete();
        
        // Intentar eliminar de Storage si hay URL
        if (url != null) {
          try {
            final ref = FirebaseStorage.instance.refFromURL(url);
            await ref.delete();
          } catch (e) {
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto eliminada'), backgroundColor: Colors.green),
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
  
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(_galleryCollection)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay fotos para eliminar'));
        }
        
        // Ordenar por fecha en el cliente (más recientes primero)
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aCreated = aData['created_at'] as Timestamp?;
            final bCreated = bData['created_at'] as Timestamp?;
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
                    crossAxisCount = 2;
                    spacing = 8;
                  } else if (screenWidth < 900) {
                    crossAxisCount = 3;
                    spacing = 10;
                  } else if (screenWidth < 1400) {
                    crossAxisCount = 4;
                    spacing = 12;
                  } else {
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
                      final approved = data['approved'] ?? false;
                      
                      if (url == null) return const SizedBox.shrink();
                      
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildMediaWidget(url, docId: doc.id),
                          ),
                          if (approved)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Aprobada',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Material(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(24),
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                                onPressed: () => _deletePhoto(doc.id, url),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                                tooltip: 'Eliminar',
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
                      icon: const Icon(Icons.chevron_left, color: gold),
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                    Text(
                      'Página ${_currentPage + 1} de $totalPages',
                      style: const TextStyle(color: gold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: gold),
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
    );
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
  
  bool _isVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') || 
           lowerUrl.contains('.mov') || 
           lowerUrl.contains('.webm') ||
           lowerUrl.contains('video') ||
           lowerUrl.contains('video/');
  }
  
  Widget _buildOptimizedImage(String url) {
    // Detectar si es video
    if (_isVideo(url)) {
      return Container(
        color: Colors.grey[900],
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam, color: Color(0xFFD4AF37), size: 48),
                  const SizedBox(height: 8),
                  const Text(
                    'Video',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
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
        if (frame == null) {
          return Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
                strokeWidth: 2,
              ),
            ),
          );
        }
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white54),
        );
      },
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
                    .orderBy('created_at', descending: true)
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
