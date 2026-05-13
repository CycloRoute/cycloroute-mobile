import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/theme/app_theme.dart';
import 'package:cyclerisk/core/constants/app_strings.dart';
import 'package:cyclerisk/app/routes.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';

class CycloRouteApp extends StatelessWidget {
  const CycloRouteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: _LoadingHome()),
        routes: AppRoutes.getRoutes(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _LoadingHome extends StatefulWidget {
  const _LoadingHome({Key? key}) : super(key: key);

  @override
  State<_LoadingHome> createState() => _LoadingHomeState();
}

class _LoadingHomeState extends State<_LoadingHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
