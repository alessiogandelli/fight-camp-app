// Route argument payloads shared between pages.
import 'models/types.dart';

class LiveArgs {
  final LiveConfig config;
  final int? resumeElapsedMs;
  LiveArgs(this.config, {this.resumeElapsedMs});
}

class CompleteArgs {
  final LiveConfig config;
  final SessionSummary summary;
  CompleteArgs(this.config, this.summary);
}
