import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The phone's operating system; overridden in tests.
final platformProvider = Provider<TargetPlatform>(
  (ref) => defaultTargetPlatform,
);

/// The platform's own health source: Apple Health on iPhone, Health
/// Connect on Android. Each only exists on its own platform.
enum HealthSource { appleHealth, healthConnect }

HealthSource? healthSourceFor(TargetPlatform platform) => switch (platform) {
      TargetPlatform.iOS => HealthSource.appleHealth,
      TargetPlatform.android => HealthSource.healthConnect,
      _ => null,
    };
