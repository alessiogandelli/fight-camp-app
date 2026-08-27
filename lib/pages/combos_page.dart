// Combinations page ported from src/pages/CombinationsPage.tsx.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_args.dart';
import '../data/store.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import '../l10n/app_localizations.dart';

enum _Filter { all, favorites, boxing, kicks, knees, elbows, defense }

/// Library section: bag combos vs stretching routines (ADR 0002 — same
/// entity, different technique category).
enum _Section { bag, stretching }

/// Maps a stretching technique id to its SVG illustration asset.
String? stretchImageFor(String techniqueId) {
  switch (techniqueId) {
    case 't-pancake':
      return 'assets/stretch/pancake.svg';
    case 't-figure4-sx':
    case 't-figure4-dx':
      return 'assets/stretch/figure4.svg';
    case 't-hipflexor-sx':
    case 't-hipflexor-dx':
      return 'assets/stretch/hip-flexor.svg';
    case 't-lat-sx':
    case 't-lat-dx':
      return 'assets/stretch/lat-stretch.svg';
    default:
      return null;
  }
}

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
    var combos = store.data.combinations
        .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    if (_section == _Section.stretching) {
      combos = combos.where((c) => store.isStretchRoutine(c)).toList();
    } else {
      combos = combos.where((c) => !store.isStretchRoutine(c)).toList();
    }
    if (_filter == _Filter.favorites) {
      combos = combos.where((c) => c.favorite).toList();
    } else if (_filter != _Filter.all && _section == _Section.bag) {
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

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            96,
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
                      (value: _Section.stretching, label: l.libraryStretching),
                    ],
                    onChanged: (v) => setState(() {
                      _section = v;
                      _filter = _Filter.all;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.sm + 2),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l.combosSearch,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.mut,
                      ),
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
                              if (c.id != TechniqueCategory.stretching) ...[
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
                  if (combos.isEmpty)
                    EmptyState(title: l.combosEmpty, message: l.combosEmptyMsg)
                  else ...[
                    for (var i = 0; i < combos.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm + 4),
                      _ComboCard(
                        combo: combos[i],
                        stretchSection: _section == _Section.stretching,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            heroTag: null,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            tooltip: l.combosCreate,
            onPressed: () => context.go('/library/new'),
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
    TechniqueCategory.stretching => _Filter.all,
  };
}

class _ComboCard extends StatefulWidget {
  final Combination combo;
  final bool stretchSection;
  const _ComboCard({required this.combo, this.stretchSection = false});

  @override
  State<_ComboCard> createState() => _ComboCardState();
}

class _ComboCardState extends State<_ComboCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final combo = widget.combo;
    final stretchSection = widget.stretchSection;

    Future<bool> confirmDelete() async {
      final ok = await showConfirm(
        context,
        title: l.combosDeleteTitle,
        message: l.combosDeleteMsg(combo.name),
        cancelLabel: l.commonCancel,
        confirmLabel: l.commonDelete,
      );
      if (ok) {
        store.deleteCombination(combo.id);
        if (context.mounted) context.showToast(l.combosDeleted);
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
      context.push('/live', extra: LiveArgs(cfg));
    }

    final techniqueNames = [
      for (final id in combo.techniqueIds)
        store.data.techniques
                .where((t) => t.id == id)
                .firstOrNull
                ?.shortIn(lang) ??
            l.sessionUnknown,
    ];

    final stretchImages = <String>[];
    if (stretchSection) {
      for (final id in combo.techniqueIds) {
        final img = stretchImageFor(id);
        if (img != null && !stretchImages.contains(img)) stretchImages.add(img);
      }
    }

    return Dismissible(
      key: ValueKey(combo.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.accent.withAlpha(38),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withAlpha(140)),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.accent),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () => context.go('/library/${combo.id}'),
        child: ScaleTransition(
          scale: AlwaysStoppedAnimation(_down ? 0.98 : 1.0),
          child: CardWidget(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        combo.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    IconButton2(
                      combo.favorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: combo.favorite ? AppColors.warn : AppColors.mut,
                      onTap: () => store.toggleFavorite(combo.id),
                    ),
                  ],
                ),
                if (stretchImages.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final img in stretchImages) ...[
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.panel2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: SvgPicture.asset(img, width: 44, height: 44),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                    ],
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Wrap(
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
                          const Text(
                            '→',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mut,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (!stretchSection) ...[
                      Button(
                        label: l.commonStart,
                        size: BtnSize.sm,
                        icon: Icons.play_arrow_rounded,
                        onTap: quickStart,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Button(
                      label: l.commonNew,
                      icon: Icons.copy_rounded,
                      variant: BtnVariant.ghost,
                      size: BtnSize.sm,
                      onTap: () {
                        final copy = store.duplicateCombination(combo.id);
                        context.showToast(
                          copy != null
                              ? l.combosDuplicated
                              : l.comboNotFoundMsg,
                        );
                      },
                    ),
                    const Spacer(),
                    Text(
                      l.commonEdit.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.mut,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.mut,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
