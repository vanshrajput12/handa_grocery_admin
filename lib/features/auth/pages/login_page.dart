
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

const _brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.amber, AppColors.amber, AppColors.warm],
  stops: [0.0, 0.72, 1.0],
);

// ---------------------------------------------------------------------------
// Slider content (decorative labels only, no business data)
// ---------------------------------------------------------------------------

class _ChipSpec {
  const _ChipSpec(this.icon, this.label, this.alignment, this.phase);

  final IconData icon;
  final String label;
  final Alignment alignment;
  final double phase;
}

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.chips,
    this.centerAsset,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<_ChipSpec> chips;

  /// Optional product photo shown inside the centre badge. If the file does
  /// not exist, the icon is shown instead.
  final String? centerAsset;
}

const _slides = [
  _Slide(
    icon: Icons.receipt_long_rounded,
    title: 'Orders in real time',
    subtitle:
    'See every customer order the moment it is placed and update its status in one tap.',
    chips: [
      _ChipSpec(Icons.notifications_active_outlined, 'New order',
          Alignment(-1, -0.6), 0.0),
      _ChipSpec(
          Icons.soup_kitchen_outlined, 'Preparing', Alignment(1, 0.05), 0.33),
      _ChipSpec(Icons.check_circle_outline, 'Delivered',
          Alignment(-0.7, 0.9), 0.66),
    ],
  ),
  _Slide(
    icon: Icons.inventory_2_rounded,
    centerAsset: 'assets/images/rice.png',
    title: 'Products and stock',
    subtitle:
    'Add groceries, change prices and keep an eye on low stock without leaving the page.',
    chips: [
      _ChipSpec(Icons.rice_bowl_outlined, 'Rice', Alignment(-1, -0.6), 0.1),
      _ChipSpec(Icons.cookie_outlined, 'Snacks', Alignment(1, 0.05), 0.43),
      _ChipSpec(Icons.warning_amber_rounded, 'Low stock',
          Alignment(-0.7, 0.9), 0.76),
    ],
  ),
  _Slide(
    icon: Icons.delivery_dining_rounded,
    title: 'Smooth deliveries',
    subtitle:
    'Assign riders and follow every delivery from pickup to the customer\'s door.',
    chips: [
      _ChipSpec(Icons.person_pin_circle_outlined, 'Rider assigned',
          Alignment(-1, -0.6), 0.2),
      _ChipSpec(Icons.local_shipping_outlined, 'Out for delivery',
          Alignment(1, 0.05), 0.53),
      _ChipSpec(Icons.home_outlined, 'At the door', Alignment(-0.7, 0.9), 0.86),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Small animation helpers
// ---------------------------------------------------------------------------

/// Fades and slides its child up shortly after it first appears.
class _Reveal extends StatefulWidget {
  const _Reveal({super.key, required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final Animation<double> _curve =
  CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}

/// Slightly enlarges its child while the mouse is over it.
class _HoverScale extends StatefulWidget {
  const _HoverScale({required this.child});

  final Widget child;

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().signIn(_emailCtrl.text, _passCtrl.text);
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

<<<<<<< HEAD
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: scheme.primaryContainer,
                                child: Icon(
                                  Icons.storefront_rounded,
                                  size: 32,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Handa Grocery Admin',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sign in to manage your store',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            if (state.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: scheme.errorContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(
                                    color: scheme.onErrorContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _emailCtrl,
                              enabled: !state.isSubmitting,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) return 'Enter your email';
                                if (!value.contains('@')) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passCtrl,
                              enabled: !state.isSubmitting,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscure
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter your password'
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: state.isSubmitting ? null : _submit,
                              child: state.isSubmitting
                                  ? const SizedBox(
<<<<<<< HEAD
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
=======
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
>>>>>>> origin/main
                                  : const Text('Sign in'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
=======
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.inkSoft),
      floatingLabelStyle: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: AppColors.inkSoft),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(AppColors.ink, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }

  Widget _buildForm(BuildContext context, AuthState state) {
    final text = Theme.of(context).textTheme;

    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Reveal(
              key: const ValueKey('title'),
              child: Text(
                'Welcome back',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
>>>>>>> origin/main
                ),
              ),
            ),
            const SizedBox(height: 6),
            _Reveal(
              key: const ValueKey('subtitle'),
              delayMs: 80,
              child: Text(
                'Sign in to manage orders, products and deliveries.',
                style: text.bodyMedium?.copyWith(color: AppColors.inkSoft),
              ),
            ),
            const SizedBox(height: 28),
            if (state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 20,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            _Reveal(
              key: const ValueKey('email'),
              delayMs: 160,
              child: TextFormField(
                controller: _emailCtrl,
                enabled: !state.isSubmitting,
                cursorColor: AppColors.ink,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: _decoration(
                  label: 'Email',
                  icon: Icons.email_outlined,
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Enter your email';
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            _Reveal(
              key: const ValueKey('password'),
              delayMs: 240,
              child: TextFormField(
                controller: _passCtrl,
                enabled: !state.isSubmitting,
                cursorColor: AppColors.ink,
                obscureText: _obscure,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: _decoration(
                  label: 'Password',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.inkSoft,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter your password' : null,
              ),
            ),
            const SizedBox(height: 28),
            _Reveal(
              key: const ValueKey('button'),
              delayMs: 320,
              child: _HoverScale(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      AppColors.ink.withValues(alpha: 0.6),
                      disabledForegroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: state.isSubmitting ? null : _submit,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: state.isSubmitting
                          ? const SizedBox(
                        key: ValueKey('loading'),
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.amber,
                        ),
                      )
                          : const Text(
                        'Sign in',
                        key: ValueKey('label'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const _Reveal(
              key: ValueKey('footer'),
              delayMs: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.inkSoft),
                  SizedBox(width: 6),
                  Text(
                    'Authorized store staff only',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final form = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildForm(context, state),
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(flex: 5, child: _BrandPanel()),
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(40),
                          child: form,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const _CompactHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                      child: Center(child: form),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

class _Logo extends StatelessWidget {
  const _Logo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.storefront_rounded,
        size: size * 0.5,
        color: AppColors.amber,
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(this.size, this.alpha);

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _FloatChip extends StatelessWidget {
  const _FloatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.amber),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterBadge extends StatelessWidget {
  const _CenterBadge({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(slide.icon, size: 52, color: AppColors.amber);
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: slide.centerAsset == null
          ? fallback
          : ClipOval(
        child: Image.asset(
          slide.centerAsset!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

/// Illustration for one slide: a centre badge with floating chips that bob up
/// and down. [animation] is a looping 0..1 value.
class _SlideArt extends StatelessWidget {
  const _SlideArt({super.key, required this.slide, required this.animation});

  final _Slide slide;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 280,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value;
          double bob(double phase, double amp) =>
              math.sin((t + phase) * 2 * math.pi) * amp;

          return Stack(
            children: [
              Center(
                child: Transform.scale(
                  scale: 1 + 0.025 * math.sin(t * 2 * math.pi),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const _Circle(236, 0.26),
                      const _Circle(180, 0.42),
                      _CenterBadge(slide: slide),
                    ],
                  ),
                ),
              ),
              for (final chip in slide.chips)
                Align(
                  alignment: chip.alignment,
                  child: Transform.translate(
                    offset: Offset(0, bob(chip.phase, 7)),
                    child: _FloatChip(icon: chip.icon, label: chip.label),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Narrow screens: simple header
// ---------------------------------------------------------------------------

class _CompactHeader extends StatelessWidget {
  const _CompactHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 36),
      decoration: const BoxDecoration(
        gradient: _brandGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: const _Reveal(
        key: ValueKey('compact'),
        child: Row(
          children: [
            _Logo(size: 56),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Handa Grocery',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wide screens: animated brand panel with slider
// ---------------------------------------------------------------------------

class _BrandPanel extends StatefulWidget {
  const _BrandPanel();

  @override
  State<_BrandPanel> createState() => _BrandPanelState();
}

class _BrandPanelState extends State<_BrandPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  Timer? _timer;
  int _index = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!_paused && mounted) _go(1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _float.dispose();
    super.dispose();
  }

  void _go(int delta) {
    setState(() => _index = (_index + delta + _slides.length) % _slides.length);
  }

  void _jump(int i) => setState(() => _index = i);

  Widget _drifting({
    required double phase,
    required double amp,
    required Widget Function(double dy) builder,
  }) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, _) {
        final dy = math.sin((_float.value + phase) * 2 * math.pi) * amp;
        return builder(dy);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];

    return MouseRegion(
      onEnter: (_) => _paused = true,
      onExit: (_) => _paused = false,
      child: Container(
        decoration: const BoxDecoration(gradient: _brandGradient),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            _drifting(
              phase: 0.0,
              amp: 14,
              builder: (dy) => Positioned(
                top: -90 + dy,
                right: -70,
                child: const _Circle(280, 0.14),
              ),
            ),
            _drifting(
              phase: 0.5,
              amp: 18,
              builder: (dy) => Positioned(
                bottom: -110 + dy,
                left: -90,
                child: const _Circle(340, 0.10),
              ),
            ),
            _drifting(
              phase: 0.25,
              amp: 10,
              builder: (dy) => Positioned(
                top: 180 + dy,
                left: 40,
                child: const _Circle(60, 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Reveal(
                    key: ValueKey('brand'),
                    child: Row(
                      children: [
                        _Logo(size: 52),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Handa Grocery',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              'Admin Panel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.92, end: 1)
                                      .animate(animation),
                                  child: child,
                                ),
                              ),
                          child: _SlideArt(
                            key: ValueKey('art$_index'),
                            slide: slide,
                            animation: _float,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.topLeft,
                        children: [...previous, if (current != null) current],
                      ),
                      child: Column(
                        key: ValueKey('text$_index'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide.subtitle,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: AppColors.ink.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 92),
                ],
              ),
            ),
            Positioned(
              left: 56,
              right: 56,
              bottom: 40,
              child: Row(
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    GestureDetector(
                      onTap: () => _jump(i),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.only(right: 8),
                          width: i == _index ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? AppColors.ink
                                : AppColors.ink.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  _ArrowButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Previous',
                    onPressed: () => _go(-1),
                  ),
                  const SizedBox(width: 8),
                  _ArrowButton(
                    icon: Icons.arrow_forward_rounded,
                    tooltip: 'Next',
                    onPressed: () => _go(1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 20, color: AppColors.ink),
        onPressed: onPressed,
      ),
    );
  }
}
