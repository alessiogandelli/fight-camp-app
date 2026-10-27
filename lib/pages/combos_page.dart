// Combinations page ported from src/pages/CombinationsPage.tsx.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_args.dart';
import '../data/store.dart';
import '../lib/conditioning.dart';
import '../lib/stretch.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import '../ui/workout_icons.dart';
import '../widgets/pushup_counter.dart';
import '../l10n/app_localizations.dart';
import 'combo_builder_page.dart';

Future<void> _openComboBuilder(BuildContext context, {String? comboId}) async {
  final l = AppLocalizations.of(context)!;
  final saved = await showComboBuilderSheet(context, comboId: comboId);
  if (!context.mounted || saved != true) return;
  context.showToast(l.comboSaved);
}

Future<void> _showImagePreview(
  BuildContext context, {
  required String title,
  required String image,
  String? description,
}) async {
  await showAppModal<void>(
    context,
    title: title,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: SvgPicture.asset(image, width: 220, height: 220)),
        const SizedBox(height: 12),
        if (description != null)
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.mut),
          ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

enum _Filter { all, favorites, boxing, kicks, knees, elbows, defense }

/// Library section: bag combos, conditioning circuits, stretching exercises,
/// or the push-up tool.
enum _Section { bag, conditioning, stretching, tool }

class CombosPage extends StatefulWidget {
  const CombosPage({super.key});

  @override
  State<CombosPage> createState() => _CombosPageState();
}

class _CombosPageState extends State<CombosPage> {
  _Filter _filter = _Filter.all;
  _Section _section = _Section.bag;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final query = _query.toLowerCase();

