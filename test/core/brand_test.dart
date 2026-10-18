import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localmind_ai/app/theme.dart';
import 'package:localmind_ai/core/format.dart';
import 'package:localmind_ai/core/widgets/brand.dart';
import 'package:localmind_ai/core/widgets/state_views.dart';

void main() {
  test('formatWhen: time today, short date this year, full date before', () {
    final now = DateTime(2026, 10, 18, 15);
    expect(formatWhen(DateTime(2026, 10, 18, 9, 5), now: now), '09:05');
    expect(formatWhen(DateTime(2026, 3, 2), now: now), 'Mar 2');
    expect(formatWhen(DateTime(2025, 3, 2), now: now), 'Mar 2, 2025');
  });

  for (final theme in [AppTheme.light(), AppTheme.dark()]) {
    testWidgets('logo and shared widgets render (${theme.brightness.name})', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Column(
              children: [
                BrandLogo(size: 48),
                StatusPill('Ready', tone: PillTone.success),
                NoticeText('A very long notice text that has to wrap nicely.'),
                SectionCard(
                  title: 'Section',
                  icon: Icons.info_outline,
                  child: InfoRow('Label', 'Value'),
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(theme.extension<AppColors>(), isNotNull);
      expect(find.text('Ready'), findsOneWidget);
    });
  }
}
