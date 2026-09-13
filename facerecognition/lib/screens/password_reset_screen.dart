import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../widgets/gradient_button.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  bool _tokenSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  void _requestResetToken() async {
    if (_emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your registered email address'), backgroundColor: AppTheme.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Sim API
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _tokenSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset token generated & dispatched!'), backgroundColor: AppTheme.green),
    );
  }

  void _resetPassword() async {
    if (_tokenCtrl.text.isEmpty || _newPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter reset token and new password'), backgroundColor: AppTheme.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully! Please log in.'), backgroundColor: AppTheme.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: const Text('🔐 Password Recovery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Secure Password Reset', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Enter your registered email address to receive a secure single-use reset token.', style: TextStyle(color: AppTheme.textSub, fontSize: 13)),
              const SizedBox(height: 24),
              _inputField(_emailCtrl, 'Email Address', Icons.email_outlined),
              const SizedBox(height: 16),
              if (!_tokenSent)
                GradientButton(
                  label: 'Generate Reset Token',
                  icon: Icons.send_outlined,
                  isLoading: _isLoading,
                  onTap: _requestResetToken,
                )
              else ...[
                const Divider(height: 32, color: AppTheme.border),
                _inputField(_tokenCtrl, 'Reset Token', Icons.vpn_key_outlined),
                const SizedBox(height: 12),
                _inputField(_newPassCtrl, 'New Password', Icons.lock_outline, obscure: true),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'Update Password',
                  icon: Icons.check_circle_outline,
                  gradient: AppTheme.greenGradient,
                  textColor: Colors.black,
                  isLoading: _isLoading,
                  onTap: _resetPassword,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.bgSurface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
