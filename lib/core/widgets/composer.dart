import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Bottom input bar shared by chat, document Q&A and the agent: a hairline
/// on top, a pill text field and trailing actions.
class ComposerBar extends StatelessWidget {
  const ComposerBar({super.key, required this.field, this.trailing = const []});

  final Widget field;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.of(context).hairline)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.ms,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: field),
          const SizedBox(width: AppSpacing.xs),
          ...trailing,
        ],
      ),
    );
  }
}

/// Pill-shaped input decoration for [ComposerBar] fields.
InputDecoration composerDecoration(BuildContext context, String hint) {
  final s = Theme.of(context).colorScheme;
  final pill = BorderRadius.circular(AppRadius.xl);
  return InputDecoration(
    hintText: hint,
    counterText: '',
    fillColor: s.surfaceContainer,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    border: OutlineInputBorder(borderRadius: pill, borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: pill,
      borderSide: BorderSide.none,
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: pill,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: pill,
      borderSide: BorderSide(color: s.primary, width: 1.2),
    ),
  );
}

/// Spinner the same size as the composer's round buttons.
class ComposerSpinner extends StatelessWidget {
  const ComposerSpinner({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(12),
    child: SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}
