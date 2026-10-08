// Shared mapping of conditioning technique ids to their SVG illustration asset.
// Several variants share one line-art image (push-up family, squat family,
// lunge family, dorsali family) to keep the asset set small.
const _conditioningAssets = <String, String>{
  't-cond-pushup': 'assets/conditioning/pushup.svg',
  't-cond-pushup-diamond': 'assets/conditioning/pushup.svg',
  't-cond-pushup-wide': 'assets/conditioning/pushup.svg',
  't-cond-pushup-explosive': 'assets/conditioning/pushup.svg',
  't-cond-pushup-side': 'assets/conditioning/pushup.svg',
  't-cond-pushup-fists': 'assets/conditioning/pushup.svg',
  't-cond-squat': 'assets/conditioning/squat.svg',
  't-cond-sumo-squat': 'assets/conditioning/squat.svg',
  't-cond-jump-squat': 'assets/conditioning/jump-squat.svg',
  't-cond-lunges': 'assets/conditioning/lunge.svg',
  't-cond-jump-lunges': 'assets/conditioning/lunge.svg',
  't-cond-switch-lunges': 'assets/conditioning/lunge.svg',
  't-cond-lunge-knee-dx': 'assets/conditioning/lunge.svg',
  't-cond-lunge-knee-sx': 'assets/conditioning/lunge.svg',
  't-cond-crunch': 'assets/conditioning/crunch.svg',
  't-cond-bicycles': 'assets/conditioning/bicycles.svg',
  't-cond-crucifix': 'assets/conditioning/dorsali.svg',
  't-cond-vups': 'assets/conditioning/v-ups.svg',
  't-cond-russian-twist': 'assets/conditioning/russian-twist.svg',
  't-cond-toe-touch': 'assets/conditioning/toe-touch.svg',
  't-cond-leg-raises': 'assets/conditioning/leg-raises.svg',
  't-cond-side-crunch-dx': 'assets/conditioning/side-crunch.svg',
  't-cond-side-crunch-sx': 'assets/conditioning/side-crunch.svg',
  't-cond-abs-laterali': 'assets/conditioning/side-crunch.svg',
  't-cond-plank': 'assets/conditioning/plank.svg',
  't-cond-low-high-plank': 'assets/conditioning/low-high-plank.svg',
  't-cond-shoulder-taps': 'assets/conditioning/shoulder-taps.svg',
  't-cond-squadra': 'assets/conditioning/squadra.svg',
  't-cond-mountain-climbers': 'assets/conditioning/mountain-climbers.svg',
  't-cond-switch-mountain-climbers':
      'assets/conditioning/mountain-climbers.svg',
  't-cond-in-outs': 'assets/conditioning/in-outs.svg',
  't-cond-burpees': 'assets/conditioning/burpees.svg',
  't-cond-half-burpees': 'assets/conditioning/burpees.svg',
  't-cond-dorsali': 'assets/conditioning/dorsali.svg',
  't-cond-dorsali-avanti': 'assets/conditioning/dorsali.svg',
  't-cond-dorsali-fianchi': 'assets/conditioning/dorsali.svg',
  't-cond-dorsali-incrociate': 'assets/conditioning/dorsali.svg',
  't-cond-dorsali-cross-foot': 'assets/conditioning/dorsali.svg',
  't-cond-knee-floor': 'assets/conditioning/knee-floor.svg',
};

/// Returns the SVG asset for a conditioning technique, or null if none exists.
String? conditioningImageFor(String techniqueId) =>
    _conditioningAssets[techniqueId];
