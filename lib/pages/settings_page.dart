import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../health/health_service.dart';
import '../health/hr_zones.dart';
import '../l10n/app_localizations.dart';
import '../lib/audio.dart';
import '../lib/combo_voice.dart';
import '../lib/haptics.dart';
import '../lib/speech.dart';
import '../lib/vibrate.dart' as vibrate;
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';

/// App settings: language, sound cues, vibration, prep countdown.
/// Uses the same chrome as the tab pages (header row + back) instead of an AppBar.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _supported = true;
  bool _healthAvailable = true;
  bool _syncing = false;
  int? _suggestedMaxHr;
  int? _suggestedRestingHr;

  @override
  void initState() {
    super.initState();
    vibrate.vibrationSupported().then((v) {
      if (mounted) setState(() => _supported = v);
    });
    healthService.available().then((v) {
      if (mounted) setState(() => _healthAvailable = v);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHrSuggestions());
  }

  Future<void> _loadHrSuggestions() async {
    final store = context.read<AppStore>();
    final resting = await healthService.restingHeartRateSuggestion();
    int? observedMax;
    for (final link in store.data.healthLinks.where((l) => l.hasSeries)) {
      final samples = await healthService.series.read(link.externalId);
      final max = maxObservedHr(samples);
      if (max != null && (observedMax == null || max > observedMax)) {
        observedMax = max;
      }
    }
    if (!mounted) return;
    setState(() {
      _suggestedRestingHr = resting;
      _suggestedMaxHr = observedMax;
    });
  }

  Future<void> _setHealthSync(AppStore store, bool enabled) async {
    store.setSettings(healthSync: enabled);
    if (enabled) await _importNow(store);
  }

  Future<void> _importNow(AppStore store) async {
    if (_syncing) return;
    final l = AppLocalizations.of(context)!;
    final firstSync = store.data.settings.healthLastSync == null;
    setState(() => _syncing = true);
    final result = await healthService.syncNow(store);
    if (!mounted) return;
    setState(() => _syncing = false);
    final imported = result.newSessions + result.attachedWorkouts;
    if (!result.available) {
      context.showToast(l.settingsHealthUnavailable);
    } else if (imported == 0 && firstSync) {
      // HealthKit never says "read denied", so an empty first sync is most
      // likely a permissions problem, not a lack of workouts.
      context.showToast(l.settingsHealthNeedsPermission);
    } else if (imported == 0 && result.enrichedWorkouts > 0) {
      context.showToast(l.settingsHealthEnriched);
    } else {
      context.showToast(l.settingsHealthImported(imported));
    }
  }

  String _lastSyncLabel(AppLocalizations l, int? ms) {
    if (ms == null) return l.settingsHealthNever;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final stamp =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return l.settingsHealthLastSync(stamp);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final settings = store.data.settings;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 672),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton2(Icons.arrow_back, onTap: () => context.pop()),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l.settingsTitle.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CardWidget(
                    child: _SettingBlock(
                      icon: Icons.brightness_6_outlined,
                      label: l.settingsTheme,
                      hint: l.settingsThemeHint,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Segmented<ThemeChoice>(
                          value: settings.themeChoice,
                          options: [
                            (value: ThemeChoice.system, label: l.themeSystem),
                            (value: ThemeChoice.light, label: l.themeLight),
                            (value: ThemeChoice.dark, label: l.themeDark),
                          ],
                          onChanged: (v) => store.setSettings(themeChoice: v),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CardWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.translate_rounded,
                              size: 18,
                              color: AppColors.mut,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                l.settingsLanguage,
                                style: AppText.muted,
                              ),
                            ),
                            // Bounded width: Segmented uses flexible children internally.
                            SizedBox(
                              width: 130,
                              child: Segmented<Lang>(
                                value: store.lang,
                                options: const [
                                  (value: Lang.it, label: 'IT'),
                                  (value: Lang.en, label: 'EN'),
                                ],
                                onChanged: store.setLang,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CardWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SettingRow(
                          icon: Icons.volume_up_rounded,
                          label: l.settingsSound,
                          trailing: Toggle(
                            value: settings.sound,
                            onChanged: (v) => store.setSettings(sound: v),
                          ),
                        ),
                        _SettingBlock(
                          icon: Icons.notifications_active_outlined,
                          label: l.settingsBells,
                          hint: l.settingsBellsHint,
                          // Full-width block: three bank names never fit next
                          // to the label without truncating.
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Segmented<String>(
                              value: settings.bellSet,
                              options: [
                                (value: 'classic', label: l.bellClassic),
                                (value: 'ring', label: l.bellRing),
                                (value: 'beep', label: l.bellBeep),
                              ],
                              onChanged: (v) {
                                store.setSettings(bellSet: v);
                                // Immediate feedback: the bank just switched.
                                Sound.preview('done');
                              },
                            ),
                          ),
                        ),
                        _SettingRow(
                          icon: Icons.record_voice_over_rounded,
                          label: l.settingsComboVoice,
                          hint: l.settingsComboVoiceHint,
                          trailing: Toggle(
                            value: settings.comboVoice,
                            onChanged: (v) => store.setSettings(comboVoice: v),
                          ),
                        ),
                        _SettingRow(
                          icon: Icons.play_circle_outline_rounded,
                          label: l.settingsComboVoiceTest,
                          trailing: Icon(
                            Icons.volume_up_rounded,
                            size: 20,
                            color: AppColors.mut,
                          ),
                          onTap: () => _previewCombo(store),
                        ),
                        if (_supported)
                          _SettingRow(
                            icon: Icons.vibration_rounded,
                            label: l.settingsVibration,
                            trailing: Toggle(
                              value: settings.vibration,
                              onChanged: (v) => store.setSettings(vibration: v),
                            ),
                          ),
                        _SettingRow(
                          icon: Icons.timer_outlined,
                          label: l.settingsPrep,
                          hint: l.settingsPrepHint,
                          // Bounded width: NumStepper expands internally.
                          trailing: SizedBox(
                            width: 140,
                            child: NumStepper(
                              value: settings.prepSeconds,
                              min: 0,
                              max: 30,
                              step: 5,
                              onChanged: (v) =>
                                  store.setSettings(prepSeconds: v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CardWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SettingRow(
                          icon: Icons.health_and_safety_outlined,
                          label: l.settingsHealth,
                          hint: l.settingsHealthHint,
                          trailing: Toggle(
                            value: settings.healthSync && _healthAvailable,
                            onChanged: _healthAvailable
                                ? (v) => _setHealthSync(store, v)
                                : (_) {},
                          ),
                        ),
                        _SettingRow(
                          icon: Icons.download_rounded,
                          label: l.settingsHealthImportNow,
                          hint: _healthAvailable
                              ? _lastSyncLabel(l, settings.healthLastSync)
                              : l.settingsHealthUnavailable,
                          trailing: _syncing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: AppColors.mut,
                                ),
                          onTap: _healthAvailable && !_syncing
                              ? () => _importNow(store)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CardWidget(
                    child: _HrZonesSettings(
                      store: store,
                      suggestedMax: _suggestedMaxHr,
                      suggestedResting: _suggestedRestingHr,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CardWidget(
                    padding: EdgeInsets.zero,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.push('/onboarding'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: _SettingRow(
                          icon: Icons.school_outlined,
                          label: l.settingsHowItWorks,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppColors.mut,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Speaks a real combo (first bag combo if any, else a short sample) so the
  /// user can hear how announcements sound without starting a session.
  void _previewCombo(AppStore store) {
    final byId = {for (final t in store.data.techniques) t.id: t};
    final bagCombos = store.data.combinations.where(
      (c) => c.techniqueIds.isNotEmpty && !store.isStretchRoutine(c),
    );
    final combo = bagCombos.isEmpty ? null : bagCombos.first;
    final words = combo == null
        ? const <String>[]
        : spokenCombo(combo.techniqueIds, byId, store.lang);
    // Fallback sample localized to the app language.
    final sample = store.lang == Lang.it
        ? const ['uno', 'due']
        : const ['jab', 'cross'];
    Speech.speakCombo(words.isEmpty ? sample : words, store.lang);
  }
}

class _HrZonesSettings extends StatefulWidget {
  final AppStore store;
  final int? suggestedMax;
  final int? suggestedResting;

  const _HrZonesSettings({
    required this.store,
    required this.suggestedMax,
    required this.suggestedResting,
  });

  @override
  State<_HrZonesSettings> createState() => _HrZonesSettingsState();
}

class _HrZonesSettingsState extends State<_HrZonesSettings> {
  late final TextEditingController _maxController;
  late final TextEditingController _restingController;

  @override
  void initState() {
    super.initState();
    _maxController = TextEditingController(
      text: widget.store.data.settings.maxHeartRate?.toString() ?? '',
    );
    _restingController = TextEditingController(
      text: widget.store.data.settings.restingHeartRate?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _maxController.dispose();
    _restingController.dispose();
    super.dispose();
  }

  void _saveMax(String raw) {
    final value = int.tryParse(raw);
    if (value == null || value < 100 || value > 240) return;
    widget.store.setSettings(maxHeartRate: value);
  }

  void _saveResting(String raw) {
    final value = int.tryParse(raw);
    if (value == null || value < 30 || value > 130) return;
    widget.store.setSettings(restingHeartRate: value);
  }

  void _useMaxSuggestion() {
    final value = widget.suggestedMax;
    if (value == null) return;
    _maxController.text = '$value';
    widget.store.setSettings(maxHeartRate: value);
  }

  void _useRestingSuggestion() {
    final value = widget.suggestedResting;
    if (value == null) return;
    _restingController.text = '$value';
    widget.store.setSettings(restingHeartRate: value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _SettingBlock(
      icon: Icons.favorite_border_rounded,
      label: l.settingsHrZones,
      hint: l.settingsHrZonesHint,
      child: Column(
        children: [
          _HrInput(
            label: l.settingsMaxHr,
            controller: _maxController,
            suggestion: widget.suggestedMax,
            placeholder: l.settingsHrNotSet,
            onChanged: _saveMax,
            onUseSuggestion: _useMaxSuggestion,
          ),
          const SizedBox(height: 10),
          _HrInput(
            label: l.settingsRestingHr,
            controller: _restingController,
            suggestion: widget.suggestedResting,
            placeholder: l.settingsHrNotSet,
            onChanged: _saveResting,
            onUseSuggestion: _useRestingSuggestion,
          ),
        ],
      ),
    );
  }
}

class _HrInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int? suggestion;
  final String placeholder;
  final ValueChanged<String> onChanged;
  final VoidCallback onUseSuggestion;

  const _HrInput({
    required this.label,
    required this.controller,
    required this.suggestion,
    required this.placeholder,
    required this.onChanged,
    required this.onUseSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Field(
            label: label,
            hint: suggestion == null
                ? placeholder
                : l.settingsHrSuggested(suggestion!),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: suggestion == null
                    ? placeholder
                    : l.settingsHrSuggested(suggestion!),
                suffixText: 'bpm',
              ),
            ),
          ),
        ),
        if (suggestion != null) ...[
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TextButton(
              onPressed: onUseSuggestion,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                l.settingsHrUseSuggested.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Label + hint with the control underneath, for settings whose control needs
/// the full card width (e.g. a three-way segmented picker).
class _SettingBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? hint;
  final Widget child;
  const _SettingBlock({
    required this.icon,
    required this.label,
    this.hint,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(icon, size: 18, color: AppColors.mut),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label.toUpperCase(), style: AppText.muted),
                    if (hint != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        hint!,
                        style: TextStyle(fontSize: 11, color: AppColors.mut),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? hint;
  final Widget trailing;
  final VoidCallback? onTap;
  const _SettingRow({
    required this.icon,
    required this.label,
    this.hint,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.mut),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label.toUpperCase(), style: AppText.muted),
                if (hint != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    hint!,
                    style: TextStyle(fontSize: 11, color: AppColors.mut),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          trailing,
        ],
      ),
    );
    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.selection();
        onTap!();
      },
      child: row,
    );
  }
}
