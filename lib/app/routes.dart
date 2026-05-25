import 'package:flutter/material.dart';
import 'package:cyclerisk/features/home/presentation/screens/home_screen_new.dart';
import 'package:cyclerisk/features/route_search/presentation/screens/route_search_screen.dart';
import 'package:cyclerisk/features/route_results/presentation/screens/route_results_screen.dart';
import 'package:cyclerisk/features/navigation/presentation/screens/navigation_screen.dart';
import 'package:cyclerisk/features/auth/presentation/screens/auth_entry_screen.dart';
import 'package:cyclerisk/features/auth/presentation/screens/login_screen_new.dart';
import 'package:cyclerisk/features/auth/presentation/screens/register_screen_new.dart';
import 'package:cyclerisk/features/auth/presentation/screens/terms_screen.dart';
import 'package:cyclerisk/features/secondary/presentation/screens/secondary_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String routeSearch = '/route_search';
  static const String routeResults = '/route_results';
  static const String navigation = '/navigation';
  static const String authEntry = '/auth-entry';
  static const String login = '/login';
  static const String register = '/register';
  static const String terms = '/terms';
  static const String secondary = '/secondary';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreenNew(),
      routeSearch: (context) => const RouteSearchScreen(),
      routeResults: (context) => const RouteResultsScreen(),
      navigation: (context) => const NavigationScreen(),
      authEntry: (context) => const AuthEntryScreen(),
      login: (context) => const LoginScreenNew(),
      register: (context) => const RegisterScreenNew(),
      terms: (context) => const TermsScreen(),
      secondary: (context) => const SecondaryScreen(title: 'Secondary Screen'),
    };
  }
}
