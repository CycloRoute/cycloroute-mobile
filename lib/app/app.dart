import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/theme/app_theme.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/navigation/session_handler.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/bike_profile_provider.dart';
import 'package:cyclerisk/core/providers/compass_provider.dart';
import 'package:cyclerisk/core/providers/locale_provider.dart';
import 'package:cyclerisk/core/providers/navigation_preferences_provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/services/user_preferences_sync.dart';
import 'package:cyclerisk/features/navigation/domain/navigation_session_controller.dart';
import 'package:cyclerisk/l10n/app_localizations.dart';

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  final name = settings.name;
  if (name == null || name == '/' || name.isEmpty) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/'),
      builder: (_) => const Scaffold(body: _LoadingHome()),
    );
  }

  final builder = AppRoutes.getRoutes()[name];
  if (builder != null) {
    return MaterialPageRoute<void>(settings: settings, builder: builder);
  }

  return MaterialPageRoute<void>(
    settings: const RouteSettings(name: '/'),
    builder: (_) => const Scaffold(body: _LoadingHome()),
  );
}

List<Route<dynamic>> _onGenerateInitialRoutes(String initialRoute) {
  final name = initialRoute.isEmpty ? '/' : initialRoute;
  final route = _onGenerateRoute(RouteSettings(name: name));
  return [route!];
}

class CycloRouteApp extends StatelessWidget {
  const CycloRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => BikeProfileProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationPreferencesProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => CompassProvider()),
        ChangeNotifierProvider(
          create: (_) => NavigationSessionController(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            navigatorKey: SessionHandler.navigatorKey,
            onGenerateTitle: (context) => appL10n(context).appName,
            theme: AppTheme.lightTheme,
            locale: localeProvider.effectiveLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateRoute: _onGenerateRoute,
            onGenerateInitialRoutes: _onGenerateInitialRoutes,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class _LoadingHome extends StatefulWidget {
  const _LoadingHome({super.key});

  @override
  State<_LoadingHome> createState() => _LoadingHomeState();
}

class _LoadingHomeState extends State<_LoadingHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LocaleProvider>().initialize();
      await context.read<BikeProfileProvider>().initialize();
      await context.read<NavigationPreferencesProvider>().initialize();
      final authProvider = context.read<AuthProvider>();
      await authProvider.ensureInitialized();

      if (!mounted) return;

      if (authProvider.isLoggedIn) {
        final user = await authProvider.refreshProfile();
        if (!mounted) return;

        await UserPreferencesSync.applyFromAuthUserIfPresent(
          user: user,
          bikeProfileProvider: context.read<BikeProfileProvider>(),
          navigationPreferencesProvider:
              context.read<NavigationPreferencesProvider>(),
        );
        if (!mounted) return;

        if (!authProvider.hasCompletedPreferenceOnboarding) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.bikeOnboarding);
          return;
        }

        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        return;
      }

      Navigator.of(context).pushReplacementNamed(AppRoutes.authEntry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
