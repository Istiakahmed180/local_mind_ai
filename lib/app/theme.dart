import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Spacing scale (4-pt grid). Screens use these instead of raw numbers.
abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const ms = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  /// Horizontal padding of every screen body.
  static const page = 20.0;
}

abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
}

/// Brand palette: calm deep teal with an indigo accent on cool neutrals.
abstract final class AppPalette {
  static const teal = Color(0xFF0E6E66);
  static const tealBright = Color(0xFF4FD1BF);
  static const indigo = Color(0xFF4652B3);
  static const indigoBright = Color(0xFFA9B2FF);

  /// Brand gradient (logo, hero surfaces).
  static const brandGradient = [Color(0xFF0E6E66), Color(0xFF3B4FA8)];
}

/// Colours Material's scheme has no slot for.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.subtle,
    required this.hairline,
    required this.userBubble,
    required this.onUserBubble,
  });

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;

  /// Secondary text (captions, metadata).
  final Color subtle;

  /// 1-px card and divider lines.
  final Color hairline;
  final Color userBubble;
  final Color onUserBubble;

  static const light = AppColors(
    success: Color(0xFF15803D),
    successContainer: Color(0xFFDCF5E4),
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFDF0DC),
    subtle: Color(0xFF5B6575),
    hairline: Color(0xFFE3E7EE),
    userBubble: Color(0xFF0E6E66),
    onUserBubble: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    success: Color(0xFF6EE7A0),
    successContainer: Color(0xFF113524),
    warning: Color(0xFFF7B867),
    warningContainer: Color(0xFF3A2A12),
    subtle: Color(0xFF98A2B3),
    hairline: Color(0xFF242C38),
    userBubble: Color(0xFF1C5C56),
    onUserBubble: Color(0xFFF1FBF9),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      success: l(success, other.success),
      successContainer: l(successContainer, other.successContainer),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      subtle: l(subtle, other.subtle),
      hairline: l(hairline, other.hairline),
      userBubble: l(userBubble, other.userBubble),
      onUserBubble: l(onUserBubble, other.onUserBubble),
    );
  }
}

