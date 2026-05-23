import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/cubit/login_cubit.dart';
import 'presentation/home/cubit/home_cubit.dart';
import 'presentation/onboarding/cubit/onboarding_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read the onboarding flag before the first frame so the router can set its
  // initialLocation without a visible redirect flash.
  final hasSeenOnboarding = await OnboardingCubit.hasBeenSeen();

  runApp(App(hasSeenOnboarding: hasSeenOnboarding));
}

class App extends StatefulWidget {
  final bool hasSeenOnboarding;
  const App({super.key, required this.hasSeenOnboarding});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppDependencies _deps;
  late final AppRouter       _appRouter;

  @override
  void initState() {
    super.initState();
    _deps      = AppDependencies.setup();
    _appRouter = AppRouter(
      _deps.authRepository,
      hasSeenOnboarding: widget.hasSeenOnboarding,
    );
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginCubit(_deps.authRepository)),
        BlocProvider(create: (_) => HomeCubit(_deps.authRepository)),
        BlocProvider(create: (_) => OnboardingCubit()),
      ],
      child: ScreenUtilInit(
        designSize:      const Size(390, 844),
        minTextAdapt:    true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp.router(
          title:                  'Recollia',
          debugShowCheckedModeBanner: false,
          theme:                  AppTheme.darkTheme,
          routerConfig:           _appRouter.router,
        ),
      ),
    );
  }
}
