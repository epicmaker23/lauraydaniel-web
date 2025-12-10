import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:excel/excel.dart' hide Border;

// Configuración de Appwrite
const _appwriteEndpoint = String.fromEnvironment('APPWRITE_ENDPOINT', defaultValue: '');
const _appwriteProjectId = String.fromEnvironment('APPWRITE_PROJECT_ID', defaultValue: '');
const _appwriteApiKey = String.fromEnvironment('APPWRITE_API_KEY', defaultValue: '');
const _appwriteDatabaseId = String.fromEnvironment('APPWRITE_DATABASE_ID', defaultValue: '');
const _rsvpCollectionId = String.fromEnvironment('APPWRITE_RSVP_COLLECTION_ID', defaultValue: '');
const _galleryCollectionId = String.fromEnvironment('APPWRITE_GALLERY_COLLECTION_ID', defaultValue: '');
const _appwriteStorageId = String.fromEnvironment('APPWRITE_STORAGE_ID', defaultValue: '');

// Debug: imprimir configuración en consola (solo en desarrollo)
void _debugAppwriteConfig() {
  if (_appwriteEndpoint.isEmpty) {
    print('⚠️ APPWRITE_ENDPOINT está vacío!');
  } else {
    print('✅ APPWRITE_ENDPOINT: $_appwriteEndpoint');
  }
  print('APPWRITE_PROJECT_ID: ${_appwriteProjectId.isEmpty ? "VACÍO" : "✓"}');
  print('APPWRITE_DATABASE_ID: ${_appwriteDatabaseId.isEmpty ? "VACÍO" : "✓"}');
  print('APPWRITE_RSVP_COLLECTION_ID: ${_rsvpCollectionId.isEmpty ? "VACÍO" : "✓"}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Rutas sin hash: /formulario en lugar de /#/formulario
  setUrlStrategy(PathUrlStrategy());
  // Debug: mostrar configuración en consola
  _debugAppwriteConfig();
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
        // Por compatibilidad si llega sin slash
        'formulario': (_) => const PreinscriptionPage(),
      },
      onGenerateRoute: (settings) {
        print('🔍 [onGenerateRoute] Ruta solicitada: "${settings.name}"');
        if (settings.name == '/formulario') {
          print('✅ [onGenerateRoute] Redirigiendo a PreinscriptionPage');
          return MaterialPageRoute(builder: (_) => const PreinscriptionPage());
        }
        if (settings.name == 'formulario') {
          print('✅ [onGenerateRoute] Redirigiendo a PreinscriptionPage');
          return MaterialPageRoute(builder: (_) => const PreinscriptionPage());
        }
        if (settings.name == '/admin') {
          print('✅ [onGenerateRoute] Redirigiendo a Admin');
          return MaterialPageRoute(
            builder: (_) => _isAdminAuthenticated() ? const AdminPage() : const AdminLoginPage(),
          );
        }
        if (settings.name == 'admin') {
          print('✅ [onGenerateRoute] Redirigiendo a Admin');
          return MaterialPageRoute(
            builder: (_) => _isAdminAuthenticated() ? const AdminPage() : const AdminLoginPage(),
          );
        }
        print('⚠️ [onGenerateRoute] Ruta no encontrada, retornando null');
        return null;
      },
      onGenerateInitialRoutes: (String initialRouteName) {
        final path = Uri.base.path; // e.g. "/formulario" o "/admin" o "/"
        print('🔍 [onGenerateInitialRoutes] Ruta inicial: "$path", initialRouteName: "$initialRouteName"');
        if (path == '/formulario' || path == 'formulario' || path == '/formulario/') {
          print('✅ [onGenerateInitialRoutes] Redirigiendo a PreinscriptionPage');
          return [MaterialPageRoute(builder: (_) => const PreinscriptionPage())];
        }
        if (path == '/admin' || path == 'admin' || path == '/admin/') {
          print('✅ [onGenerateInitialRoutes] Redirigiendo a Admin');
          return [
            MaterialPageRoute(
              builder: (_) => _isAdminAuthenticated() ? const AdminPage() : const AdminLoginPage(),
            )
          ];
        }
        print('✅ [onGenerateInitialRoutes] Redirigiendo a HomePage (default)');
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
                  padding: const EdgeInsets.all(12),
                  child: ClipOval(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => Text(
                          'L&D',
                          style: GoogleFonts.allura(
                            fontSize: 90,
                            color: border,
                            fontWeight: FontWeight.w600,
                            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                          ),
                        ),
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
                      const SizedBox(height: 6),
                      Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: subSize)),
                      const SizedBox(height: 6),
                      Text(
                        detail,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: detailSize),
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

// Helpers
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
              Text(titulo, style: GoogleFonts.allura(fontSize: 36, color: const Color(0xFFD4AF37))),
              const SizedBox(height: 12),
              Text(contenido),
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

void _mostrarRecordatorios(BuildContext context) {
  _dialogoSimple(
    context,
    'Recordatorios',
    'Se crearán 2 recordatorios: 1 semana antes (18/04/2026 10:00) y 3 horas antes (25/04/2026 09:30).',
  );
}

void _mostrarTransporte(BuildContext context) {
  _dialogoSimple(
    context,
    'Transporte',
    'Servicio de Autobús Gratuito para invitados.\n\nIda:\n• 11:00h – Santander Estación Marítima (Ferry)\n• 11:20h – Torrelavega Estación de Autobuses\n\nVuelta:\n• 01:00h – Salida desde la finca\n\nHorarios orientativos, se confirmarán más adelante.',
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
                Text('Alojamiento', style: GoogleFonts.allura(fontSize: 36, color: const Color(0xFFD4AF37))),
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
      const SizedBox(height: 4),
      Text('Ubicación: $ubicacion'),
      Text('Servicios: $servicios'),
      const SizedBox(height: 4),
      InkWell(
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: const Text('Abrir web', style: TextStyle(color: Colors.blue)),
      ),
    ],
  );
}

