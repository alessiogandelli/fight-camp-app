// Heart-rate series live on disk, not in SharedPreferences: one workout can
// have a few thousand samples, and the JSON blob that holds all app data would
// grow to megabytes and be rewritten on every change.
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'health_source.dart';

/// Samples are averaged into 10-second buckets before being stored: enough
/// resolution for a workout chart, ~10x smaller than the raw stream.
const hrBucketMs = 10 * 1000;

abstract class HrSeriesStore {
  Future<void> write(String externalId, List<HeartSample> samples);
  Future<List<HeartSample>> read(String externalId);

  /// Distance intervals associated with the same workout. Stored next to the
  /// HR series so splits can be computed without keeping raw GPS routes.
  Future<void> writeDistance(String externalId, List<DistanceSample> samples);
  Future<List<DistanceSample>> readDistance(String externalId);

  /// Deletes series for workouts no longer referenced by a Health link.
  Future<void> prune(Set<String> keep);
}

class FileHrSeriesStore implements HrSeriesStore {
  final Directory? _dir;
  FileHrSeriesStore({Directory? dir}) : _dir = dir;

  Future<Directory> _root() async {
    final base = _dir ?? await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/health');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _file(String externalId) async {
    final root = await _root();
    return File('${root.path}/${_safe(externalId)}.json');
  }

  Future<File> _distanceFile(String externalId) async {
    final root = await _root();
    return File('${root.path}/${_safe(externalId)}.distance.json');
  }

  String _safe(String id) => id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  @override
  Future<void> write(String externalId, List<HeartSample> samples) async {
    final bucketed = downsampleHr(samples);
    if (bucketed.isEmpty) return;
    final file = await _file(externalId);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(
      jsonEncode([
        for (final s in bucketed) [s.ms, s.bpm],
      ]),
      flush: true,
    );
    await tmp.rename(file.path);
  }

  @override
  Future<List<HeartSample>> read(String externalId) async {
    try {
      final file = await _file(externalId);
      if (!await file.exists()) return const [];
      final parsed = jsonDecode(await file.readAsString());
      if (parsed is! List) return const [];
      return [
        for (final e in parsed)
          if (e is List && e.length >= 2)
            HeartSample((e[0] as num).toInt(), (e[1] as num).toInt()),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> writeDistance(
    String externalId,
    List<DistanceSample> samples,
  ) async {
    if (samples.isEmpty) return;
    final file = await _distanceFile(externalId);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(
      jsonEncode([
        for (final s in samples) [s.start, s.end, s.meters],
      ]),
      flush: true,
    );
    await tmp.rename(file.path);
  }

  @override
  Future<List<DistanceSample>> readDistance(String externalId) async {
    try {
      final file = await _distanceFile(externalId);
      if (!await file.exists()) return const [];
      final parsed = jsonDecode(await file.readAsString());
      if (parsed is! List) return const [];
      return [
        for (final e in parsed)
          if (e is List && e.length >= 3)
            DistanceSample(
              (e[0] as num).toInt(),
              (e[1] as num).toInt(),
              (e[2] as num).toDouble(),
            ),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> prune(Set<String> keep) async {
    try {
      final root = await _root();
      final keepNames = {
        for (final id in keep) ...[
          '${_safe(id)}.json',
          '${_safe(id)}.distance.json',
        ],
      };
      await for (final entity in root.list()) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (!name.endsWith('.json')) continue;
        if (!keepNames.contains(name)) await entity.delete();
      }
    } catch (_) {
      // A missing or locked directory is not worth failing a sync over.
    }
  }
}

/// Averages samples into [hrBucketMs] buckets, keeping the first timestamp of
/// each bucket.
List<HeartSample> downsampleHr(List<HeartSample> samples) {
  if (samples.isEmpty) return const [];
  final sorted = [...samples]..sort((a, b) => a.ms.compareTo(b.ms));
  final out = <HeartSample>[];
  var bucketStart = sorted.first.ms;
  var sum = 0;
  var count = 0;
  for (final s in sorted) {
    if (s.ms - bucketStart >= hrBucketMs) {
      if (count > 0) out.add(HeartSample(bucketStart, (sum / count).round()));
      bucketStart = s.ms;
      sum = 0;
      count = 0;
    }
    sum += s.bpm;
    count++;
  }
  if (count > 0) out.add(HeartSample(bucketStart, (sum / count).round()));
  return out;
}

/// In-memory store for tests.
class MemoryHrSeriesStore implements HrSeriesStore {
  final Map<String, List<HeartSample>> series = {};
  final Map<String, List<DistanceSample>> distanceSeries = {};

  @override
  Future<void> write(String externalId, List<HeartSample> samples) async {
    series[externalId] = downsampleHr(samples);
  }

  @override
  Future<List<HeartSample>> read(String externalId) async =>
      series[externalId] ?? const [];

  @override
  Future<void> writeDistance(
    String externalId,
    List<DistanceSample> samples,
  ) async {
    distanceSeries[externalId] = [...samples];
  }

  @override
  Future<List<DistanceSample>> readDistance(String externalId) async =>
      distanceSeries[externalId] ?? const [];

  @override
  Future<void> prune(Set<String> keep) async {
    series.removeWhere((id, _) => !keep.contains(id));
    distanceSeries.removeWhere((id, _) => !keep.contains(id));
  }
}
