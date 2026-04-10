import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import 'task_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  int? _selectedReportId;

  // SRM University default
  static const _defaultCenter = LatLng(12.8231, 80.0444);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
        });
        _mapController.move(_userLocation!, 16);
      }
    } catch (_) {}
  }

  Color _markerColor(String severity, String status) {
    if (status == 'Pending Proof') return AppColors.blue;
    switch (severity) {
      case 'High':
        return AppColors.red;
      case 'Medium':
        return AppColors.orange;
      default:
        return AppColors.emerald;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().translate;
    final reports = context.watch<AppProvider>().reports;
    
    final activeReports =
        reports.where((r) => r.status != 'Cleaned').toList();

    // Safely look up the selected report without modifying state during build
    final currentReport = reports.cast<Report?>().firstWhere(
          (r) => r?.id == _selectedReportId,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── THE MAP ───
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 16,
              onTap: (_, __) => setState(() => _selectedReportId = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.cleancity.frontend',
              ),

              // User location marker
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: _UserDot(),
                    ),
                  ],
                ),

              // Report markers
              MarkerLayer(
                markers: activeReports.map((report) {
                  final color = _markerColor(report.severity, report.status);
                  return Marker(
                    point: LatLng(report.lat, report.lng),
                    width: 36,
                    height: 36,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedReportId = report.id),
                      child: _ReportMarker(
                        color: color,
                        isPulsing: report.severity == 'High',
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ─── Top Header ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppColors.emeraldGradient.createShader(b),
                        child: Text(
                          t('CleanChain'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _MapLegend(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Location Button ───
          Positioned(
            bottom: 120,
            right: 20,
            child: GestureDetector(
              onTap: _getUserLocation,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
            ),
          ),

          // ─── Task Sheet overlay ───
          if (currentReport != null)
            TaskSheet(
              reportId: currentReport.id,
              onClose: () => setState(() => _selectedReportId = null),
            ),
        ],
      ),
    );
  }
}

class _UserDot extends StatefulWidget {
  @override
  State<_UserDot> createState() => _UserDotState();
}

class _UserDotState extends State<_UserDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue.withOpacity(_anim.value * 0.3),
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blue,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withOpacity(0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMarker extends StatefulWidget {
  final Color color;
  final bool isPulsing;
  const _ReportMarker({required this.color, required this.isPulsing});

  @override
  State<_ReportMarker> createState() => _ReportMarkerState();
}

class _ReportMarkerState extends State<_ReportMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.isPulsing) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: widget.isPulsing ? _scale.value : 1.0,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.25),
            border: Border.all(color: widget.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().translate;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: 100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendItem(t('High'), AppColors.red),
          _legendItem(t('Med'), AppColors.orange),
          _legendItem(t('Low'), AppColors.emerald),
          _legendItem(t('Proof'), AppColors.blue),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}
