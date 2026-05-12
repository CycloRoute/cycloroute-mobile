import 'package:flutter/material.dart';
import 'package:cyclerisk/features/home/presentation/screens/home_screen.dart';
import 'package:cyclerisk/features/route_search/presentation/screens/route_search_screen.dart';
import 'package:cyclerisk/features/route_results/presentation/screens/route_results_screen.dart';
import 'package:cyclerisk/features/navigation/presentation/screens/navigation_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String routeSearch = '/route_search';
  static const String routeResults = '/route_results';
  static const String navigation = '/navigation';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      routeSearch: (context) => const RouteSearchScreen(),
      routeResults: (context) => const RouteResultsScreen(),
      navigation: (context) => const NavigationScreen(),
    };
  }
}
