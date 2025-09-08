import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale("ar");

  Locale get locale => _locale;

  LocaleProvider() {
    loadLocale();
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  void loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? "ar";
    _locale = Locale(code);
    notifyListeners();
  }
}