void _mostrarRegalos(BuildContext context) {
  _dialogoSimple(
    context,
    'Lista de Regalos',
    'Vuestra compañía es el regalo más preciado.\n\nIBAN: ES61 0081 2714 1500 0827 1440',
  );
}

void _mostrarParking(BuildContext context) {
  _dialogoSimple(
    context,
    'Parking',
    'Ceremonia (Soto‑Iruz): Aparcamiento gratuito, recomendable aparcar en arcén, plazas limitadas (~25).\n\nFinca (Villasevil): Aparcamiento gratuito con amplias zonas entre 50-150m.',
  );
}

void _mostrarSubirFotos(BuildContext context) {
  _uploadMediaWithAppwrite(context);
}

void _mostrarFotomaton(BuildContext context) {
  _dialogoSimple(
    context,
    'Fotomatón',
    'Descarga tus fotos divertidas del fotomatón. Disponible después de la boda.',
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
      // Debug: mostrar configuración actual
      final debugInfo = 'Endpoint: $_appwriteEndpoint\nProject: $_appwriteProjectId\nDatabase: $_appwriteDatabaseId\nCollection: $_rsvpCollectionId';
      print('🔍 Iniciando envío de confirmación...');
      print('🔍 $debugInfo');
      
      final payload = _buildRsvpPayload();
      print('📋 Payload construido: ${payload.keys.toList()}');
      
      // Verificar que no estamos usando Supabase
      if (_appwriteEndpoint.contains('supabase') || _appwriteEndpoint.contains('epicmaker.dev')) {
        throw 'ERROR CRÍTICO: El endpoint configurado es de Supabase: $_appwriteEndpoint\n\nDebes recompilar con: --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1"';
      }
      
      print('📤 Enviando a Appwrite...');
      await _sendRsvpToAppwrite(payload);
      print('✅ Envío completado exitosamente');
      
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
      print('❌ Error en _submit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enviando: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        print('🏁 Estado _sending actualizado a false');
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
      'coche_propio': _ownCar?.toUpperCase(),
      'canciones': _songs.text.trim().isEmpty ? null : _songs.text.trim().toUpperCase(),
      'album_digital': _albumDigital?.toUpperCase(),
      'mensaje_novios': _message.text.trim().isEmpty ? null : _message.text.trim().toUpperCase(),
      'created_at': DateTime.now().toIso8601String(),
      'origen_form': 'FLUTTER_WEB',
    };
    if (_companion == 'si' && _companions.isNotEmpty) {
      data['acompanantes_json'] = _companions
          .map((c) => {
                'nombre': c.name.text.trim().toUpperCase(),
                'edad': c.age.toUpperCase(),
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
    
    // Debug: Intentar obtener la estructura de la colección para verificar atributos
    try {
      String endpoint = _appwriteEndpoint.trim();
      if (endpoint.endsWith('/')) {
        endpoint = endpoint.substring(0, endpoint.length - 1);
      }
      if (!endpoint.endsWith('/v1')) {
        endpoint = '$endpoint/v1';
      }
      
      final collectionUri = Uri.parse('$endpoint/databases/$_appwriteDatabaseId/collections/$_rsvpCollectionId');
      final collectionResp = await http.get(collectionUri, headers: headers);
      
      if (collectionResp.statusCode == 200) {
        final collectionData = jsonDecode(collectionResp.body) as Map<String, dynamic>;
        final attributes = collectionData['attributes'] as List<dynamic>?;
        if (attributes != null) {
          final attributeKeys = attributes.map((a) => (a as Map<String, dynamic>)['key'] as String).toList();
          print('📋 Atributos reconocidos por Appwrite: $attributeKeys');
        }
      }
    } catch (e) {
      print('⚠️ No se pudo obtener estructura de colección: $e');
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
      throw 'ERROR: URL no es absoluta. Las variables de entorno no se pasaron correctamente.\n\nURL construida: $urlString\n\nEndpoint: "$_appwriteEndpoint"\n\nDebes recompilar con: --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1"';
    }
    
    final uri = Uri.parse(urlString);
    
    // Debug: verificar URL antes de enviar
    if (!uri.toString().contains('api.lauraydaniel.es')) {
      throw 'ERROR: URL incorrecta. Debe contener api.lauraydaniel.es.\n\nURL actual: ${uri.toString()}\n\nEndpoint configurado: "$_appwriteEndpoint"\n\nRecompila con: --dart-define="APPWRITE_ENDPOINT=https://api.lauraydaniel.es/v1"';
    }
    
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
    
    // Debug: imprimir payload en consola
    print('📤 Enviando a Appwrite: ${jsonEncode(appwritePayload)}');
    print('📋 Headers: ${headers.toString()}');
    
    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(appwritePayload),
    );
    
    if (resp.statusCode >= 300) {
      // Mostrar respuesta completa para debug
      final errorBody = resp.body;
      print('❌ Error de Appwrite (${resp.statusCode}): $errorBody');
      print('📋 Request URL: ${uri.toString()}');
      print('📋 Request Headers: ${headers.toString()}');
      throw 'Error ${resp.statusCode}: ${errorBody.length > 200 ? errorBody.substring(0, 200) + "..." : errorBody}';
    }
    
    print('✅ Documento creado exitosamente en Appwrite');
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
                                  validator: (v) => v!.trim().isEmpty ? 'Campo obligatorio' : null,
                                ),
                                _TextField(
                                  controller: _email,
                                  label: 'Correo electrónico',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v!.trim().isEmpty || _isValidEmail(v.trim()) ? null : 'Email no válido',
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
                                      if (c.age == 'adulto') totalAdult++;
                                      if (c.age == '12-18') totalTeen++;
                                      if (c.age == '0-12') totalKid++;
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
      padding: const EdgeInsets.all(10),
      child: ClipOval(
        child: Center(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Text(
              'L&D',
              style: GoogleFonts.allura(
                fontSize: 72,
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.w600,
                shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
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
            imageAsset: 'assets/images/santuario.jpg',
            lines: const ['Convento de San Francisco de El Soto', 'Soto‑Iruz – 12:30h'],
          ),
          detailCard(
            iconData: Icons.celebration,
            title: 'Celebración',
            imageAsset: 'assets/images/labranza.jpg',
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
  final TextEditingController allergies = TextEditingController();
}

class _CompanionCard extends StatelessWidget {
  final int index;
  final _CompanionData data;
  final ValueChanged<String> onAgeChanged;
  const _CompanionCard({required this.index, required this.data, required this.onAgeChanged});
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
Future<void> _uploadMediaWithAppwrite(BuildContext context) async {
  await _uploadViaRest(context);
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
  // Selección de archivos
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic', 'heif', 'mp4', 'mov', 'avi', 'mkv'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No seleccionaste archivos.')));
    return;
  }
  if (_appwriteEndpoint.isEmpty || _appwriteProjectId.isEmpty || _appwriteStorageId.isEmpty || _appwriteDatabaseId.isEmpty || _galleryCollectionId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backend no configurado. Faltan variables de Appwrite.')));
    return;
  }

  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(SnackBar(content: Text('Subiendo ${result.files.length} archivo(s)...')));

  for (final file in result.files) {
    final bytes = file.bytes;
    if (bytes == null) {
      scaffold.showSnackBar(SnackBar(content: Text('No pude leer datos de ${file.name}.')));
      continue;
    }

    try {
      // En Appwrite, primero subimos el archivo a Storage
      // 1. Subir archivo a Storage
      // El endpoint ya incluye /v1, así que solo añadimos la ruta
      final storageRequest = http.MultipartRequest(
        'POST',
        Uri.parse('$_appwriteEndpoint/storage/$_appwriteStorageId/files'),
      );
      
      storageRequest.headers['X-Appwrite-Project'] = _appwriteProjectId;
      if (_appwriteApiKey.isNotEmpty) {
        storageRequest.headers['X-Appwrite-Key'] = _appwriteApiKey;
      }
      
      final mime = _inferMime(file.extension);
      storageRequest.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ),
      );
      
      storageRequest.fields['fileId'] = 'unique()'; // Appwrite genera ID único
      
      final storageResponse = await storageRequest.send();
      final storageResponseBody = await http.Response.fromStream(storageResponse);
      
      if (storageResponse.statusCode >= 300) {
        scaffold.showSnackBar(SnackBar(content: Text('Fallo subiendo archivo ${file.name}: ${storageResponse.statusCode} ${storageResponseBody.body}')));
        continue;
      }
      
      final storageData = jsonDecode(storageResponseBody.body) as Map<String, dynamic>;
      final fileId = storageData[r'$id'] as String? ?? storageData['id'] as String?;
      
      if (fileId == null) {
        scaffold.showSnackBar(SnackBar(content: Text('No se pudo obtener ID del archivo ${file.name}.')));
        continue;
      }
      
      // 2. Crear documento en la colección de galería con referencia al archivo
      // El endpoint ya incluye /v1, así que solo añadimos la ruta
      final docRequest = http.Request(
        'POST',
        Uri.parse('$_appwriteEndpoint/databases/$_appwriteDatabaseId/collections/$_galleryCollectionId/documents'),
      );
      
      docRequest.headers['Content-Type'] = 'application/json';
      docRequest.headers['X-Appwrite-Project'] = _appwriteProjectId;
      if (_appwriteApiKey.isNotEmpty) {
        docRequest.headers['X-Appwrite-Key'] = _appwriteApiKey;
      }
      
      docRequest.body = jsonEncode({
        'documentId': 'unique()',
        'data': {
          'fileId': fileId,
          'approved': false,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      });
      
      final docResponse = await docRequest.send();
      final docResponseBody = await http.Response.fromStream(docResponse);
      
      if (docResponse.statusCode >= 300) {
        scaffold.showSnackBar(SnackBar(content: Text('Fallo creando registro para ${file.name}: ${docResponse.statusCode} ${docResponseBody.body}')));
      }
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Error subiendo ${file.name}: $e')));
    }
  }

  scaffold.clearSnackBars();
  scaffold.showSnackBar(const SnackBar(content: Text('¡Archivos subidos correctamente!')));
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
    print('Error guardando autenticación: $e');
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
      print('📡 Cargando RSVPs desde: $url');
      final resp = await http.get(url, headers: headers);

      print('📥 Respuesta status: ${resp.statusCode}');
      print('📥 Respuesta body: ${resp.body.substring(0, resp.body.length > 500 ? 500 : resp.body.length)}');

      if (resp.statusCode >= 300) {
        throw 'Error ${resp.statusCode}: ${resp.body}';
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      print('📋 Estructura de respuesta: ${data.keys.toList()}');
      
      final documents = data['documents'] as List<dynamic>? ?? [];
      print('📋 Documentos encontrados: ${documents.length}');

      if (documents.isNotEmpty) {
        print('📋 Primer documento: ${documents[0]}');
      }

      final List<Map<String, dynamic>> loadedRsvps = [];
      final Map<String, String> loadedIds = {};
      
      for (int i = 0; i < documents.length; i++) {
        final doc = documents[i] as Map<String, dynamic>;
        print('📄 Documento completo: $doc');
        
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
            print('⚠️ Error parseando acompañantes_json: $e');
          }
        }
        
        print('📄 Datos extraídos: $docData');
        loadedRsvps.add(docData ?? <String, dynamic>{});
      }
      
      setState(() {
        _rsvps = loadedRsvps;
        _documentIds = loadedIds;
        _loading = false;
      });
      
      print('✅ Cargados ${_rsvps.length} RSVPs');
      if (_rsvps.isNotEmpty) {
        print('📋 Primer RSVP: ${_rsvps[0]}');
      }
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
      print('🗑️ Eliminando documento: $url');
      
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
      print('⚠️ Error parseando acompañantes: $e');
    }

    // Crear controladores para cada acompañante
    final acompanantesControllers = <Map<String, dynamic>>[];
    for (final comp in acompanantesList) {
      acompanantesControllers.add({
        'nombre': TextEditingController(text: comp['nombre']?.toString() ?? ''),
        'edad': comp['edad']?.toString().toLowerCase() ?? 'adulto',
        'alergias': TextEditingController(text: comp['alergias']?.toString() ?? ''),
      });
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar RSVP'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
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
                    children: [
                      const Text('Acompañantes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          DropdownButtonFormField<String>(
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
                                  'alergias': TextEditingController(),
                                });
                              }
                            }),
                          ),
                          if (acompanante == 'si')
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setDialogState(() {
                                acompanantesControllers.add({
                                  'nombre': TextEditingController(),
                                  'edad': 'adulto',
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
          actions: [
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
                    final edad = comp['edad'] as String;
                    if (edad == 'adulto') countAdult++;
                    if (edad == '12-18') countTeen++;
                    if (edad == '0-12') countKid++;
                  }
                }

                // Construir lista de acompañantes
                List<Map<String, dynamic>> acompanantesJson = [];
                if (acompanante == 'si') {
                  acompanantesJson = acompanantesControllers.map((comp) {
                    return {
                      'nombre': (comp['nombre'] as TextEditingController).text.trim().toUpperCase(),
                      'edad': (comp['edad'] as String).toUpperCase(),
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
      print('✏️ Actualizando documento: $url');
      print('📋 Datos: $data');

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

  String _formatAgeRange(String? edad) {
    if (edad == null || edad.isEmpty) return '';
    final edadUpper = edad.toUpperCase().trim();
    if (edadUpper == 'ADULTO' || edadUpper.contains('ADULTO')) {
      return '18+ años';
    } else if (edadUpper == '12-18' || edadUpper.contains('12-18')) {
      return '12-18 años';
    } else if (edadUpper == '0-12' || edadUpper.contains('0-12')) {
      return '0-12 años';
    }
    return edad; // Si no coincide, devolver el valor original
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
        'Rango de Edad',
        'Alergias',
        'Tipo',
        'Nº Acompañantes',
        'Nº Adultos',
        'Nº 12-18 años',
        'Nº Menores 12',
        'Necesita Transporte',
        'Coche Propio',
        'Canciones',
        'Álbum Digital',
        'Mensaje Novios',
        'Nombre Acompañante',
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
          print('⚠️ Error parseando acompañantes en Excel: $e');
        }
        
        // Si no hay acompañantes, escribir solo la fila del invitado principal
        if (acompanantes.isEmpty) {
          int col = 0;
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['name']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['email']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['phone']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['asistencia']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(_formatAgeRange(rsvp['edad_principal']?.toString()));
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['alergias_principal']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('INVITADO PRINCIPAL');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_acompanantes'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_adultos'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_12_18'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_0_12'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['necesita_transporte']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['coche_propio']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['canciones']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['album_digital']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['mensaje_novios']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(''); // Nombre Acompañante vacío si no hay
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
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(_formatAgeRange(rsvp['edad_principal']?.toString()));
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['alergias_principal']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('INVITADO PRINCIPAL');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_acompanantes'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_adultos'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_12_18'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(rsvp['num_0_12'] ?? 0);
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['necesita_transporte']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['coche_propio']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['canciones']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['album_digital']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['mensaje_novios']?.toString() ?? '');
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(_getCompanionsNames(acompanantes)); // Nombres de acompañantes
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
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['asistencia']?.toString() ?? ''); // Misma asistencia
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(_formatAgeRange(compMap['edad']?.toString()));
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(compMap['alergias']?.toString() ?? '');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('ACOMPAÑANTE');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(0);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(0);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(0);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = IntCellValue(0);
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['necesita_transporte']?.toString() ?? '');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['coche_propio']?.toString() ?? '');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue('');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['created_at']?.toString() ?? '');
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: col++, rowIndex: currentRow)).value = TextCellValue(rsvp['origen_form']?.toString() ?? '');
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
                        // Debug: ver qué valor tiene asistencia
                        print('📋 RSVP ${rsvp['name']}: asistencia = "$asistenciaValue"');
                        
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
    
    // Debug: imprimir el valor para ver qué llega
    print('🔍 Valor de asistencia: "$asistencia" -> limpio: "$asistenciaClean"');
    
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
    print('⚠️ Valor de asistencia no reconocido: "$asistencia"');
    return const Icon(Icons.help_outline, color: Colors.grey, size: 24);
  }
}
