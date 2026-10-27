// Optional search/source filters, opened from the Progress header.
import 'package:flutter/material.dart';

import '../lib/progress_stats.dart';
import '../l10n/app_localizations.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

typedef ProgressFilters = ({String query, TrainingSourceFilter source});

Future<ProgressFilters?> showProgressFilters(
  BuildContext context, {
  required String query,
  required TrainingSourceFilter source,
}) async {
  final controller = TextEditingController(text: query);
  var selectedSource = source;
  final l = AppLocalizations.of(context)!;

  final result = await showAppModal<ProgressFilters>(
    context,
    title: l.progressFilters,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Field(
            label: l.historySearch,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: l.historySearch),
            ),
          ),
          const SizedBox(height: 14),
          Text(l.progressAllSources.toUpperCase(), style: AppText.micro),
          const SizedBox(height: 7),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final option in TrainingSourceFilter.values)
                ChipWidget(
                  label: switch (option) {
                    TrainingSourceFilter.all => l.progressAllSources,
                    TrainingSourceFilter.app => l.progressSourceApp,
                    TrainingSourceFilter.health => l.progressSourceHealth,
                  },
                  active: selectedSource == option,
                  onTap: () => setState(() => selectedSource = option),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Button(
                  label: l.progressResetFilters,
                  variant: BtnVariant.ghost,
                  onTap: () => setState(() {
                    controller.clear();
                    selectedSource = TrainingSourceFilter.all;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Button(
                  label: l.commonSave,
                  onTap: () => Navigator.pop<ProgressFilters>(context, (
                    query: controller.text,
                    source: selectedSource,
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return result;
}
