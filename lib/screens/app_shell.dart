import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';
import '../models/models.dart';
import 'login_screen.dart';
import 'call_center/register_screen.dart';
import 'call_center/cc_dashboard.dart';
import 'call_center/cc_filtered_students.dart';
import 'examinator/ex_screens.dart';
import 'examinator/enter_results.dart';
import 'examinator/manage_schedule.dart';

// ── Nav Item Model ────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final List<String>? subItems; // Optional sub-menus
  const _NavItem(this.label, this.icon, {this.subItems});
}

// ══════════════════════════════════════════════════════════════════════════
// CALL CENTER SHELL
// ══════════════════════════════════════════════════════════════════════════

class CallCenterShell extends StatefulWidget {
  final VoidCallback onLogout;
  const CallCenterShell({super.key, required this.onLogout});

  @override
  State<CallCenterShell> createState() => _CallCenterShellState();
}

class _CallCenterShellState extends State<CallCenterShell> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem('Dashboard', Icons.grid_view_rounded),
    _NavItem('Register Student', Icons.person_add_rounded),
    _NavItem('Passed Students', Icons.check_circle_outline),
    _NavItem('Failed Students', Icons.cancel_outlined),
  ];

  Widget get _body {
    switch (_selectedIndex) {
      case 0: return CallCenterDashboard(onRefresh: _refresh);
      case 1: return RegisterStudentScreen(onSaved: () {
          setState(() => _selectedIndex = 0);
        });
      case 2: return const CCFilteredStudentsScreen(isPassed: true);
      case 3: return const CCFilteredStudentsScreen(isPassed: false);
      default: return const Center(child: Text('Under Construction'));
    }
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return _ShellLayout(
      roleLabel: 'Call Center',
      navItems: _navItems,
      selectedIndex: _selectedIndex,
      onSelect: (i) => setState(() => _selectedIndex = i),
      onLogout: widget.onLogout,
      body: _body,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EXAMINATOR SHELL
// ══════════════════════════════════════════════════════════════════════════

class ExaminatorShell extends StatefulWidget {
  final VoidCallback onLogout;
  const ExaminatorShell({super.key, required this.onLogout});

  @override
  State<ExaminatorShell> createState() => _ExaminatorShellState();
}

class _ExaminatorShellState extends State<ExaminatorShell> {
  int _selectedIndex = 0;

  static const _navItems = [
    _NavItem('Students', Icons.people_rounded),
    _NavItem('Timetable', Icons.calendar_month_rounded),
    _NavItem('Manage Schedule', Icons.edit_calendar_rounded),
    _NavItem('Enter Results', Icons.assignment_turned_in_rounded),
  ];

  Widget get _body {
    switch (_selectedIndex) {
      case 0: return const ExStudentListScreen();
      case 1: return const TimetableScreen();
      case 2: return const ManageScheduleScreen();
      case 3: return const EnterResultsScreen();
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ShellLayout(
      roleLabel: 'Examinator',
      navItems: _navItems,
      selectedIndex: _selectedIndex,
      onSelect: (i) => setState(() => _selectedIndex = i),
      onLogout: widget.onLogout,
      body: _body,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SHELL LAYOUT (DUAL PANEL)
// ══════════════════════════════════════════════════════════════════════════

class _ShellLayout extends StatelessWidget {
  final String roleLabel;
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final Widget body;

  const _ShellLayout({
    required this.roleLabel,
    required this.navItems,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            _ExpandableSidebar(
              roleLabel: roleLabel,
              navItems: navItems,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
              onLogout: onLogout,
            ),
            const SizedBox(width: 24),

            // Main Content Area
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  color: AppTheme.background,
                  child: Column(
                    children: [
                      // Floating Top Bar
                      _FloatingTopBar(
                        pageTitle: navItems[selectedIndex].label,
                        roleLabel: roleLabel,
                      ),
                      const SizedBox(height: 16),
                      // Content
                      Expanded(child: body),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableSidebar extends StatefulWidget {
  final String roleLabel;
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const _ExpandableSidebar({
    required this.roleLabel,
    required this.navItems,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  State<_ExpandableSidebar> createState() => _ExpandableSidebarState();
}

class _ExpandableSidebarState extends State<_ExpandableSidebar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: _isHovered ? 260 : 70,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppTheme.smallShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedSparkles,
                      color: AppTheme.accent,
                      size: 26,
                    ),
                    Expanded(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isHovered ? 1.0 : 0.0,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            'Menu',
                            style: GoogleFonts.nunito(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: widget.navItems.length,
                  itemBuilder: (context, i) {
                    final item = widget.navItems[i];
                    final isActive = i == widget.selectedIndex;
                    return _SidebarItem(
                      icon: item.icon,
                      label: item.label,
                      isActive: isActive,
                      isExpanded: _isHovered,
                      onTap: () => widget.onSelect(i),
                    );
                  },
                ),
              ),
              
              // Logout button at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _SidebarItem(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  isActive: false,
                  isExpanded: _isHovered,
                  onTap: widget.onLogout,
                ),
              ),
              const SizedBox(height: 16),
              
              // Role label
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.symmetric(
                    horizontal: _isHovered ? 16 : 10,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedUserGroup,
                        color: AppTheme.textSecondary,
                        size: 26,
                      ),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isHovered ? 1.0 : 0.0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              widget.roleLabel,
                              style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (val) => setState(() => _hovered = val),
          borderRadius: BorderRadius.circular(24),
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isExpanded ? 16 : 10,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppTheme.accent
                  : (_hovered ? AppTheme.borderLight : Colors.transparent),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 26,
                  color: widget.isActive ? Colors.white : AppTheme.textSecondary,
                ),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: widget.isExpanded ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        widget.label,
                        style: GoogleFonts.nunito(
                          color: widget.isActive ? Colors.white : AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
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
}

// ── Floating Top Bar ──────────────────────────────────────────────────────
class _FloatingTopBar extends StatelessWidget {
  final String pageTitle;
  final String roleLabel;

  const _FloatingTopBar({
    required this.pageTitle,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppTheme.smallShadow,
      ),
      child: Row(
        children: [
          Text(pageTitle,
            style: GoogleFonts.nunito(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
