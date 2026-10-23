// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'home_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  final String devEmail = "admin@tra.go.tz";
  final String devPassword = "123456";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    if (_emailController.text.trim() == devEmail && _passwordController.text == devPassword) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => const HomeDashboard(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid credentials\nadmin@tra.go.tz / 123456')),
    );
    setState(() => _isLoading = false);
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    _buildHero(topInset),
                    Expanded(child: _buildFormSheet()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(double topInset) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, topInset + 36, 24, 36),
      child: FadeSlideIn(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppShadows.lifted,
                ),
                child: Image.asset('assets/images/tra_logo.png', width: 56, height: 56),
              ),
              const SizedBox(height: 26),
              const Text(
                "Welcome back",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Sign in to TRA SecureScan to scan,\nsecure and share documents.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.onPrimary.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSheet() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
            child: FadeSlideIn(
              index: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Email", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textHigh)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      hintText: "your.name@tra.go.tz",
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                      fillColor: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text("Password", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textHigh)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _isLoading ? null : _login(),
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      fillColor: AppColors.background,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textLow,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _rememberMe = !_rememberMe),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                ),
                              ),
                              const Flexible(
                                child: Text(
                                  "Remember me",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: AppColors.textMedium, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _comingSoon('Password reset'),
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(color: AppColors.primaryDark, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.onPrimary),
                            )
                          : const Text("Sign In"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 24),
          const _SecureAccessFooter(),
        ],
      ),
    );
  }
}

/// Bottom artwork of the login sheet: "secure access" badge over a navy and
/// gold wave, drawn in code so it stays sharp at any size.
class _SecureAccessFooter extends StatelessWidget {
  const _SecureAccessFooter();

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 210 + bottomInset,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _WavePainter())),
          Positioned(
            top: 18,
            left: 0,
            right: 0,
            // Browsers can lay the page out at ~1px wide while the window opens;
            // skip the badge until there is room for the icon.
            child: LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth < 80
                  ? const SizedBox.shrink()
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 40, color: AppColors.navy),
                        SizedBox(width: 14),
                        Flexible(
                          child: Text(
                            "Secure access for\nTRA staff only",
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 15,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
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
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Gold band peeking out above the navy wave on the right.
    final gold = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.93)
      ..quadraticBezierTo(w * 0.55, h * 0.93, w, h * 0.26)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(gold, Paint()..color = AppColors.primary);

    final navy = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.95)
      ..quadraticBezierTo(w * 0.55, h * 0.97, w, h * 0.34)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      navy,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [AppColors.navyDeep, AppColors.navy],
        ).createShader(Offset.zero & size),
    );

    // Darker front swoosh along the bottom edge for depth.
    final front = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.97)
      ..quadraticBezierTo(w * 0.6, h * 1.0, w, h * 0.86)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(front, Paint()..color = AppColors.navyDeep);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
