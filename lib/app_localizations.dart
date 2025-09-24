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

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Charger le fichier JSON correspondant à la langue
  Future<bool> load() async {
    final String jsonString =
    await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? '** $key not found';
  }

  // Getters pratiques
  String get settings => translate('settings');
  String get profile => translate('profile');
  String get editProfile => translate('editProfile');
  String get notifications => translate('notifications');
  String get enableNotifications => translate('enableNotifications');
  String get appearance => translate('appearance');
  String get darkMode => translate('dark_mode');
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


  String get filterByCountry => translate('filterByCountry');
  String get world => translate('world');
  String get country => translate('country');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}