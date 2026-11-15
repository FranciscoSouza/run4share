/// Links the app opens or shares. Kept here so they change in one place.
abstract final class AppLinks {
  /// Store page; shows "not found" until the app is published.
  static final Uri playStore = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.run4share.app',
  );

  /// Draft privacy policy in the repository (docs/privacy-policy.md).
  /// Replace with the hosted page once there is one.
  static final Uri privacyPolicy = Uri.parse(
    'https://github.com/FranciscoSouza/run4share/blob/main/docs/privacy-policy.md',
  );

  /// "Send feedback instead": a new GitHub issue, pre-titled.
  static Uri feedback({required String version}) => Uri.https(
        'github.com',
        '/FranciscoSouza/run4share/issues/new',
        {'title': 'Feedback', 'body': '\n\n---\nrun4share $version'},
      );
}
