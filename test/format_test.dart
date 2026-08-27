// Tests ported from src/tests/format.test.ts.
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/format.dart';

void main() {
  group('fmtClock', () {
    test('formats minutes and seconds with padding', () {
      expect(fmtClock(0), '00:00');
      expect(fmtClock(59), '00:59');
      expect(fmtClock(60), '01:00');
      expect(fmtClock(137), '02:17');
    });
    test('includes hours when needed', () {
      expect(fmtClock(3600), '1:00:00');
      expect(fmtClock(3671), '1:01:11');
    });
    test('never goes negative', () {
      expect(fmtClock(-5), '00:00');
    });
  });

  group('parseTimeInput', () {
    test('parses plain seconds', () {
      expect(parseTimeInput('90'), 90);
      expect(parseTimeInput('0'), 0);
    });
    test('parses m:ss', () {
      expect(parseTimeInput('3:00'), 180);
      expect(parseTimeInput('0:30'), 30);
      expect(parseTimeInput('12:5'), 725);
    });
    test('parses h:mm:ss (2-part only supported like web TimeField)', () {
      expect(parseTimeInput('1:30'), 90);
    });
    test('rejects garbage', () {
      expect(parseTimeInput(''), null);
      expect(parseTimeInput('abc'), null);
      expect(parseTimeInput('1:2:3:4'), null);
      expect(parseTimeInput('12x'), null);
      expect(parseTimeInput(':30'), null);
    });
  });
}
