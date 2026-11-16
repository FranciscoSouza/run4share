import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_shell.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/activities/activity_form_screen.dart';
import 'package:run4share/features/create/crop_screen.dart';
import 'package:run4share/features/creations/creation_detail_screen.dart';
import 'package:run4share/features/creations/creations_screen.dart';
import 'package:run4share/features/editor/editor_screen.dart';
import 'package:run4share/features/home/home_screen.dart';
import 'package:run4share/features/invite/invite_screen.dart';
import 'package:run4share/features/onboarding/onboarding.dart';
import 'package:run4share/features/onboarding/onboarding_screen.dart';
import 'package:run4share/features/photos/photo_step_screen.dart';
import 'package:run4share/features/pro/pro_screen.dart';
import 'package:run4share/features/settings/settings_screen.dart';
import 'package:run4share/features/share/saved_screen.dart';
import 'package:run4share/features/share/share_screen.dart';
import 'package:run4share/features/strava/connect_strava_screen.dart';
import 'package:run4share/features/templates/template_activity_screen.dart';
import 'package:run4share/features/templates/template_preview_screen.dart';
import 'package:run4share/features/templates/templates_screen.dart';

/// Route paths, so screens never spell them out.
abstract final class AppRoutes {
  static const activities = '/activities';
  static const creations = '/creations';
  static const settings = '/settings';
  static const connectStrava = '/connect/strava';
  static const newActivity = '/activity/new';
  static String editActivity(int id) => '/activity/$id/edit';
  static String choosePhoto(int activityId) => '/create/$activityId/photo';
  static String crop(int activityId, String photoId) =>
      '/create/$activityId/photo/${Uri.encodeComponent(photoId)}';
  static const editor = '/create/editor';
  static const share = '/create/share';
  static String saved(int creationId) => '/saved/$creationId';
  static String creation(int id) => '/creation/$id';
  static const invite = '/invite';
  static const pro = '/pro';
  static String template(String id) => '/template/$id';

  /// Every template (Home's See all).
  static const templates = '/templates';
  static String templateActivity(String id) => '/template/$id/activity';

  /// The introduction; extra `true` replays it from Settings.
  static const onboarding = '/welcome';
}

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Two tabs (Activities, My Creations) in a shell, and Settings above it.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootKey,
    // Read once: watching would rebuild the router when it completes.
    initialLocation: ref.read(onboardingDoneProvider)
        ? AppRoutes.activities
        : AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.templates,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const TemplatesScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            OnboardingScreen(replay: state.extra == true),
      ),
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
        path: AppRoutes.newActivity,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ActivityFormScreen(),
      ),
      GoRoute(
        path: '/activity/:id/edit',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => ActivityFormScreen(
          activityId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.editor,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const EditorScreen(),
      ),
      GoRoute(
        path: AppRoutes.pro,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ProScreen(),
      ),
      GoRoute(
        path: AppRoutes.invite,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const InviteScreen(),
      ),
      GoRoute(
        path: AppRoutes.share,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ShareScreen(),
      ),
      GoRoute(
        path: '/saved/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => SavedScreen(
          creationId: int.tryParse(state.pathParameters['id']!) ?? 0,
        ),
      ),
      GoRoute(
        path: '/creation/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => CreationDetailScreen(
          creationId: int.tryParse(state.pathParameters['id']!) ?? 0,
        ),
      ),
      GoRoute(
        path: '/template/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            TemplatePreviewScreen(templateId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'activity',
            parentNavigatorKey: _rootKey,
            builder: (context, state) => TemplateActivityScreen(
              templateId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/create/:activityId/photo',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => PhotoStepScreen(
          activityId: int.tryParse(state.pathParameters['activityId']!) ?? 0,
        ),
        routes: [
          GoRoute(
            path: ':photoId',
            parentNavigatorKey: _rootKey,
            builder: (context, state) => CropScreen(
              activityId:
                  int.tryParse(state.pathParameters['activityId']!) ?? 0,
              photoId: state.pathParameters['photoId']!,
            ),
          ),
        ],
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
