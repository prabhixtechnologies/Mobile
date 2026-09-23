import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Small labeled fields for a counter action. Returns trimmed values, or null
/// when the person cancels.
Future<List<String>?> askCounterFields(
  BuildContext context, {
  required String title,
  required List<String> labels,
  List<TextInputType> keyboards = const [],
  String action = 'Save',
}) async {
  final controllers = [for (final _ in labels) TextEditingController()];
  final result = await showDialog<List<String>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < labels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: controllers[i],
                    autofocus: i == 0,
                    keyboardType: i < keyboards.length ? keyboards[i] : TextInputType.text,
                    inputFormatters: (i < keyboards.length && keyboards[i] == TextInputType.number)
                        ? [FilteringTextInputFormatter.digitsOnly]
                        : null,
                    decoration: InputDecoration(labelText: labels[i]),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              [for (final field in controllers) field.text.trim()],
            ),
            child: Text(action),
          ),
        ],
      );
    },
  );
  Future<void>.delayed(const Duration(milliseconds: 400), () {
    for (final field in controllers) {
      field.dispose();
    }
  });
  return result;
}
