// One compact Log row per real-world training. Detail lives in an opaque
// training sheet, not in nested cards inside the list.
import 'package:flutter/material.dart';

import '../lib/format.dart';
import '../l10n/app_localizations.dart';
import '../training/training.dart';
import '../ui/theme.dart';
import '../ui/workout_colors.dart';

class TrainingLogTile extends StatelessWidget {
  final Training training;
  final VoidCallback onTap;
  const TrainingLogTile({
    super.key,
    required this.training,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = training;
    final first = t.sessions.isNotEmpty ? t.sessions.first : null;
    final title = t.sessions.length == 1
        ? (first?.name ?? l.historyTraining)
        : l.historyTraining;
    final accent = progressTrainingColor(t);

    final meta = <String>[
      fmtTimeOfDay(t.start),
      fmtDurationHuman(t.durationSec),
      if (t.distanceKm != null) fmtDistance(t.distanceKm),
      if (t.paceSecPerKm != null) fmtPace(t.paceSecPerKm),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: accent, width: 4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.mut,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (t.avgHr != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    l.progressHrBpm(t.avgHr!),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color: AppColors.mut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
