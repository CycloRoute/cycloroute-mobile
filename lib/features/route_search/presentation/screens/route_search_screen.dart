import 'package:flutter/material.dart';
import 'package:cyclerisk/core/constants/app_strings.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/features/route_search/presentation/widgets/location_input_widget.dart';
import 'package:cyclerisk/shared/widgets/primary_button.dart';

class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({Key? key}) : super(key: key);

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  late final TextEditingController _originController;
  late final TextEditingController _destinationController;

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController();
    _destinationController = TextEditingController();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  bool get _canCalculate =>
      _originController.text.isNotEmpty &&
      _destinationController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.routeSearchTitle),
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.16),
                      AppColors.primaryLight.withOpacity(0.08),
                      AppColors.cardBackground,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Find routes prioritizing bike infrastructure',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Built for protected bike lanes, quieter streets, and lower-risk crossings.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                        children: const [
                        _PillBadge(label: 'Bike infrastructure'),
                        _PillBadge(label: 'Live risk scoring'),
                        _PillBadge(label: 'Bike-friendly streets'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.08),
                      blurRadius: 18,
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.navigationCyan.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: AppColors.navigationCyan,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plan your ride',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Choose a start and destination to compare safe routes.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LocationInputWidget(
                      label: AppStrings.origin,
                      hint: AppStrings.originHint,
                      controller: _originController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.navigationCyan.withOpacity(0.16),
                              AppColors.primary.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.swap_vert),
                          iconSize: 22,
                          color: AppColors.navigationCyan,
                          tooltip: 'Swap origin and destination',
                          onPressed: () {
                            final temp = _originController.text;
                            _originController.text = _destinationController.text;
                            _destinationController.text = temp;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    LocationInputWidget(
                      label: AppStrings.destination,
                      hint: AppStrings.destinationHint,
                      controller: _destinationController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 18,
                                color: AppColors.navigationCyan,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Quick destinations',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _QuickLocationChip(
                                location: 'Downtown Center',
                                onTap: () => _applyQuickLocation('Downtown Center'),
                              ),
                              _QuickLocationChip(
                                location: 'Central Park',
                                onTap: () => _applyQuickLocation('Central Park'),
                              ),
                              _QuickLocationChip(
                                location: 'City Harbor',
                                onTap: () => _applyQuickLocation('City Harbor'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: AppStrings.calculateRoute,
                        onPressed: _canCalculate
                            ? () {
                                Navigator.of(context).pushNamed('/route_results');
                              }
                            : () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyQuickLocation(String location) {
    if (_originController.text.isEmpty) {
      _originController.text = location;
    } else if (_destinationController.text.isEmpty) {
      _destinationController.text = location;
    }
    setState(() {});
  }
}

class _PillBadge extends StatelessWidget {
  final String label;

  const _PillBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _QuickLocationChip extends StatelessWidget {
  final String location;
  final VoidCallback onTap;

  const _QuickLocationChip({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.navigationCyan.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.navigationCyan,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              location,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
