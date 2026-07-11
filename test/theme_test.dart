import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prohori_app/theme.dart';

void main() {
  test('theme maps corporate palette exactly', () {
    expect(appTheme.colorScheme.primary, AppPalette.primary);
    expect(appTheme.colorScheme.onPrimary, Colors.white);
    expect(appTheme.colorScheme.secondary, AppPalette.secondary);
    expect(appTheme.colorScheme.error, AppPalette.error);
    expect(appTheme.scaffoldBackgroundColor, AppPalette.canvas);
    expect(appTheme.dividerColor, AppPalette.border);
    expect(appTheme.extraSurface, AppPalette.extraSurface);
    expect(appTheme.success, AppPalette.success);
  });

  test('controls use flat geometry', () {
    final cardShape = appTheme.cardTheme.shape as RoundedRectangleBorder;
    final dialogShape = appTheme.dialogTheme.shape as RoundedRectangleBorder;
    final buttonShape =
        appTheme.elevatedButtonTheme.style!.shape!.resolve(<MaterialState>{})
            as RoundedRectangleBorder;

    expect(cardShape.borderRadius, BorderRadius.circular(8));
    expect(dialogShape.borderRadius, BorderRadius.circular(12));
    expect(buttonShape.borderRadius, BorderRadius.circular(8));
    expect(
      appTheme.elevatedButtonTheme.style!.backgroundColor!.resolve(
        <MaterialState>{},
      ),
      AppPalette.ctaGold,
    );
  });
}
