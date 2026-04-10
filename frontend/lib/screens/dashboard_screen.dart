import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_pill.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final localeProv = context.watch<LocaleProvider>();
    final t = localeProv.translate;
    
    final stats = provider.userStats;
    final reports = provider.reports;
    final leaderboard = provider.leaderboard;

    final totalReports = reports.length;
    final inProgress = reports.where((r) => r.status == 'In Progress' || r.status == 'Pending Proof').length;
    final cleaned = reports.where((r) => r.status == 'Cleaned').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.emerald,
          backgroundColor: AppColors.card,
          onRefresh: () => provider.fetchAll(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ShaderMask(
                                  shaderCallback: (b) =>
                                      AppColors.emeraldGradient.createShader(b),
                                  child: Text(
                                    t('Dashboard'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.language, color: Colors.white70),
                                  onPressed: () => localeProv.toggleLocale(),
                                  tooltip: 'Language',
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${t("Hello")}, ${stats?.name ?? 'Eco Warrior'} 👋',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Points badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: AppColors.emerald.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emerald.withOpacity(0.2),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events_rounded,
                                    color: AppColors.emerald, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  '${stats?.points ?? 0} pts',
                                  style: const TextStyle(
                                    color: AppColors.emerald,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Streak badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: AppColors.orange.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  '${stats?.streak ?? 0} ${t("Day Streak")}',
                                  style: const TextStyle(
                                    color: AppColors.orange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Gamification Extra Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _StatCard(
                        label: t('Trust Score'),
                        value: stats?.trustScore ?? 100,
                        icon: Icons.verified_user_rounded,
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: t('Total Cleanups'),
                        value: stats?.totalCleanups ?? 0,
                        icon: Icons.cleaning_services_rounded,
                        color: AppColors.emerald,
                      ),
                    ],
                  ),
                ),
              ),

              // Normal Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _StatCard(
                        label: t('Total Reports'),
                        value: totalReports,
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: t('In Progress'),
                        value: inProgress,
                        icon: Icons.autorenew_rounded,
                        color: AppColors.orange,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        label: t('Cleaned'),
                        value: cleaned,
                        icon: Icons.eco_rounded,
                        color: AppColors.emerald,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // Impact Highlights
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.blue.withOpacity(0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.public_rounded, color: AppColors.blue, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              t('Global Impact'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ImpactStat(
                              label: t('Area Cleaned'),
                              value: '${cleaned * 150}m²',
                              icon: Icons.map_rounded,
                              color: AppColors.emerald,
                            ),
                            _ImpactStat(
                              label: t('Impact Score'),
                              value: '${stats?.totalCleanups != null ? stats!.totalCleanups * 12 : 0}',
                              icon: Icons.bolt_rounded,
                              color: AppColors.yellow,
                            ),
                            _ImpactStat(
                              label: t('Top Volunteers'),
                              value: '${leaderboard.length}',
                              icon: Icons.people_alt_rounded,
                              color: AppColors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Section Header: Leaderboard
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded,
                          color: AppColors.yellow, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        t('Local Leaderboard'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Leaderboard
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: leaderboard.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                t('Elite Warriors'),
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          )
                        : Column(
                            children: leaderboard.asMap().entries.map((e) {
                              final idx = e.key;
                              final entry = e.value;
                              return _LeaderboardRow(
                                rank: idx + 1,
                                entry: entry,
                                showDivider: idx < leaderboard.length - 1,
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ),

              // AI Predictive Heatmap
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined,
                          color: AppColors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        t('AI Predictive Heatmap'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: _PredictiveCard(reportCount: reports.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
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
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<int>(
              duration: const Duration(milliseconds: 800),
              tween: IntTween(begin: 0, end: value),
              builder: (_, v, __) => Text(
                '$v',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final dynamic entry;
  final bool showDivider;

  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = entry.isMe as bool;
    final medalColors = [AppColors.yellow, const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
    final medalIcons = ['🥇', '🥈', '🥉'];

    return Column(
      children: [
        Container(
          color: isMe ? AppColors.emerald.withOpacity(0.05) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 32,
                child: rank <= 3
                    ? Text(
                        medalIcons[rank - 1],
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        '#$rank',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [AppColors.emerald, AppColors.blue])
                      : null,
                  color: isMe ? null : Colors.white.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    entry.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: TextStyle(
                        color:
                            isMe ? AppColors.emerald : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: AppColors.yellow.withOpacity(0.2)),
                      ),
                      child: Text(
                        entry.badge,
                        style: const TextStyle(
                          color: AppColors.yellow,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Points & Trust
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.points}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          color: AppColors.blue, size: 10),
                      const SizedBox(width: 2),
                      Text(
                        '${entry.trustScore}',
                        style: TextStyle(
                          color: AppColors.blue.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withOpacity(0.05),
          ),
      ],
    );
  }
}

// Animated predictive heatmap card
class _PredictiveCard extends StatefulWidget {
  final int reportCount;
  const _PredictiveCard({required this.reportCount});

  @override
  State<_PredictiveCard> createState() => _PredictiveCardState();
}

class _PredictiveCardState extends State<_PredictiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanCtrl;
  late Animation<double> _scanY;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scanY = Tween<double>(begin: 0, end: 1).animate(_scanCtrl);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleProvider>().translate;
    return GlassCard(
      borderColor: AppColors.red.withOpacity(0.2),
      shadows: [
        BoxShadow(color: AppColors.red.withOpacity(0.1), blurRadius: 20),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Dumping Risk: High (88%)',
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Pulsing dot
                        _PulsingDot(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${t("AI Analyzed")} ${widget.reportCount} reports. Sector 7G is the predicted next critical dumping site.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Scanning heatmap box
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 110,
              child: Stack(
                children: [
                  // Background grid
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Radial glow
                  Center(
                    child: Container(
                      width: 180,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.red.withOpacity(0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Scan line
                  AnimatedBuilder(
                    animation: _scanY,
                    builder: (_, __) {
                      return Positioned(
                        top: _scanY.value * 110,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.red.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.red.withOpacity(0.6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Icon
                  Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.white.withOpacity(0.06),
                      size: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Predicted Route',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
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
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.red.withOpacity(_anim.value),
          boxShadow: [
            BoxShadow(
              color: AppColors.red.withOpacity(_anim.value * 0.5),
              blurRadius: 6,
            )
          ],
        ),
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ImpactStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}
