import 'package:flutter_test/flutter_test.dart';
import 'package:prohori_app/core/formatting/time_format.dart';

void main() {
  test('relative time uses compact minute wording', () {
    final now = DateTime(2026, 7, 12, 12);
    expect(TimeFormat.relative(now.subtract(const Duration(minutes: 30)), now: now), '30 min ago');
    expect(TimeFormat.relative(now, now: now), 'just now');
  });

  test('clock uses compact local hour and minute', () {
    expect(TimeFormat.clock(DateTime(2026, 7, 12, 4, 37)), '4:37');
  });
}
