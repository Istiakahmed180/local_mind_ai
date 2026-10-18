import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Empty, error and "nothing here yet" states: a tinted icon badge, a title,
/// optional explanation and action.
class MessageState extends StatelessWidget {
  const MessageState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Inside a list (unbounded height) it must not add its own scroll view.
    return LayoutBuilder(
      builder: (context, box) {
        final content = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(icon, size: 72, iconSize: 32),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (body != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  body!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        );
        if (!box.hasBoundedHeight) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(child: content),
          );
        }
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: content,
          ),
        );
      },
    );
  }
}

/// Label/value row used in detail cards.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Outlined card with an optional title (and leading icon).
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.title, this.icon});

  final String? title;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  if (icon != null) ...[
                    IconBadge(icon!, size: 32, iconSize: 18),
                    const SizedBox(width: AppSpacing.ms),
                  ],
                  Expanded(
                    child: Text(title!, style: theme.textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.ms),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

/// Rounded tinted square holding an icon.
class IconBadge extends StatelessWidget {
  const IconBadge(
    this.icon, {
    super.key,
    this.size = 40,
    this.iconSize = 22,
    this.color,
    this.background,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? s.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, size: iconSize, color: color ?? s.onPrimaryContainer),
    );
  }
}

/// Small uppercase-style section label above a group of content.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

enum PillTone { neutral, primary, success, warning, error }

/// Compact status chip, e.g. "Ready", "Offline", "OCR".
class StatusPill extends StatelessWidget {
  const StatusPill(
    this.label, {
    super.key,
    this.tone = PillTone.neutral,
    this.icon,
  });

  final String label;
  final PillTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final c = AppColors.of(context);
    final (bg, fg) = switch (tone) {
      PillTone.neutral => (s.surfaceContainerHigh, s.onSurfaceVariant),
      PillTone.primary => (s.primaryContainer, s.onPrimaryContainer),
      PillTone.success => (c.successContainer, c.success),
      PillTone.warning => (c.warningContainer, c.warning),
      PillTone.error => (s.errorContainer, s.onErrorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline warning/notice line with an icon.
class NoticeText extends StatelessWidget {
  const NoticeText(
    this.text, {
    super.key,
    this.tone = PillTone.warning,
    this.icon = Icons.info_outline,
  });

  final String text;
  final PillTone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final c = AppColors.of(context);
    final (bg, fg) = switch (tone) {
      PillTone.error => (s.errorContainer, s.onErrorContainer),
      PillTone.success => (c.successContainer, c.success),
      PillTone.primary => (s.primaryContainer, s.onPrimaryContainer),
      PillTone.neutral => (s.surfaceContainer, s.onSurfaceVariant),
      PillTone.warning => (c.warningContainer, c.warning),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.ms),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: fg, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title block at the top of a bottom sheet: icon badge, title, explainer.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.icon,
    required this.title,
    this.body,
  });

  final IconData icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleLarge),
                if (body != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(body!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of big-number statistics inside a card.
class StatRow extends StatelessWidget {
  const StatRow(this.stats, {super.key});

  /// (value, label) pairs.
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (value, label) in stats)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}

/// Filled button style for destructive confirmations (delete, clear).
ButtonStyle dangerButtonStyle(BuildContext context) {
  final s = Theme.of(context).colorScheme;
  return FilledButton.styleFrom(
    backgroundColor: s.error,
    foregroundColor: s.onError,
  );
}