    // Bag combos: routines and conditioning circuits live in Workouts, so
    // neither surfaces here.
    var combos = store.data.combinations
        .where((c) => !store.isStretchRoutine(c) && !store.isCircuit(c))
        .where((c) => c.name.toLowerCase().contains(query))
        .toList();
    if (_filter == _Filter.favorites) {
      combos = combos.where((c) => c.favorite).toList();
    } else if (_filter != _Filter.all) {
      final cat = switch (_filter) {
        _Filter.boxing => TechniqueCategory.boxing,
        _Filter.kicks => TechniqueCategory.kicks,
        _Filter.knees => TechniqueCategory.knees,
        _Filter.elbows => TechniqueCategory.elbows,
        _ => TechniqueCategory.defense,
      };
      combos = combos
          .where(
            (c) => c.techniqueIds.any(
              (id) => store.data.techniques.any(
                (t) => t.id == id && t.category == cat,
              ),
            ),
          )
          .toList();
    }
    combos.sort((a, b) {
      if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    // Stretching catalog: the exercises themselves, read-only.
    final stretches = store.data.techniques
        .where((t) => t.category == TechniqueCategory.stretching)
        .where(
          (t) =>
              query.isEmpty ||
              t.nameIn(lang).toLowerCase().contains(query) ||
              t.shortIn(lang).toLowerCase().contains(query) ||
              (t.descriptionIn(lang)?.toLowerCase().contains(query) ?? false),
        )
        .toList();

    // Conditioning catalog: the exercises themselves, read-only.
    final conditioning = store.data.techniques
        .where((t) => t.category == TechniqueCategory.conditioning)
        .where(
          (t) =>
              query.isEmpty ||
              t.nameIn(lang).toLowerCase().contains(query) ||
              t.shortIn(lang).toLowerCase().contains(query),
        )
        .toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            MediaQuery.paddingOf(context).top + kAppHeaderHeight + 8,
            AppSpacing.md,
            glassNavClearance(context) + 72,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 768),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionTitle(l.libraryTitle),
                  Segmented<_Section>(
                    value: _section,
                    options: [
                      (value: _Section.bag, label: l.libraryBag),
                      (
                        value: _Section.conditioning,
                        label: l.libraryConditioning,
                      ),
                      (value: _Section.stretching, label: l.libraryStretching),
                      (value: _Section.tool, label: l.libraryTool),
                    ],
                    onChanged: (v) => setState(() {
                      _section = v;
                      _filter = _Filter.all;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  if (_section == _Section.tool)
                    PushupCounterSection()
                  else ...[
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: _section == _Section.bag
                            ? l.combosSearch
                            : l.stretchesSearch,
                        prefixIcon: Icon(Icons.search, color: AppColors.mut),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_section == _Section.bag)
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black,
                            Colors.black,
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.07, 0.93, 1.0],
                        ).createShader(bounds),
                        blendMode: BlendMode.dstIn,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: AppSpacing.xs),
                              ChipWidget(
                                label: l.commonAll,
                                active: _filter == _Filter.all,
                                onTap: () =>
                                    setState(() => _filter = _Filter.all),
                              ),
                              const SizedBox(width: 6),
                              ChipWidget(
                                label: l.combosFavorites,
                                active: _filter == _Filter.favorites,
                                onTap: () =>
                                    setState(() => _filter = _Filter.favorites),
                              ),
                              for (final c in techniqueCategories)
                                if (c.id != TechniqueCategory.stretching &&
                                    c.id != TechniqueCategory.conditioning) ...[
                                  const SizedBox(width: 6),
                                  ChipWidget(
                                    label: categoryLabel(c.id, lang),
                                    active: _filter == _filterFor(c.id),
                                    onTap: () => setState(
                                      () => _filter = _filterFor(c.id),
                                    ),
                                  ),
                                ],
                              const SizedBox(width: AppSpacing.xs),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (_section == _Section.stretching)
                      if (stretches.isEmpty)
                        EmptyState(
                          title: l.stretchesEmpty,
                          message: l.stretchesEmptyMsg,
                        )
                      else
                        for (var i = 0; i < stretches.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.sm + 4),
                          _StretchExerciseCard(
                            technique: stretches[i],
                            lang: lang,
                          ),
                        ]
                    else if (_section == _Section.conditioning)
                      for (var i = 0; i < conditioning.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.sm + 4),
                        _ConditioningExerciseCard(
                          technique: conditioning[i],
                          lang: lang,
                        ),
                      ]
                    else if (combos.isEmpty)
                      EmptyState(
                        title: l.combosEmpty,
                        message: l.combosEmptyMsg,
                        action: Button(
                          label: l.combosCreate,
                          icon: Icons.add,
                          size: BtnSize.sm,
                          onTap: () => _openComboBuilder(context),
                        ),
                      )
                    else
                      for (var i = 0; i < combos.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.sm + 4),
                        _ComboCard(combo: combos[i]),
                      ],
                  ],
                ],
              ),
            ),
          ),
        ),
        if (_section == _Section.bag)
          Positioned(
            right: 20,
            bottom: glassNavClearance(context) - 8,
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: l.combosCreate,
              onPressed: () => _openComboBuilder(context),
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  _Filter _filterFor(TechniqueCategory cat) => switch (cat) {
    TechniqueCategory.boxing => _Filter.boxing,
    TechniqueCategory.kicks => _Filter.kicks,
    TechniqueCategory.knees => _Filter.knees,
    TechniqueCategory.elbows => _Filter.elbows,
    TechniqueCategory.defense => _Filter.defense,
    TechniqueCategory.conditioning => _Filter.all,
    TechniqueCategory.stretching => _Filter.all,
  };
}

// Read-only catalog entry: illustration, name and description of one exercise.
class _StretchExerciseCard extends StatelessWidget {
  final Technique technique;
  final Lang lang;
  const _StretchExerciseCard({required this.technique, required this.lang});

  @override
  Widget build(BuildContext context) {
    final img = stretchImageFor(technique.id);
    final desc = technique.descriptionIn(lang);
    return GestureDetector(
      onTap: img == null
          ? null
          : () => _showImagePreview(
              context,
              title: technique.nameIn(lang),
              image: img,
              description: desc,
            ),
      child: CardWidget(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.panel2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: img != null
                  ? SvgPicture.asset(img, width: 80, height: 80)
                  : Icon(Icons.self_improvement_rounded, color: AppColors.mut),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    technique.nameIn(lang).toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (desc != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.mut,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (img != null)
              Icon(Icons.zoom_in_rounded, size: 18, color: AppColors.mut),
          ],
        ),
      ),
    );
  }
}

