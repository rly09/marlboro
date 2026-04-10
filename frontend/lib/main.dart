import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/map_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/report_sheet.dart';
import 'theme/colors.dart';
import 'widgets/toast_overlay.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AppProvider()
              ..fetchAll()
              ..connectWebSocket()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const CleanCityApp(),
    ),
  );
}

class CleanCityApp extends StatelessWidget {
  const CleanCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanCity AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.emerald,
          secondary: AppColors.blue,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      builder: (context, child) => WebMobileWrapper(child: child!),
      home: const AppShell(),
    );
  }
}

class WebMobileWrapper extends StatelessWidget {
  final Widget child;
  const WebMobileWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF030303), // Outer deep black for web
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    MapScreen(),
    DashboardScreen(),
  ];

  void _openReport(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => const ReportSheet(),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main screen content
          _screens[_currentIndex],

          // Toast Overlay
          const Positioned.fill(
            child: IgnorePointer(
              child: ToastOverlay(),
            ),
          ),

          // ─── Bottom Pill Nav ───
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: _BottomNav(
                currentIndex: _currentIndex,
                onTabChanged: (i) => setState(() => _currentIndex = i),
              ),
            ),
          ),

          // ─── FAB Report Button ───
          Positioned(
            bottom: 20,
            right: 24,
            child: _ReportFAB(
              onTap: () => _openReport(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Pill Navigation ───
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const _BottomNav({
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().translate;
    final items = [
      (Icons.map_rounded, t('Map')),
      (Icons.bar_chart_rounded, t('Dashboard')),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: items.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            final isActive = currentIndex == idx;
            return GestureDetector(
              onTap: () => onTabChanged(idx),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    key: ValueKey(isActive),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.$1,
                        color: isActive
                            ? AppColors.emerald
                            : Colors.white.withOpacity(0.4),
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 4 : 0,
                        height: isActive ? 4 : 0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emerald,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.emerald.withOpacity(0.8),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Floating Action Button ───
class _ReportFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _ReportFAB({required this.onTap});

  @override
  State<_ReportFAB> createState() => _ReportFABState();
}

class _ReportFABState extends State<_ReportFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.emerald, AppColors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
