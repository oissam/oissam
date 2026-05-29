import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum UserRole { callCenter, examinator }

class LoginScreen extends StatefulWidget {
  final Function(UserRole) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.callCenter;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMsg;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Credentials
  static const Map<UserRole, Map<String, String>> _credentials = {
    UserRole.callCenter: {'username': 'amirfattoyev', 'password': 'exam2026'},
    UserRole.examinator: {'username': 'exam', 'password': '2026exam'},
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final creds = _credentials[_selectedRole]!;
    if (_usernameController.text.trim() == creds['username'] &&
        _passwordController.text == creds['password']) {
      widget.onLogin(_selectedRole);
    } else {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Invalid username or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.background,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left branding panel
                  Container(
                    width: 420,
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: Colors.white, size: 30),
                        ),
                        const SizedBox(height: 32),
                        Text('Internal\nExam Planner',
                            style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                height: 1.1)),
                        const SizedBox(height: 16),
                        Text(
                          'Manage student registrations,\nexam schedules, and results\nall in one place.',
                          style: GoogleFonts.nunito(
                              color: AppTheme.textSecondary,
                              fontSize: 15,
                              height: 1.6),
                        ),
                        const SizedBox(height: 48),
                        _featureRow(Icons.people_alt_rounded, 'Student Management'),
                        const SizedBox(height: 12),
                        _featureRow(Icons.calendar_month_rounded, 'Exam Scheduling'),
                        const SizedBox(height: 12),
                        _featureRow(Icons.analytics_rounded, 'Smart Score Calculator'),
                      ],
                    ),
                  ),
                  // Right login card
                  Container(
                    width: 420,
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Welcome back',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text('Sign in to continue',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary, fontSize: 14)),
                          const SizedBox(height: 32),

                          // Role selector
                          Text('Select Role',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _roleChip(
                                  UserRole.callCenter,
                                  'Call Center',
                                  Icons.headset_mic_rounded,
                                  AppTheme.callCenterColor),
                              const SizedBox(width: 10),
                              _roleChip(
                                  UserRole.examinator,
                                  'Examinator',
                                  Icons.assignment_rounded,
                                  AppTheme.examinatorColor),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Username
                          Text('Username',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _usernameController,
                            style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary, fontSize: 14),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                            decoration: const InputDecoration(
                              hintText: 'Enter your username',
                              prefixIcon: Icon(Icons.person_outline,
                                  color: AppTheme.textMuted, size: 18),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          Text('Password',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary, fontSize: 14),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Required'
                                : null,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: AppTheme.textMuted, size: 18),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppTheme.textMuted,
                                    size: 18),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),

                          if (_errorMsg != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        AppTheme.danger.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppTheme.danger, size: 16),
                                  const SizedBox(width: 8),
                                  Text(_errorMsg!,
                                      style: GoogleFonts.nunito(
                                          color: AppTheme.danger,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                backgroundColor:
                                    _selectedRole == UserRole.callCenter
                                        ? AppTheme.callCenterColor
                                        : AppTheme.examinatorColor,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : Text('Sign In',
                                      style: GoogleFonts.nunito(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
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

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppTheme.accent, size: 16),
        ),
        const SizedBox(width: 10),
        Text(text,
            style: GoogleFonts.nunito(
                color: AppTheme.textSecondary, fontSize: 14)),
      ],
    );
  }

  Widget _roleChip(
      UserRole role, String label, IconData icon, Color color) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedRole = role;
          _usernameController.text = role == UserRole.callCenter
              ? 'amirfattoyev'
              : 'exam';
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? color : AppTheme.border, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : AppTheme.textMuted, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.nunito(
                      color: isSelected ? color : AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
