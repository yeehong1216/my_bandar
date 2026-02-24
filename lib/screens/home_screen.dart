
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: _currentNavIndex == 0
          ? _buildHomeBody(provider)
          : _buildPlaceholderPage(_navLabel(_currentNavIndex)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (i) => setState(() => _currentNavIndex = i),
        height: 68,
        elevation: 3,
        shadowColor: Colors.black26,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _navLabel(int index) {
    const labels = ['Home', 'Map', 'Alerts', 'Profile'];
    return labels[index];
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildHomeBody(AppProvider provider) {
    return Stack(
      children: [
        // Gradient header background
        Container(
          height: 260,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE3F2FD), AppTheme.backgroundGrey],
            ),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Profile Bar ───
                _buildProfileBar(provider),
                const SizedBox(height: 24),

                // ─── Greeting ───
                Text(
                  'Welcome,',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  provider.userName,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Let's make our city better today.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Hero Cards ───
                _HeroCard(
                  label: 'Report Problem',
                  subtitle: 'Submit a new civic issue',
                  icon: Icons.camera_alt_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  isLight: true,
                  onTap: () => Navigator.pushNamed(context, '/submit'),
                ),
                const SizedBox(height: 16),
                _HeroCard(
                  label: 'Track Your Status',
                  subtitle: 'View your submitted reports',
                  icon: Icons.insert_chart_outlined_rounded,
                  borderColor: AppTheme.primaryBlue,
                  isLight: false,
                  onTap: () => Navigator.pushNamed(context, '/track'),
                ),
                const SizedBox(height: 28),

                // ─── Status Overview Dashboard ───
                _buildStatusDashboard(provider),
                const SizedBox(height: 22),

                // ─── Recent Reports Feed ───
                _buildRecentReportsSection(provider),
                const SizedBox(height: 22),

                // ─── Safety Tip Banner ───
                _buildSafetyTip(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────
  //  Profile Bar
  // ───────────────────────────────
  Widget _buildProfileBar(AppProvider provider) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
          child: Text(
            provider.userName.isNotEmpty ? provider.userName[0] : 'U',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'MyBandar',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            color: AppTheme.textDark,
            onPressed: () => setState(() => _currentNavIndex = 2),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────
  //  Status Overview Dashboard
  // ───────────────────────────────
  Widget _buildStatusDashboard(AppProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatusColumn(
              count: provider.pendingCount,
              label: 'Pending',
              color: AppTheme.pendingAmber,
            ),
            VerticalDivider(
              color: Colors.grey.shade200,
              thickness: 1,
              width: 1,
            ),
            _buildStatusColumn(
              count: provider.inProgressCount,
              label: 'In Progress',
              color: AppTheme.inProgressBlue,
            ),
            VerticalDivider(
              color: Colors.grey.shade200,
              thickness: 1,
              width: 1,
            ),
            _buildStatusColumn(
              count: provider.doneCount,
              label: 'Done',
              color: AppTheme.completeGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusColumn({
    required int count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────
  //  Recent Reports Feed
  // ───────────────────────────────
  Widget _buildRecentReportsSection(AppProvider provider) {
    final recentReports = provider.reports.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Reports',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/track'),
              child: Text(
                'See All',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (recentReports.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                'No reports yet',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          )
        else
          ...recentReports.map((report) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReportCard(report),
              )),
      ],
    );
  }

  Widget _buildReportCard(dynamic report) {
    Color priorityColor;
    switch (report.priority) {
      case 'High':
        priorityColor = AppTheme.cancelRed;
        break;
      case 'Medium':
        priorityColor = AppTheme.ongoingAmber;
        break;
      default:
        priorityColor = AppTheme.primaryBlue;
    }

    Color statusColor;
    IconData statusIcon;
    switch (report.status) {
      case 'Pending':
        statusColor = AppTheme.pendingAmber;
        statusIcon = Icons.schedule_rounded;
        break;
      case 'In Progress':
        statusColor = AppTheme.inProgressBlue;
        statusIcon = Icons.engineering_rounded;
        break;
      default:
        statusColor = AppTheme.completeGreen;
        statusIcon = Icons.check_circle_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          // Title + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  report.address,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Priority badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              report.priority,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: priorityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────
  //  Safety Tip Banner
  // ───────────────────────────────
  Widget _buildSafetyTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF48FB1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFC62828),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safety Tip',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFC62828),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Avoid red zones in high-traffic areas.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════
//  Hero Card with tap animation
// ═══════════════════════════════════════
class _HeroCard extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Gradient? gradient;
  final Color? borderColor;
  final bool isLight;
  final VoidCallback onTap;

  const _HeroCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.gradient,
    this.borderColor,
    required this.isLight,
    required this.onTap,
  });

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isLight ? Colors.white : AppTheme.primaryBlue;
    final subtitleColor = widget.isLight
        ? Colors.white.withValues(alpha: 0.8)
        : AppTheme.textSecondary;
    final iconBg = widget.isLight
        ? Colors.white.withValues(alpha: 0.18)
        : AppTheme.primaryBlue.withValues(alpha: 0.1);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null ? Colors.white : null,
            borderRadius: BorderRadius.circular(24),
            border: widget.borderColor != null && widget.gradient == null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.isLight
                    ? AppTheme.primaryBlue.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.poppins(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: textColor, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
