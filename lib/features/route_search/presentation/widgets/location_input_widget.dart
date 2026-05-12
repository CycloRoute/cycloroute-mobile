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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          onChanged: (value) {
            setState(() {});
            widget.onChanged?.call(value);
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.location_on_outlined),
            prefixIconColor: AppColors.textSecondary,
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    iconSize: 18,
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {});
                      widget.onChanged?.call('');
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