abstract final class AppTheme {
  static ThemeData light() => _build(_lightScheme, AppColors.light);
  static ThemeData dark() => _build(_darkScheme, AppColors.dark);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.teal,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD3F0EB),
    onPrimaryContainer: Color(0xFF053F3A),
    secondary: AppPalette.indigo,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE4E7FB),
    onSecondaryContainer: Color(0xFF1C2466),
    tertiary: Color(0xFF8A5A12),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFBEBD2),
    onTertiaryContainer: Color(0xFF3D2700),
    error: Color(0xFFC0362C),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFCE4E1),
    onErrorContainer: Color(0xFF5C120C),
    surface: Color(0xFFF7F8FA),
    onSurface: Color(0xFF111827),
    onSurfaceVariant: Color(0xFF5B6575),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF1F3F6),
    surfaceContainerHigh: Color(0xFFEBEEF2),
    surfaceContainerHighest: Color(0xFFE5E8ED),
    outline: Color(0xFFC5CBD5),
    outlineVariant: Color(0xFFE3E7EE),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1B2230),
    onInverseSurface: Color(0xFFF1F3F6),
    inversePrimary: AppPalette.tealBright,
    surfaceTint: Colors.transparent,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.tealBright,
    onPrimary: Color(0xFF00332E),
    primaryContainer: Color(0xFF134A44),
    onPrimaryContainer: Color(0xFFC8F2EA),
    secondary: AppPalette.indigoBright,
    onSecondary: Color(0xFF151C5A),
    secondaryContainer: Color(0xFF262F6E),
    onSecondaryContainer: Color(0xFFDFE2FF),
    tertiary: Color(0xFFF2C27A),
    onTertiary: Color(0xFF3D2700),
    tertiaryContainer: Color(0xFF4F370B),
    onTertiaryContainer: Color(0xFFFBEBD2),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF5C120C),
    errorContainer: Color(0xFF5A1D18),
    onErrorContainer: Color(0xFFFCE4E1),
    surface: Color(0xFF0B0F15),
    onSurface: Color(0xFFE8ECF2),
    onSurfaceVariant: Color(0xFF98A2B3),
    surfaceContainerLowest: Color(0xFF080B10),
    surfaceContainerLow: Color(0xFF121821),
    surfaceContainer: Color(0xFF161D27),
    surfaceContainerHigh: Color(0xFF1C2430),
    surfaceContainerHighest: Color(0xFF232C39),
    outline: Color(0xFF3A4452),
    outlineVariant: Color(0xFF242C38),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE8ECF2),
    onInverseSurface: Color(0xFF161D27),
    inversePrimary: AppPalette.teal,
    surfaceTint: Colors.transparent,
  );

  static TextTheme _text(ColorScheme s) {
    // System font (Roboto) with a tighter, calmer scale; Noto Sans Bengali
    // (ships with Android) is the fallback for Bengali glyphs.
    final base = Typography.material2021(platform: TargetPlatform.android).black
        .apply(bodyColor: s.onSurface, displayColor: s.onSurface);
    TextStyle? t(
      TextStyle? x,
      double size,
      FontWeight w,
      double h, [
      double ls = 0,
    ]) => x?.copyWith(
      fontSize: size,
      fontWeight: w,
      height: h,
      letterSpacing: ls,
    );
    return base.copyWith(
      displaySmall: t(base.displaySmall, 34, FontWeight.w600, 1.15, -0.6),
      headlineMedium: t(base.headlineMedium, 28, FontWeight.w600, 1.2, -0.4),
      headlineSmall: t(base.headlineSmall, 24, FontWeight.w600, 1.25, -0.3),
      titleLarge: t(base.titleLarge, 20, FontWeight.w600, 1.3, -0.2),
      titleMedium: t(base.titleMedium, 16, FontWeight.w600, 1.35, -0.1),
      titleSmall: t(base.titleSmall, 14, FontWeight.w600, 1.4),
      bodyLarge: t(base.bodyLarge, 16, FontWeight.w400, 1.5),
      bodyMedium: t(base.bodyMedium, 14, FontWeight.w400, 1.5),
      bodySmall: t(
        base.bodySmall,
        12.5,
        FontWeight.w400,
        1.45,
        0.1,
      )?.copyWith(color: s.onSurfaceVariant),
      labelLarge: t(base.labelLarge, 14, FontWeight.w600, 1.3, 0.1),
      labelMedium: t(base.labelMedium, 12, FontWeight.w600, 1.3, 0.2),
      labelSmall: t(base.labelSmall, 11, FontWeight.w600, 1.3, 0.6),
    );
  }

  static ThemeData _build(ColorScheme s, AppColors c) {
    final text = _text(s);
    final dark = s.brightness == Brightness.dark;
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    return ThemeData(
      useMaterial3: true,
      colorScheme: s,
      extensions: [c],
      textTheme: text,
      scaffoldBackgroundColor: s.surface,
      fontFamilyFallback: const ['Noto Sans Bengali', 'Noto Sans'],
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: s.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: s.onSurface,
        titleSpacing: AppSpacing.page,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: s.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: c.hairline),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: buttonPadding,
          shape: rounded,
          textStyle: text.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: buttonPadding,
          shape: rounded,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: buttonPadding,
          shape: rounded,
          side: BorderSide(color: s.outline),
          foregroundColor: s.onSurface,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: rounded,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        backgroundColor: dark ? s.primaryContainer : s.primary,
        foregroundColor: dark ? s.onPrimaryContainer : s.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.surfaceContainerLow,
        hintStyle: text.bodyLarge?.copyWith(color: s.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: s.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: s.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        iconColor: s.onSurfaceVariant,
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        minVerticalPadding: 10,
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected)
              ? Colors.transparent
              : s.outline,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        side: BorderSide(color: s.outlineVariant),
        labelStyle: text.labelMedium,
        backgroundColor: s.surfaceContainerLow,
        selectedColor: s.primaryContainer,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: rounded,
          side: BorderSide(color: s.outlineVariant),
          selectedBackgroundColor: s.primaryContainer,
          selectedForegroundColor: s.onPrimaryContainer,
          textStyle: text.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: s.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: s.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (st) => text.labelMedium?.copyWith(
            color: st.contains(WidgetState.selected)
                ? s.onSurface
                : s.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (st) => IconThemeData(
            size: 24,
            color: st.contains(WidgetState.selected)
                ? s.onPrimaryContainer
                : s.onSurfaceVariant,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: s.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(color: s.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        backgroundColor: s.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: s.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: s.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: s.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 2,
        color: s.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: c.hairline),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: s.primary,
        linearTrackColor: s.surfaceContainerHighest,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 6,
        borderRadius: BorderRadius.circular(3),
      ),
      sliderTheme: SliderThemeData(
        inactiveTrackColor: s.surfaceContainerHighest,
        trackHeight: 4,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: s.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: text.labelMedium?.copyWith(color: s.onInverseSurface),
      ),
    );
  }
}
