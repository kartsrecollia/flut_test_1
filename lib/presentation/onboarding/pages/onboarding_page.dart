import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/iris_painter.dart';

// ── Content model for the two value-prop pages ────────────────────────────────
class _PageData {
  final String label;
  final String headline;
  final String body;
  const _PageData({
    required this.label,
    required this.headline,
    required this.body,
  });
}

const _kPages = [
  _PageData(
    label:    'QUICK RECALL',
    headline: 'The right fact,\nat the right moment.',
    body:
        'Targeted spaced-repetition cards built around your gaps.\n'
        'Five minutes before ward rounds — what you need, not what you already know.',
  ),
  _PageData(
    label:    'DEEP UNDERSTANDING',
    headline: 'A tutor that knows\nyour register.',
    body:
        'Socratic dialogue calibrated to the senior consultant\'s voice.\n'
        'Ask why a treatment works. Be challenged without being condescended to.',
  ),
];

// ── Page ──────────────────────────────────────────────────────────────────────
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final PageController     _pageCtrl;
  late final AnimationController _irisAnim;
  int _currentPage = 0;

  // Total pages: 0 = splash, 1 = quick recall, 2 = deep understanding, 3 = final
  static const int _kTotal = 4;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _irisAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..forward();

    // Auto-advance from splash to page 1 after the iris finishes drawing
    Future.delayed(const Duration(milliseconds: 2800), _advanceFromSplash);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _irisAnim.dispose();
    super.dispose();
  }

  void _advanceFromSplash() {
    if (!mounted || _currentPage != 0) return;
    _pageCtrl.animateToPage(
      1,
      duration: const Duration(milliseconds: 700),
      curve:    Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentPage < _kTotal - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 420),
        curve:    Curves.easeInOut,
      );
    }
  }

  void _finish() {
    context.read<OnboardingCubit>().complete();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (_, s) => s.completed,
      listener:   (_, __) => context.go('/login'),
      child: Scaffold(
        backgroundColor: RC.dark,
        body: PageView(
          controller:    _pageCtrl,
          onPageChanged: (i) => setState(() => _currentPage = i),
          // Disable swipe on the splash so users don't skip the animation
          physics: _currentPage == 0
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          children: [
            _SplashScreen(animation: _irisAnim),
            _ValuePropScreen(
              data:        _kPages[0],
              pageIndex:   0,
              currentPage: _currentPage,
              onContinue:  _next,
              onSkip:      _finish,
            ),
            _ValuePropScreen(
              data:        _kPages[1],
              pageIndex:   1,
              currentPage: _currentPage,
              onContinue:  _next,
              onSkip:      _finish,
            ),
            _FinalScreen(onBegin: _finish),
          ],
        ),
      ),
    );
  }
}

