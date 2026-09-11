// Toast provider ported from src/components/Toast.tsx.
import 'dart:async';

import 'package:flutter/material.dart';

import 'theme.dart';

class ToastProvider extends StatefulWidget {
  final Widget child;
  const ToastProvider({super.key, required this.child});

  @override
  State<ToastProvider> createState() => ToastProviderState();
}

class ToastProviderState extends State<ToastProvider> {
  final _messages = <_ToastEntry>[];
  int _id = 0;

  void show(String msg, {String? actionLabel, VoidCallback? onAction}) {
    final id = _id++;
    setState(() => _messages.add(_ToastEntry(id, msg, actionLabel, onAction)));
    Timer(Duration(milliseconds: actionLabel == null ? 2400 : 4000), () {
      if (!mounted) return;
      setState(() => _messages.removeWhere((m) => m.id == id));
    });
  }

  void _dismiss(int id) {
    setState(() => _messages.removeWhere((m) => m.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          if (_messages.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 84,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final m in _messages)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      decoration: BoxDecoration(
                        color: AppColors.panel2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(90),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              m.msg,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (m.actionLabel != null) ...[
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                _dismiss(m.id);
                                m.onAction?.call();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.accent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                m.actionLabel!,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ToastEntry {
  final int id;
  final String msg;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _ToastEntry(this.id, this.msg, this.actionLabel, this.onAction);
}

extension ToastX on BuildContext {
  void showToast(String msg, {String? actionLabel, VoidCallback? onAction}) {
    final state = findAncestorStateOfType<ToastProviderState>();
    state?.show(msg, actionLabel: actionLabel, onAction: onAction);
  }
}
