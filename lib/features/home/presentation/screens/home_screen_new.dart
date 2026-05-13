import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cyclerisk/core/providers/location_provider.dart';
import 'package:cyclerisk/core/constants/app_strings.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/core/providers/auth_provider.dart';
import 'package:cyclerisk/shared/widgets/primary_button.dart';
import 'package:cyclerisk/features/shared/widgets/osm_map_widget.dart';
import 'package:cyclerisk/features/home/presentation/widgets/risk_legend_widget.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({Key? key}) : super(key: key);

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  @override
  void initState() {
    super.initState();
    // Request current location once when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        elevation: 0,
        backgroundColor: AppColors.background,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Profile'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: const ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: const ListTile(
                    leading: Icon(Icons.logout, color: AppColors.alertRed),
                    title: Text(
                      'Logout',
                      style: TextStyle(color: AppColors.alertRed),
                    ),
                  ),
                  onTap: () {
                    context.read<AuthProvider>().logout();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    });
                  },
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) => Text(
                  'Welcome, ${authProvider.userEmail?.split('@').first ?? 'Cyclist'}!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your current location and route options',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // OpenStreetMap widget - center on current location when available
              Consumer<LocationProvider>(
                builder: (context, loc, _) {
                  return OsmMapWidget(center: loc.currentLocation);
                },
              ),
              const SizedBox(height: 24),
              // Risk legend
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const RiskLegendWidget(),
              ),
              const SizedBox(height: 24),
              // Premium search card (compact)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.directions_bike,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Plan your route',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        // Optional small action
                        IconButton(
                          icon: const Icon(Icons.history_edu_outlined),
                          color: AppColors.textSecondary,
                          onPressed: () {
                            // Placeholder for actions like recent routes
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Inline search field that looks native and premium
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed('/route_search'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppStrings.searchSafeRoute,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Search button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: AppStrings.searchSafeRoute,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/route_search');
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
