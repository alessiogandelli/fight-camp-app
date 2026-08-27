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

  void show(String msg) {
    final id = _id++;
    setState(() => _messages.add(_ToastEntry(id, msg)));
    Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() => _messages.removeWhere((m) => m.id == id));
    });
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
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final m in _messages)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.panel2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.line),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(90), blurRadius: 14)],
                        ),
                        child: Text(m.msg,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                      ),
                  ],
                ),
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
  const _ToastEntry(this.id, this.msg);
}

extension ToastX on BuildContext {
  void showToast(String msg) {
    final state = findAncestorStateOfType<ToastProviderState>();
    state?.show(msg);
  }
}