// ── Splash ────────────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  final Animation<double> animation;
  const _SplashScreen({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final p         = animation.value;
        final textAlpha = ((p - 0.68) / 0.32).clamp(0.0, 1.0);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Iris draws on progressively
            SizedBox(
              width:  220,
              height: 220,
              child: CustomPaint(
                painter: IrisPainter(progress: p, alpha: 1.0),
              ),
            ),
            const SizedBox(height: 44),
            Opacity(
              opacity: textAlpha,
              child: Column(
                children: [
                  Text(
                    'RECOLLIA',
                    style: GoogleFonts.fraunces(
                      fontSize:     22,
                      fontWeight:   FontWeight.w300,
                      letterSpacing: 9,
                      color:        RC.ivory,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Medicine, remembered.',
                    style: GoogleFonts.fraunces(
                      fontSize:   14,
                      fontWeight: FontWeight.w200,
                      fontStyle:  FontStyle.italic,
                      color:      RC.ivoryDim,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Value-prop pages (1 + 2) ──────────────────────────────────────────────────
class _ValuePropScreen extends StatelessWidget {
  final _PageData  data;
  final int        pageIndex;   // 0-based within value-prop pages
  final int        currentPage; // overall PageView index
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const _ValuePropScreen({
    required this.data,
    required this.pageIndex,
    required this.currentPage,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Skip ──────────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onSkip,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'SKIP',
                    style: GoogleFonts.inter(
                      fontSize:      10,
                      letterSpacing: 2.5,
                      fontWeight:    FontWeight.w400,
                      color:         RC.ivoryDim.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // ── Section label ─────────────────────────────────────────────
            Text(
              data.label,
              style: GoogleFonts.inter(
                fontSize:      10,
                letterSpacing: 3.5,
                fontWeight:    FontWeight.w500,
                color:         RC.amber,
              ),
            ),
            const SizedBox(height: 22),

            // ── Headline ──────────────────────────────────────────────────
            Text(
              data.headline,
              style: GoogleFonts.fraunces(
                fontSize:   34,
                fontWeight: FontWeight.w200,
                fontStyle:  FontStyle.italic,
                color:      RC.ivory,
                height:     1.18,
              ),
            ),
            const SizedBox(height: 26),

            // ── Body ──────────────────────────────────────────────────────
            Text(
              data.body,
              style: GoogleFonts.inter(
                fontSize:   15,
                fontWeight: FontWeight.w300,
                color:      RC.ivoryDim,
                height:     1.75,
              ),
            ),

            const Spacer(flex: 3),

            // ── Bottom row: dots + continue ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Page indicator — thin amber lines (active) / faint marks
                Row(
                  children: List.generate(3, (i) {
                    final active = i == pageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve:    Curves.easeInOut,
                      margin:   const EdgeInsets.only(right: 7),
                      width:    active ? 22 : 6,
                      height:   1.5,
                      color: active
                          ? RC.amber
                          : RC.ivoryDim.withValues(alpha: 0.28),
                    );
                  }),
                ),

                // Continue — text + amber rule, no loud button
                GestureDetector(
                  onTap: onContinue,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        'CONTINUE',
                        style: GoogleFonts.inter(
                          fontSize:      11,
                          letterSpacing: 2.5,
                          fontWeight:    FontWeight.w400,
                          color:         RC.ivory,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(width: 28, height: 1, color: RC.amber),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Final screen ──────────────────────────────────────────────────────────────
class _FinalScreen extends StatelessWidget {
  final VoidCallback onBegin;
  const _FinalScreen({required this.onBegin});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),

            // Iris — earns its place here as the brand milestone moment
            Center(
              child: SizedBox(
                width:  130,
                height: 130,
                child: CustomPaint(
                  painter: IrisPainter(progress: 1.0, alpha: 0.88),
                ),
              ),
            ),
            const SizedBox(height: 44),

            // ── Headline ──────────────────────────────────────────────────
            Text(
              'Medicine,\nremembered.',
              style: GoogleFonts.fraunces(
                fontSize:   38,
                fontWeight: FontWeight.w200,
                fontStyle:  FontStyle.italic,
                color:      RC.ivory,
                height:     1.15,
              ),
            ),
            const SizedBox(height: 22),

            // ── Body ──────────────────────────────────────────────────────
            Text(
              'Built for the Indian medical register.\n'
              'For long nights, not bright mornings.',
              style: GoogleFonts.inter(
                fontSize:   15,
                fontWeight: FontWeight.w300,
                color:      RC.ivoryDim,
                height:     1.75,
              ),
            ),

            const Spacer(flex: 3),

            // ── BEGIN button — primary amber, sharp corners ───────────────
            SizedBox(
              width:  double.infinity,
              height: 52,
              child: TextButton(
                onPressed: onBegin,
                style: TextButton.styleFrom(
                  backgroundColor: RC.amber,
                  foregroundColor: RC.dark,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'BEGIN',
                  style: GoogleFonts.inter(
                    fontSize:      12,
                    letterSpacing: 4,
                    fontWeight:    FontWeight.w500,
                    color:         RC.dark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Already have an account ───────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: onBegin,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'I have an account  ·  Sign in',
                    style: GoogleFonts.inter(
                      fontSize:      13,
                      letterSpacing: 0.4,
                      fontWeight:    FontWeight.w300,
                      color:         RC.ivoryDim.withValues(alpha: 0.65),
                    ),
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
