// Shared mapping of stretching technique ids to their SVG illustration asset.
const _stretchAssets = <String, String>{
  't-pancake': 'assets/stretch/pancake.svg',
  't-figure4-sx': 'assets/stretch/figure4.svg',
  't-figure4-dx': 'assets/stretch/figure4.svg',
  't-hipflexor-sx': 'assets/stretch/hip-flexor.svg',
  't-hipflexor-dx': 'assets/stretch/hip-flexor.svg',
  't-lat-sx': 'assets/stretch/lat-stretch.svg',
  't-lat-dx': 'assets/stretch/lat-stretch.svg',
};

/// Returns the SVG asset for a stretching technique, or null if none exists.
String? stretchImageFor(String techniqueId) => _stretchAssets[techniqueId];