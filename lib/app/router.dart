import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_shell.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/creations/creations_screen.dart';
import 'package:run4share/features/home/home_screen.dart';
import 'package:run4share/features/settings/settings_screen.dart';
import 'package:run4share/features/strava/connect_strava_screen.dart';

/// Route paths, so screens never spell them out.
abstract final class AppRoutes {
  static const activities = '/activities';
  static const creations = '/creations';
  static const settings = '/settings';
  static const connectStrava = '/connect/strava';
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Two tabs (Activities, My Creations) in a shell, and Settings above it.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.activities,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.activities,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.creations,
                builder: (context, state) => const CreationsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.connectStrava,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ConnectStravaScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
