import 'package:flutter/material.dart';

final ThemeData appTheme = PayPalTheme.light();

class AppPalette {
  static const Color primary = Color(0xFF003087);
  static const Color primaryPressed = Color(0xFF002070);
  static const Color secondary = Color(0xFF009CDE);
  static const Color error = Color(0xFFC23934);
  static const Color surface = Color(0xFFF5F7FA);
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF2C2E2F);
  static const Color inkMuted = Color(0xFF687173);
  static const Color border = Color(0xFFD7DCE1);
  static const Color extraSurface = Color(0xFFEEF0F3);
  static const Color success = Color(0xFF22A94F);
  static const Color ctaGold = Color(0xFFFFD140);
  static const Color onCta = Color(0xFF003087);
}

class PayPalThemeTokens extends ThemeExtension<PayPalThemeTokens> {
  const PayPalThemeTokens({required this.extraSurface, required this.success});

  final Color extraSurface;
  final Color success;

  @override
  PayPalThemeTokens copyWith({Color? extraSurface, Color? success}) {
    return PayPalThemeTokens(
      extraSurface: extraSurface ?? this.extraSurface,
      success: success ?? this.success,
    );
  }

  @override
  PayPalThemeTokens lerp(ThemeExtension<PayPalThemeTokens>? other, double t) {
    if (other is! PayPalThemeTokens) {
      return this;
    }

    return PayPalThemeTokens(
      extraSurface: Color.lerp(extraSurface, other.extraSurface, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension PayPalThemeDataX on ThemeData {
  Color get extraSurface => extension<PayPalThemeTokens>()!.extraSurface;
  Color get success => extension<PayPalThemeTokens>()!.success;
}

class PayPalTheme {
  static ThemeData light() {
    const tokens = PayPalThemeTokens(
      extraSurface: AppPalette.extraSurface,
      success: AppPalette.success,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      secondary: AppPalette.secondary,
      onSecondary: Colors.white,
      error: AppPalette.error,
      onError: Colors.white,
      surface: AppPalette.surface,
      onSurface: AppPalette.ink,
      surfaceVariant: AppPalette.extraSurface,
      onSurfaceVariant: AppPalette.inkMuted,
      outline: AppPalette.border,
      outlineVariant: AppPalette.border,
      shadow: Color(0x1A000000),
      scrim: Color(0x66000000),
      inverseSurface: Color(0xFF1D2329),
      onInverseSurface: Colors.white,
      inversePrimary: AppPalette.secondary,
      surfaceTint: Colors.transparent,
    );

    final textTheme = Typography.material2021().black.copyWith(
      bodyLarge: const TextStyle(color: AppPalette.ink),
      bodyMedium: const TextStyle(color: AppPalette.ink),
      bodySmall: const TextStyle(color: AppPalette.inkMuted),
      labelLarge: const TextStyle(color: AppPalette.ink),
      labelMedium: const TextStyle(color: AppPalette.ink),
      labelSmall: const TextStyle(color: AppPalette.inkMuted),
      titleSmall: const TextStyle(color: AppPalette.ink),
      titleMedium: const TextStyle(color: AppPalette.ink),
      titleLarge: const TextStyle(color: AppPalette.ink),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.canvas,
      canvasColor: AppPalette.canvas,
      dividerColor: AppPalette.border,
      splashColor: AppPalette.primaryPressed,
      highlightColor: AppPalette.primaryPressed.withOpacity(0.12),
      hoverColor: AppPalette.primaryPressed.withOpacity(0.04),
      iconTheme: const IconThemeData(color: AppPalette.ink),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppPalette.border, width: 1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppPalette.canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppPalette.border, width: 1),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        buttonColor: AppPalette.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return AppPalette.border;
            }
            return AppPalette.ctaGold;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return AppPalette.inkMuted;
            }
            return AppPalette.onCta;
          }),
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed) ||
                states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.focused)) {
              return AppPalette.primaryPressed.withOpacity(0.12);
            }
            return null;
          }),
          shadowColor: const MaterialStatePropertyAll<Color>(
            Colors.transparent,
          ),
          surfaceTintColor: const MaterialStatePropertyAll<Color>(
            Colors.transparent,
          ),
          minimumSize: const MaterialStatePropertyAll<Size>(
            Size.fromHeight(48),
          ),
          padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          textStyle: MaterialStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _brandButtonStyle(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _brandButtonStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: AppPalette.primary,
          side: BorderSide.none,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _brandButtonStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: AppPalette.primary,
          side: const BorderSide(color: AppPalette.border, width: 1),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.canvas,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: AppPalette.inkMuted),
        labelStyle: const TextStyle(color: AppPalette.inkMuted),
        helperStyle: const TextStyle(color: AppPalette.inkMuted),
        errorStyle: const TextStyle(color: AppPalette.error),
        border: _inputBorder(AppPalette.border),
        enabledBorder: _inputBorder(AppPalette.border),
        disabledBorder: _inputBorder(AppPalette.border),
        focusedBorder: _inputBorder(AppPalette.primary, width: 1.5),
        errorBorder: _inputBorder(AppPalette.error),
        focusedErrorBorder: _inputBorder(AppPalette.error, width: 1.5),
      ),
      dividerTheme: const DividerThemeData(
        color: AppPalette.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.canvas,
        foregroundColor: AppPalette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[tokens],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkRipple.splashFactory,
    );
  }

  static InputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ButtonStyle _brandButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    BorderSide side = BorderSide.none,
    Size minimumSize = const Size(0, 40),
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  }) {
    return ButtonStyle(
      backgroundColor: MaterialStatePropertyAll<Color>(backgroundColor),
      foregroundColor: MaterialStatePropertyAll<Color>(foregroundColor),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed) ||
            states.contains(MaterialState.hovered) ||
            states.contains(MaterialState.focused)) {
          return AppPalette.primaryPressed.withOpacity(0.12);
        }
        return null;
      }),
      side: MaterialStatePropertyAll<BorderSide>(side),
      shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      minimumSize: MaterialStatePropertyAll<Size>(minimumSize),
      padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(padding),
      surfaceTintColor: const MaterialStatePropertyAll<Color>(
        Colors.transparent,
      ),
      shadowColor: const MaterialStatePropertyAll<Color>(Colors.transparent),
    );
  }
}
