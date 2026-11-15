import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current time; overridden in tests.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);
