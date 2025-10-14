import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Charger le fichier JSON correspondant à la langue
  Future<bool> load() async {
    final String jsonString = await rootBundle.loadString(
      'assets/lang/${locale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? '** $key not found';
  }

  // --- Getters pratiques ---
  String get settings => translate('settings');
  String get profile => translate('profile');
  String get editProfile => translate('editProfile');
  String get notifications => translate('notifications');
  String get enableNotifications => translate('enableNotifications');
  String get appearance => translate('appearance');
  String get darkMode => translate('darkMode');
  String get textSize => translate('textSize');
  String get language => translate('language');
  String get security => translate('security');
  String get changePassword => translate('changePassword');
  String get about => translate('about');
  String get version => translate('version');
  String get helpSupport => translate('helpSupport');
  String get name => translate('name');
  String get email => translate('email');
  String get photo => translate('photo');
  String get recipes => translate('recipes');
  String get favorites => translate('favorites');
  String get settingsMenu => translate('settingsMenu');
  String get countries => translate('countries');
  String get all => translate('all');
  String get viewDetails => translate('viewDetails');
  String get filter => translate('filter');
  String get searchRecipe => translate('searchRecipe');
  String get welcome => translate('welcome');
  String get createAccount => translate('createAccount');
  String get signIn => translate('signIn');
  String get changeAccount => translate('changeAccount');
  String get or => translate('or');
  String get signInWithApple => translate('signInWithApple');
  String get signInWithGoogle => translate('signInWithGoogle');
  String get signInWithFacebook => translate('signInWithFacebook');
  String get faceIDLogin => translate('faceIDLogin');
  String get agreeTermsPart1 => translate('agreeTermsPart1');
  String get terms => translate('terms');
  String get agreeTermsPart2 => translate('agreeTermsPart2');
  String get privacyPolicy => translate('privacyPolicy');
  String get noAccount => translate('noAccount');
  String get chooseAccount => translate('chooseAccount');
  String get addAccount => translate('addAccount');

  // --- Clés supplémentaires pour SettingsScreen ---
  String get logout => translate('logout');
  String get shareApp => translate('shareApp');
  String get clearCache => translate('clearCache');
  String get filterByCountry => translate('filterByCountry');
  String get world => translate('world');
  String get country => translate('country');

  // --- Gamification ---
  String get gamificationTitle => translate('gamification_title');
  String get gamificationSubtitle => translate('gamification_subtitle');
  String get recipeExplorerTitle => translate('recipe_explorer_title');
  String get recipeExplorerDesc => translate('recipe_explorer_desc');
  String get pointsBadgesTitle => translate('points_badges_title');
  String get pointsBadgesDesc => translate('points_badges_desc');
  String get leaderboardTitle => translate('leaderboard_title');
  String get leaderboardDesc => translate('leaderboard_desc');
  String get dailyChallengesTitle => translate('daily_challenges_title');
  String get dailyChallengesDesc => translate('daily_challenges_desc');
  String get photoSharingTitle => translate('photo_sharing_title');
  String get photoSharingDesc => translate('photo_sharing_desc');
  String get mealStreaksTitle => translate('meal_streaks_title');
  String get mealStreaksDesc => translate('meal_streaks_desc');
  String get getStarted => translate('get_started');
  String get swipeToExplore => translate('swipe_to_explore');
  String get learnMore => translate('learn_more');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
