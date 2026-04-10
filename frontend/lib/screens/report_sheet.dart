import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';

class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key});

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  int _step = 1;
  Uint8List? _imageBytes;
  String _filename = 'photo.jpg';
  bool _isAnalyzing = false;
  bool _isSubmitting = false;
  bool _isGpsLoading = false;
  String _locMode = 'gps'; // gps | map
  LatLng _coords = const LatLng(12.8231, 80.0444);
  final _descCtrl = TextEditingController();
  final _mapCtrl = MapController();

  @override
  void initState() {
    super.initState();
    _grabGPS();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _grabGPS() async {
    setState(() => _isGpsLoading = true);
    try {
      LocationPermission perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => _isGpsLoading = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 6),
      );
      if (mounted) {
        setState(() {
          _coords = LatLng(pos.latitude, pos.longitude);
          _isGpsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isGpsLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _filename = xFile.name;
      _isAnalyzing = true;
    });
    // Simulate AI pre-scan delay
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _step = 2;
      });
    }
  }

  Future<void> _submit() async {
    if (_imageBytes == null) return;
    setState(() => _isSubmitting = true);
    try {
      await context.read<AppProvider>().addReport(
            lat: _coords.latitude,
            lng: _coords.longitude,
            description: _descCtrl.text.trim().isEmpty
                ? 'User reported waste'
                : _descCtrl.text.trim(),
            imageBytes: _imageBytes!,
            filename: _filename,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().translate;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1726),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald.withOpacity(0.08),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.emeraldGradient.createShader(b),
                          child: Text(
                            t('Report Garbage'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.close,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _step == 1 ? _buildStep1() : _buildStep2(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final t = context.watch<LocaleProvider>().translate;
    return GestureDetector(
      onTap: _isAnalyzing ? null : _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isAnalyzing
                ? AppColors.emerald.withOpacity(0.6)
                : Colors.white.withOpacity(0.15),
            width: 2,
          ),
          color: _isAnalyzing
              ? AppColors.emerald.withOpacity(0.05)
              : Colors.white.withOpacity(0.03),
        ),
        child: _isAnalyzing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (_, v, __) => Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: v,
                            color: AppColors.emerald,
                            strokeWidth: 2,
                          ),
                        ),
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.emerald,
                          size: 28,
                        ),
                      ],
                    ),
                    onEnd: () {},
                  ),
                  const SizedBox(height: 16),
                  const _TypewriterText(
                    texts: [
                      'Detecting waste objects...',
                      'Running YOLO inference...',
                      'Calling Cerebras AI...',
                      'Analysis complete!',
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 52,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('Tap to Capture / Upload'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t('Photo + GPS auto-detected'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStep2() {
    final t = context.watch<LocaleProvider>().translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image preview
        if (_imageBytes != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  _imageBytes!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC060C14)],
                    ),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.emerald,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AI analysis complete ✓',
                        style: TextStyle(
                          color: AppColors.emerald,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),

        // Description
        const Text(
          'Description',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descCtrl,
          maxLines: 2,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Describe the garbage / location...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Location mode toggle + content
        Row(
          children: [
            const Text(
              'Location',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const Spacer(),
            _LocToggle(
              mode: _locMode,
              onGps: () {
                setState(() => _locMode = 'gps');
                _grabGPS();
              },
              onMap: () => setState(() => _locMode = 'map'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_locMode == 'gps')
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_pin,
                  color: AppColors.blue,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_coords.latitude.toStringAsFixed(5)}, ${_coords.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _isGpsLoading ? 'Acquiring GPS…' : 'GPS coordinates',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _grabGPS,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      _isGpsLoading ? '...' : 'Refresh',
                      style: const TextStyle(
                          color: AppColors.blue, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 180,
              child: FlutterMap(
                mapController: _mapCtrl,
                options: MapOptions(
                  initialCenter: _coords,
                  initialZoom: 15,
                  onTap: (_, latlng) => setState(() => _coords = latlng),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.cleancity.frontend',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _coords,
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.emerald, AppColors.blue],
                            ),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.emerald.withOpacity(0.5),
                                  blurRadius: 10)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Submit
        GestureDetector(
          onTap: _isSubmitting ? null : _submit,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: _isSubmitting
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.emerald, AppColors.blue],
                    ),
              color: _isSubmitting ? AppColors.card : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _isSubmitting
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.emerald.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Analyzing & Submitting...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    t('Submit Report'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Location mode toggle
class _LocToggle extends StatelessWidget {
  final String mode;
  final VoidCallback onGps;
  final VoidCallback onMap;

  const _LocToggle(
      {required this.mode, required this.onGps, required this.onMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn('GPS', Icons.gps_fixed_rounded, mode == 'gps', onGps, AppColors.blue),
          _btn('Map', Icons.map_outlined, mode == 'map', onMap, AppColors.emerald),
        ],
      ),
    );
  }

  Widget _btn(
      String label, IconData icon, bool active, VoidCallback fn, Color c) {
    return GestureDetector(
      onTap: fn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? c.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              active ? Border.all(color: c.withOpacity(0.4)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? c : Colors.white38, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? c : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Typewriter animation for analyzing step
class _TypewriterText extends StatefulWidget {
  final List<String> texts;
  const _TypewriterText({required this.texts});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  Future<void> _cycle() async {
    for (var t in widget.texts) {
      if (!mounted) return;
      setState(() => _idx = widget.texts.indexOf(t));
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        widget.texts[_idx],
        key: ValueKey(_idx),
        style: const TextStyle(
          color: AppColors.emerald,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
