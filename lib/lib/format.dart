// Utilities ported from src/lib/format.ts and src/lib/id.ts.
import '../models/types.dart';

String pad2(int n) => n.toString().padLeft(2, '0');

String fmtClock(num totalSec) {
  final s = totalSec < 0 ? 0 : totalSec.round();
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  if (h > 0) return '$h:${pad2(m)}:${pad2(sec)}';
  return '${pad2(m)}:${pad2(sec)}';
}

String fmtMinutes(num totalSec) {
  final m = (totalSec / 60).round();
  if (m < 60) return '$m min';
  final h = m ~/ 60;
  return '$h h ${pad2(m % 60)}m';
}

int? parseTimeInput(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  if (RegExp(r'^\d+$').hasMatch(s)) {
    return int.tryParse(s);
  }
  final parts = s.split(':');
  if (parts.length < 2 || parts.length > 3) return null;
  if (!parts.every((p) => RegExp(r'^\d{1,2}$').hasMatch(p))) return null;
  final nums = parts.map(int.parse).toList();
  if (parts.length == 2) return nums[0] * 60 + nums[1];
  return nums[0] * 3600 + nums[1] * 60 + nums[2];
}

String dateKey(DateTime d) => '${d.year}-${pad2(d.month)}-${pad2(d.day)}';

String dayLabel(int ts, Lang lang) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime.fromMillisecondsSinceEpoch(ts);
  final dayMid = DateTime(day.year, day.month, day.day);
  final diff = today.difference(dayMid).inDays;
  final locale = lang == Lang.it ? 'it-IT' : 'en-US';
  if (diff == 0) return lang == Lang.en ? 'TODAY' : 'OGGI';
  if (diff == 1) return lang == Lang.en ? 'YESTERDAY' : 'IERI';
  if (diff > 1 && diff < 7) {
    return _weekdayLong(dayMid, lang).toUpperCase();
  }
  return _shortDate(dayMid, lang, locale);
}

final _itWeekdaysLong = const [
  'lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica'
];

String _weekdayLong(DateTime d, Lang lang) {
  // Monday-based index.
  final idx = (d.weekday + 6) % 7;
  if (lang == Lang.it) return _itWeekdaysLong[idx];
  const en = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return en[idx];
}

/// Three-letter uppercase weekday for compact strips (e.g. "LUN", "MON").
String weekdayShort(DateTime d, Lang lang) =>
    _weekdayLong(d, lang).substring(0, 3).toUpperCase();

const _itMonthsShort = const [
  'gen', 'feb', 'mar', 'apr', 'mag', 'giu', 'lug', 'ago', 'set', 'ott', 'nov', 'dic'
];

String _shortDate(DateTime d, Lang lang, String locale) {
  final weekday = _weekdayLong(d, lang).substring(0, 3);
  final month = lang == Lang.it ? _itMonthsShort[d.month - 1] : _enMonthShort(d.month);
  return '$weekday $month ${d.day}';
}

String _enMonthShort(int month) {
  const en = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return en[month - 1];
}

String fmtDistance(double? km) {
  if (km == null || km.isNaN || !km.isFinite) return '';
  return '${km.toStringAsFixed(1)} km';
}

String fmtPace(int? secPerKm) {
  if (secPerKm == null || secPerKm <= 0) return '';
  final m = secPerKm ~/ 60;
  final s = secPerKm % 60;
  return '$m:${pad2(s)} /km';
}

String uid() {
  final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final rnd = DateTime.now().microsecondsSinceEpoch ^ Object().hashCode;
  return '$ts-${rnd.toRadixString(36)}${(rnd >> 8).abs().toRadixString(36)}';
}
