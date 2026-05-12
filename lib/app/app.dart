import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_theme.dart';
import 'package:cyclerisk/core/constants/app_strings.dart';
import 'package:cyclerisk/app/routes.dart';

class CycloRouteApp extends StatelessWidget {
  const CycloRouteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      home: const Scaffold(body: _LoadingHome()),
      routes: AppRoutes.getRoutes(),
      debugShowCheckedModeBanner: false,
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
    // Navigate to home after a frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}
