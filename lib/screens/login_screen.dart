import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum UserRole { callCenter, examinator }

class LoginScreen extends StatefulWidget {
  final Function(UserRole) onLogin;
  LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserRole _selectedRole = UserRole.callCenter;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMsg;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Credentials
  static Map<UserRole, Map<String, String>> _credentials = {
    UserRole.callCenter: {'username': 'amirfattoyev', 'password': 'exam2026'},
    UserRole.examinator: {'username': 'exam', 'password': '2026exam'},
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: Duration(milliseconds: 800), vsync: this);
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

    await Future.delayed(Duration(milliseconds: 600));

    final inputUsername = _usernameController.text.trim();
    final inputPassword = _passwordController.text;

    final callCenterCreds = _credentials[UserRole.callCenter]!;
    final examinatorCreds = _credentials[UserRole.examinator]!;

    if (inputUsername == callCenterCreds['username'] && inputPassword == callCenterCreds['password']) {
      widget.onLogin(UserRole.callCenter);
    } else if (inputUsername == examinatorCreds['username'] && inputPassword == examinatorCreds['password']) {
      widget.onLogin(UserRole.examinator);
    } else if (inputUsername == 'admin' && inputPassword == '20262026') {
      // Master login: ask which panel
      setState(() {
        _isLoading = false;
      });
      _showMasterLoginDialog();
    } else {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Invalid username or password';
      });
    }
  }

  void _showMasterLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Panel', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        content: Text('You used the master password. Which panel do you want to access?', style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogin(UserRole.callCenter);
            },
            child: Text('Call Center', style: GoogleFonts.nunito(color: AppTheme.callCenterColor, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogin(UserRole.examinator);
            },
            child: Text('Examinator', style: GoogleFonts.nunito(color: AppTheme.examinatorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;
                  final leftPanel = Container(
                    width: isMobile ? double.infinity : 420,
                    padding: EdgeInsets.all(isMobile ? 32 : 60),
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
                          child: Icon(Icons.school_rounded,
                              color: Colors.white, size: 30),
                        ),
                        SizedBox(height: 32),
                        Text('Internal\nExam Planner',
                            style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary,
                                fontSize: isMobile ? 32 : 40,
                                fontWeight: FontWeight.w800,
                                height: 1.1)),
                        SizedBox(height: 16),
                        Text(
                          'Manage student registrations,\nexam schedules, and results\nall in one place.',
                          style: GoogleFonts.nunito(
                              color: AppTheme.textSecondary,
                              fontSize: 15,
                              height: 1.6),
                        ),
                        SizedBox(height: 48),
                        if (!isMobile) ...[
                          _featureRow(Icons.people_alt_rounded, 'Student Management'),
                          SizedBox(height: 12),
                          _featureRow(Icons.calendar_month_rounded, 'Exam Scheduling'),
                          SizedBox(height: 12),
                          _featureRow(Icons.analytics_rounded, 'Smart Score Calculator'),
                        ],
                      ],
                    ),
                  );

                  final rightPanel = Container(
                    width: isMobile ? double.infinity : 420,
                    margin: EdgeInsets.all(24),
                    padding: EdgeInsets.all(40),
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
                          SizedBox(height: 6),
                          Text('Sign in to continue',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary, fontSize: 14)),
                          SizedBox(height: 32),

                          // Username
                          Text('Username',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 6),
                          TextFormField(
                            controller: _usernameController,
                            style: GoogleFonts.nunito(
                                color: AppTheme.textPrimary, fontSize: 14),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
                              prefixIcon: Icon(Icons.person_outline,
                                  color: AppTheme.textMuted, size: 18),
                            ),
                          ),
                          SizedBox(height: 16),

                          // Password
                          Text('Password',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 6),
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
                              prefixIcon: Icon(Icons.lock_outline,
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
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        AppTheme.danger.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: AppTheme.danger, size: 16),
                                  SizedBox(width: 8),
                                  Text(_errorMsg!,
                                      style: GoogleFonts.nunito(
                                          color: AppTheme.danger,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                backgroundColor: AppTheme.accent,
                              ),
                              child: _isLoading
                                  ? SizedBox(
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

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );

                  return isMobile 
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [leftPanel, rightPanel],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [leftPanel, rightPanel],
                      );
                }
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
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppTheme.accent, size: 16),
        ),
        SizedBox(width: 10),
        Text(text,
            style: GoogleFonts.nunito(
                color: AppTheme.textSecondary, fontSize: 14)),
      ],
    );
  }
}


