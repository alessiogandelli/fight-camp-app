// Design system ported from src/components/ui.tsx and Icons.tsx.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../lib/haptics.dart';
import 'theme.dart';

String cx(List<String?> parts) =>
    parts.whereType<String>().where((s) => s.isNotEmpty).join(' ');

// ---------- Buttons ----------

enum BtnVariant { primary, ghost, danger, outline, dark }

enum BtnSize { sm, md, lg, xl }

class Button extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnVariant variant;
  final BtnSize size;
  final IconData? icon;
  final bool expanded;
  const Button({
    super.key,
    required this.label,
    this.onTap,
    this.variant = BtnVariant.primary,
    this.size = BtnSize.md,
    this.icon,
    this.expanded = false,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _down = false;

  Color _bg(BtnVariant v) {
    switch (v) {
      case BtnVariant.primary:
        return AppColors.accent;
      case BtnVariant.ghost:
        return AppColors.panel2;
      case BtnVariant.danger:
      case BtnVariant.outline:
        return Colors.transparent;
      case BtnVariant.dark:
        return Colors.black26;
    }
  }

  Color _fg(BtnVariant v) {
    switch (v) {
      case BtnVariant.primary:
        return Colors.white;
      case BtnVariant.danger:
        return AppColors.accent;
      default:
        return AppColors.ink;
    }
  }

  double get _height {
    switch (widget.size) {
      case BtnSize.sm:
        return 36;
      case BtnSize.md:
        return 44;
      case BtnSize.lg:
        return 56;
      case BtnSize.xl:
        return 64;
    }
  }

  double get _font {
    switch (widget.size) {
      case BtnSize.sm:
        return 11;
      case BtnSize.md:
        return 12.5;
      case BtnSize.lg:
        return 14;
      case BtnSize.xl:
        return 17;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap == null
          ? null
          : () {
              Haptics.light();
              widget.onTap!();
            },
      child: ScaleTransition(
        scale: AlwaysStoppedAnimation(_down ? 0.96 : 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: _height,
          padding: EdgeInsets.symmetric(
            horizontal: widget.size == BtnSize.sm ? 12 : 18,
          ),
          decoration: BoxDecoration(
            color: enabled
                ? _bg(widget.variant)
                : _bg(widget.variant).withAlpha(90),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.variant == BtnVariant.danger
                  ? AppColors.accent
                  : (widget.variant == BtnVariant.primary
                        ? Colors.transparent
                        : AppColors.line),
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: _font + 6, color: _fg(widget.variant)),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    color: enabled
                        ? _fg(widget.variant)
                        : _fg(widget.variant).withAlpha(120),
                    fontWeight: FontWeight.w800,
                    fontSize: _font,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconButton2 extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final double size;
  const IconButton2(
    this.icon, {
    super.key,
    this.onTap,
    this.color = AppColors.mut,
    this.size = 20,
  });

  @override
  State<IconButton2> createState() => _IconButton2State();
}

class _IconButton2State extends State<IconButton2> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap == null
          ? null
          : () {
              Haptics.selection();
              widget.onTap!();
            },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Opacity(
          opacity: widget.onTap == null ? 0.4 : (_down ? 0.7 : 1),
          child: Icon(widget.icon, size: widget.size, color: widget.color),
        ),
      ),
    );
  }
}

// ---------- Cards / titles ----------

class CardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  const CardWidget({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.mut,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    ),
  );
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
  });

  @override
  Widget build(BuildContext context) => CardWidget(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.mut,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        if (sub != null)
          Text(
            sub!,
            style: const TextStyle(fontSize: 10.5, color: AppColors.mut),
          ),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.line, style: BorderStyle.solid),
      color: AppColors.bg.withAlpha(60),
    ),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.mut, fontSize: 13),
        ),
        if (action != null) ...[const SizedBox(height: 14), action!],
      ],
    ),
  );
}

// ---------- Modal / confirm ----------

Future<T?> showAppModal<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  bool scrollable = true,
}) {
  final wide = MediaQuery.of(context).size.width >= 640;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.88,
        ),
        margin: wide
            ? const EdgeInsets.symmetric(vertical: 40, horizontal: 100)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.vertical(
            top: wide ? const Radius.circular(24) : Radius.zero,
            bottom: wide ? const Radius.circular(24) : Radius.zero,
          ),
          border: Border(
            top: BorderSide(color: wide ? AppColors.line : AppColors.line),
            left: wide
                ? const BorderSide(color: AppColors.line)
                : BorderSide.none,
            right: wide
                ? const BorderSide(color: AppColors.line)
                : BorderSide.none,
            bottom: wide
                ? const BorderSide(color: AppColors.line)
                : BorderSide.none,
          ),
        ),
        child: Builder(
          builder: (ctx) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      IconButton2(
                        Icons.close,
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: scrollable
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                          child: Builder(builder: builder),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                          child: Builder(builder: builder),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

Future<bool> showConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
          child: Text(confirmLabel.toUpperCase()),
        ),
      ],
    ),
  );
  return res ?? false;
}

// ---------- Form primitives ----------

