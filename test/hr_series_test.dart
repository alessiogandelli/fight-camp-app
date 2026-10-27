import 'package:fight_camp/health/health_source.dart';
import 'package:fight_camp/health/hr_series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('downsampleHr averages ten-second buckets', () {
    final out = downsampleHr(const [
      HeartSample(0, 100),
      HeartSample(4000, 110),
      HeartSample(9000, 120),
      HeartSample(11000, 130),
      HeartSample(19000, 150),
    ]);
    expect(out, hasLength(2));
    expect(out[0].ms, 0);
    expect(out[0].bpm, 110); // (100 + 110 + 120) / 3
    expect(out[1].ms, 11000);
    expect(out[1].bpm, 140); // (130 + 150) / 2
  });

  test('memory store round-trips and prunes', () async {
    final store = MemoryHrSeriesStore();
    await store.write('a', const [HeartSample(0, 100)]);
    await store.write('b', const [HeartSample(0, 120)]);
    await store.writeDistance('a', const [DistanceSample(0, 1000, 500)]);
    expect((await store.read('a')).single.bpm, 100);
    expect((await store.readDistance('a')).single.meters, 500);
    await store.prune({'a'});
    expect(await store.read('b'), isEmpty);
    expect(await store.readDistance('a'), hasLength(1));
  });
}
