// Global store ported from src/store/AppStore.tsx (ChangeNotifier-based).
import 'package:flutter/foundation.dart';

import '../lib/format.dart';
import '../lib/haptics.dart';
import '../models/types.dart';
import 'storage.dart';

class AppStore extends ChangeNotifier {
  AppData data;
  bool vibrationSupported = true;
  Lang lang;
  bool onboardingSeen;

  AppStore(this.data, this.lang, {this.onboardingSeen = false}) {
    Haptics.enabled = data.settings.vibration;
  }

  static Future<AppStore> create() async {
    final loaded = await loadData();
    final lang = await loadLang();
    final onboardingSeen = await loadOnboardingSeen();
    return AppStore(loaded, lang, onboardingSeen: onboardingSeen);
  }

  Future<void> markOnboardingSeen() async {
    if (onboardingSeen) return;
    onboardingSeen = true;
    notifyListeners();
    await saveOnboardingSeen();
  }

  /// Immutable snapshot for undo: capture before a delete, pass it back to
  /// [restore] to undo it (including any cascading changes).
  AppData get snapshot => data;

  void restore(AppData next) => _set(next);

  void _set(AppData next) {
    data = next;
    Haptics.enabled = next.settings.vibration;
    notifyListeners();
    saveData(next);
  }

  // ---- language ----
  Future<void> setLang(Lang l) async {
    lang = l;
    notifyListeners();
    await saveLang(l);
  }

  // ---- techniques ----
  Technique addTechnique(Technique t) {
    final tech = t.copyWith(id: uid());
    _set(
      AppData(
        version: data.version,
        techniques: [...data.techniques, tech],
        combinations: data.combinations,
        workouts: data.workouts,
        sessions: data.sessions,
        plans: data.plans,
        settings: data.settings,
      ),
    );
    return tech;
  }

  void deleteTechnique(String id) {
    _set(
      _copyWith(
        techniques: data.techniques.where((t) => t.id != id).toList(),
        combinations: data.combinations
            .map(
              (c) => Combination(
                id: c.id,
                name: c.name,
                techniqueIds: c.techniqueIds.where((tid) => tid != id).toList(),
                favorite: c.favorite,
                createdAt: c.createdAt,
              ),
            )
            .where((c) => c.techniqueIds.isNotEmpty)
            .toList(),
      ),
    );
  }

  // ---- combinations ----
  void saveCombination(Combination c) {
    final exists = data.combinations.any((x) => x.id == c.id);
    _set(
      _copyWith(
        combinations: exists
            ? data.combinations.map((x) => x.id == c.id ? c : x).toList()
            : [...data.combinations, c],
      ),
    );
  }

  void deleteCombination(String id) {
    _set(
      _copyWith(
        combinations: data.combinations.where((c) => c.id != id).toList(),
        workouts: data.workouts
            .map(
              (w) => w.copyWith(
                combinationIds: w.combinationIds
                    .where((cid) => cid != id)
                    .toList(),
                clearRoutineId: w.routineId == id,
              ),
            )
            .toList(),
      ),
    );
  }

  Combination? duplicateCombination(String id) {
    final src = (data.combinations.where((c) => c.id == id).isEmpty
        ? null
        : data.combinations.firstWhere((c) => c.id == id));
    if (src == null) return null;
    final copy = Combination(
      id: uid(),
      name: '${src.name} COPY',
      techniqueIds: src.techniqueIds.toList(),
      favorite: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _set(_copyWith(combinations: [...data.combinations, copy]));
    return copy;
  }

  void toggleFavorite(String id) {
    _set(
      _copyWith(
        combinations: data.combinations
            .map(
              (c) => c.id == id
                  ? Combination(
                      id: c.id,
                      name: c.name,
                      techniqueIds: c.techniqueIds,
                      favorite: !c.favorite,
                      createdAt: c.createdAt,
                    )
                  : c,
            )
            .toList(),
      ),
    );
  }

  bool isStretchRoutine(Combination c) {
    if (c.techniqueIds.isEmpty) return false;
    final byId = {for (final t in data.techniques) t.id: t};
    return c.techniqueIds.every(
      (id) => byId[id]?.category == TechniqueCategory.stretching,
    );
  }

  // ---- workouts ----
  void saveWorkout(Workout w) {
    final exists = data.workouts.any((x) => x.id == w.id);
    _set(
      _copyWith(
        workouts: exists
            ? data.workouts.map((x) => x.id == w.id ? w : x).toList()
            : [...data.workouts, w],
      ),
    );
  }

  void deleteWorkout(String id) {
    _set(_copyWith(workouts: data.workouts.where((w) => w.id != id).toList()));
  }

  Workout? duplicateWorkout(String id) {
    final src = (data.workouts.where((w) => w.id == id).isEmpty
        ? null
        : data.workouts.firstWhere((w) => w.id == id));
    if (src == null) return null;
    final copy = Workout(
      id: uid(),
      name: '${src.name} COPY',
      workDuration: src.workDuration,
      restDuration: src.restDuration,
      rounds: src.rounds,
      combinationIds: src.combinationIds.toList(),
      routineId: src.routineId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _set(_copyWith(workouts: [...data.workouts, copy]));
    return copy;
  }

  // ---- sessions ----
  void addSession(SessionRecord s) {
    _set(_copyWith(sessions: [...data.sessions, s]));
  }

  void updateSession(SessionRecord s) {
    if (!data.sessions.any((x) => x.id == s.id)) return;
    _set(
      _copyWith(
        sessions: data.sessions.map((x) => x.id == s.id ? s : x).toList(),
      ),
    );
  }

  void deleteSession(String id) {
    _set(_copyWith(sessions: data.sessions.where((s) => s.id != id).toList()));
  }

  // ---- week plan ----
  void addPlan(WeekPlanItem p) {
    _set(_copyWith(plans: [...data.plans, p]));
  }

  void togglePlan(String id) {
    _set(
      _copyWith(
        plans: data.plans
            .map((p) => p.id == id ? p.copyWith(done: !p.done) : p)
            .toList(),
      ),
    );
  }

  void deletePlan(String id) {
    _set(_copyWith(plans: data.plans.where((p) => p.id != id).toList()));
  }

  // ---- settings ----
  void setSettings({bool? sound, bool? vibration, int? prepSeconds}) {
    _set(
      _copyWith(
        settings: data.settings.copyWith(
          sound: sound,
          vibration: vibration,
          prepSeconds: prepSeconds,
        ),
      ),
    );
  }

  AppData _copyWith({
    List<Technique>? techniques,
    List<Combination>? combinations,
    List<Workout>? workouts,
    List<SessionRecord>? sessions,
    List<WeekPlanItem>? plans,
    Settings? settings,
  }) => AppData(
    version: data.version,
    techniques: techniques ?? data.techniques,
    combinations: combinations ?? data.combinations,
    workouts: workouts ?? data.workouts,
    sessions: sessions ?? data.sessions,
    plans: plans ?? data.plans,
    settings: settings ?? data.settings,
  );
}
