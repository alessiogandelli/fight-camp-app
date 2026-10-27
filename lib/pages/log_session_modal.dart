// Manual session logging, opened from Progress when there is no training or
// from its empty/filtered states.
import 'package:flutter/material.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../lib/stats.dart';
import '../l10n/app_localizations.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';

/// Opens the "log a manual session" modal and saves the record on confirmation.
Future<void> showLogSessionModal(BuildContext context, AppStore store) async {
  final lang = store.lang;
  final l = AppLocalizations.of(context)!;
  var type = WorkoutType.other;
  final nameCtrl = TextEditingController();
  int duration = 1800;
  int? rpe;
  int? energy;
  Feeling? feeling;
  final notesCtrl = TextEditingController();
  final distCtrl = TextEditingController();
  final exercises =
      <
        ({
          TextEditingController ex,
          TextEditingController sets,
          TextEditingController reps,
          TextEditingController kg,
        })
      >[];

  final saved = await showAppModal<bool>(
    context,
    title: l.historyLogSession,
    builder: (_) => StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Field(
              label: l.commonType,
              child: Select<WorkoutType>(
                value: type,
                options: [
                  for (final wt in workoutTypes)
                    (
                      value: wt.id,
                      label: '${wt.icon} ${workoutTypeLabel(wt.id, lang)}',
                    ),
                ],
                onChanged: (v) => setModalState(() => type = v),
              ),
            ),
            const SizedBox(height: 10),
            Field(
              label: l.historyNameOptional,
              child: TextInput(controller: nameCtrl, uppercase: true),
            ),
            const SizedBox(height: 10),
            Field(
              label: l.commonDuration,
              hint: l.historyMinDuration,
              child: TimeField(
                value: duration,
                min: 60,
                max: 21600,
                step: 60,
                onChanged: (v) => setModalState(() => duration = v),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.completeHowHard.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.mut,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (var i = 1; i <= 10; i++)
                  GestureDetector(
                    onTap: () => setModalState(() => rpe = i),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rpe == i
                            ? (i >= 8 ? AppColors.primary : AppColors.panel2)
                            : AppColors.panel2,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: rpe == i ? Colors.transparent : AppColors.line,
                        ),
                      ),
                      child: Text(
                        '$i',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: rpe == i ? Colors.white : AppColors.mut,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (rpe != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${l.commonLoad}: ${computeLoad(duration, rpe)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (type == WorkoutType.running) ...[
              const SizedBox(height: 10),
              Field(
                label: l.historyDistance,
                child: TextInput(controller: distCtrl, hint: '0.0'),
              ),
            ],
            if (type == WorkoutType.strength) ...[
              const SizedBox(height: 12),
              SectionTitle(l.historyExercises),
              for (final e in exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextInput(
                          controller: e.ex,
                          hint: l.historyExercisePlaceholder,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(width: 48, child: TextInput(controller: e.sets)),
                      SizedBox(width: 52, child: TextInput(controller: e.reps)),
                      SizedBox(width: 56, child: TextInput(controller: e.kg)),
                      IconButton2(
                        Icons.close,
                        onTap: () => setModalState(() => exercises.remove(e)),
                      ),
                    ],
                  ),
                ),
              Text(
                l.historyNoExercises,
                style: TextStyle(fontSize: 11, color: AppColors.mut),
              ),
              Button(
                label: l.historyAdd,
                variant: BtnVariant.ghost,
                size: BtnSize.sm,
                icon: Icons.add,
                onTap: () => setModalState(
                  () => exercises.add((
                    ex: TextEditingController(),
                    sets: TextEditingController(),
                    reps: TextEditingController(),
                    kg: TextEditingController(),
                  )),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Field(
              label: l.completeEnergyBefore,
              child: NumStepper(
                value: energy ?? 3,
                min: 1,
                max: 5,
                onChanged: (v) => setModalState(() => energy = v),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final f in Feeling.values)
                  ChipWidget(
                    label: feelingLabel(f, lang),
                    active: feeling == f,
                    onTap: () => setModalState(() => feeling = f),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Field(
              label: l.historyNotes,
              child: TextInput(controller: notesCtrl, maxLines: 3),
            ),
            const SizedBox(height: 16),
            Button(
              label: l.historySaveSession,
              size: BtnSize.lg,
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    ),
  );

  if (saved != true || !context.mounted) return;

  final dist = double.tryParse(distCtrl.text.replaceAll(',', '.'));
  final pace = (dist != null && dist > 0 && duration > 0)
      ? (duration / dist).round()
      : null;
  store.addSession(
    SessionRecord(
      id: uid(),
      date: DateTime.now().millisecondsSinceEpoch,
      type: type,
      source: 'manual',
      name: nameCtrl.text.trim().toUpperCase().isEmpty
          ? workoutTypeLabel(type, lang).toUpperCase()
          : nameCtrl.text.trim().toUpperCase(),
      duration: duration,
      load: computeLoad(duration, rpe),
      rpe: rpe,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      energyBefore: energy,
      feelingAfter: feeling,
      running: type == WorkoutType.running
          ? RunningExtra(distanceKm: dist, paceSecPerKm: pace)
          : null,
      strength: type == WorkoutType.strength
          ? [
              for (final e in exercises)
                StrengthEntry(
                  exercise: e.ex.text.trim(),
                  sets: int.tryParse(e.sets.text) ?? 1,
                  reps: int.tryParse(e.reps.text) ?? 0,
                  weightKg: double.tryParse(e.kg.text.replaceAll(',', '.')),
                ),
            ]
          : null,
    ),
  );
  context.showToast(l.historySessionLogged);
}
