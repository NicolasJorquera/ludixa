import 'package:flutter/material.dart';

import 'game_colors.dart';
import 'palette.dart';
import 'typography.dart';

/// Expone la paleta completa a los widgets: `context.palette`.
@immutable
final class LudixaColors extends ThemeExtension<LudixaColors> {
  const LudixaColors(this.palette, this.variant);

  final LudixaPalette palette;
  final PaletteVariant variant;

  @override
  LudixaColors copyWith() => this;

  @override
  LudixaColors lerp(LudixaColors? other, double t) => t < 0.5 || other == null ? this : other;
}

extension LudixaThemeContext on BuildContext {
  LudixaPalette get palette => Theme.of(this).extension<LudixaColors>()!.palette;

  SudokuColors get sudokuColors => Theme.of(this).extension<SudokuColors>()!;

  MinesweeperColors get minesweeperColors => Theme.of(this).extension<MinesweeperColors>()!;

  WordSearchColors get wordSearchColors => Theme.of(this).extension<WordSearchColors>()!;
}

/// Radios del sistema visual.
abstract final class LudixaRadii {
  static const cell = 6.0;
  static const control = 12.0;
  static const button = 14.0;
  static const card = 16.0;
  static const sheet = 26.0;
}

/// Tema de Ludixa para un brillo y una variante de paleta.
ThemeData buildLudixaTheme({required Brightness brightness, PaletteVariant variant = PaletteVariant.standard}) {
  final p = LudixaPalette.of(brightness, variant);
  final light = brightness == Brightness.light;
  final text = LudixaTypography.textTheme(p);

  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: p.primarySoft,
    onPrimaryContainer: p.ink,
    secondary: p.primary,
    onSecondary: p.onPrimary,
    secondaryContainer: p.primarySoft,
    onSecondaryContainer: p.ink,
    tertiary: p.wordSearch,
    onTertiary: light ? const Color(0xFFFFFFFF) : p.background,
    tertiaryContainer: p.wordSearchSoft,
    onTertiaryContainer: p.ink,
    error: p.danger,
    onError: light ? const Color(0xFFFFFFFF) : p.background,
    errorContainer: p.dangerSoft,
    onErrorContainer: p.dangerInk,
    surface: p.surface,
    onSurface: p.ink,
    onSurfaceVariant: p.inkMuted,
    surfaceContainerLowest: p.surface,
    surfaceContainerLow: p.surface,
    surfaceContainer: p.surface,
    surfaceContainerHigh: p.surfaceMuted,
    surfaceContainerHighest: p.surfaceMuted,
    outline: p.outline,
    outlineVariant: p.line,
    inverseSurface: p.ink,
    onInverseSurface: p.surface,
    inversePrimary: light ? LudixaPalette.dark.primary : LudixaPalette.light.primary,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    surfaceTint: const Color(0x00000000),
  );

  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(LudixaRadii.button));
  const buttonSize = Size(64, 52);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    textTheme: text,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    extensions: [
      LudixaColors(p, variant),
      SudokuColors.from(p),
      MinesweeperColors.from(p, variant),
      WordSearchColors.from(p),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.headlineSmall,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      indicatorColor: p.primarySoft,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => text.labelMedium!.copyWith(
          color: states.contains(WidgetState.selected) ? p.primary : p.inkMuted,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(color: states.contains(WidgetState.selected) ? p.primary : p.inkMuted, size: 24),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink,
        minimumSize: buttonSize,
        shape: buttonShape,
        side: BorderSide(color: p.outline, width: 1.5),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        minimumSize: const Size(48, 48),
        textStyle: text.labelLarge,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LudixaRadii.card),
        side: BorderSide(color: p.line),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: p.inkMuted,
      textColor: p.ink,
      titleTextStyle: text.bodyLarge,
      subtitleTextStyle: text.bodySmall,
      minVerticalPadding: 12,
    ),
    dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: const Color(0x00000000),
      showDragHandle: true,
      dragHandleColor: p.outline,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(LudixaRadii.sheet))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: const Color(0x00000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.onPrimary : p.surface,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.primary : p.outline,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Color(0x00000000)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.primary : p.outline,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.ink,
      contentTextStyle: text.bodyMedium!.copyWith(color: p.surface),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
