import 'package:run4share/app/system.dart';

class FakeSystemActions implements SystemActions {
  FakeSystemActions({this.hasAppLanguageScreen = true});

  /// Android 13+ / iOS: true. Android 12 and older: false.
  bool hasAppLanguageScreen;
  int languageScreens = 0;
  final links = <Uri>[];
  int reviews = 0;
  int storeListings = 0;

  @override
  Future<bool> openAppLanguage() async {
    if (hasAppLanguageScreen) languageScreens++;
    return hasAppLanguageScreen;
  }

  @override
  Future<void> openLink(Uri uri) async => links.add(uri);

  final pages = <Uri>[];

  @override
  Future<void> openPage(Uri uri) async => pages.add(uri);

  @override
  Future<void> requestReview() async => reviews++;

  @override
  Future<void> openStoreListing() async => storeListings++;
}
