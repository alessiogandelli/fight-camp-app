import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/vibrate.dart' as vibrate;
import '../l10n/app_localizations.dart';
import '../models/types.dart';
import '../ui/theme.dart';
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

  @override
  void initState() {
    super.initState();
    vibrate.vibrationSupported().then((v) {
      if (mounted) setState(() => _supported = v);
    });
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 672),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    IconButton2(Icons.arrow_back, onTap: () => context.pop()),
                    const SizedBox(width: AppSpacing.xs),
                    Text(l.settingsTitle.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  CardWidget(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.translate_rounded, size: 18, color: AppColors.mut),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(l.settingsLanguage, style: AppText.muted)),
                          // Bounded width: Segmented uses flexible children internally.
                          SizedBox(
                            width: 130,
                            child: Segmented<Lang>(
                              value: store.lang,
                              options: const [(value: Lang.it, label: 'IT'), (value: Lang.en, label: 'EN')],
                              onChanged: store.setLang,
                            ),
                          ),
                        ]),
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
                          trailing: Toggle(value: settings.sound, onChanged: (v) => store.setSettings(sound: v)),
                        ),
                        if (_supported)
                          _SettingRow(
                            icon: Icons.vibration_rounded,
                            label: l.settingsVibration,
                            trailing: Toggle(value: settings.vibration, onChanged: (v) => store.setSettings(vibration: v)),
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
                              onChanged: (v) => store.setSettings(prepSeconds: v),
                            ),
                          ),
                        ),
                      ],
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
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? hint;
  final Widget trailing;
  const _SettingRow({required this.icon, required this.label, this.hint, required this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
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
                    Text(hint!, style: const TextStyle(fontSize: 11, color: AppColors.mut)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            trailing,
          ],
        ),
      );
}
