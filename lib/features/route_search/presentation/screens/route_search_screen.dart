import 'package:flutter/material.dart';
import 'package:cyclerisk/core/constants/app_strings.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';
import 'package:cyclerisk/shared/widgets/primary_button.dart';
import 'package:cyclerisk/features/route_search/presentation/widgets/location_input_widget.dart';

class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({Key? key}) : super(key: key);

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  late TextEditingController _originController;
  late TextEditingController _destinationController;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.routeSearchTitle),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Your Journey',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ll find the safest route considering real-time road risk factors.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Origin input
              LocationInputWidget(
                label: AppStrings.origin,
                hint: AppStrings.originHint,
                controller: _originController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // Swap button
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.unfold_more),
                    iconSize: 20,
                    color: AppColors.navigationCyan,
                    onPressed: () {
                      final temp = _originController.text;
                      _originController.text = _destinationController.text;
                      _destinationController.text = temp;
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Destination input
              LocationInputWidget(
                label: AppStrings.destination,
                hint: AppStrings.destinationHint,
                controller: _destinationController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 32),

              // Quick location suggestions
              Text(
                'Recent locations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildQuickLocationChip('Downtown Center'),
              const SizedBox(height: 8),
              _buildQuickLocationChip('Central Park'),
              const SizedBox(height: 8),
              _buildQuickLocationChip('City Harbor'),
              const SizedBox(height: 32),

              // Calculate button
              PrimaryButton(
                label: AppStrings.calculateRoute,
                onPressed: _canCalculate
                    ? () {
                        Navigator.of(context).pushNamed('/route_results');
                      }
                    : () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLocationChip(String location) {
    return GestureDetector(
      onTap: () {
        if (_originController.text.isEmpty) {
          _originController.text = location;
        } else if (_destinationController.text.isEmpty) {
          _destinationController.text = location;
        }
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16),
            const SizedBox(width: 8),
            Text(location, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
