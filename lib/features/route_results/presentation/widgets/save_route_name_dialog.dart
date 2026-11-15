import 'package:flutter/material.dart';
import 'package:cyclerisk/core/l10n/l10n.dart';

Future<String?> promptSavedRouteName(
  BuildContext context, {
  required String initialName,
}) {
  final l10n = appL10n(context);
  final controller = TextEditingController(text: initialName);
  var showError = false;

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.renameSavedRouteHint),
            content: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.renameSavedRouteHint,
                errorText: showError ? l10n.saveRouteNameRequired : null,
              ),
              onSubmitted: (_) => _submit(
                dialogContext,
                controller,
                () => setState(() => showError = true),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => _submit(
                  dialogContext,
                  controller,
                  () => setState(() => showError = true),
                ),
                child: Text(l10n.saveRoute),
              ),
            ],
          );
        },
      );
    },
  ).whenComplete(controller.dispose);
}

void _submit(
  BuildContext dialogContext,
  TextEditingController controller,
  void Function() showError,
) {
  final name = controller.text.trim();
  if (name.isEmpty) {
    showError();
    return;
  }
  Navigator.of(dialogContext).pop(name);
}
