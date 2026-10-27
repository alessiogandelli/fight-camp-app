import Flutter
import HealthKit
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let healthStore = HKHealthStore()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerAppearanceChannel(engineBridge)
    registerHealthChannel(engineBridge)
  }

  /// Keeps native chrome (the liquid-glass tab bar, sheets, keyboard) in sync
  /// with the in-app theme switch. Dart sends `system`, `light` or `dark`.
  private func registerAppearanceChannel(_ engineBridge: FlutterImplicitEngineBridge) {
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "FightCampAppearance")
    else { return }
    let channel = FlutterMethodChannel(
      name: "fight_camp/appearance",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setStyle" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let style: UIUserInterfaceStyle
      switch call.arguments as? String {
      case "dark": style = .dark
      case "light": style = .light
      default: style = .unspecified
      }
      for scene in UIApplication.shared.connectedScenes {
        guard let windowScene = scene as? UIWindowScene else { continue }
        for window in windowScene.windows {
          window.overrideUserInterfaceStyle = style
        }
      }
      result(nil)
    }
  }

  /// Extra read-only HealthKit data the `health` plugin does not expose:
  /// workout Effort scores and per-workout distance samples used for km splits.
  private func registerHealthChannel(_ engineBridge: FlutterImplicitEngineBridge) {
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "FightCampHealth")
    else { return }
    let channel = FlutterMethodChannel(
      name: "fight_camp/health_extra",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "unavailable", message: "Health store unavailable", details: nil))
        return
      }
      switch call.method {
      case "requestAccess":
        self.requestAccess(result: result)
      case "enrichWorkouts":
        guard let args = call.arguments as? [String: Any] else {
          result([])
          return
        }
        self.enrichWorkouts(args: args, result: result)
      case "latestRestingHeartRate":
        self.latestRestingHeartRate(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func requestAccess(result: @escaping FlutterResult) {
    guard HKHealthStore.isHealthDataAvailable() else {
      result(false)
      return
    }
    var read: Set<HKObjectType> = [HKObjectType.workoutType()]
    if let hr = HKQuantityType.quantityType(forIdentifier: .heartRate) { read.insert(hr) }
    if let distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
      read.insert(distance)
    }
    if let resting = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
      read.insert(resting)
    }
    if #available(iOS 18.0, *) {
      if let effort = HKQuantityType.quantityType(forIdentifier: .workoutEffortScore) {
        read.insert(effort)
      }
      if let estimated = HKQuantityType.quantityType(
        forIdentifier: .estimatedWorkoutEffortScore
      ) {
        read.insert(estimated)
      }
    }
    healthStore.requestAuthorization(toShare: [], read: read) { success, _ in
      DispatchQueue.main.async { result(success) }
    }
  }

  private func enrichWorkouts(args: [String: Any], result: @escaping FlutterResult) {
    guard HKHealthStore.isHealthDataAvailable() else {
      result([])
      return
    }
    let group = DispatchGroup()
    let lock = NSLock()
    var output: [[String: Any]] = []

    for (id, raw) in args {
      guard let info = raw as? [String: Any],
            let startMs = info["start"] as? NSNumber,
            let endMs = info["end"] as? NSNumber,
            let uuid = UUID(uuidString: id) else { continue }
      group.enter()
      fetchWorkout(uuid: uuid, start: startMs.doubleValue / 1000, end: endMs.doubleValue / 1000) {
        workout in
        guard let workout else {
          group.leave()
          return
        }
        self.enrich(workout: workout) { effort, distance in
          var item: [String: Any] = ["id": id, "distance": distance]
          if let effort { item["effort"] = effort }
          lock.lock()
          output.append(item)
          lock.unlock()
          group.leave()
        }
      }
    }

    group.notify(queue: .main) { result(output) }
  }

  private func fetchWorkout(
    uuid: UUID,
    start: Double,
    end: Double,
    completion: @escaping (HKWorkout?) -> Void
  ) {
    let predicate = HKQuery.predicateForObject(with: uuid)
    let query = HKSampleQuery(
      sampleType: HKObjectType.workoutType(),
      predicate: predicate,
      limit: 1,
      sortDescriptors: nil
    ) { _, samples, _ in
      if let workout = samples?.first as? HKWorkout {
        completion(workout)
        return
      }
      // Fallback for HealthKit builds that don't match UUID predicates on workouts.
      let range = HKQuery.predicateForSamples(
        withStart: Date(timeIntervalSince1970: start),
        end: Date(timeIntervalSince1970: end),
        options: [.strictStartDate]
      )
      let fallback = HKSampleQuery(
        sampleType: HKObjectType.workoutType(),
        predicate: range,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: nil
      ) { _, samples, _ in
        let match = (samples as? [HKWorkout])?.first { $0.uuid == uuid }
        completion(match)
      }
      self.healthStore.execute(fallback)
    }
    healthStore.execute(query)
  }

  private func enrich(
    workout: HKWorkout,
    completion: @escaping (Int?, [[String: Any]]) -> Void
  ) {
    effortScore(workout: workout) { effort in
      self.distanceSamples(workout: workout) { samples in
        completion(effort, samples)
      }
    }
  }

  private func effortScore(
    workout: HKWorkout,
    completion: @escaping (Int?) -> Void
  ) {
    guard #available(iOS 18.0, *) else {
      completion(nil)
      return
    }
    let userType = HKQuantityType.quantityType(forIdentifier: .workoutEffortScore)
    let estimatedType = HKQuantityType.quantityType(
      forIdentifier: .estimatedWorkoutEffortScore
    )
    queryEffort(type: userType, workout: workout) { value in
      if let value {
        completion(value)
        return
      }
      self.queryEffort(type: estimatedType, workout: workout, completion: completion)
    }
  }

  @available(iOS 18.0, *)
  private func queryEffort(
    type: HKQuantityType?,
    workout: HKWorkout,
    completion: @escaping (Int?) -> Void
  ) {
    guard let type else {
      completion(nil)
      return
    }
    let predicate = HKQuery.predicateForWorkoutEffortSamplesRelated(
      workout: workout,
      activity: nil
    )
    let query = HKSampleQuery(
      sampleType: type,
      predicate: predicate,
      limit: 1,
      sortDescriptors: [
        NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
      ]
    ) { _, samples, _ in
      guard let sample = samples?.first as? HKQuantitySample else {
        completion(nil)
        return
      }
      let raw = sample.quantity.doubleValue(for: HKUnit.appleEffortScore())
      let value = Int(raw.rounded())
      completion(value > 0 ? min(value, 10) : nil)
    }
    healthStore.execute(query)
  }

  private func distanceSamples(
    workout: HKWorkout,
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    guard let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
      completion([])
      return
    }
    let associated = HKQuery.predicateForObjects(from: workout)
    queryDistance(type: type, predicate: associated, workout: workout) { samples in
      if !samples.isEmpty {
        completion(samples)
        return
      }
      let range = HKQuery.predicateForSamples(
        withStart: workout.startDate,
        end: workout.endDate,
        options: [.strictStartDate]
      )
      self.queryDistance(type: type, predicate: range, workout: workout, completion: completion)
    }
  }

  private func queryDistance(
    type: HKQuantityType,
    predicate: NSPredicate,
    workout: HKWorkout,
    completion: @escaping ([[String: Any]]) -> Void
  ) {
    let query = HKSampleQuery(
      sampleType: type,
      predicate: predicate,
      limit: HKObjectQueryNoLimit,
      sortDescriptors: [
        NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
      ]
    ) { _, samples, _ in
      let workoutStart = workout.startDate.timeIntervalSince1970 * 1000
      let workoutEnd = workout.endDate.timeIntervalSince1970 * 1000
      var out: [[String: Any]] = []
      for sample in (samples as? [HKQuantitySample]) ?? [] {
        let start = sample.startDate.timeIntervalSince1970 * 1000
        let end = sample.endDate.timeIntervalSince1970 * 1000
        guard end > start, end >= workoutStart, start <= workoutEnd else { continue }
        let meters = sample.quantity.doubleValue(for: .meter())
        guard meters > 0 else { continue }
        out.append([
          "start": max(start, workoutStart),
          "end": min(end, workoutEnd),
          "meters": meters,
        ])
      }
      completion(out)
    }
    healthStore.execute(query)
  }

  private func latestRestingHeartRate(result: @escaping FlutterResult) {
    guard HKHealthStore.isHealthDataAvailable(),
          let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
      result(nil)
      return
    }
    let query = HKSampleQuery(
      sampleType: type,
      predicate: nil,
      limit: 1,
      sortDescriptors: [
        NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
      ]
    ) { _, samples, _ in
      guard let sample = samples?.first as? HKQuantitySample else {
        DispatchQueue.main.async { result(nil) }
        return
      }
      let bpm = sample.quantity.doubleValue(
        for: HKUnit.count().unitDivided(by: HKUnit.minute())
      )
      DispatchQueue.main.async { result(bpm > 0 ? Int(bpm.rounded()) : nil) }
    }
    healthStore.execute(query)
  }
}
