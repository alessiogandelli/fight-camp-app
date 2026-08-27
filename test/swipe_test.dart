import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/swipe.dart';

void main() {
  group('resolveSwipe', () {
    test('maps leftward velocity to skip', () {
      expect(resolveSwipe(-300), SwipeAction.skip);
    });

    test('maps rightward velocity to previous', () {
      expect(resolveSwipe(300), SwipeAction.previous);
    });

    test('ignores slow drags below threshold', () {
      expect(resolveSwipe(-150), SwipeAction.none);
      expect(resolveSwipe(150), SwipeAction.none);
    });

    test('ignores zero velocity', () {
      expect(resolveSwipe(0), SwipeAction.none);
    });
  });
}