/// Read-only catalog entry for one conditioning exercise: illustration + name.
class _ConditioningExerciseCard extends StatelessWidget {
  final Technique technique;
  final Lang lang;
  const _ConditioningExerciseCard({
    required this.technique,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final img = conditioningImageFor(technique.id);
    return GestureDetector(
      onTap: img == null
          ? null
          : () => _showImagePreview(
              context,
              title: technique.nameIn(lang),
              image: img,
            ),
      child: CardWidget(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.panel2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: img != null
                  ? SvgPicture.asset(img, width: 80, height: 80)
                  : Icon(Icons.fitness_center_rounded, color: AppColors.mut),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                technique.nameIn(lang).toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            if (img != null)
              Icon(Icons.zoom_in_rounded, size: 18, color: AppColors.mut),
          ],
        ),
      ),
    );
  }
}

class _ComboCard extends StatelessWidget {
  final Combination combo;
  const _ComboCard({required this.combo});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;

    Future<bool> confirmDelete() async {
      final ok = await showConfirm(
        context,
        title: l.combosDeleteTitle,
        message: l.combosDeleteMsg(combo.name),
        cancelLabel: l.commonCancel,
        confirmLabel: l.commonDelete,
      );
      if (ok) {
        final before = store.snapshot;
        store.deleteCombination(combo.id);
        if (context.mounted) {
          context.showToast(
            l.combosDeleted,
            actionLabel: l.commonUndo,
            onAction: () => store.restore(before),
          );
        }
      }
      return ok;
    }

    Future<void> quickStart() async {
      var rounds = 5;
      var duration = 180;
      var rest = 60;
      final started = await showAppModal<bool>(
        context,
        title: l.combosTrain(combo.name),
        builder: (_) => StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Field(
                  label: l.commonRounds,
                  child: NumStepper(
                    value: rounds,
                    min: 1,
                    max: 20,
                    onChanged: (v) => setModalState(() => rounds = v),
                  ),
                ),
                const SizedBox(height: 10),
                Field(
                  label: l.combosRoundLength,
                  child: TimeField(
                    value: duration,
                    onChanged: (v) => setModalState(() => duration = v),
                  ),
                ),
                const SizedBox(height: 10),
                Field(
                  label: l.combosRestBetween,
                  child: TimeField(
                    value: rest,
                    min: 0,
                    onChanged: (v) => setModalState(() => rest = v),
                  ),
                ),
                const SizedBox(height: 14),
                Button(
                  label: l.combosStartSession,
                  size: BtnSize.lg,
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            );
          },
        ),
      );
      if (started != true || !context.mounted) return;
      final cfg = LiveConfig(
        name: combo.name.toUpperCase(),
        type: WorkoutType.heavyBag,
        prepSeconds: store.data.settings.prepSeconds,
        rounds: List.generate(
          rounds,
          (i) => RoundBase(
            duration: duration,
            restDuration: i < rounds - 1 ? rest : 0,
            type: RoundType.combination,
            combinationIds: [combo.id],
          ),
        ),
      );
      context.push('/live', extra: LiveArgs(cfg, autostart: true));
    }

    final techniqueNames = [
      for (final id in combo.techniqueIds)
        store.data.techniques
                .where((t) => t.id == id)
                .firstOrNull
                ?.shortIn(lang) ??
            l.sessionUnknown,
    ];

    return Dismissible(
      key: ValueKey(combo.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(38),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withAlpha(140)),
        ),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: ActionCard(
        icon: comboCardIcon,
        title: combo.name,
        titleTrailing: IconButton2(
          combo.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
          color: combo.favorite ? AppColors.warning : AppColors.mut,
          onTap: () => store.toggleFavorite(combo.id),
        ),
        body: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            for (var i = 0; i < techniqueNames.length; i++) ...[
              Text(
                techniqueNames[i],
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              if (i < techniqueNames.length - 1)
                Text('→', style: TextStyle(fontSize: 12, color: AppColors.mut)),
            ],
          ],
        ),
        playLabel: l.commonStart,
        menuTitle: l.commonActions,
        onPlay: quickStart,
        onTap: () => _openComboBuilder(context, comboId: combo.id),
        menu: [
          CardMenuAction(
            label: l.commonDuplicate,
            icon: Icons.copy_rounded,
            onTap: () {
              final copy = store.duplicateCombination(combo.id);
              context.showToast(
                copy != null ? l.combosDuplicated : l.comboNotFoundMsg,
              );
            },
          ),
          CardMenuAction(
            label: l.commonEdit,
            icon: Icons.edit_outlined,
            onTap: () => _openComboBuilder(context, comboId: combo.id),
          ),
        ],
      ),
    );
  }
}
