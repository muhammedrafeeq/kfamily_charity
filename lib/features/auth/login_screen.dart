import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signIn(
        phone: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = View.of(context);
    final screenHeight = view.display.size.height / view.devicePixelRatio;

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Gradient background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
            ),
          ),
          // ... circles ...
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Content
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.volunteer_activism_rounded,
                            size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.appName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Family Charity Fund',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textOnDarkSub,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Login Card
                      Container(
                        padding: const EdgeInsets.all(28),
                        margin: const EdgeInsets.only(bottom: 40),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 40,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('Welcome back',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  )),
                              const SizedBox(height: 4),
                              Text('Sign in using your phone number and 4-digit key',
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 24),
                              // ...
                                // ... rest of form fields ...

                              if (_error != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusRejected.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.statusRejected.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: AppColors.statusRejected, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(_error!,
                                            style: const TextStyle(
                                              color: AppColors.statusRejected, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              TextFormField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Enter your phone number' : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  labelText: '4-Digit Login Key / Password',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 8),
                              /* Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push(AppRoutes.forgotPassword),
                                  child: const Text(AppStrings.forgotPassword),
                                ),
                              ), */
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text(AppStrings.login,
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
