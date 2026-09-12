// Shared mapping of stretching technique ids to their SVG illustration asset.
const _stretchAssets = <String, String>{
  't-pancake': 'assets/stretch/pancake.svg',
  't-figure4-sx': 'assets/stretch/figure4.svg',
  't-figure4-dx': 'assets/stretch/figure4.svg',
  't-hipflexor-sx': 'assets/stretch/hip-flexor.svg',
  't-hipflexor-dx': 'assets/stretch/hip-flexor.svg',
  't-lat-sx': 'assets/stretch/lat-stretch.svg',
  't-lat-dx': 'assets/stretch/lat-stretch.svg',
  't-butterfly': 'assets/stretch/butterfly.svg',
  't-forward-fold': 'assets/stretch/forward-fold.svg',
  't-calf': 'assets/stretch/calf.svg',
  't-quad': 'assets/stretch/quad.svg',
  't-triceps': 'assets/stretch/triceps.svg',
  't-chest': 'assets/stretch/chest-opener.svg',
  't-neck': 'assets/stretch/neck.svg',
  't-wrist': 'assets/stretch/wrist.svg',
  't-pigeon': 'assets/stretch/pigeon.svg',
};

/// Returns the SVG asset for a stretching technique, or null if none exists.
String? stretchImageFor(String techniqueId) => _stretchAssets[techniqueId];
