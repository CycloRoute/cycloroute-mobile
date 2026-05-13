import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';

class LocationInputWidget extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Function(String)? onChanged;

  const LocationInputWidget({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  State<LocationInputWidget> createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasValue
                  ? AppColors.navigationCyan.withOpacity(0.35)
                  : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: (value) {
              setState(() {});
              widget.onChanged?.call(value);
            },
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.navigationCyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.place_outlined,
                  color: AppColors.navigationCyan,
                  size: 20,
                ),
              ),
              suffixIcon: hasValue
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      iconSize: 18,
                      color: AppColors.textSecondary,
                      onPressed: () {
                        widget.controller.clear();
                        setState(() {});
                        widget.onChanged?.call('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
