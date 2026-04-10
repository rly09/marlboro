import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_pill.dart';

class TaskSheet extends StatefulWidget {
  final int reportId;
  final VoidCallback onClose;

  const TaskSheet({super.key, required this.reportId, required this.onClose});

  @override
  State<TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _confettiCtrl =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  // Action handlers
  Future<void> _handleClaim() async {
    if (_isClaiming) return;
    setState(() => _isClaiming = true);
    await context.read<AppProvider>().claimReport(widget.reportId);
    _confettiCtrl.play();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) widget.onClose();
  }

  String _cleanupTime(Report r) {
    switch (r.severity) {
      case 'High':
        return '2-3 hours';
      case 'Medium':
        return '45 mins';
      default:
        return '15 mins';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().translate;
    final reports = context.watch<AppProvider>().reports;
    
    // Find the current report in the latest reports list
    final r = reports.cast<Report?>().firstWhere(
          (e) => e?.id == widget.reportId,
          orElse: () => null,
        );
    
    if (r == null) {
      return const SizedBox.shrink();
    }
    
    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: widget.onClose,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),

        // Sheet content
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1726),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image header
                _ImageHeader(report: r!, onClose: widget.onClose),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Insight card
                      if (r.aiInsight != null) ...[
                        GlassCard(
                          padding: const EdgeInsets.all(14),
                          borderColor: AppColors.emerald.withOpacity(0.3),
                          shadows: [
                            BoxShadow(
                              color: AppColors.emerald.withOpacity(0.15),
                              blurRadius: 20,
                            )
                          ],
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.emerald,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Cerebras AI Insight',
                                      style: TextStyle(
                                        color: AppColors.emerald,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      r.aiInsight!,
                                      style: const TextStyle(
                                        color: Color(0xB310B981),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Stats row
                      Row(
                        children: [
                          _StatCard(
                            label: 'Est. Cleanup',
                            value: _cleanupTime(r),
                            icon: Icons.timer_rounded,
                            color: AppColors.blue,
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            label: 'Coords',
                            value:
                                '${r.lat.toStringAsFixed(3)}, ${r.lng.toStringAsFixed(3)}',
                            icon: Icons.location_on_rounded,
                            color: AppColors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Description
                      Text(
                        r.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Volunteer & Score Info
                      Row(
                        children: [
                          if (r.claimedByName != null) ...[
                            Icon(Icons.person_outline_rounded,
                                color: AppColors.emerald.withOpacity(0.7), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${t("Claimed by")}: ${r.claimedByName}',
                              style: TextStyle(
                                color: AppColors.emerald.withOpacity(0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                          ],
                          Icon(Icons.stars_rounded,
                              color: AppColors.yellow.withOpacity(0.7), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '+${r.severity == "High" ? 50 : r.severity == "Medium" ? 25 : 10} ${t("Points")}',
                            style: TextStyle(
                              color: AppColors.yellow.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons or Before/After
                      if (r.status == 'Cleaned' && r.afterImg != null)
                        ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Before & After Validation',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(child: _buildComparisonImage(t('Before'), r.img)),
                              const SizedBox(width: 12),
                              if (r.afterImg != null)
                                Expanded(child: _buildComparisonImage(t('After'), r.afterImg!)),
                            ],
                          ),
                        ]
                      else if (r.status == 'Pending')
                        _SwipeToClaim(
                          isClaiming: _isClaiming,
                          onClaim: _handleClaim,
                        )
                      else if (r.status == 'In Progress' || r.status == 'Pending Proof')
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt_rounded),
                            label: Text(
                              t('Mark as Cleaned'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(source: ImageSource.camera);
                              
                              if (image != null) {
                                final bytes = await image.readAsBytes();
                                if (!mounted) return;
                                setState(() => _isClaiming = true);
                                await context.read<AppProvider>().completeReport(widget.reportId, bytes, image.name);
                                _confettiCtrl.play();
                                if (!mounted) return;
                                setState(() => _isClaiming = false);
                                await Future.delayed(const Duration(seconds: 2));
                                if (mounted) widget.onClose();
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiCtrl,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.1,
            colors: const [
              AppColors.emerald,
              AppColors.blue,
              AppColors.yellow,
              Colors.white,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonImage(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'http://127.0.0.1:8000$url',
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 120,
              color: Colors.white10,
              child: const Icon(Icons.broken_image, color: Colors.white54),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        )
      ],
    );
  }
}

class _ImageHeader extends StatelessWidget {
  final Report report;
  final VoidCallback onClose;

  const _ImageHeader({required this.report, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: Stack(
          children: [
            report.img.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: report.img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Image.network(
                    'http://127.0.0.1:8000${report.img}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
            // Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC060C14)],
                ),
              ),
            ),
            // Tags bottom
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusPill(
                    label: report.status,
                    color: statusColor(report.status),
                  ),
                  StatusPill(
                    label: report.severity,
                    color: severityColor(report.severity),
                  ),
                ],
              ),
            ),
            // Close button
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeToClaim extends StatefulWidget {
  final bool isClaiming;
  final VoidCallback onClaim;

  const _SwipeToClaim({required this.isClaiming, required this.onClaim});

  @override
  State<_SwipeToClaim> createState() => _SwipeToClaimState();
}

class _SwipeToClaimState extends State<_SwipeToClaim> {
  double _dx = 0;
  static const _maxDx = 220.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fill bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: Duration.zero,
              width: _dx + 56,
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          // Label
          const Text(
            'Swipe → to Claim',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),

          // Thumb
          Positioned(
            left: 4,
            top: 4,
            bottom: 4,
            child: GestureDetector(
              onHorizontalDragUpdate: (d) {
                setState(() {
                  _dx = (_dx + d.delta.dx).clamp(0, _maxDx);
                });
              },
              onHorizontalDragEnd: (_) {
                if (_dx > _maxDx * 0.8) {
                  widget.onClaim();
                } else {
                  setState(() => _dx = 0);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 48,
                transform: Matrix4.translationValues(_dx, 0, 0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.emerald, AppColors.blue],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withOpacity(0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: widget.isClaiming
                    ? const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
