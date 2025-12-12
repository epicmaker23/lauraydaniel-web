import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:add_2_calendar/add_2_calendar.dart';

// Configuración de Appwrite
const _appwriteEndpoint = String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
const _appwriteProjectId = String.fromEnvironment('APPWRITE_PROJECT_ID', defaultValue: '');
const _appwriteApiKey = String.fromEnvironment('APPWRITE_API_KEY', defaultValue: '');
const _appwriteDatabaseId = String.fromEnvironment('APPWRITE_DATABASE_ID', defaultValue: '');
const _rsvpCollectionId = String.fromEnvironment('APPWRITE_RSVP_COLLECTION_ID', defaultValue: '');
const _galleryCollectionId = String.fromEnvironment('APPWRITE_GALLERY_COLLECTION_ID', defaultValue: '');
const _appwriteStorageId = String.fromEnvironment('APPWRITE_STORAGE_ID', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
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
        colorSchemeSeed: const Color(0xFFD4AF37), // dorado
        scaffoldBackgroundColor: Colors.black, // se verá cubierto por fondo
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color(0xFF3B3B3B),
              displayColor: const Color(0xFF3B3B3B),
            ),
      ),
      routes: {
        '/': (_) => const HomePage(),
        '/formulario': (_) => const PreinscriptionPage(),
        '/admin': (_) => _isAdminAuthenticated() ? const AdminPage() : const AdminLoginPage(),
        '/galeria': (_) => _isGalleryAuthenticated() ? const GalleryPage() : const GalleryLoginPage(),
        '/upload': (_) => const UploadPage(),
        // Por compatibilidad si llega sin slash
        'formulario': (_) => const PreinscriptionPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/formulario' || settings.name == 'formulario') {
          return MaterialPageRoute(builder: (_) => const PreinscriptionPage());
        }
        if (settings.name == '/admin' || settings.name == 'admin') {
          return MaterialPageRoute(
            builder: (_) => _isAdminAuthenticated() ? const AdminPage() : const AdminLoginPage(),
          );
        }
        if (settings.name == '/galeria' || settings.name == 'galeria') {
          return MaterialPageRoute(
            builder: (_) => _isGalleryAuthenticated() ? const GalleryPage() : const GalleryLoginPage(),
          );
        }
        if (settings.name == '/upload' || settings.name == 'upload') {
          return MaterialPageRoute(builder: (_) => const UploadPage());
        }
        return null;
      },
      onGenerateInitialRoutes: (String initialRouteName) {
        final path = Uri.base.path;
        if (path == '/formulario' || path == 'formulario' || path == '/formulario/') {
          return [MaterialPageRoute(builder: (_) => const PreinscriptionPage())];
        }
        if (path == '/admin' || path == 'admin' || path == '/admin/') {
          return [
            MaterialPageRoute(
              builder: (_) => _isAdminAuthenticated() ? const AdminPage() : const AdminLoginPage(),
            )
          ];
        }
        if (path == '/galeria' || path == 'galeria' || path == '/galeria/') {
          return [
            MaterialPageRoute(
              builder: (_) => _isGalleryAuthenticated() ? const GalleryPage() : const GalleryLoginPage(),
            )
          ];
        }
        if (path == '/upload' || path == 'upload' || path == '/upload/') {
          return [MaterialPageRoute(builder: (_) => const UploadPage())];
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
          // Fondo con imagen (widget directo para evitar issues con web decoration)
          Positioned.fill(
            child: Image.asset(
              'assets/images/imagenPrincipal.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          // Capa translúcida para simular blur dark
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
                  subtitle: 'Vuestra presencia es nuestro mejor regalo',
                  detail: 'Número de cuenta disponible',
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
                  detail: 'Revive tus momentos',
                  onTap: () => Navigator.pushNamed(context, '/galeria'),
                ),
                _InfoCard(
                  icon: Icons.movie,
                  title: 'Fotomatón',
                  subtitle: 'Disponible tras la boda',
                  detail: 'Descarga de fotos',
                  onTap: () => _mostrarFotomaton(context),
                ),
              ];
              // Rejilla responsiva con ancho máximo para evitar tarjetas gigantes
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
    final Color border = const Color(0xFFD4AF37);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Círculo para logo/foto
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: border, width: 4),
                  ),
                  padding: EdgeInsets.zero,
                        alignment: Alignment.center,
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: _LogoWithTransparentBackground(
                      imagePath: 'assets/images/logoNuevo.png',
                      width: 172,
                      height: 172,
                      fallbackText: 'L&D',
                      textStyle: GoogleFonts.allura(
                            fontSize: 90,
                            color: border,
                            fontWeight: FontWeight.w600,
                            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Laura & Daniel',
                  style: GoogleFonts.allura(
                    fontSize: 48,
                    color: const Color(0xFFD4AF37),
                    shadows: const [Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 3)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '25 de Abril de 2026',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, shadows: const [Shadow(color: Colors.black45, blurRadius: 2)]),
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
  final String target; // yyyy-MM-dd HH:mm:ss local
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
  final String? subtitle;
  final String? detail;
  final VoidCallback? onTap;
  const _InfoCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.detail,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final borderColor = const Color(0xFFD4AF37);
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
                      if (subtitle != null) ...[
                      const SizedBox(height: 6),
                        Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: subSize)),
                      ],
                      if (detail != null) ...[
                      const SizedBox(height: 6),
                      Text(
                          detail!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: detailSize),
                      ),
                      ],
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

// Helpers
Future<void> _abrirMapa(String direccion) async {
  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(direccion)}');
  await launchUrl(url, mode: LaunchMode.externalApplication);
}

