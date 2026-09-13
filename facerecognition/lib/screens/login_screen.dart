import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_button.dart';
import 'dashboard_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  final _emailCtrl = TextEditingController(text: 'alex.vance@nilgiri.edu');
  final _passCtrl = TextEditingController(text: '••••••••');
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    await AuthService.instance.login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DashboardScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          // Floating biometric node orbs
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (_, __) => Stack(children: [
              _orb(top: 120 + _floatCtrl.value * 25, left: 30,
                  color: AppTheme.green, icon: Icons.fingerprint),
              _orb(top: 260 - _floatCtrl.value * 18, left: 280,
                  color: AppTheme.blue, icon: Icons.person_outline),
              _orb(top: 400 + _floatCtrl.value * 12, left: 60,
                  color: AppTheme.red, icon: Icons.camera_alt_outlined),
              _orb(top: 180 + _floatCtrl.value * 15, left: 320,
                  color: AppTheme.gold, icon: Icons.shield_outlined),
            ]),
          ),

          // Frosted bottom sheet panel
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgSurface.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusXl)),
                border: Border(
                  top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08), width: 1.5),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                  AppTheme.spaceLg, AppTheme.spaceLg,
                  AppTheme.spaceLg, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.textMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  const Text('Sign in to continue',
                      style: TextStyle(color: AppTheme.textSub, fontSize: 14)),
                  const SizedBox(height: 24),

                  // Email field
                  _inputField(
                    controller: _emailCtrl,
                    label: 'Email address',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // Password field
                  _inputField(
                    controller: _passCtrl,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscure: _obscurePass,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted, size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Forgot password?',
                        style: TextStyle(color: AppTheme.cyan.withValues(alpha: 0.8),
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 22),

                  GradientButton(
                    label: 'Log In',
                    icon: Icons.arrow_forward,
                    isLoading: _isLoading,
                    onTap: _login,
                  ),
                  const SizedBox(height: 14),

                  OutlineButton(
                    label: 'Register Face Baseline (First Time)',
                    borderColor: AppTheme.green,
                    textColor: AppTheme.green,
                    icon: Icons.face_retouching_natural,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegistrationScreen())),
                  ),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Protected by on-device neural biometrics',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                  ),
                ],
              ),
            ).animate().slideY(
                begin: 0.4, duration: 600.ms, curve: Curves.easeOutCubic),
          ),

          // Hero text top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceLg, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.cyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                          color: AppTheme.cyan.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_outlined, color: AppTheme.cyan, size: 14),
                        SizedBox(width: 6),
                        Text('Zero-friction check-in',
                            style: TextStyle(
                                color: AppTheme.cyan,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                  const SizedBox(height: 16),
                  const Text('PulseAttend',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          height: 1.1))
                      .animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 10),
                  const Text(
                      'Secure event check-ins\npowered by neural biometrics.',
                      style: TextStyle(
                          color: AppTheme.textSub, fontSize: 16, height: 1.5))
                      .animate(delay: 450.ms).fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb({required double top, required double left,
      required Color color, required IconData icon}) {
    return Positioned(
      top: top, left: left,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [BoxShadow(
              color: color.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 3)],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
