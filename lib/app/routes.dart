import 'package:flutter/material.dart';
import 'package:cyclerisk/features/home/presentation/screens/home_screen_new.dart';
import 'package:cyclerisk/features/route_search/presentation/screens/route_search_screen.dart';
import 'package:cyclerisk/features/route_results/presentation/screens/route_results_screen.dart';
import 'package:cyclerisk/features/navigation/presentation/screens/navigation_screen.dart';
import 'package:cyclerisk/features/auth/presentation/screens/auth_entry_screen.dart';
import 'package:cyclerisk/features/auth/presentation/screens/login_screen_new.dart';
import 'package:cyclerisk/features/auth/presentation/screens/register_screen_new.dart';
import 'package:cyclerisk/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:cyclerisk/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:cyclerisk/features/settings/presentation/screens/settings_screen.dart';
import 'package:cyclerisk/features/infrastructure/presentation/screens/infrastructure_admin_screen.dart';
import 'package:cyclerisk/features/infrastructure/presentation/screens/reviewer_capture_screen.dart';
import 'package:cyclerisk/features/infrastructure/presentation/screens/reviewer_map_screen.dart';
import 'package:cyclerisk/features/profile/presentation/screens/profile_screen.dart';
import 'package:cyclerisk/features/onboarding/presentation/screens/bike_onboarding_screen.dart';
import 'package:cyclerisk/features/onboarding/presentation/screens/preference_onboarding_screen.dart';
import 'package:cyclerisk/features/route_results/presentation/screens/saved_routes_screen.dart';
import 'package:cyclerisk/features/route_results/presentation/screens/saved_route_detail_screen.dart';
import 'package:cyclerisk/features/route_results/presentation/screens/route_history_screen.dart';
import 'package:cyclerisk/features/route_results/presentation/screens/route_history_detail_screen.dart';
import 'package:cyclerisk/features/route_results/presentation/screens/route_coverage_screen.dart';
import 'package:cyclerisk/features/reports/presentation/screens/my_reports_screen.dart';
import 'package:cyclerisk/features/reports/presentation/screens/create_report_screen.dart';
import 'package:cyclerisk/features/reports/presentation/screens/reports_list_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:cyclerisk/features/reviewer/presentation/screens/reviewer_tools_screen.dart';
import 'package:cyclerisk/core/widgets/admin_guard.dart';
import 'package:cyclerisk/core/widgets/reviewer_guard.dart';
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
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String settings = '/settings';
  static const String reviewerCapture = '/reviewer-capture';
  static const String collaborativeMap = '/collaborative-map';
  static const String reviewerMap = '/reviewer-map';
  static const String profile = '/profile';
  static const String preferenceOnboarding = '/preference-onboarding';
  static const String bikeOnboarding = '/bike-onboarding';
  static const String savedRoutes = '/saved-routes';
  static const String savedRouteDetail = '/saved-route-detail';
  static const String routeHistory = '/route-history';
  static const String routeHistoryDetail = '/route-history-detail';
  static const String routeCoverage = '/route-coverage';
  static const String createReport = '/create-report';
  static const String myReports = '/my-reports';
  static const String reportsList = '/reports-list';
  static const String infrastructureAdmin = '/infrastructure-admin';
  static const String reviewerTools = '/reviewer-tools';
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
      forgotPassword: (context) => const ForgotPasswordScreen(),
      resetPassword: (context) {
        final email = ModalRoute.of(context)?.settings.arguments as String?;
        return ResetPasswordScreen(initialEmail: email);
      },
      settings: (context) => const SettingsScreen(),
      reviewerCapture: (context) =>
          const ReviewerGuard(child: ReviewerCaptureScreen()),
      collaborativeMap: (context) =>
          const ReviewerGuard(child: ReviewerMapScreen()),
      reviewerMap: (context) =>
          const ReviewerGuard(child: ReviewerMapScreen()),
      profile: (context) => const ProfileScreen(),
      preferenceOnboarding: (context) => const PreferenceOnboardingScreen(),
      bikeOnboarding: (context) => const BikeOnboardingScreen(),
      savedRoutes: (context) => const SavedRoutesScreen(),
      savedRouteDetail: (context) => const SavedRouteDetailScreen(),
      routeHistory: (context) => const RouteHistoryScreen(),
      routeHistoryDetail: (context) => const RouteHistoryDetailScreen(),
      routeCoverage: (context) =>
          const AdminGuard(child: RouteCoverageScreen()),
      createReport: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return CreateReportScreen(
          initialLocation: args is LatLng ? args : null,
        );
      },
      myReports: (context) => const MyReportsScreen(),
      reportsList: (context) =>
          const ReviewerGuard(child: ReportsListScreen()),
      infrastructureAdmin: (context) =>
          const AdminGuard(child: InfrastructureAdminScreen()),
      reviewerTools: (context) =>
          const AdminGuard(child: ReviewerToolsScreen()),
      secondary: (context) => const SecondaryScreen(title: 'Secondary Screen'),
    };
  }
}