void _mostrarRecordatorios(BuildContext context) {
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
              Row(
                children: [
                  const Text('📅 ', style: TextStyle(fontSize: 32)),
                  Text('Recordatorios', style: GoogleFonts.allura(fontSize: 36, color: const Color(0xFFD4AF37))),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Añade recordatorios a tu calendario para no perderte nuestra boda.\n\nPuedes crear dos recordatorios:'),
              const SizedBox(height: 16),
              // Recordatorio 1 semana antes
              _RecordatorioButton(
                titulo: 'Recordatorio 1 semana antes',
                descripcion: 'Te recordamos que nuestra boda es en una semana',
                fecha: DateTime(2026, 4, 18, 10, 0),
                duracion: const Duration(hours: 1),
              ),
              const SizedBox(height: 12),
              // Recordatorio 3 horas antes
              _RecordatorioButton(
                titulo: 'Recordatorio 3 horas antes',
                descripcion: '¡Nuestra boda es en 3 horas!',
                fecha: DateTime(2026, 4, 25, 9, 30),
                duracion: const Duration(hours: 1),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RecordatorioButton extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final Duration duracion;

  const _RecordatorioButton({
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.duracion,
  });

  Future<void> _crearRecordatorio(BuildContext context) async {
    if (kIsWeb) {
      // Para web, usar enlace de Google Calendar
      final fechaInicio = fecha.toUtc();
      final fechaFin = fecha.add(duracion).toUtc();
      
      // Formato para Google Calendar: YYYYMMDDTHHMMSSZ
      final formatoFecha = (DateTime fecha) {
        return '${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}T${fecha.hour.toString().padLeft(2, '0')}${fecha.minute.toString().padLeft(2, '0')}${fecha.second.toString().padLeft(2, '0')}Z';
      };
      
      final tituloEncoded = Uri.encodeComponent('Boda Laura & Daniel');
      final descripcionEncoded = Uri.encodeComponent(descripcion);
      final ubicacionEncoded = Uri.encodeComponent('Finca Villasevil');
      
      final googleCalendarUrl = 'https://calendar.google.com/calendar/render?action=TEMPLATE'
          '&text=$tituloEncoded'
          '&dates=${formatoFecha(fechaInicio)}/${formatoFecha(fechaFin)}'
          '&details=$descripcionEncoded'
          '&location=$ubicacionEncoded';
      
      final url = Uri.parse(googleCalendarUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se abrirá Google Calendar para añadir el evento'),
              backgroundColor: Color(0xFFD4AF37),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      // Para móvil (Android/iOS), usar add_2_calendar
      try {
        final event = Event(
          title: 'Boda Laura & Daniel',
          description: descripcion,
          location: 'Finca Villasevil',
          startDate: fecha,
          endDate: fecha.add(duracion),
          iosParams: const IOSParams(
            reminder: Duration(minutes: 15), // Recordatorio 15 minutos antes en iOS
          ),
          androidParams: const AndroidParams(
            emailInvites: [],
          ),
        );

        final result = await Add2Calendar.addEvent2Cal(event);
        if (result && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recordatorio "$titulo" añadido a tu calendario'),
              backgroundColor: const Color(0xFFD4AF37),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear el recordatorio: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _crearRecordatorio(context),
        icon: const Icon(Icons.event, color: Colors.white),
        label: Text(titulo),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

void _mostrarTransporte(BuildContext context) {
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
                    const Text('🚌 ', style: TextStyle(fontSize: 32)),
                    Text('Transporte', style: GoogleFonts.allura(fontSize: 36, color: const Color(0xFFD4AF37))),
                  ],
                ),
                const SizedBox(height: 16),
                // Introducción
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🚌 ', style: TextStyle(fontSize: 20)),
                    const Expanded(
                      child: Text(
                        'Servicio de autobús gratuito para invitados',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(left: 28),
                  child: Text(
                    'Ponemos a disposición de nuestros invitados un servicio de autobús gratuito que facilitará el desplazamiento hasta la celebración.',
                  ),
                ),
                const SizedBox(height: 20),
                // Ruta
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🗺️ ', style: TextStyle(fontSize: 20)),
                    const Expanded(
                      child: Text(
                        'RUTA:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 28),
                  child: Text('Los autobuses realizarán la ruta Santander - Villasevil y viceversa.'),
                ),
                const SizedBox(height: 20),
                // Paradas
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📍 ', style: TextStyle(fontSize: 20)),
                    const Expanded(
                      child: Text(
                        'PARADAS:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Se realizarán paradas tanto a la ida como a la vuelta en Santander, Torrelavega y Puente Viesgo para facilitar el acceso a todos los invitados.'),
                      const SizedBox(height: 8),
                      const Text('Los puntos exactos de paradas en estas localidades se facilitarán más adelante en la web.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Horarios
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⏰ ', style: TextStyle(fontSize: 20)),
                    const Expanded(
                      child: Text(
                        'HORARIOS:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 28),
                  child: Text('Los horarios exactos se facilitarán más adelante en la web. No obstante, informamos que habrá dos horarios de vuelta disponibles:'),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('  • Primer horario: 21:30 horas'),
                      const SizedBox(height: 6),
                      const Text('  • Segundo horario: 00:30 horas'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Actualizaciones
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📢 ', style: TextStyle(fontSize: 20)),
                    const Expanded(
                      child: Text(
                        'Os mantendremos informados de cualquier actualización a través de esta web.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
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
                    const Text('🏨 ', style: TextStyle(fontSize: 32)),
                Text('Alojamiento', style: GoogleFonts.allura(fontSize: 36, color: const Color(0xFFD4AF37))),
                  ],
                ),
                const SizedBox(height: 12),
                _hotel('Gran Hotel Balneario de Puente Viesgo (4*)',
                    'Puente Viesgo (8 km de la ceremonia)',
                    'Spa, Balneario, Templo del Agua, Piscinas',
                    'https://balneariodepuenteviesgo.com'),
                const SizedBox(height: 12),
                _hotel('Posada La Anjana (3*)',
                    'Puente Viesgo (8 km de la ceremonia)',
                    'Vistas al río Pas, Jardín, Parking gratuito',
                    'https://posadalaanjana.es/'),
                const SizedBox(height: 12),
                _hotel('Posada Rincón del Pas (3*)',
                    'Puente Viesgo centro',
                    'Terraza, Bar, Jardín, WiFi',
                    'https://www.booking.com/hotel/es/posada-rincon-del-pas.html'),
                const SizedBox(height: 12),
                _hotel('Abba Palacio de Soñanes Hotel (4*)',
                    'Villacarriedo (15 km de la ceremonia)',
                    'Palacio histórico, Jardín, Parking, WiFi',
                    'https://www.abbahoteles.com/es/hoteles/abba-palacio-de-sonanes-hotel/'),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📍 ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text('Ubicación: $ubicacion')),
        ],
      ),
      const SizedBox(height: 4),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨ ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text('Servicios: $servicios')),
        ],
      ),
      const SizedBox(height: 6),
      InkWell(
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🔗 ', style: TextStyle(fontSize: 14)),
            Text('Abrir web', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    ],
  );
}

void _mostrarRegalos(BuildContext context) {
  final mostrarCuenta = ValueNotifier<bool>(false);
  showDialog(
    context: context,
    builder: (dialogContext) => ValueListenableBuilder<bool>(
      valueListenable: mostrarCuenta,
      builder: (context, cuentaVisible, _) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎁 ', style: TextStyle(fontSize: 32)),
                    Text(
                      'Regalos',
                      style: GoogleFonts.allura(fontSize: 36, color: const Color(0xFFD4AF37)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Primer texto
                const Text(
                  'Vuestra presencia es nuestro mejor regalo',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    'No tendremos lista de bodas. Lo más importante para nosotros es compartir este día especial con vosotros.',
                  ),
                ),
                const SizedBox(height: 20),
                // Segundo texto
                const Text(
                  'Si queréis tener un detalle con nosotros',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(left: 0),
                  child: Text(
                    'Aquí os dejamos nuestro número de cuenta para que podáis hacernos un regalo si lo deseáis.',
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => mostrarCuenta.value = !mostrarCuenta.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cuentaVisible ? const Color(0xFFF5F5F5) : Colors.transparent,
                      border: Border.all(
                        color: cuentaVisible ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: cuentaVisible
                              ? SelectableText(
                                  'ES61 0081 2714 1500 0827 1440',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD4AF37),
                                  ),
                                )
                              : const Text(
                                  '[Haz clic aquí para ver el número de cuenta]',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                        ),
                        if (cuentaVisible)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              color: const Color(0xFFD4AF37),
                              onPressed: () {
                                html.window.navigator.clipboard?.writeText('ES61 0081 2714 1500 0827 1440');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Número de cuenta copiado!'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          ),
                        Icon(
                          cuentaVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Mil gracias por acompañarnos en este día tan especial.',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      mostrarCuenta.dispose();
                      Navigator.pop(context);
                    },
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

void _mostrarParking(BuildContext context) {
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
              Row(
                children: [
                  const Text('🅿️ ', style: TextStyle(fontSize: 32)),
                  Text('Aparcamiento', style: GoogleFonts.allura(fontSize: 36, color: const Color(0xFFD4AF37))),
                ],
              ),
              const SizedBox(height: 16),
              // Aparcamiento Ceremonia
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⛪ ', style: TextStyle(fontSize: 20)),
                  const Expanded(
                    child: Text(
                      'CEREMONIA:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 28),
                child: Text('Aparcamiento disponible en los alrededores del Convento de San Francisco de El Soto.'),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: InkWell(
                  onTap: () async {
                    final url = Uri.parse('https://maps.app.goo.gl/qxfQCxtks6mswXry7');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map, color: Color(0xFFD4AF37), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Ver ubicación del aparcamiento',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Aparcamiento Celebración
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎉 ', style: TextStyle(fontSize: 20)),
                  const Expanded(
                    child: Text(
                      'CELEBRACIÓN:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 28),
                child: Text('Se puede aparcar en los alrededores de la finca, en el pueblo. También hay un aparcamiento grande a 5 minutos andando de la finca, siguiendo la carretera nacional.'),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: InkWell(
                  onTap: () async {
                    final url = Uri.parse('https://maps.app.goo.gl/JGaGz6RskTJeDiCy7');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map, color: Color(0xFFD4AF37), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Ver ubicación del aparcamiento',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _mostrarFotomaton(BuildContext context) {
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
              Row(
                children: [
                  const Text('📸 ', style: TextStyle(fontSize: 32)),
                  Text('Fotomatón', style: GoogleFonts.allura(fontSize: 36, color: const Color(0xFFD4AF37))),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Descarga tus fotos divertidas del fotomatón. Disponible después de la boda.'),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// =================== FORMULARIO DE PREINSCRIPCIÓN ===================
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

  String? _attendance; // 'si' | 'no'
  String _age = 'adulto'; // adulto | 12-18 | 0-12
  String? _companion; // 'si' | 'no'
  int _numCompanions = 1;
  List<_CompanionData> _companions = [];
  String? _needTransport; // 'si' | 'no'
  String? _ownCar; // 'si' | 'no'
  String? _albumDigital; // 'si' | 'no'
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
        _companions.addAll(List.generate(_numCompanions - _companions.length, (_) => _CompanionData()));
      } else if (_companions.length > _numCompanions) {
        _companions = _companions.sublist(0, _numCompanions);
      }
    });
  }

  bool _isValidEmail(String v) {
    final r = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return r.hasMatch(v);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_attendance == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La confirmación de asistencia es obligatoria.')));
      return;
    }
    if (_attendance == 'si') {
      if (_companion == null || _needTransport == null || _ownCar == null || _albumDigital == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa los campos obligatorios.')));
        return;
      }
      if (_companion == 'si') {
        for (var i = 0; i < _companions.length; i++) {
          if (_companions[i].name.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nombre acompañante ${i + 1} obligatorio.')));
            return;
          }
        }
      }
    }

    setState(() => _sending = true);
    try {
      final payload = _buildRsvpPayload();
      await _sendRsvpToAppwrite(payload);
      
      if (mounted) {
        // Limpiar formulario después de enviar exitosamente
        _name.clear();
        _email.clear();
        _phone.clear();
        _allergies.clear();
        _songs.clear();
        _message.clear();
        setState(() {
          _attendance = null;
          _age = 'adulto';
          _companion = null;
          _needTransport = null;
          _ownCar = null;
          _albumDigital = null;
          _companions.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Confirmación de asistencia enviada!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar la confirmación. Por favor, inténtalo de nuevo.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Map<String, dynamic> _buildRsvpPayload() {
    // Contadores de edades (incluyendo invitado principal si asiste)
    int countAdult = 0, countTeen = 0, countKid = 0;
    if (_attendance == 'si') {
      if (_age == 'adulto') countAdult++;
      if (_age == '12-18') countTeen++;
      if (_age == '0-12') countKid++;
    }
    if (_companion == 'si') {
      for (final c in _companions) {
        // Solo contar acompañantes que van a asistir
        if (c.asistencia == 'si') {
        if (c.age == 'adulto') countAdult++;
        if (c.age == '12-18') countTeen++;
        if (c.age == '0-12') countKid++;
        }
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
      'necesita_transporte': (_needTransport ?? 'NO').toUpperCase(),
      'coche_propio': (_ownCar ?? 'NO').toUpperCase(),
      'canciones': _songs.text.trim().isEmpty ? null : _songs.text.trim().toUpperCase(),
      'album_digital': (_albumDigital ?? 'NO').toUpperCase(),
      'mensaje_novios': _message.text.trim().isEmpty ? null : _message.text.trim().toUpperCase(),
      'created_at': DateTime.now().toIso8601String(),
      'origen_form': 'FLUTTER_WEB',
    };
    if (_companion == 'si' && _companions.isNotEmpty) {
      data['acompanantes_json'] = _companions
          .map((c) => {
                'nombre': c.name.text.trim().toUpperCase(),
                'edad': c.age.toUpperCase(),
                'asistencia': c.asistencia.toUpperCase(),
                'alergias': c.allergies.text.trim().isEmpty ? null : c.allergies.text.trim().toUpperCase(),
              })
          .toList();
    }
    return data;
  }

  Future<void> _sendRsvpToAppwrite(Map<String, dynamic> payload) async {
    // Validación estricta de variables
    if (_appwriteEndpoint.isEmpty) {
      throw 'APPWRITE_ENDPOINT no configurado. Valor actual: "$_appwriteEndpoint"';
    }
    if (_appwriteProjectId.isEmpty) {
      throw 'APPWRITE_PROJECT_ID no configurado. Valor actual: "$_appwriteProjectId"';
    }
    if (_appwriteDatabaseId.isEmpty) {
      throw 'APPWRITE_DATABASE_ID no configurado. Valor actual: "$_appwriteDatabaseId"';
    }
    if (_rsvpCollectionId.isEmpty) {
      throw 'APPWRITE_RSVP_COLLECTION_ID no configurado. Valor actual: "$_rsvpCollectionId"';
    }
    
    // Verificar que el endpoint NO es Supabase
    if (_appwriteEndpoint.contains('supabase') || _appwriteEndpoint.contains('epicmaker.dev')) {
      throw 'ERROR: El endpoint parece ser de Supabase: $_appwriteEndpoint. Debe ser api.lauraydaniel.es';
    }
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Appwrite-Project': _appwriteProjectId,
    };
    
    // Si hay API Key, la usamos
    if (_appwriteApiKey.isNotEmpty) {
      headers['X-Appwrite-Key'] = _appwriteApiKey;
    }
    
    // Appwrite API: POST /v1/databases/{databaseId}/collections/{collectionId}/documents
    // El endpoint ya incluye /v1, así que solo añadimos la ruta
    // Asegurar que el endpoint termine con /v1 y no tenga barra final
    String endpoint = _appwriteEndpoint.trim();
    if (endpoint.endsWith('/')) {
      endpoint = endpoint.substring(0, endpoint.length - 1);
    }
    if (!endpoint.endsWith('/v1')) {
      endpoint = '$endpoint/v1';
    }
    
    final urlString = '$endpoint/databases/$_appwriteDatabaseId/collections/$_rsvpCollectionId/documents';
    
    // Validar que la URL sea absoluta (debe empezar con http:// o https://)
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      throw 'Error de configuración: URL inválida';
    }
    
    final uri = Uri.parse(urlString);
    
    // Appwrite espera el payload con documentId y data
    // Limpiar y formatear el payload según los tipos esperados por Appwrite
    final cleanPayload = <String, dynamic>{};
    payload.forEach((key, value) {
      if (value == null) {
        // Omitir valores null
        return;
      }
      
      // Convertir tipos según lo esperado por Appwrite
      if (key == 'created_at' && value is String) {
        // Appwrite espera formato ISO 8601 completo con timezone
        try {
          final dt = DateTime.parse(value);
          cleanPayload[key] = dt.toUtc().toIso8601String();
        } catch (e) {
          // Si falla el parseo, usar el valor original
          cleanPayload[key] = value;
        }
      } else if (key == 'acompanantes_json' && value is List) {
        // Convertir lista a JSON string para el tipo string en Appwrite
        cleanPayload[key] = jsonEncode(value);
      } else {
        cleanPayload[key] = value;
      }
    });
    
    // Appwrite requiere documentId: 'unique()' para generar ID automáticamente
    final appwritePayload = {
      'documentId': 'unique()',
      'data': cleanPayload,
    };
    
    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(appwritePayload),
    );
    
    if (resp.statusCode >= 300) {
      String errorMessage = 'Error al procesar la solicitud';
      try {
        final errorJson = jsonDecode(resp.body) as Map<String, dynamic>?;
        if (errorJson != null && errorJson.containsKey('message')) {
          errorMessage = errorJson['message'] as String;
        }
      } catch (e) {
        // Si no se puede parsear, usar mensaje genérico
      }
      throw errorMessage;
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
                    gradient: LinearGradient(colors: [
                      Colors.black.withOpacity(.35),
                      Colors.black.withOpacity(.55),
                    ]),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(blurRadius: 40, color: Colors.black38, offset: Offset(0, 10))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Column(
                            children: [
                              _LogoCircle(),
                              const SizedBox(height: 12),
                              Text('Laura & Daniel', style: GoogleFonts.allura(fontSize: 36, color: const Color(0xFFD4AF37), shadows: const [Shadow(color: Colors.black54, blurRadius: 3)])),
                              const SizedBox(height: 4),
                              const Text('Confirma tu asistencia', style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 16),
                            ],
                          ),
                          const _EventDetailsSection(),
                          // Datos
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
                                    if (v!.trim().isEmpty) {
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
                                    if (v!.trim().isEmpty) {
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
                                    if (v!.trim().isEmpty) {
                                      return 'Campo obligatorio';
                                    }
                                    if (v.trim().length != 9) {
                                      return 'El teléfono debe tener 9 dígitos';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Asistencia
                          _Section(
                            title: 'Confirmación de asistencia',
                            child: _RadioGroup(
                              value: _attendance,
                              onChanged: (v) => setState(() => _attendance = v),
                              items: const [('si', 'Sí, asistiré'), ('no', 'No podré asistir')],
                            ),
                          ),
                          if (_attendance == 'si') ...[
                            // Información adicional
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
                                  _TextField(controller: _allergies, label: 'Alergias o intolerancias', maxLines: 3),
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
                                        IconButton(onPressed: _numCompanions > 1 ? () => _setCompanions(_numCompanions - 1) : null, icon: const Icon(Icons.remove)),
                                        Text('$_numCompanions', style: const TextStyle(color: Colors.white)),
                                        IconButton(onPressed: _numCompanions < 9 ? () => _setCompanions(_numCompanions + 1) : null, icon: const Icon(Icons.add)),
                                        const SizedBox(width: 8),
                                        const Text('Mínimo 1 · Máximo 9', style: TextStyle(color: Colors.white70)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    for (int i = 0; i < _companions.length; i++)
                                      _CompanionCard(
                                        index: i + 1,
                                        data: _companions[i],
                                        onAgeChanged: (String newAge) {
                                          setState(() {
                                            _companions[i].age = newAge;
                                          });
                                        },
                                        onAsistenciaChanged: (String newAsistencia) {
                                          setState(() {
                                            _companions[i].asistencia = newAsistencia;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            // Resumen de invitados por edad (solo lectura)
                            _Section(
                              title: 'Resumen de invitados por edad',
                              child: Builder(
                                builder: (context) {
                                  // Calcular totales automáticamente
                                  int totalAdult = 0, totalTeen = 0, totalKid = 0;
                                  if (_attendance == 'si') {
                                    if (_age == 'adulto') totalAdult++;
                                    if (_age == '12-18') totalTeen++;
                                    if (_age == '0-12') totalKid++;
                                  }
                                  if (_companion == 'si') {
                                    for (final c in _companions) {
                                      // Solo contar acompañantes que van a asistir
                                      if (c.asistencia == 'si') {
                                        if (c.age == 'adulto') totalAdult++;
                                        if (c.age == '12-18') totalTeen++;
                                        if (c.age == '0-12') totalKid++;
                                      }
                                    }
                                  }
                                  
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 2),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Verifica que los números coincidan con lo que has seleccionado:',
                                          style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildTotalCounter('Adultos (+18)', totalAdult),
                                            _buildTotalCounter('12-18 años', totalTeen),
                                            _buildTotalCounter('Menores de 12', totalKid),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Total de invitados: ${totalAdult + totalTeen + totalKid}',
                                            style: const TextStyle(
                                              color: Color(0xFFD4AF37),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                ),
                              ),
                            // Transporte
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
                                  const Text('¿Llevarás coche propio? (para organizar parking)', style: TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  _RadioGroup(
                                    value: _ownCar,
                                    onChanged: (v) => setState(() => _ownCar = v),
                                    items: const [('si', 'Sí'), ('no', 'No')],
                                  ),
                                ],
                              ),
                            ),
                            // Entretenimiento
                            _Section(
                              title: 'Entretenimiento',
                              child: _TextField(controller: _songs, label: '¿Qué canciones te gustaría escuchar?', maxLines: 3),
                            ),
                            // Comunicación
                            _Section(
                              title: 'Comunicación',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('¿Te gustaría recibir el álbum digital?', style: TextStyle(color: Colors.white)),
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
                          // Mensaje
                          _Section(title: 'Mensaje especial', child: _TextField(controller: _message, label: 'Mensaje para los novios', maxLines: 3)),
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

  Widget _buildTotalCounter(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text('$value', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _LogoCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4AF37), width: 3),
        color: Colors.transparent,
        boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black45, offset: Offset(0, 2))],
      ),
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      child: ClipOval(
        clipBehavior: Clip.antiAlias,
        child: _LogoWithTransparentBackground(
          imagePath: 'assets/images/logoNuevo.png',
          width: 154,
          height: 154,
          fallbackText: 'L&D',
          textStyle: GoogleFonts.allura(
            fontSize: 72,
            color: const Color(0xFFD4AF37),
            fontWeight: FontWeight.w600,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
      ),
    );
  }
}

class _LogoWithTransparentBackground extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final String fallbackText;
  final TextStyle textStyle;

  const _LogoWithTransparentBackground({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.fallbackText,
    required this.textStyle,
  });

  @override
  State<_LogoWithTransparentBackground> createState() => _LogoWithTransparentBackgroundState();
}

class _LogoWithTransparentBackgroundState extends State<_LogoWithTransparentBackground> {
  html.ImageElement? _processedImage;
  bool _isProcessing = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    if (kIsWeb) {
      setState(() => _isProcessing = true);
      try {
        final image = html.ImageElement(src: widget.imagePath);
        await image.onLoad.first;
        
        final canvas = html.CanvasElement(width: image.width!, height: image.height!);
        final ctx = canvas.context2D;
        ctx.drawImage(image, 0, 0);
        
        final imageData = ctx.getImageData(0, 0, canvas.width!, canvas.height!);
        final data = imageData.data;
        
        // Procesar píxeles: fondo blanco a dorado, dibujo (letras, circunferencia, flores, palo) a translúcido
        // Color dorado: #D4AF37 = RGB(212, 175, 55)
        const doradoR = 212;
        const doradoG = 175;
        const doradoB = 55;
        
        for (int i = 0; i < data.length; i += 4) {
          final r = data[i];
          final g = data[i + 1];
          final b = data[i + 2];
          final a = data[i + 3];
          
          // Calcular el brillo del píxel
          final brightness = (r + g + b) / 3;
          
          // Si el píxel es blanco puro o casi blanco (fondo), convertirlo a dorado
          if (brightness > 245 && a > 200) {
            // Fondo blanco: convertir a dorado sólido
            data[i] = doradoR;     // R = dorado
            data[i + 1] = doradoG; // G = dorado
            data[i + 2] = doradoB; // B = dorado
            data[i + 3] = 255;     // A = opaco (dorado sólido)
          } else {
            // Todo lo demás (letras, circunferencia, flores, palo) hacerlo translúcido/transparente
            data[i + 3] = 0; // A = completamente transparente
          }
        }
        
        ctx.putImageData(imageData, 0, 0);
        
        final processedImage = html.ImageElement();
        processedImage.src = canvas.toDataUrl();
        await processedImage.onLoad.first;
        
        // Registrar el elemento para HtmlElementView
        final viewType = 'logo-${widget.imagePath.hashCode}';
        ui_web.platformViewRegistry.registerViewFactory(
          viewType,
          (int viewId) => processedImage,
        );
        
        if (mounted) {
          setState(() {
            _processedImage = processedImage;
            _isProcessing = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isProcessing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || (!kIsWeb && _isProcessing)) {
      return Center(
        child: Text(
          widget.fallbackText,
          style: widget.textStyle,
        ),
      );
    }

    if (kIsWeb && _processedImage != null) {
      _processedImage!.style.width = '${widget.width}px';
      _processedImage!.style.height = '${widget.height}px';
      _processedImage!.style.objectFit = 'contain';
      _processedImage!.style.display = 'block';
      _processedImage!.style.margin = '0 auto';
      _processedImage!.style.position = 'relative';
      _processedImage!.style.left = '50%';
      _processedImage!.style.transform = 'translateX(-50%)';
      
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: HtmlElementView(
            viewType: 'logo-${widget.imagePath.hashCode}',
          ),
        ),
      );
    }

    // Fallback a imagen normal mientras se procesa
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset(
            widget.imagePath,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Text(
              widget.fallbackText,
              style: widget.textStyle,
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
    const gold = Color(0xFFD4AF37);
    Widget detailCard({
      String? emoji,
      IconData? iconData,
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
              // Cabecera con alto fijo: icono + título alineados horizontalmente entre tarjetas
              SizedBox(
                height: 74,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 34,
                      child: Center(
                        child: iconData != null
                            ? Icon(iconData, color: gold, size: 30)
                            : Text(
                                emoji ?? '',
                                style: const TextStyle(fontSize: 26),
                              ),
                      ),
                    ),
              const SizedBox(height: 6),
                    SizedBox(
                      height: 18,
                      child: Center(
                        child: Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // fin cabecera fija
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
      child: LayoutBuilder(builder: (context, c) {
        final width = c.maxWidth;
        final cross = width >= 800 ? 3 : 1;
        final children = <Widget>[
          detailCard(
            iconData: Icons.church,
            title: 'Ceremonia',
            lines: const ['Convento de San Francisco de El Soto', 'Soto‑Iruz – 12:30h'],
          ),
          detailCard(
            iconData: Icons.celebration,
            title: 'Celebración',
            lines: const ['Finca La Real Labranza de Villasevil', '14:00h'],
          ),
          detailCard(
            iconData: Icons.event_available,
            title: 'Fecha',
            lines: const ['Sábado, 25 de Abril de 2026'],
          ),
        ];
        // Altura fija por tarjeta para evitar desbordes, contenido centrado.
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
      }),
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
          Text(title, style: GoogleFonts.allura(fontSize: 28, color: const Color(0xFFD4AF37), shadows: const [Shadow(color: Colors.black45, blurRadius: 2)])),
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
  const _RadioGroup({required this.value, required this.onChanged, required this.items});
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
  String asistencia = 'si'; // 'si' | 'no'
  final TextEditingController allergies = TextEditingController();
}

class _CompanionCard extends StatelessWidget {
  final int index;
  final _CompanionData data;
  final ValueChanged<String> onAgeChanged;
  final ValueChanged<String> onAsistenciaChanged;
  const _CompanionCard({
    required this.index,
    required this.data,
    required this.onAgeChanged,
    required this.onAsistenciaChanged,
  });
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border.all(color: gold),
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
          const Text('¿Asistirá a la boda?', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Sí'),
                selected: data.asistencia == 'si',
                onSelected: (selected) {
                  if (selected) onAsistenciaChanged('si');
                },
                selectedColor: gold,
                labelStyle: TextStyle(
                  color: data.asistencia == 'si' ? Colors.black : Colors.black87,
                  fontWeight: data.asistencia == 'si' ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              ChoiceChip(
                label: const Text('No'),
                selected: data.asistencia == 'no',
                onSelected: (selected) {
                  if (selected) onAsistenciaChanged('no');
                },
                selectedColor: gold,
                labelStyle: TextStyle(
                  color: data.asistencia == 'no' ? Colors.black : Colors.black87,
                  fontWeight: data.asistencia == 'no' ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Grupo de edad', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Adulto (+18)'),
                selected: data.age == 'adulto',
                onSelected: (selected) {
                  if (selected) onAgeChanged('adulto');
                },
                selectedColor: gold,
                labelStyle: TextStyle(
                  color: data.age == 'adulto' ? Colors.black : Colors.black87,
                  fontWeight: data.age == 'adulto' ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              ChoiceChip(
                label: const Text('12-18 años'),
                selected: data.age == '12-18',
                onSelected: (selected) {
                  if (selected) onAgeChanged('12-18');
                },
                selectedColor: gold,
                labelStyle: TextStyle(
                  color: data.age == '12-18' ? Colors.black : Colors.black87,
                  fontWeight: data.age == '12-18' ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              ChoiceChip(
                label: const Text('Menor 12 años'),
                selected: data.age == '0-12',
                onSelected: (selected) {
                  if (selected) onAgeChanged('0-12');
                },
                selectedColor: gold,
                labelStyle: TextStyle(
                  color: data.age == '0-12' ? Colors.black : Colors.black87,
                  fontWeight: data.age == '0-12' ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: data.allergies,
            decoration: const InputDecoration(labelText: 'Alergias o intolerancias (opcional)'),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// =================== Subida de imágenes y vídeos a Appwrite ===================
Future<bool> _uploadMediaWithAppwrite(BuildContext context, {VoidCallback? onComplete}) async {
  return await _uploadViaRest(context, onComplete: onComplete);
}

String _inferMime(String? ext) {
  final e = (ext ?? '').toLowerCase();
  // Formatos de imagen
  if (e == 'jpg' || e == 'jpeg') return 'image/jpeg';
  if (e == 'png') return 'image/png';
  if (e == 'webp') return 'image/webp';
  if (e == 'gif') return 'image/gif';
  if (e == 'bmp') return 'image/bmp';
  if (e == 'svg') return 'image/svg+xml';
  if (e == 'heic' || e == 'heif') return 'image/heic';
  if (e == 'tiff' || e == 'tif') return 'image/tiff';
  // Formatos de video
  if (e == 'mp4' || e == 'm4v') return 'video/mp4';
  if (e == 'mov') return 'video/quicktime';
  if (e == 'avi') return 'video/x-msvideo';
  if (e == 'mkv') return 'video/x-matroska';
  if (e == 'webm') return 'video/webm';
  if (e == 'flv') return 'video/x-flv';
  if (e == 'wmv') return 'video/x-ms-wmv';
  if (e == '3gp') return 'video/3gpp';
  return 'application/octet-stream';
}

Future<bool> _uploadViaRest(BuildContext context, {VoidCallback? onComplete}) async {
  // Selección de archivos (fotos y videos)
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    type: FileType.media, // Permite seleccionar fotos y videos
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No seleccionaste archivos.')));
    return false;
  }
  if (_appwriteEndpoint.isEmpty || _appwriteProjectId.isEmpty || _appwriteStorageId.isEmpty || _appwriteDatabaseId.isEmpty || _galleryCollectionId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backend no configurado. Faltan variables de Appwrite.')));
    return false;
    }

    final scaffold = ScaffoldMessenger.of(context);
  
  // Mostrar diálogo de progreso
  final uploadProgress = <String, double>{};
  final uploadStatus = <String, String>{};
  bool uploadCompleted = false;
  int successCount = 0;
  int failCount = 0;
  void Function()? updateDialog;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        updateDialog = () => setDialogState(() {});
        return AlertDialog(
          title: const Text('Subiendo archivos'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: ${result.files.length} archivo(s)'),
                const SizedBox(height: 16),
                ...result.files.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  final fileName = file.name.length > 30 ? '${file.name.substring(0, 30)}...' : file.name;
                  final progress = uploadProgress[file.name] ?? 0.0;
                  final status = uploadStatus[file.name] ?? 'Esperando...';
                  final fileSizeMB = (file.size ?? 0) / (1024 * 1024);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${index + 1}. $fileName',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              fileSizeMB > 0 ? '${fileSizeMB.toStringAsFixed(1)} MB' : '',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            status.contains('Error') || status.contains('Falló')
                                ? Colors.red
                                : status.contains('Completado')
                                    ? Colors.green
                                    : const Color(0xFFD4AF37),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            color: status.contains('Error') || status.contains('Falló')
                                ? Colors.red
                                : status.contains('Completado')
                                    ? Colors.green
                                    : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (uploadCompleted) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Completado: $successCount exitoso(s), $failCount fallido(s)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: failCount > 0 ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: uploadCompleted
              ? [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cerrar'),
                  ),
                ]
              : [],
        );
      },
    ),
  );
  
  // Ejecutar subida después de mostrar el diálogo
  Future.microtask(() async {
    // Construir endpoint
    String endpoint = _appwriteEndpoint.trim();
    if (endpoint.endsWith('/')) {
      endpoint = endpoint.substring(0, endpoint.length - 1);
    }
    if (!endpoint.endsWith('/v1')) {
      endpoint = '$endpoint/v1';
    }

    // Subir archivos secuencialmente para mejor control
    for (int i = 0; i < result.files.length; i++) {
      final file = result.files[i];
      final bytes = file.bytes;
      
        if (bytes == null) {
        uploadStatus[file.name] = 'Error: No se pudo leer el archivo';
        failCount++;
          continue;
        }

      final fileSizeMB = bytes.length / (1024 * 1024);
      uploadProgress[file.name] = 0.0;
      uploadStatus[file.name] = 'Preparando... (${fileSizeMB.toStringAsFixed(1)} MB)';
      
      // Actualizar diálogo
      updateDialog?.call();

      uploadStatus[file.name] = 'Subiendo...';
      uploadProgress[file.name] = 0.1;
      updateDialog?.call();
      
      final storageUrl = Uri.parse('$endpoint/storage/buckets/$_appwriteStorageId/files');
      final storageRequest = http.MultipartRequest('POST', storageUrl);
      
      // Headers requeridos
      storageRequest.headers['X-Appwrite-Project'] = _appwriteProjectId;
      if (_appwriteApiKey.isNotEmpty) {
        storageRequest.headers['X-Appwrite-Key'] = _appwriteApiKey;
      }
      
      final mime = _inferMime(file.extension);
      // Agregar archivo con Content-Type correcto
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
              bytes,
        filename: file.name,
        contentType: mime != null ? MediaType.parse(mime) : null,
      );
      storageRequest.files.add(multipartFile);
      
      // fileId es opcional, Appwrite puede generarlo automáticamente
      storageRequest.fields['fileId'] = 'unique()';
      
      uploadProgress[file.name] = 0.2;
      uploadStatus[file.name] = 'Enviando datos al servidor...';
      updateDialog?.call();
      
      final startTime = DateTime.now();
      
      // Simular progreso durante la subida para archivos grandes
      Timer? progressTimer;
      if (fileSizeMB > 10) {
        progressTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
          final elapsed = DateTime.now().difference(startTime).inSeconds;
          // Simular progreso gradual (no real, pero da feedback visual)
          if (uploadProgress[file.name]! < 0.8) {
            uploadProgress[file.name] = (0.2 + (elapsed / 120) * 0.6).clamp(0.2, 0.8);
            uploadStatus[file.name] = 'Subiendo... (${elapsed}s)';
            updateDialog?.call();
          }
        });
      }
      
      try {
        final sendStartTime = DateTime.now();
        
        // Usar timeout más largo para videos grandes
        final timeoutDuration = fileSizeMB > 50 
            ? const Duration(minutes: 20)  // 20 minutos para archivos > 50MB
            : const Duration(minutes: 10); // 10 minutos para archivos más pequeños
        
        // Usar un timeout y detectar si la conexión está activa
        final storageResponse = await storageRequest.send().timeout(
          timeoutDuration,
          onTimeout: () {
            progressTimer?.cancel();
            throw TimeoutException('La subida del archivo ${file.name} (${fileSizeMB.toStringAsFixed(1)} MB) excedió el tiempo límite. El archivo puede ser demasiado grande o la conexión es muy lenta.');
          },
        );
        
        progressTimer?.cancel();
        uploadProgress[file.name] = 0.8;
        uploadStatus[file.name] = 'Procesando respuesta...';
        updateDialog?.call();
      
        final responseStartTime = DateTime.now();
        
        final storageResponseBody = await http.Response.fromStream(storageResponse).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Timeout leyendo la respuesta del servidor');
          },
        );
        
        if (storageResponse.statusCode >= 300) {
          final errorMsg = 'Error ${storageResponse.statusCode}: ${storageResponseBody.body}';
          
          String statusMsg = 'Error ${storageResponse.statusCode}';
          if (storageResponse.statusCode == 502) {
            statusMsg = 'Error 502 Bad Gateway: El servidor rechazó el archivo (${fileSizeMB.toStringAsFixed(1)} MB). Verifica los límites de tamaño en Appwrite y los timeouts del servidor.';
          } else if (storageResponse.statusCode == 0 || storageResponseBody.body.contains('CORS')) {
            statusMsg = 'Error CORS: Ve a Appwrite → Settings → Platforms → Agregar plataforma web → URL: http://localhost:8080';
          } else {
            statusMsg = 'Error ${storageResponse.statusCode}: ${storageResponseBody.body.length > 100 ? storageResponseBody.body.substring(0, 100) + "..." : storageResponseBody.body}';
          }
          
          uploadStatus[file.name] = statusMsg;
          uploadProgress[file.name] = 0.0;
          failCount++;
          updateDialog?.call();
          continue;
        }
        
        final storageData = jsonDecode(storageResponseBody.body) as Map<String, dynamic>;
        uploadProgress[file.name] = 0.9;
        updateDialog?.call();
        
        final fileId = storageData[r'$id'] as String? ?? storageData['id'] as String?;
        
        if (fileId == null) {
          uploadStatus[file.name] = 'Error: No se obtuvo ID del archivo';
          uploadProgress[file.name] = 0.0;
          failCount++;
          updateDialog?.call();
          continue;
        }
        
        uploadStatus[file.name] = 'Creando registro...';
        updateDialog?.call();
        
        // 2. Crear documento en la colección de galería con referencia al archivo
        final docUrl = Uri.parse('$endpoint/databases/$_appwriteDatabaseId/collections/$_galleryCollectionId/documents');
        
        final docRequest = http.Request('POST', docUrl);
        
        docRequest.headers['Content-Type'] = 'application/json';
        docRequest.headers['X-Appwrite-Project'] = _appwriteProjectId;
        if (_appwriteApiKey.isNotEmpty) {
          docRequest.headers['X-Appwrite-Key'] = _appwriteApiKey;
        }
        
        final docPayload = {
          'documentId': 'unique()',
          'data': {
            'fileId': fileId,
            'approved': false,
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        };
        
        docRequest.body = jsonEncode(docPayload);
        
        final docResponse = await docRequest.send();
        final docResponseBody = await http.Response.fromStream(docResponse);
        
        if (docResponse.statusCode >= 300) {
          uploadStatus[file.name] = 'Error creando registro';
          uploadProgress[file.name] = 0.0;
          failCount++;
        } else {
          uploadStatus[file.name] = 'Completado ✓';
          uploadProgress[file.name] = 1.0;
          successCount++;
        }
        
        updateDialog?.call();
      } catch (e, stackTrace) {
        progressTimer?.cancel();
        String errorMsg = e.toString();
        String userMsg = 'Error desconocido';
        
        // Detectar múltiples errores
        final hasCors = errorMsg.contains('CORS') || errorMsg.contains('Access-Control-Allow-Origin') || errorMsg.contains('Failed to fetch');
        final has502 = errorMsg.contains('502') || errorMsg.contains('Bad Gateway') || errorMsg.contains('ERR_FAILED 502');
        
        if (hasCors && has502) {
          userMsg = 'Error CORS y 502: Configura "localhost:8080" como plataforma en Appwrite (Settings → Platforms) y verifica los límites de tamaño de archivo en el servidor.';
        } else if (hasCors) {
          userMsg = 'Error CORS: Ve a Appwrite → Settings → Platforms → Agregar plataforma web → URL: http://localhost:8080';
        } else if (has502) {
          userMsg = 'Error 502 Bad Gateway: El servidor rechazó el archivo (${fileSizeMB.toStringAsFixed(1)} MB). Verifica los límites de tamaño en Appwrite (_APP_STORAGE_LIMIT) y los timeouts del servidor.';
        } else if (errorMsg.contains('TimeoutException') || errorMsg.contains('timeout')) {
          userMsg = 'Timeout: El archivo es muy grande (${fileSizeMB.toStringAsFixed(1)} MB) o la conexión es muy lenta. Intenta con un archivo más pequeño o verifica tu conexión.';
        } else if (errorMsg.contains('SocketException') || errorMsg.contains('Connection')) {
          userMsg = 'Error de conexión: La conexión con el servidor se perdió. Verifica tu conexión a internet.';
        } else {
          userMsg = errorMsg.length > 60 ? errorMsg.substring(0, 60) + '...' : errorMsg;
        }
        
        uploadStatus[file.name] = userMsg;
        uploadProgress[file.name] = 0.0;
        failCount++;
        updateDialog?.call();
      }
    }

    // Marcar como completado
    uploadCompleted = true;
    updateDialog?.call();
    
    if (successCount > 0 && context.mounted) {
      scaffold.showSnackBar(SnackBar(
        content: Text('✅ $successCount archivo(s) subido(s) correctamente${failCount > 0 ? ". $failCount fallaron." : ""}'),
        backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
        duration: const Duration(seconds: 5),
      ));
      
      // Ejecutar callback si se proporcionó (incluso si algunos fallaron, si hubo al menos un éxito)
      if (onComplete != null && successCount > 0) {
        onComplete();
      }
    }
    
    return successCount > 0;
  });
  
  return false;
}

// =================== AUTENTICACIÓN ADMIN ===================
bool _isAdminAuthenticated() {
  try {
    final authKey = html.window.localStorage['admin_authenticated'];
    return authKey == 'true';
      } catch (e) {
    return false;
  }
}

void _setAdminAuthenticated(bool value) {
  try {
    if (value) {
      html.window.localStorage['admin_authenticated'] = 'true';
    } else {
      html.window.localStorage.remove('admin_authenticated');
    }
  } catch (e) {
    // Error silencioso al guardar autenticación
  }
}

// =================== AUTENTICACIÓN GALERÍA ===================
bool _isGalleryAuthenticated() {
  try {
    final authKey = html.window.localStorage['gallery_authenticated'];
    return authKey == 'true';
  } catch (e) {
    return false;
  }
}

void _setGalleryAuthenticated(bool value) {
  try {
    if (value) {
      html.window.localStorage['gallery_authenticated'] = 'true';
    } else {
      html.window.localStorage.remove('gallery_authenticated');
    }
  } catch (e) {
    // Error silencioso al guardar autenticación
  }
}

// =================== PÁGINA DE LOGIN ADMIN ===================
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa todos los campos';
      });
    return;
  }

    if (username == 'boda' && password == '25deabril') {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      _setAdminAuthenticated(true);
      
      // Redirigir a la página de admin
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminPage()),
        );
      });
    } else {
      setState(() {
        _errorMessage = 'Usuario o contraseña incorrectos';
        _passwordController.clear();
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Administración',
                      style: GoogleFonts.allura(
                        fontSize: 36,
                        color: const Color(0xFFD4AF37),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD4AF37)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD4AF37)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      onSubmitted: (_) => _login(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[900]?.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =================== PÁGINA DE LOGIN GALERÍA ===================
class GalleryLoginPage extends StatefulWidget {
  const GalleryLoginPage({super.key});
  @override
  State<GalleryLoginPage> createState() => _GalleryLoginPageState();
}

class _GalleryLoginPageState extends State<GalleryLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, completa todos los campos';
      });
    return;
  }

    if (username == 'boda' && password == '25deabril') {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      _setGalleryAuthenticated(true);
      
      // Redirigir a la página de galería
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GalleryPage()),
        );
      });
    } else {
      setState(() {
        _errorMessage = 'Usuario o contraseña incorrectos';
        _passwordController.clear();
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              color: Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Galería',
                      style: GoogleFonts.allura(
                        fontSize: 36,
                        color: const Color(0xFFD4AF37),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Usuario',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD4AF37)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD4AF37)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      onSubmitted: (_) => _login(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[900]?.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =================== PÁGINA DE GALERÍA ===================
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});
  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_appwriteEndpoint.isEmpty || _appwriteProjectId.isEmpty || _appwriteDatabaseId.isEmpty || _galleryCollectionId.isEmpty) {
        setState(() {
          _errorMessage = 'Backend no configurado';
          _isLoading = false;
        });
        return;
      }

      String endpoint = _appwriteEndpoint.trim();
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }

      final url = Uri.parse('$endpoint/databases/$_appwriteDatabaseId/collections/$_galleryCollectionId/documents');
      
      final response = await http.get(
        url,
      headers: {
          'X-Appwrite-Project': _appwriteProjectId,
          if (_appwriteApiKey.isNotEmpty) 'X-Appwrite-Key': _appwriteApiKey,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final documents = data['documents'] as List<dynamic>? ?? [];
        
        // Primero obtener la lista de archivos que realmente existen en el storage
        final existingFileIds = <String>{};
        try {
          final storageListUrl = Uri.parse('$endpoint/storage/buckets/$_appwriteStorageId/files');
          final storageListResponse = await http.get(
            storageListUrl,
            headers: {
              'X-Appwrite-Project': _appwriteProjectId,
              if (_appwriteApiKey.isNotEmpty) 'X-Appwrite-Key': _appwriteApiKey,
            },
          ).timeout(const Duration(seconds: 15));
          
          if (storageListResponse.statusCode == 200) {
            final storageData = jsonDecode(storageListResponse.body) as Map<String, dynamic>;
            final storageFiles = storageData['files'] as List<dynamic>? ?? [];
            for (final file in storageFiles) {
              final fileData = file as Map<String, dynamic>;
              final id = fileData[r'$id'] as String?;
              if (id != null) {
                existingFileIds.add(id);
              }
            }
          }
        } catch (e) {
          // Error silencioso al verificar archivos
        }
        
        // Solo agregar fotos cuyos archivos realmente existen en el storage
        final photos = <Map<String, dynamic>>[];
        for (final doc in documents) {
          final docData = doc as Map<String, dynamic>;
          final fileId = docData['fileId'] as String?;
          // Solo agregar si tiene fileId válido y el archivo existe en el storage
          if (fileId != null && fileId.isNotEmpty && existingFileIds.contains(fileId)) {
            // Obtener URL de preview del archivo
            final fileUrl = '$endpoint/storage/buckets/$_appwriteStorageId/files/$fileId/view?project=$_appwriteProjectId';
            photos.add({
              'id': docData[r'$id'] as String? ?? '',
              'fileId': fileId,
              'url': fileUrl,
              'uploaded_at': docData['uploaded_at'] as String? ?? '',
            });
          }
        }
        
        // Ordenar fotos por fecha de subida (más recientes primero)
        photos.sort((a, b) {
          final dateA = a['uploaded_at'] as String? ?? '';
          final dateB = b['uploaded_at'] as String? ?? '';
          if (dateA.isEmpty && dateB.isEmpty) return 0;
          if (dateA.isEmpty) return 1; // Las sin fecha van al final
          if (dateB.isEmpty) return -1; // Las sin fecha van al final
          try {
            final dtA = DateTime.parse(dateA);
            final dtB = DateTime.parse(dateB);
            return dtB.compareTo(dtA); // Orden descendente (más recientes primero)
          } catch (e) {
            // Si hay error al parsear, comparar como string
            return dateB.compareTo(dateA);
          }
        });
        
        setState(() {
          _photos = photos;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar fotos: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadNewFiles() async {
    await _uploadMediaWithAppwrite(
      context,
      onComplete: () {
        // Esperar un momento para que los archivos estén disponibles en el storage
        // y luego recargar automáticamente después de subir
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _loadPhotos();
          }
        });
      },
    );
  }

  Future<void> _downloadPhoto(Map<String, dynamic> photo) async {
    try {
      final url = photo['url'] as String;
      final fileId = photo['fileId'] as String;
      final uploadedAt = photo['uploaded_at'] as String? ?? '';
      
      // Determinar extensión basada en la URL
      String extension = 'jpg';
      if (url.contains('.mp4') || url.contains('video')) {
        extension = 'mp4';
      } else if (url.contains('.mov')) {
        extension = 'mov';
      } else if (url.contains('.png')) {
        extension = 'png';
      } else if (url.contains('.jpeg') || url.contains('.jpg')) {
        extension = 'jpg';
      }
      
      // Crear nombre de archivo más descriptivo
      String fileName = 'foto_$fileId.$extension';
      if (uploadedAt.isNotEmpty) {
        try {
          final date = DateTime.parse(uploadedAt);
          final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}';
          fileName = 'foto_${dateStr}_$fileId.$extension';
        } catch (e) {
          // Si falla el parseo, usar el nombre por defecto
        }
      }
      
      // Crear un elemento anchor para descargar el archivo
      final anchor = html.AnchorElement(href: url);
      anchor.download = fileName;
      anchor.target = '_blank';
      html.document.body?.append(anchor);
      anchor.click();
      // Eliminar el elemento después de un breve delay
      Future.delayed(const Duration(milliseconds: 100), () {
        anchor.remove();
      });
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

  Future<void> _downloadAllPhotos() async {
    if (_photos.isEmpty) return;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Iniciando descarga de ${_photos.length} archivo(s)...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    // Descargar cada foto con un pequeño delay para evitar bloqueos del navegador
    int downloaded = 0;
    for (int i = 0; i < _photos.length; i++) {
      await _downloadPhoto(_photos[i]);
      downloaded++;
      // Esperar un poco entre descargas para evitar problemas
      if (i < _photos.length - 1) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Descarga completada: $downloaded archivo(s)'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Fotos / Videos',
          style: GoogleFonts.allura(
            fontSize: 28,
            color: const Color(0xFFD4AF37),
          ),
        ),
        actions: [
          // Botón de descargar todas las fotos - siempre visible cuando hay fotos
          if (_photos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton.icon(
                onPressed: _downloadAllPhotos,
                icon: const Icon(Icons.download, size: 20),
                label: const Text('Descargar todas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.upload),
            tooltip: 'Subir archivos',
            onPressed: _uploadNewFiles,
            color: const Color(0xFFD4AF37),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              _setGalleryAuthenticated(false);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            color: const Color(0xFFD4AF37),
          ),
        ],
      ),
      floatingActionButton: _photos.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _downloadAllPhotos,
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.download),
              label: const Text('Descargar todo'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPhotos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _photos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No hay fotos aún', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _uploadNewFiles,
                            icon: const Icon(Icons.upload),
                            label: const Text('Subir primera foto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPhotos,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _photos.length == 1 ? 1 : (_photos.length == 2 ? 2 : 3),
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          final isVideo = photo['url'].toString().contains('.mp4') || 
                                         photo['url'].toString().contains('.mov') ||
                                         photo['url'].toString().contains('video');
                          void openViewer() {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(16),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: isVideo
                                          ? SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.9,
                                              height: MediaQuery.of(context).size.height * 0.8,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.videocam, size: 64, color: Colors.white),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'Video',
                                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      html.window.open(photo['url'] as String, '_blank');
                                                    },
                                                    icon: const Icon(Icons.play_arrow),
                                                    label: const Text('Reproducir video'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFFD4AF37),
                                                      foregroundColor: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : InteractiveViewer(
                                              child: Image.network(
                                                photo['url'] as String,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.red, size: 48),
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
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => _downloadPhoto(photo),
                                              borderRadius: BorderRadius.circular(25),
                                              child: Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.8),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(0xFFD4AF37),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.download,
                                                  color: Color(0xFFD4AF37),
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white, size: 32),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Stack(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: openViewer,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: isVideo
                                          ? Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.network(
                                                  photo['url'] as String,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Container(
                                                    color: Colors.grey[800],
                                                    child: const Icon(Icons.videocam, color: Colors.grey),
                                                  ),
                                                ),
                                                const Center(
                                                  child: Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
                                                ),
                                              ],
                                            )
                                          : Image.network(
                                              photo['url'] as String,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: Colors.grey[800],
                                                child: const Icon(Icons.image, color: Colors.grey),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Material(
                                  color: Colors.black.withOpacity(0.85),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => _downloadPhoto(photo),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.download,
                                        color: Color(0xFFD4AF37),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
    );
  }
}

// =================== PÁGINA DE SUBIDA PÚBLICA (QR) ===================
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});
  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _isUploading = false;

  Future<void> _uploadFiles() async {
    setState(() {
      _isUploading = true;
    });
    
    await _uploadMediaWithAppwrite(context);
    
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo dorado
                  _LogoWithTransparentBackground(
                    imagePath: 'assets/images/logoNuevo.png',
                    width: 172,
                    height: 172,
                    fallbackText: 'L&D',
                    textStyle: GoogleFonts.allura(
                      fontSize: 64,
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Subir Fotos / Videos',
                    style: GoogleFonts.allura(
                      fontSize: 36,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Revive tus momentos',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Botón de subida
                  SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadFiles,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Icon(Icons.cloud_upload, size: 48),
                      label: Text(
                        _isUploading ? 'Subiendo archivos...' : 'Seleccionar y Subir Archivos',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Instrucciones
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Instrucciones',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Puedes seleccionar múltiples archivos a la vez\n'
                          '• Se admiten fotos y videos\n'
                          '• Los archivos se subirán automáticamente',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón para volver al inicio
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    ),
                    icon: const Icon(Icons.home),
                    label: const Text('Volver al inicio'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
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
}

// =================== PÁGINA DE ADMINISTRACIÓN ===================
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> _rsvps = [];
  Map<String, String> _documentIds = {}; // Mapa de índice a documentId
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Verificar autenticación antes de cargar datos
    if (!_isAdminAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminLoginPage()),
        );
      });
      return;
    }
    _loadRsvps();
  }

  Future<void> _loadRsvps() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      String endpoint = _appwriteEndpoint.trim();
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }
      if (!endpoint.endsWith('/v1')) {
        endpoint = '$endpoint/v1';
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'X-Appwrite-Project': _appwriteProjectId,
      };

      if (_appwriteApiKey.isNotEmpty) {
        headers['X-Appwrite-Key'] = _appwriteApiKey;
      }

      final url = Uri.parse('$endpoint/databases/$_appwriteDatabaseId/collections/$_rsvpCollectionId/documents');
      final resp = await http.get(url, headers: headers);

      if (resp.statusCode >= 300) {
        throw 'Error al cargar datos';
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final documents = data['documents'] as List<dynamic>? ?? [];

      final List<Map<String, dynamic>> loadedRsvps = [];
      final Map<String, String> loadedIds = {};
      
      for (int i = 0; i < documents.length; i++) {
        final doc = documents[i] as Map<String, dynamic>;
        
        // Guardar el ID del documento
        final docId = doc[r'$id'] as String? ?? doc['id'] as String? ?? '';
        if (docId.isNotEmpty) {
          loadedIds[i.toString()] = docId;
        }
        
        // En Appwrite, cuando guardamos con 'data', los datos están dentro de 'data'
        // Pero también pueden estar directamente en el documento
        Map<String, dynamic>? docData = doc['data'] as Map<String, dynamic>?;
        
        // Si no hay 'data', intentar usar el documento completo pero excluir metadatos
        if (docData == null || docData.isEmpty) {
          docData = <String, dynamic>{};
          doc.forEach((key, value) {
            // Excluir campos de metadatos de Appwrite
            if (!key.startsWith('\$') && 
                key != 'permissions' && 
                key != r'$collectionId' && 
                key != r'$databaseId') {
              docData![key] = value;
            }
          });
        }
        
        // Parsear acompañantes_json si existe
        if (docData['acompanantes_json'] != null) {
          try {
            if (docData['acompanantes_json'] is String) {
              docData['acompanantes_json'] = jsonDecode(docData['acompanantes_json'] as String);
            }
          } catch (e) {
            // Error silencioso al parsear acompañantes
          }
        }
        
        loadedRsvps.add(docData ?? <String, dynamic>{});
      }
      
      setState(() {
        _rsvps = loadedRsvps;
        _documentIds = loadedIds;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteRsvp(BuildContext context, int index, String documentId) async {
    if (documentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo identificar el documento')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este RSVP? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      String endpoint = _appwriteEndpoint.trim();
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }
      if (!endpoint.endsWith('/v1')) {
        endpoint = '$endpoint/v1';
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'X-Appwrite-Project': _appwriteProjectId,
      };

      if (_appwriteApiKey.isNotEmpty) {
        headers['X-Appwrite-Key'] = _appwriteApiKey;
      }

      final url = Uri.parse('$endpoint/databases/$_appwriteDatabaseId/collections/$_rsvpCollectionId/documents/$documentId');
      final resp = await http.delete(url, headers: headers);

      if (resp.statusCode >= 300) {
        throw 'Error ${resp.statusCode}: ${resp.body}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RSVP eliminado correctamente')),
        );
        _loadRsvps(); // Recargar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  Future<void> _editRsvp(BuildContext context, int index, String documentId, Map<String, dynamic> rsvp) async {
    if (documentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo identificar el documento')),
      );
      return;
    }

    // Crear controladores con los valores actuales
    final nameController = TextEditingController(text: rsvp['name']?.toString() ?? '');
    final emailController = TextEditingController(text: rsvp['email']?.toString() ?? '');
    final phoneController = TextEditingController(text: rsvp['phone']?.toString() ?? '');
    final alergiasController = TextEditingController(text: rsvp['alergias_principal']?.toString() ?? '');
    final cancionesController = TextEditingController(text: rsvp['canciones']?.toString() ?? '');
    final mensajeController = TextEditingController(text: rsvp['mensaje_novios']?.toString() ?? '');

    String? asistencia = rsvp['asistencia']?.toString().toLowerCase();
    String? edadPrincipal = rsvp['edad_principal']?.toString().toLowerCase();
    String? necesitaTransporte = rsvp['necesita_transporte']?.toString().toLowerCase();
    String? cochePropio = rsvp['coche_propio']?.toString().toLowerCase();
    String? albumDigital = rsvp['album_digital']?.toString().toLowerCase();
    String? acompanante = rsvp['acompanante']?.toString().toLowerCase();

    // Parsear acompañantes existentes
    List<Map<String, dynamic>> acompanantesList = [];
    try {
      if (rsvp['acompanantes_json'] != null) {
        dynamic acompanantesJson = rsvp['acompanantes_json'];
        if (acompanantesJson is String) {
          acompanantesList = List<Map<String, dynamic>>.from(jsonDecode(acompanantesJson));
        } else if (acompanantesJson is List) {
          acompanantesList = List<Map<String, dynamic>>.from(acompanantesJson);
        }
      }
    } catch (e) {
      // Error silencioso al parsear acompañantes
    }

    // Crear controladores para cada acompañante
    final acompanantesControllers = <Map<String, dynamic>>[];
    for (final comp in acompanantesList) {
      acompanantesControllers.add({
        'nombre': TextEditingController(text: comp['nombre']?.toString() ?? ''),
        'edad': comp['edad']?.toString().toLowerCase() ?? 'adulto',
        'asistencia': comp['asistencia']?.toString().toLowerCase() ?? 'si',
        'alergias': TextEditingController(text: comp['alergias']?.toString() ?? ''),
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Editar RSVP',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 500),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email *'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono *'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: asistencia,
                    decoration: const InputDecoration(labelText: 'Asistencia'),
                    items: const [
                      DropdownMenuItem(value: 'si', child: Text('Sí')),
                      DropdownMenuItem(value: 'no', child: Text('No')),
                    ],
                    onChanged: (value) => setDialogState(() => asistencia = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: edadPrincipal,
                    decoration: const InputDecoration(labelText: 'Edad Principal'),
                    items: const [
                      DropdownMenuItem(value: 'adulto', child: Text('Adulto')),
                      DropdownMenuItem(value: '12-18', child: Text('12-18 años')),
                      DropdownMenuItem(value: '0-12', child: Text('0-12 años')),
                    ],
                    onChanged: (value) => setDialogState(() => edadPrincipal = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: alergiasController,
                    decoration: const InputDecoration(labelText: 'Alergias'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: necesitaTransporte,
                    decoration: const InputDecoration(labelText: 'Necesita Transporte'),
                    items: const [
                      DropdownMenuItem(value: 'si', child: Text('Sí')),
                      DropdownMenuItem(value: 'no', child: Text('No')),
                    ],
                    onChanged: (value) => setDialogState(() => necesitaTransporte = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: cochePropio,
                    decoration: const InputDecoration(labelText: 'Coche Propio'),
                    items: const [
                      DropdownMenuItem(value: 'si', child: Text('Sí')),
                      DropdownMenuItem(value: 'no', child: Text('No')),
                    ],
                    onChanged: (value) => setDialogState(() => cochePropio = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cancionesController,
                    decoration: const InputDecoration(labelText: 'Canciones'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: albumDigital,
                    decoration: const InputDecoration(labelText: 'Álbum Digital'),
                    items: const [
                      DropdownMenuItem(value: 'si', child: Text('Sí')),
                      DropdownMenuItem(value: 'no', child: Text('No')),
                    ],
                    onChanged: (value) => setDialogState(() => albumDigital = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mensajeController,
                    decoration: const InputDecoration(labelText: 'Mensaje para los novios'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Acompañantes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 200,
                            child: DropdownButtonFormField<String>(
                              value: acompanante,
                              decoration: const InputDecoration(
                                labelText: 'Tiene acompañantes',
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'si', child: Text('Sí')),
                                DropdownMenuItem(value: 'no', child: Text('No')),
                              ],
                              onChanged: (value) => setDialogState(() {
                                acompanante = value;
                                if (value == 'no') {
                                  acompanantesControllers.clear();
                                } else if (acompanantesControllers.isEmpty) {
                                  acompanantesControllers.add({
                                    'nombre': TextEditingController(),
                                    'edad': 'adulto',
                                    'asistencia': 'si',
                                    'alergias': TextEditingController(),
                                  });
                                }
                              }),
                            ),
                          ),
                          if (acompanante == 'si')
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setDialogState(() {
                                acompanantesControllers.add({
                                  'nombre': TextEditingController(),
                                  'edad': 'adulto',
                                  'asistencia': 'si',
                                  'alergias': TextEditingController(),
                                });
                              }),
                              tooltip: 'Agregar acompañante',
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (acompanante == 'si') ...[
                    const SizedBox(height: 12),
                    ...acompanantesControllers.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final comp = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Acompañante ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: Colors.red,
                                  onPressed: () => setDialogState(() {
                                    (comp['nombre'] as TextEditingController).dispose();
                                    (comp['alergias'] as TextEditingController).dispose();
                                    acompanantesControllers.removeAt(idx);
                                  }),
                                  tooltip: 'Eliminar',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: comp['nombre'] as TextEditingController,
                              decoration: const InputDecoration(labelText: 'Nombre *'),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: comp['asistencia'] as String,
                              decoration: const InputDecoration(labelText: 'Asistencia'),
                              items: const [
                                DropdownMenuItem(value: 'si', child: Text('Sí')),
                                DropdownMenuItem(value: 'no', child: Text('No')),
                              ],
                              onChanged: (value) => setDialogState(() {
                                comp['asistencia'] = value as String;
                              }),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: comp['edad'] as String,
                              decoration: const InputDecoration(labelText: 'Edad'),
                              items: const [
                                DropdownMenuItem(value: 'adulto', child: Text('Adulto')),
                                DropdownMenuItem(value: '12-18', child: Text('12-18 años')),
                                DropdownMenuItem(value: '0-12', child: Text('0-12 años')),
                              ],
                              onChanged: (value) => setDialogState(() {
                                comp['edad'] = value as String;
                              }),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: comp['alergias'] as TextEditingController,
                              decoration: const InputDecoration(labelText: 'Alergias'),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          nameController.dispose();
                          emailController.dispose();
                          phoneController.dispose();
                          alergiasController.dispose();
                          cancionesController.dispose();
                          mensajeController.dispose();
                          Navigator.pop(context);
                        },
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor completa los campos obligatorios')),
                  );
                  return;
                }

                // Validar acompañantes si tiene
                if (acompanante == 'si') {
                  for (var i = 0; i < acompanantesControllers.length; i++) {
                    final comp = acompanantesControllers[i];
                    if ((comp['nombre'] as TextEditingController).text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Nombre del acompañante ${i + 1} es obligatorio')),
                      );
                      return;
                    }
                  }
                }

                // Calcular contadores de edad
                int countAdult = 0, countTeen = 0, countKid = 0;
                if (asistencia == 'si') {
                  if (edadPrincipal == 'adulto') countAdult++;
                  if (edadPrincipal == '12-18') countTeen++;
                  if (edadPrincipal == '0-12') countKid++;
                }
                if (acompanante == 'si') {
                  for (final comp in acompanantesControllers) {
                    // Solo contar acompañantes que van a asistir
                    if (comp['asistencia'] == 'si') {
                      final edad = comp['edad'] as String;
                      if (edad == 'adulto') countAdult++;
                      if (edad == '12-18') countTeen++;
                      if (edad == '0-12') countKid++;
                    }
                  }
                }

                // Construir lista de acompañantes
                List<Map<String, dynamic>> acompanantesJson = [];
                if (acompanante == 'si') {
                  acompanantesJson = acompanantesControllers.map((comp) {
                    return {
                      'nombre': (comp['nombre'] as TextEditingController).text.trim().toUpperCase(),
                      'edad': (comp['edad'] as String).toUpperCase(),
                      'asistencia': (comp['asistencia'] as String).toUpperCase(),
                      'alergias': (comp['alergias'] as TextEditingController).text.trim().isEmpty
                          ? null
                          : (comp['alergias'] as TextEditingController).text.trim().toUpperCase(),
                    };
                  }).toList();
                }

                final updatedData = <String, dynamic>{
                  'name': nameController.text.trim().toUpperCase(),
                  'email': emailController.text.trim().toUpperCase(),
                  'phone': phoneController.text.trim().toUpperCase(),
                  'asistencia': asistencia?.toUpperCase(),
                  'edad_principal': edadPrincipal?.toUpperCase(),
                  'alergias_principal': alergiasController.text.trim().isEmpty
                      ? null
                      : alergiasController.text.trim().toUpperCase(),
                  'acompanante': acompanante?.toUpperCase(),
                  'num_acompanantes': acompanante == 'si' ? acompanantesControllers.length : 0,
                  'num_adultos': countAdult,
                  'num_12_18': countTeen,
                  'num_0_12': countKid,
                  'necesita_transporte': necesitaTransporte?.toUpperCase(),
                  'coche_propio': cochePropio?.toUpperCase(),
                  'canciones': cancionesController.text.trim().isEmpty
                      ? null
                      : cancionesController.text.trim().toUpperCase(),
                  'album_digital': albumDigital?.toUpperCase(),
                  'mensaje_novios': mensajeController.text.trim().isEmpty
                      ? null
                      : mensajeController.text.trim().toUpperCase(),
                  'acompanantes_json': acompanantesJson,
                  'created_at': rsvp['created_at'],
                  'origen_form': rsvp['origen_form'],
                };

                // Limpiar controladores
                nameController.dispose();
                emailController.dispose();
                phoneController.dispose();
                alergiasController.dispose();
                cancionesController.dispose();
                mensajeController.dispose();
                for (final comp in acompanantesControllers) {
                  (comp['nombre'] as TextEditingController).dispose();
                  (comp['alergias'] as TextEditingController).dispose();
                }

                Navigator.pop(context);
                await _updateRsvp(context, documentId, updatedData);
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateRsvp(BuildContext context, String documentId, Map<String, dynamic> data) async {
    try {
      String endpoint = _appwriteEndpoint.trim();
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }
      if (!endpoint.endsWith('/v1')) {
        endpoint = '$endpoint/v1';
      }

      final headers = <String, String>{
          'Content-Type': 'application/json',
        'X-Appwrite-Project': _appwriteProjectId,
      };

      if (_appwriteApiKey.isNotEmpty) {
        headers['X-Appwrite-Key'] = _appwriteApiKey;
      }

      final url = Uri.parse('$endpoint/databases/$_appwriteDatabaseId/collections/$_rsvpCollectionId/documents/$documentId');
      
      // Limpiar y formatear el payload igual que en _sendRsvpToAppwrite
      final cleanPayload = <String, dynamic>{};
      data.forEach((key, value) {
        if (value == null) {
          return; // Omitir valores null
        }
        
        // Convertir tipos según lo esperado por Appwrite
        if (key == 'created_at' && value is String) {
          try {
            final dt = DateTime.parse(value);
            cleanPayload[key] = dt.toUtc().toIso8601String();
          } catch (e) {
            cleanPayload[key] = value;
          }
        } else if (key == 'acompanantes_json' && value is List) {
          // Convertir lista a JSON string para el tipo string en Appwrite
          cleanPayload[key] = jsonEncode(value);
        } else {
          cleanPayload[key] = value;
        }
      });

      // Appwrite usa PATCH para actualizar documentos
      final resp = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'data': cleanPayload}),
      );

      if (resp.statusCode >= 300) {
        throw 'Error ${resp.statusCode}: ${resp.body}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RSVP actualizado correctamente')),
        );
        _loadRsvps(); // Recargar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }


  String _getCompanionsNames(List<dynamic> acompanantes) {
    if (acompanantes.isEmpty) return '';
    try {
      final names = acompanantes.map((comp) {
        if (comp is Map<String, dynamic>) {
          return comp['nombre']?.toString() ?? '';
        }
        return '';
      }).where((name) => name.isNotEmpty).toList();
      return names.join(', ');
    } catch (e) {
      return '';
    }
  }

  String _getCompanionsAsistencia(List<dynamic> acompanantes) {
    if (acompanantes.isEmpty) return '';
    try {
      final asistencias = acompanantes.map((comp) {
        if (comp is Map<String, dynamic>) {
          return comp['asistencia']?.toString().toUpperCase() ?? 'SI';
        }
        return 'SI';
      }).toList();
      return asistencias.join(', ');
    } catch (e) {
      return '';
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1');
      final sheet = excel['RSVPs'];

      // Encabezados
      final headers = [
        'Nombre',
        'Email',
        'Teléfono',
        'Asistencia',
        'Asistencia Acompañantes',
        'Alergias',
        'Necesita Transporte',
        'Coche Propio',
        'Álbum Digital',
        'Tipo',
        'Nº Acompañantes',
        'Nº Adultos',
        'Nº 12-18 años',
        'Nº Menores 12',
        'Canciones',
        'Nombre Acompañante',
        'Mensaje Novios',
        'Fecha Creación',
        'Origen',
      ];

      // Escribir encabezados
      for (int i = 0; i < headers.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = CellStyle(
          bold: true,
        );
      }

      // Escribir datos - una fila por invitado principal y una por cada acompañante
      int currentRow = 1;
      for (int rsvpIndex = 0; rsvpIndex < _rsvps.length; rsvpIndex++) {
        final rsvp = _rsvps[rsvpIndex];
        
        // Parsear acompañantes
        List<dynamic> acompanantes = [];
        try {
          if (rsvp['acompanantes_json'] != null) {
            if (rsvp['acompanantes_json'] is String) {
              acompanantes = jsonDecode(rsvp['acompanantes_json'] as String) as List<dynamic>;
            } else if (rsvp['acompanantes_json'] is List) {
              acompanantes = rsvp['acompanantes_json'] as List<dynamic>;
            }
          }
        } catch (e) {
          // Error silencioso al parsear acompañantes
        }
        
        // Si no hay acompañantes, escribir solo la fila del invitado principal
        if (acompanantes.isEmpty) {
          int col = 0;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['name']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['email']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['phone']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['asistencia']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(''); // Asistencia Acompañantes vacío si no hay
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['alergias_principal']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['necesita_transporte']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['coche_propio']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['album_digital']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('INVITADO PRINCIPAL');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_acompanantes'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_adultos'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_12_18'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_0_12'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['canciones']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(''); // Nombre Acompañante vacío si no hay
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['mensaje_novios']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['created_at']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['origen_form']?.toString() ?? '');
          currentRow++;
        } else {
          // Escribir fila del invitado principal
          int col = 0;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['name']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['email']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['phone']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['asistencia']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(_getCompanionsAsistencia(acompanantes)); // Asistencia Acompañantes
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['alergias_principal']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['necesita_transporte']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['coche_propio']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['album_digital']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('INVITADO PRINCIPAL');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_acompanantes'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_adultos'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_12_18'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_0_12'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['canciones']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(_getCompanionsNames(acompanantes)); // Nombre Acompañante
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['mensaje_novios']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['created_at']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['origen_form']?.toString() ?? '');
          currentRow++;
          
          // Escribir una fila por cada acompañante
          for (final comp in acompanantes) {
            final compMap = comp as Map<String, dynamic>;
            col = 0;
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(compMap['nombre']?.toString() ?? '');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['email']?.toString() ?? ''); // Mismo email del principal
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['phone']?.toString() ?? ''); // Mismo teléfono del principal
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(compMap['asistencia']?.toString() ?? 'SI'); // Asistencia del acompañante
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(compMap['asistencia']?.toString() ?? 'SI'); // Asistencia Acompañantes
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(compMap['alergias']?.toString() ?? '');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['necesita_transporte']?.toString() ?? '');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['coche_propio']?.toString() ?? '');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(''); // Álbum Digital
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('ACOMPAÑANTE');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(0);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(0);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(0);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(0);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(''); // Canciones
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(''); // Nombre Acompañante vacío para fila de acompañante
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(''); // Mensaje Novios
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['created_at']?.toString() ?? ''); // Fecha Creación
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['origen_form']?.toString() ?? ''); // Origen
            currentRow++;
          }
        }
      }

      // Ajustar ancho de columnas
      for (int i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20.0);
      }

      // Generar archivo
      final excelBytes = excel.save();
      if (excelBytes == null) {
        throw 'Error al generar el archivo Excel';
      }

      // Descargar archivo usando dart:html
      final blob = Uint8List.fromList(excelBytes);
      final fileName = 'RSVPs_${DateTime.now().toString().split(' ')[0]}.xlsx';
      
      // Crear blob y descargarlo
      final blobData = html.Blob([blob]);
      final url = html.Url.createObjectUrlFromBlob(blobData);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel exportado: $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración - RSVPs'),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRsvps,
            tooltip: 'Actualizar',
          ),
          if (_rsvps.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _exportToExcel,
              tooltip: 'Exportar a Excel',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _setAdminAuthenticated(false);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AdminLoginPage()),
              );
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRsvps,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _rsvps.isEmpty
                  ? const Center(child: Text('No hay RSVPs registrados'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rsvps.length,
                      itemBuilder: (context, index) {
                        final rsvp = _rsvps[index];
                        // Contar acompañantes
                        int numAcompanantes = 0;
                        try {
                          if (rsvp['acompanantes_json'] != null) {
                            dynamic acompanantesJson = rsvp['acompanantes_json'];
                            if (acompanantesJson is String) {
                              final parsed = jsonDecode(acompanantesJson) as List;
                              numAcompanantes = parsed.length;
                            } else if (acompanantesJson is List) {
                              numAcompanantes = acompanantesJson.length;
                            }
                          }
                        } catch (e) {
                          // Ignorar errores de parsing
                        }
                        
                        final documentId = _documentIds[index.toString()] ?? '';
                        final asistenciaValue = rsvp['asistencia']?.toString() ?? '';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(rsvp['name']?.toString() ?? 'Sin nombre'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${rsvp['email'] ?? ''} - ${rsvp['phone'] ?? ''}'),
                                if (numAcompanantes > 0)
                                  Text(
                                    '$numAcompanantes acompañante${numAcompanantes > 1 ? 's' : ''}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAsistenciaIcon(asistenciaValue),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  color: Colors.blue,
                                  onPressed: () => _editRsvp(context, index, documentId, rsvp),
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: Colors.red,
                                  onPressed: () => _deleteRsvp(context, index, documentId),
                                  tooltip: 'Borrar',
                                ),
                              ],
                            ),
                            isThreeLine: numAcompanantes > 0,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(rsvp['name']?.toString() ?? 'RSVP'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildDetailRow('Email', rsvp['email']),
                                        _buildDetailRow('Teléfono', rsvp['phone']),
                                        _buildDetailRow('Asistencia', rsvp['asistencia']),
                                        _buildDetailRow('Edad Principal', rsvp['edad_principal']),
                                        _buildDetailRow('Alergias', rsvp['alergias_principal']),
                                        _buildDetailRow('Acompañante', rsvp['acompanante']),
                                        _buildDetailRow('Nº Acompañantes', rsvp['num_acompanantes']),
                                        _buildDetailRow('Nº Adultos', rsvp['num_adultos']),
                                        _buildDetailRow('Nº 12-18 años', rsvp['num_12_18']),
                                        _buildDetailRow('Nº Menores 12', rsvp['num_0_12']),
                                        _buildDetailRow('Necesita Transporte', rsvp['necesita_transporte']),
                                        _buildDetailRow('Coche Propio', rsvp['coche_propio']),
                                        _buildDetailRow('Canciones', rsvp['canciones']),
                                        _buildDetailRow('Álbum Digital', rsvp['album_digital']),
                                        _buildDetailRow('Mensaje', rsvp['mensaje_novios']),
                                        _buildDetailRow('Fecha', rsvp['created_at']),
                                        if (rsvp['acompanantes_json'] != null)
                                          ..._buildCompanionsSection(rsvp['acompanantes_json']),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cerrar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCompanionsSection(dynamic acompanantesJson) {
    final List<Widget> widgets = [
      const Padding(
        padding: EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          'Acompañantes:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ];

    try {
      List<dynamic> acompanantes = [];
      if (acompanantesJson is String) {
        acompanantes = jsonDecode(acompanantesJson) as List<dynamic>;
      } else if (acompanantesJson is List) {
        acompanantes = acompanantesJson;
      }

      for (int i = 0; i < acompanantes.length; i++) {
        final comp = acompanantes[i] as Map<String, dynamic>;
        widgets.add(
          Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acompañante ${i + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                _buildDetailRow('Nombre', comp['nombre']),
                _buildDetailRow('Asistencia', comp['asistencia'] ?? 'SI'),
                _buildDetailRow('Edad', comp['edad']),
                _buildDetailRow('Alergias', comp['alergias'] ?? 'Ninguna'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text('Error al mostrar acompañantes: $e', style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return widgets;
  }

  Widget _buildAsistenciaIcon(String? asistencia) {
    if (asistencia == null || asistencia.isEmpty) {
      return const Icon(Icons.help_outline, color: Colors.grey, size: 24);
    }
    
    // Limpiar el valor: quitar espacios, convertir a minúsculas y normalizar
    final asistenciaClean = asistencia.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    
    // Verificar si contiene "si" o "sí" (puede estar en mayúsculas o con acentos)
    if (asistenciaClean == 'si' || 
        asistenciaClean == 'sí' || 
        asistenciaClean == 'yes' ||
        asistenciaClean.contains('si') ||
        asistenciaClean.contains('sí')) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 24,
      );
    } 
    // Verificar si contiene "no"
    else if (asistenciaClean == 'no' || 
             asistenciaClean == 'not' ||
             asistenciaClean.contains('no')) {
      return const Icon(
        Icons.cancel,
        color: Colors.red,
        size: 24,
      );
    }
    
    // Si no coincide con ninguno, mostrar icono gris
    return const Icon(Icons.help_outline, color: Colors.grey, size: 24);
  }
}