class Field extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;
  const Field({super.key, required this.label, this.hint, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.mut,
        ),
      ),
      const SizedBox(height: 6),
      child,
      if (hint != null) ...[
        const SizedBox(height: 5),
        Text(hint!, style: const TextStyle(fontSize: 11, color: AppColors.mut)),
      ],
    ],
  );
}

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final int maxLines;
  final bool uppercase;
  final ValueChanged<String>? onChanged;
  const TextInput({
    super.key,
    this.controller,
    this.hint,
    this.maxLines = 1,
    this.uppercase = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    onChanged: onChanged,
    inputFormatters: uppercase
        ? [
            TextInputFormatter.withFunction(
              (oldValue, newValue) =>
                  newValue.copyWith(text: newValue.text.toUpperCase()),
            ),
          ]
        : null,
    style: const TextStyle(fontSize: 14.5),
    decoration: InputDecoration(hintText: hint),
  );
}

class Select<T> extends StatelessWidget {
  final T value;
  final List<({T value, String label})> options;
  final ValueChanged<T> onChanged;
  const Select({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.panel2,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.line),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        dropdownColor: AppColors.panel2,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.mut),
        style: const TextStyle(color: AppColors.ink, fontSize: 14),
        items: [
          for (final o in options)
            DropdownMenuItem(value: o.value, child: Text(o.label)),
        ],
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    ),
  );
}

class Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const Toggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Haptics.selection();
      onChanged(!value);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? AppColors.accent : AppColors.line,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Align(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}

class ChipWidget extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const ChipWidget({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Haptics.selection();
      onTap();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.accent.withAlpha(38) : AppColors.panel2,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: active ? AppColors.accent.withAlpha(140) : AppColors.line,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? AppColors.accent : AppColors.mut,
        ),
      ),
    ),
  );
}

class Segmented<T> extends StatelessWidget {
  final List<({T value, String label})> options;
  final T value;
  final ValueChanged<T> onChanged;
  const Segmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.line),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final o in options)
          Flexible(
            flex: o.label.length.clamp(2, 6),
            child: GestureDetector(
              onTap: () {
                Haptics.selection();
                onChanged(o.value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: value == o.value
                      ? AppColors.accent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  o.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: value == o.value ? Colors.white : AppColors.mut,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class NumStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;
  final String? suffix;
  const NumStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    void change(int delta) {
      var v = value + delta;
      if (v < min) v = min;
      if (v > max) v = max;
      onChanged(v);
      Haptics.selection();
    }

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.panel2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          IconButton2(
            Icons.remove,
            onTap: value > min ? () => change(-step) : null,
            size: 16,
          ),
          Expanded(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$value',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (suffix != null)
                      TextSpan(
                        text: ' ${suffix}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mut,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          IconButton2(
            Icons.add,
            onTap: value < max ? () => change(step) : null,
            size: 16,
          ),
        ],
      ),
    );
  }
}

/// TimeField — minus/plus buttons around an editable MM:SS input.
class TimeField extends StatefulWidget {
  final int value; // seconds
  final int min;
  final int max;
  final int step;
  final ValueChanged<int>? onChanged;
  const TimeField({
    super.key,
    required this.value,
    this.min = 5,
    this.max = 7200,
    this.step = 15,
    required this.onChanged,
  });

  @override
  State<TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  late final controller = TextEditingController(text: _fmt());
  bool _editing = false;

  String _fmt() {
    final s = widget.value;
    final m = s ~/ 60;
    final sec = s % 60;
    return '$m:${sec.toString().padLeft(2, '0')}';
  }

  void _bump(int delta) {
    final cb = widget.onChanged;
    if (cb == null) return;
    var v = widget.value + delta;
    if (v < widget.min) v = widget.min;
    if (v > widget.max) v = widget.max;
    cb(v);
  }

  void _commit(String raw) {
    _editing = false;
    final parsed = _parse(raw);
    final cb = widget.onChanged;
    if (parsed != null &&
        parsed >= widget.min &&
        parsed <= widget.max &&
        cb != null) {
      cb(parsed);
      controller.text = _fmtOf(parsed);
    } else {
      controller.text = _fmt();
    }
  }

  String _fmtOf(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  int? _parse(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    if (RegExp(r'^\d+$').hasMatch(s)) return int.tryParse(s);
    final parts = s.split(':');
    if (parts.isEmpty || parts.length > 2) return null;
    if (!parts.every((p) => RegExp(r'^\d{1,2}$').hasMatch(p))) return null;
    final nums = parts.map(int.parse).toList();
    return nums[0] * 60 + nums[1];
  }

  @override
  void didUpdateWidget(TimeField old) {
    super.didUpdateWidget(old);
    if (!_editing && widget.value != old.value) controller.text = _fmt();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.panel2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          IconButton2(Icons.remove, onTap: () => _bump(-widget.step), size: 16),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.datetime,
              textAlign: TextAlign.center,
              onTap: () => _editing = true,
              onSubmitted: _commit,
              onEditingComplete: () => _commit(controller.text),
              focusNode: FocusNode(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.escape) {
                    node.unfocus();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton2(Icons.add, onTap: () => _bump(widget.step), size: 16),
        ],
      ),
    );
  }
}
