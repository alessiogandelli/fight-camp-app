// Swipe direction resolution shared by the live player.
enum SwipeAction { skip, previous, none }

/// Maps a horizontal drag velocity (positive = rightward) to a navigation
/// action. Drags below [threshold] are treated as accidental and return none.
SwipeAction resolveSwipe(double velocity, {double threshold = 200}) {
  if (velocity.abs() < threshold) return SwipeAction.none;
  return velocity < 0 ? SwipeAction.skip : SwipeAction.previous;
}
