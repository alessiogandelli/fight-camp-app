// Assign a real workout type to imported/legacy sessions currently classified
// as "other". Updates are session-level so mixed trainings keep their pieces.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../l10n/app_localizations.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

Future<int> showCategorizeSessions(
  BuildContext context,
  List<SessionRecord> sessions,
) async {
  final store = context.read<AppStore>();
  final lang = store.lang;
  final l = AppLocalizations.of(context)!;
  final chosen = <String, WorkoutType>{};

  final saved = await showAppModal<int>(
    context,
    title: l.progressCategorizeTitle,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        final options = [
          for (final wt in workoutTypes)
            if (wt.id != WorkoutType.other) wt,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.progressCategorizeHint,
              style: TextStyle(fontSize: 12.5, color: AppColors.mut),
            ),
            const SizedBox(height: 14),
            for (final session in sessions) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            dayLabel(session.date, lang),
                            fmtTimeOfDay(
                              session.date - session.duration * 1000,
                            ),
                            fmtDurationHuman(session.duration),
                          ].join(' · '),
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.mut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<WorkoutType>(
                    onSelected: (value) =>
                        setState(() => chosen[session.id] = value),
                    itemBuilder: (_) => [
                      for (final wt in options)
                        PopupMenuItem(
                          value: wt.id,
                          child: Text(
                            '${wt.icon} ${workoutTypeLabel(wt.id, lang)}',
                          ),
                        ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.panel2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chosen[session.id] == null
                                ? l.progressChooseType
                                : workoutTypeLabel(chosen[session.id]!, lang),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: chosen[session.id] == null
                                  ? AppColors.mut
                                  : AppColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: AppColors.mut,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: AppColors.line),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            Button(
              label: l.progressCategorizeSave,
              size: BtnSize.lg,
              onTap: chosen.isEmpty
                  ? null
                  : () {
                      for (final session in sessions) {
                        final type = chosen[session.id];
                        if (type == null) continue;
                        store.updateSession(session.copyWith(type: type));
                      }
                      Navigator.pop(context, chosen.length);
                    },
            ),
          ],
        );
      },
    ),
  );
  return saved ?? 0;
}
